@testable import Afterflow
import Foundation
import Testing

@MainActor
struct SpotifyAuthManagerTests {
    private let config = SpotifyAuthManager.Configuration(
        clientID: "test-client",
        redirectURI: "afterflow://auth",
        scopes: ["playlist-read-private"],
        authorizeURL: URL(string: "https://accounts.spotify.com/authorize")!,
        tokenURL: URL(string: "https://accounts.spotify.com/api/token")!
    )

    @Test("PKCE generator returns valid verifier and challenge") func pkceGeneration() async throws {
        let manager = SpotifyAuthManager(configuration: config)
        let pkce = manager.generatePKCEPair()
        #expect(pkce.verifier.count >= 43)
        #expect(pkce.challenge.count >= 43)
    }

    @Test("Authorization URL contains PKCE parameters") func authorizationURL() async throws {
        let manager = SpotifyAuthManager(configuration: config)
        let pkce = manager.generatePKCEPair()
        let url = manager.makeAuthorizationURL(pkce: pkce)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = components?.queryItems ?? []
        func value(_ name: String) -> String? { items.first { $0.name == name }?.value }
        #expect(value("code_challenge") == pkce.challenge)
        #expect(value("code_challenge_method") == "S256")
    }
}
