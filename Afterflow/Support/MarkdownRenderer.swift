import Foundation
import SwiftUI

enum MarkdownRenderer {
    static func render(_ text: String) -> AttributedString {
        do {
            return try AttributedString(markdown: text)
        } catch {
            return AttributedString(text)
        }
    }

    static func hasFormatting(_ text: String) -> Bool {
        let markdownPatterns = ["**", "*", "• ", "1. ", "2. ", "3. ", "#"]
        return markdownPatterns.contains { text.contains($0) }
    }
}
