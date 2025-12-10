@testable import Afterflow
import XCTest

final class CSVImportServiceTests: XCTestCase {
    func testRoundTripExportImport() throws {
        let exportService = CSVExportService()
        let importService = CSVImportService()

        let session = TherapeuticSession(
            sessionDate: date("2024-12-01T10:30:00Z"),
            treatmentType: .psilocybin,
            administration: .oral,
            intention: "Grounding",
            moodBefore: 4,
            moodAfter: 7,
            reflections: "Deep breath",
            reminderDate: nil
        )
        session.musicLinkURL = "https://open.spotify.com/playlist/abc123"

        let url = try exportService.export(sessions: [session])
        let imported = try importService.import(from: url)

        XCTAssertEqual(imported.count, 1)
        let restored = imported[0]
        XCTAssertEqual(restored.intention, "Grounding")
        XCTAssertEqual(restored.reflections, "Deep breath")
        XCTAssertEqual(restored.treatmentType, .psilocybin)
        XCTAssertEqual(restored.administration, .oral)
        XCTAssertEqual(restored.moodBefore, 4)
        XCTAssertEqual(restored.moodAfter, 7)
        XCTAssertEqual(restored.musicLinkURL, "https://open.spotify.com/playlist/abc123")
        XCTAssertEqual(restored.musicLinkProvider, .spotify)
    }

    func testParsesQuotedAndEscapedFields() throws {
        let exportService = CSVExportService()
        let importService = CSVImportService()

        let session = TherapeuticSession(
            sessionDate: date("2024-12-01T10:30:00Z"),
            treatmentType: .psilocybin,
            administration: .oral,
            intention: "Hello, \"World\"",
            moodBefore: 3,
            moodAfter: 4,
            reflections: "Line1\nLine2"
        )
        session.musicLinkURL = "https://soundcloud.com/artist/track"

        let url = try exportService.export(sessions: [session])
        let imported = try importService.import(from: url)

        XCTAssertEqual(imported.count, 1)
        let restored = imported[0]
        XCTAssertEqual(restored.intention, "Hello, \"World\"")
        XCTAssertEqual(restored.reflections, "Line1\nLine2")
        XCTAssertEqual(restored.musicLinkProvider, .soundcloud)
    }

    func testInvalidHeaderThrows() {
        let csv = """
        Bad,Header
        1,2
        """
        XCTAssertThrowsError(try CSVImportService().import(from: csv)) { error in
            guard case CSVImportService.CSVImportError.invalidHeader = error else {
                return XCTFail("Expected invalidHeader, got \(error)")
            }
        }
    }

    private func date(_ iso8601: String) -> Date {
        ISO8601DateFormatter().date(from: iso8601) ?? Date()
    }
}
