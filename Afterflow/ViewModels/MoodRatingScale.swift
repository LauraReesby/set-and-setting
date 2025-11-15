//  Constitutional Compliance: Therapeutic Tone, Accessibility-First

import Foundation

/// Provides descriptive context and emoji mappings for mood ratings.
/// Keeps slider labels calm and reflective while remaining testable.
struct MoodRatingScale {
    /// Clamp incoming slider values to the 1...10 range expected by the UX.
    private static func clamped(_ value: Int) -> Int {
        max(1, min(value, 10))
    }

    /// Return a supportive descriptor for a specific mood rating.
    static func descriptor(for value: Int) -> String {
        switch self.clamped(value) {
        case 1 ... 2:
            return "Tender"
        case 3 ... 4:
            return "Reflective"
        case 5 ... 6:
            return "Centered"
        case 7 ... 8:
            return "Uplifted"
        default:
            return "Radiant"
        }
    }

    /// Return the emoji that pairs with the descriptor.
    static func emoji(for value: Int) -> String {
        switch self.clamped(value) {
        case 1 ... 2:
            return "☁️"
        case 3 ... 4:
            return "🌦️"
        case 5 ... 6:
            return "🌤️"
        case 7 ... 8:
            return "☀️"
        default:
            return "✨"
        }
    }
}
