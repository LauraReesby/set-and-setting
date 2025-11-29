@testable import Afterflow
import Foundation
import Testing

@MainActor
struct SecureStoreTests {
    private let store = SecureStore(service: "test.afterflow.securestore")

    @Test("SecureStore set/get/remove roundtrip") func roundTrip() async throws {
        let key = "token"
        let payload = "hello".data(using: .utf8)!
        try store.set(payload, for: key)
        let stored = try #require(store.data(for: key))
        #expect(stored == payload)
        try store.remove(key: key)
        let missing = try store.data(for: key)
        #expect(missing == nil)
    }
}
