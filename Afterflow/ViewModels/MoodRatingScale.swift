//  Constitutional Compliance: Therapeutic Tone, Accessibility-First

import Foundation

/// Provides descriptive context and emoji mappings for mood ratings.
/// Keeps slider labels calm and reflective while remaining testable.
enum MoodRatingScale {
    /// Clamp incoming slider values to the 1...10 range expected by the UX.
    private static func clamped(_ value: Int) -> Int {
        max(1, min(value, 10))
    }

    /// Return a supportive descriptor for a specific mood rating.
    static func descriptor(for value: Int) -> String {
        switch self.clamped(value) {
        case 1 ... 2:
            "Tender"
        case 3 ... 4:
            "Reflective"
        case 5 ... 6:
            "Centered"
        case 7 ... 8:
            "Uplifted"
        default:
            "Radiant"
        }
    }

    /// Return the emoji that pairs with the descriptor.
    static func emoji(for value: Int) -> String {
        switch self.clamped(value) {
        case 1 ... 2:
            "☁️"
        case 3 ... 4:
            "🌦️"
        case 5 ... 6:
            "🌤️"
        case 7 ... 8:
            "☀️"
        default:
            "✨"
        }
    }
}
