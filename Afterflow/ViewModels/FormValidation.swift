//  Constitutional Compliance: Privacy-First, SwiftUI Native, Therapeutic Value-First

import Foundation
import SwiftData

/// Result of a field validation with therapeutic tone messaging
struct ValidationResult {
    let isValid: Bool
    let message: String?

    static let valid = ValidationResult(isValid: true, message: nil)

    static func invalid(_ message: String?) -> ValidationResult {
        ValidationResult(isValid: false, message: message)
    }
}

/// Form data structure for session creation
struct SessionFormData {
    let sessionDate: Date
    let treatmentType: PsychedelicTreatmentType
    let dosage: String
    let administration: AdministrationMethod
    let intention: String
}

/// Complete form validation result
struct FormValidationResult {
    let isValid: Bool
    let errors: [String]

    static let valid = FormValidationResult(isValid: true, errors: [])

    static func invalid(_ errors: [String]) -> FormValidationResult {
        FormValidationResult(isValid: false, errors: errors)
    }
}

/// Form validation service with therapeutic tone messaging
struct FormValidation {
    // MARK: - Date Validation Constants

    /// Reasonable range for therapeutic sessions (10 years ago to today)
    private static let earliestValidSessionDate: TimeInterval = -10 * 365 * 24 * 60 * 60 // 10 years ago

    /// Latest valid time for "today" sessions (allow up to 1 hour in future for scheduling)
    private static let futureToleranceInterval: TimeInterval = 60 * 60 // 1 hour

    // MARK: - Validation Methods

    /// Validate intention field with therapeutic messaging
    func validateIntention(_ intention: String) -> ValidationResult {
        let trimmed = intention.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return ValidationResult.invalid(nil)
        }

        return ValidationResult.valid
    }

    /// Validate session date with enhanced normalization and therapeutic messaging
    func validateSessionDate(_ date: Date) -> ValidationResult {
        let now = Date()
        let normalizedDate = self.normalizeSessionDate(date)

        // Check if date is too far in the future
        let maxFutureDate = now.addingTimeInterval(Self.futureToleranceInterval)
        if normalizedDate > maxFutureDate {
            return ValidationResult.invalid("Please choose a date from today or earlier")
        }

        // Check if date is unreasonably old for therapeutic sessions
        let earliestDate = now.addingTimeInterval(Self.earliestValidSessionDate)
        if normalizedDate < earliestDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let earliestDateString = formatter.string(from: earliestDate)
            return ValidationResult.invalid("Please choose a date after \(earliestDateString) for accurate tracking")
        }

        return ValidationResult.valid
    }

    /// Normalize session date for therapeutic context
    /// - Rounds minutes to nearest 15-minute interval
    /// - Ensures timezone consistency
    /// - Returns standardized date for storage
    func normalizeSessionDate(_ date: Date) -> Date {
        let calendar = Calendar.current

        // Get date components in current timezone
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        // Round minutes to nearest 15-minute interval (therapeutic sessions typically align to quarters)
        if let minute = components.minute {
            let roundedMinute = ((minute + 7) / 15) * 15 // Round to nearest 15
            components.minute = roundedMinute >= 60 ? 0 : roundedMinute

            // Handle hour overflow if minute was rounded to 60
            if roundedMinute >= 60, let hour = components.hour {
                components.hour = (hour + 1) % 24
            }
        }

        // Create normalized date
        let normalizedDate = calendar.date(from: components) ?? date

        return normalizedDate
    }

    /// Get user-friendly description of date normalization changes
    func getDateNormalizationMessage(originalDate: Date, normalizedDate: Date) -> String? {
        let timeDifference = abs(normalizedDate.timeIntervalSince(originalDate))

        // Only show message if there was a significant change (more than 1 minute)
        guard timeDifference > 60 else { return nil }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let normalizedTimeString = formatter.string(from: normalizedDate)
        return "Time adjusted to \(normalizedTimeString) for easier session tracking"
    }

    /// Validate dosage field (optional but with length limits)
    func validateDosage(_ dosage: String) -> ValidationResult {
        let trimmed = dosage.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty is valid (optional field)
        if trimmed.isEmpty {
            return ValidationResult.valid
        }

        // Check for extremely long entries
        if trimmed.count > 100 {
            return ValidationResult.invalid("Please keep dosage brief for easier tracking")
        }

        return ValidationResult.valid
    }

    /// Validate complete form data
    func validateForm(_ formData: SessionFormData) -> FormValidationResult {
        var errors: [String] = []
        var formIsValid = true

        // Validate intention
        let intentionResult = self.validateIntention(formData.intention)
        if !intentionResult.isValid {
            formIsValid = false
            if let message = intentionResult.message {
                errors.append(message)
            }
        }

        // Validate date
        let dateResult = self.validateSessionDate(formData.sessionDate)
        if !dateResult.isValid {
            formIsValid = false
            if let message = dateResult.message {
                errors.append(message)
            }
        }

        // Validate dosage
        let dosageResult = self.validateDosage(formData.dosage)
        if !dosageResult.isValid {
            formIsValid = false
            if let message = dosageResult.message {
                errors.append(message)
            }
        }

        return formIsValid ? FormValidationResult.valid : FormValidationResult.invalid(errors)
    }
}
