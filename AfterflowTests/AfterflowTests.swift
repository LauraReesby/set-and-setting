import Testing
@testable import Afterflow

struct AfterflowSmokeTests {
    @Test("TherapeuticSession instances have unique identifiers")
    func testTherapeuticSessionIdentity() {
        let firstSession = TherapeuticSession()
        let secondSession = TherapeuticSession()
        
        #expect(firstSession.id != secondSession.id)
    }
    
    @Test("TherapeuticSession defaults honor therapeutic tone")
    func testDefaultIntentionIsEmpty() {
        let session = TherapeuticSession()
        
        #expect(session.intention.isEmpty)
        #expect(session.moodBefore == 5)
        #expect(session.moodAfter == 5)
    }
}
