@testable import Afterflow
import SwiftData
import XCTest

@MainActor
final class NotificationHandlerTests: XCTestCase {
    func testProcessDeepLinkOpenSessionSucceeds() async throws {
        let container = try ModelContainer(
            for: TherapeuticSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let store = SessionStore(modelContext: container.mainContext, owningContainer: container)
        let session = TherapeuticSession(
            sessionDate: Date(),
            treatmentType: .psilocybin,
            administration: .oral,
            intention: "Navigate to me",
            moodBefore: 5,
            moodAfter: 5
        )
        try store.create(session)

        let handler = NotificationHandler(modelContext: container.mainContext)
        do {
            try await handler.processDeepLink(.openSession(session.id))
        } catch {
            XCTFail("Expected openSession to succeed, got \(error)")
        }
    }

    func testProcessDeepLinkOpenSessionThrowsWhenMissing() async {
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: TherapeuticSession.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            return XCTFail("Failed to create container: \(error)")
        }
        let handler = NotificationHandler(modelContext: container.mainContext)

        do {
            _ = try await handler.processDeepLink(.openSession(UUID()))
            XCTFail("Expected sessionNotFound error")
        } catch let error as NotificationHandler.NotificationError {
            switch error {
            case .sessionNotFound:
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testProcessDeepLinkAddReflectionPersistsText() async throws {
        let container = try ModelContainer(
            for: TherapeuticSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let store = SessionStore(modelContext: container.mainContext, owningContainer: container)
        let session = TherapeuticSession(
            sessionDate: Date(),
            treatmentType: .psilocybin,
            administration: .oral,
            intention: "Add reflection",
            moodBefore: 5,
            moodAfter: 6
        )
        try store.create(session)

        let handler = NotificationHandler(modelContext: container.mainContext)
        try await handler.processDeepLink(.addReflection(sessionID: session.id, text: "Noted from notification"))

        let refreshed = try container.mainContext.fetch(FetchDescriptor<TherapeuticSession>()).first
        XCTAssertEqual(refreshed?.id, session.id)
        XCTAssertTrue(refreshed?.reflections.contains("Noted from notification") ?? false)
    }
}
