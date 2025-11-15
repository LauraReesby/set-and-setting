//  Constitutional Compliance: Privacy-First, SwiftData Native, Offline-First

import Foundation
import SwiftData
import SwiftUI

/// Service responsible for managing TherapeuticSession persistence with auto-save capabilities
/// Following constitutional principles:
/// - Privacy-First: All data remains local, no cloud sync
/// - Offline-First: Works completely without network
/// - SwiftData Native: Uses Apple's native framework for data persistence
@Observable
class SessionDataService {
    // MARK: - Properties

    /// The SwiftData model context for persistence operations
    private let modelContext: ModelContext

    /// Timer for auto-save functionality
    private var autoSaveTimer: Timer?

    /// Tracks if there are unsaved changes
    private var hasUnsavedChanges = false

    /// Auto-save interval (5 seconds as per constitutional requirements)
    private let autoSaveInterval: TimeInterval = 5.0

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.setupAutoSave()
    }

    deinit {
        autoSaveTimer?.invalidate()
    }

    // MARK: - CRUD Operations

    /// Create a new therapy session
    /// - Parameter session: The TherapeuticSession to save
    /// - Throws: Any persistence-related errors
    func createSession(_ session: TherapeuticSession) throws {
        self.modelContext.insert(session)
        self.markUnsavedChanges()
        try self.saveContext()
    }

    /// Update an existing therapy session
    /// - Parameter session: The TherapeuticSession to update
    /// - Throws: Any persistence-related errors
    func updateSession(_ session: TherapeuticSession) throws {
        session.markAsUpdated()
        self.markUnsavedChanges()
        try self.saveContext()
    }

    /// Delete a therapy session
    /// - Parameter session: The TherapeuticSession to delete
    /// - Throws: Any persistence-related errors
    func deleteSession(_ session: TherapeuticSession) throws {
        self.modelContext.delete(session)
        self.markUnsavedChanges()
        try self.saveContext()
    }

    /// Fetch all therapy sessions, sorted by date (newest first)
    /// - Returns: Array of TherapeuticSession objects
    func fetchAllSessions() throws -> [TherapeuticSession] {
        let descriptor = FetchDescriptor<TherapeuticSession>(
            sortBy: [SortDescriptor(\.sessionDate, order: .reverse)]
        )
        return try self.modelContext.fetch(descriptor)
    }

    /// Fetch sessions within a date range
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    /// - Returns: Array of TherapeuticSession objects within the date range
    func fetchSessions(from startDate: Date, to endDate: Date) throws -> [TherapeuticSession] {
        let descriptor = FetchDescriptor<TherapeuticSession>(
            predicate: #Predicate { session in
                session.sessionDate >= startDate && session.sessionDate <= endDate
            },
            sortBy: [SortDescriptor(\.sessionDate, order: .reverse)]
        )
        return try self.modelContext.fetch(descriptor)
    }

    /// Fetch sessions by treatment type
    /// - Parameter treatmentType: The treatment type to filter by
    /// - Returns: Array of TherapeuticSession objects matching the treatment type
    func fetchSessions(treatmentType: PsychedelicTreatmentType) throws -> [TherapeuticSession] {
        let treatmentTypeString = treatmentType.rawValue
        let descriptor = FetchDescriptor<TherapeuticSession>(
            predicate: #Predicate { session in
                session.treatmentTypeRawValue == treatmentTypeString
            },
            sortBy: [SortDescriptor(\.sessionDate, order: .reverse)]
        )
        return try self.modelContext.fetch(descriptor)
    }

    // MARK: - Auto-Save Implementation

    /// Set up automatic saving to prevent data loss
    private func setupAutoSave() {
        self.autoSaveTimer = Timer
            .scheduledTimer(withTimeInterval: self.autoSaveInterval, repeats: true) { [weak self] _ in
                self?.performAutoSave()
            }
    }

    /// Perform auto-save if there are unsaved changes
    private func performAutoSave() {
        guard self.hasUnsavedChanges else { return }

        do {
            try self.saveContext()
            self.hasUnsavedChanges = false
        } catch {
            // Log error but don't crash - auto-save should be resilient
            print("Auto-save failed: \(error.localizedDescription)")
        }
    }

    /// Force save immediately (for manual save operations)
    func forceSave() throws {
        try self.saveContext()
        self.hasUnsavedChanges = false
    }

    /// Mark that there are unsaved changes
    private func markUnsavedChanges() {
        self.hasUnsavedChanges = true
    }

    /// Save the model context
    /// - Throws: SwiftData persistence errors
    private func saveContext() throws {
        if self.modelContext.hasChanges {
            try self.modelContext.save()
        }
    }

    // MARK: - Draft Recovery

    /// Save a draft session snapshot for crash recovery without inserting it into the store
    /// - Parameter session: The draft session state to persist temporarily
    func saveDraft(_ session: TherapeuticSession) {
        let draft = SessionDraft(session: session)
        do {
            let data = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(data, forKey: DraftKeys.payload)
            UserDefaults.standard.set(Date(), forKey: DraftKeys.timestamp)
        } catch {
            print("Failed to encode draft: \(error.localizedDescription)")
        }
    }

    /// Recover any existing draft session
    /// - Returns: Draft TherapeuticSession if one exists, nil otherwise
    func recoverDraft() -> TherapeuticSession? {
        guard let draftSaveTime = UserDefaults.standard.object(forKey: DraftKeys.timestamp) as? Date,
              let draftData = UserDefaults.standard.data(forKey: DraftKeys.payload)
        else {
            return nil
        }

        // Only recover drafts that are less than 24 hours old
        let hoursSinceLastSave = Date().timeIntervalSince(draftSaveTime) / 3600
        guard hoursSinceLastSave < 24 else {
            self.clearDraft()
            return nil
        }

        do {
            let draft = try JSONDecoder().decode(SessionDraft.self, from: draftData)
            return draft.makeSession()
        } catch {
            print("Failed to recover draft: \(error.localizedDescription)")
            self.clearDraft()
            return nil
        }
    }

    /// Clear the current draft
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: DraftKeys.payload)
        UserDefaults.standard.removeObject(forKey: DraftKeys.timestamp)
    }

    // MARK: - Validation

    /// Validate a session before saving
    /// - Parameter session: The session to validate
    /// - Returns: Array of validation error messages (empty if valid)
    func validateSession(_ session: TherapeuticSession) -> [String] {
        var errors: [String] = []

        // Treatment type validation is built into the enum, so we just need to validate other fields
        if session.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Intention is required")
        }

        // Check for future date
        if session.sessionDate > Date() {
            errors.append("Session date cannot be in the future")
        }

        if session.moodBefore < 1 || session.moodBefore > 10 {
            errors.append("Pre-mood scale must be between 1 and 10")
        }

        if session.moodAfter < 1 || session.moodAfter > 10 {
            errors.append("Mood after must be between 1 and 10")
        }

        return errors
    }
}

// MARK: - Draft Support

private enum DraftKeys {
    static let payload = "session_draft_payload"
    static let timestamp = "session_draft_timestamp"
}

private struct SessionDraft: Codable {
    let sessionDate: Date
    let treatmentType: String
    let dosage: String
    let administration: String
    let intention: String
    let environmentNotes: String
    let musicNotes: String
    let moodBefore: Int
    let moodAfter: Int
    let reflections: String
    let spotifyPlaylistURI: String?
    let spotifyPlaylistName: String?
    let spotifyPlaylistImageURL: String?

    init(session: TherapeuticSession) {
        self.sessionDate = session.sessionDate
        self.treatmentType = session.treatmentTypeRawValue
        self.dosage = session.dosage
        self.administration = session.administrationRawValue
        self.intention = session.intention
        self.environmentNotes = session.environmentNotes
        self.musicNotes = session.musicNotes
        self.moodBefore = session.moodBefore
        self.moodAfter = session.moodAfter
        self.reflections = session.reflections
        self.spotifyPlaylistURI = session.spotifyPlaylistURI
        self.spotifyPlaylistName = session.spotifyPlaylistName
        self.spotifyPlaylistImageURL = session.spotifyPlaylistImageURL
    }

    func makeSession() -> TherapeuticSession {
        let session = TherapeuticSession(
            sessionDate: sessionDate,
            treatmentType: PsychedelicTreatmentType(rawValue: treatmentType) ?? .psilocybin,
            dosage: dosage,
            administration: AdministrationMethod(rawValue: administration) ?? .oral,
            intention: intention,
            environmentNotes: environmentNotes,
            musicNotes: musicNotes,
            moodBefore: moodBefore,
            moodAfter: moodAfter,
            reflections: reflections
        )
        session.spotifyPlaylistURI = self.spotifyPlaylistURI
        session.spotifyPlaylistName = self.spotifyPlaylistName
        session.spotifyPlaylistImageURL = self.spotifyPlaylistImageURL
        return session
    }
}

// MARK: - Background Task Support

extension SessionDataService {
    /// Save data when app enters background
    func saveOnBackground() {
        do {
            try self.forceSave()
        } catch {
            print("Failed to save on background: \(error.localizedDescription)")
        }
    }
}
