# Implementation Plan — Spotify Integration (v2)

## Overview
Integrate Spotify playlist linking into TherapeuticSession entries using secure OAuth PKCE flow and local token storage. The integration will only use the Spotify Web API for listing the user’s playlists and fetching basic playlist metadata (name, images, URI). All playback remains outside the app via Spotify deep links.

## Technical Context
**Language/Version:** Swift 5.9+ / iOS ≥ 17.6 (tested on 17.6+)  
**Frameworks:** SwiftUI, Foundation, AuthenticationServices  
**Storage:** Keychain for tokens, SwiftData for session fields  
**Testing:** TDD (Red-Green-Refactor) + XCTest + XCUITest  
**Performance Goal:** Connection < 4s; I/O < 16ms main thread; list display < 500ms  
**Privacy:** No playback, tracking, or cloud storage of user data.

## Architecture
```
Services/
 ├── SpotifyAuthManager.swift     # Handles PKCE OAuth, token refresh (Keychain storage)
 ├── SpotifyService.swift         # Calls /me/playlists & /playlists/{id}
ViewModels/
 ├── SpotifyAccountViewModel.swift
 ├── SpotifyPlaylistPickerViewModel.swift
Views/
 ├── SpotifyConnectView.swift     # Settings modal with Connect / Disconnect
 ├── SpotifyPlaylistPickerView.swift
 ├── SpotifyPlaylistCell.swift
 └── SpotifyBadgeButton.swift     # Spotify icon button embedded in Music row
Tests/
 ├── SpotifyAuthTests/
 ├── SpotifyServiceTests/
 └── SpotifyUITests/

## Flow Summary
1. **Connect Spotify (one-time)** – User taps “Connect Spotify” (Settings or Music row icon). OAuth PKCE runs in SFSafariViewController with minimal scopes (`playlist-read-private`, `user-read-email`). Tokens are persisted in Keychain only.
2. **Pick Playlist** – “Attach playlist” button (presented when connected) opens `SpotifyPlaylistPickerView`, which lists playlists using `SpotifyService.getUserPlaylists()`. Selecting a playlist stores `spotifyPlaylistURI`, `spotifyPlaylistName`, `spotifyPlaylistImageURL` on the session.
3. **Open Playlist** – Session detail shows a compact playlist card with cover art, name, and an “Open in Spotify” button that launches the `spotify:` URI (fallback to HTTPS if needed).
4. **Disconnect** – “Disconnect Spotify” removes tokens and clears cached metadata without touching session data.
```

## Phases
| Phase | Focus | Deliverables |
|-------|--------|--------------|
| 1 | OAuth PKCE Auth | SpotifyAuthManager + tests, Keychain storage |
| 2 | Playlist Metadata Fetch | SpotifyService + mock API tests (GET /me/playlists, /playlists/{id}) |
| 3 | UI Flow | Spotify badge in Music row, Connect sheet, PlaylistPickerView, playlist card |
| 4 | Integration with TherapeuticSession | Persist playlist metadata, attach/detach flows, deep link |
| 5 | QA & Governance | Privacy manifest, accessibility/UX QA, token wipe tests |

## Metrics
- OAuth connect success ≥ 95 % in test runs.  
- No background API calls after disconnect.  
- QA review pass on accessibility + privacy.
