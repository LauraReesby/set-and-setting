@testable import Afterflow
import Foundation
import Testing

@MainActor
final class SessionDetailViewModelTests {
    @Test("Saving reflection updates session and clears error")
    func saveReflectionSuccess() async throws {
        let session = TherapeuticSession(reflections: "Old")
        let persistence = MockPersistence()
        let viewModel = SessionDetailViewModel(session: session, persistence: persistence)

        viewModel.reflectionText = "  New Reflection  "
        #expect(viewModel.hasChanges)

        viewModel.saveReflection()

        #expect(session.reflections == "New Reflection")
        #expect(viewModel.reflectionText == "New Reflection")
        #expect(viewModel.showSuccessMessage)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Saving reflection surfaces persistence errors")
    func saveReflectionFailure() async throws {
        let session = TherapeuticSession(reflections: "")
        let persistence = MockPersistence(shouldThrow: true)
        let viewModel = SessionDetailViewModel(session: session, persistence: persistence)

        viewModel.reflectionText = "Needs saving"
        viewModel.saveReflection()

        #expect(viewModel.errorMessage?.contains("Couldn't save reflection") == true)
        #expect(viewModel.showSuccessMessage == false)
    }
}

private final class MockPersistence: SessionReflectionPersisting {
    var shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func updateSession(_ session: TherapeuticSession) throws {
        if shouldThrow {
            throw NSError(domain: "SessionDetailViewModelTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        }
    }
}
