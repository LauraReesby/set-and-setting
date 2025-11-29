# Feature Spec — Spotify Integration (v2)
**Feature ID:** 002  
**Status:** Active  
**Depends On:** Core Session Logging (001)  
**Constitution Reference:** v1.0.0  
**Owner:** Engineering + Product  

## Intent
Let users attach a Spotify playlist or track link to a session for context during or after therapy, keeping privacy and control.

## Problem
Music is central to therapeutic setting, yet users can’t easily log what they listened to without manual text entry.

## Success Criteria
- Link Spotify playlists to any TherapeuticSession using only Web API endpoints necessary for listing and metadata.
- No in-app playback or analytics.
- OAuth login fully transparent; access/refresh tokens stored in iOS Keychain (never SwiftData).
- UI shows playlist name, cover art, URI link.
- Logout and token deletion available at any time.
- **Performance**: OAuth flow < 15s; playlist fetch < 3s; UI remains responsive.

---

## User Stories
### US1 — Connect Spotify
**As a user**, I want to securely connect my Spotify account to retrieve my playlists.  
**Acceptance**
1. “Connect Spotify” button triggers OAuth PKCE flow.  
2. Consent screen explains scopes (`playlist-read-private`, `user-read-email`).  
3. After success, only playlist metadata stored locally.

### US2 — Attach Playlist
**As a user**, I want to attach a playlist to a session.  
**Acceptance**
1. Playlist list fetched locally after connection (GET `/me/playlists`).  
2. Selecting a playlist fetches/uses stored metadata (name, cover art, `spotify:` URI) and saves it to the session.  
3. Playlist metadata displayed in SessionDetailView with an “Open in Spotify” deep link.  

### US3 — View Playlist Info
**As a user**, I want to see which playlist I used.  
**Acceptance**
1. SessionDetailView shows playlist name, art, duration.  
2. Tap “Open in Spotify” → deep link to Spotify app.  

### US4 — Disconnect
**As a user**, I want to revoke access.  
**Acceptance**
1. “Disconnect Spotify” removes tokens & metadata.  
2. Session data remains intact; playlist field cleared.

---

## Functional Requirements
| ID | Requirement |
|----|--------------|
| FR-201 | Implement Spotify OAuth 2.0 (PKCE) flow via SafariViewController or ASWebAuthenticationSession. |
| FR-202 | Store access/refresh tokens in Keychain only; never persist in SwiftData. |
| FR-203 | Call GET `/me/playlists` and `/playlists/{id}` to retrieve playlist metadata (name, first image URL, URI). |
| FR-204 | Allow user to link one playlist per TherapeuticSession using existing fields (`spotifyPlaylistURI`, `spotifyPlaylistName`, `spotifyPlaylistImageURL`). |
| FR-205 | Deep link to Spotify via `spotify:` URI (fallback to HTTPS). |
| FR-206 | Provide disconnect & token wipe functionality. |
| FR-207 | Respect offline mode (defer connection gracefully, surface explanatory copy). |
| FR-208 | Add Spotify icon button to the Music row; tapping opens Connect flow (if not connected) or Playlist Picker (if connected). |
| FR-209 | Playlist picker view displays cover art, name, URI metadata and supports pull-to-refresh + VoiceOver labels. |

---

## Technical Requirements
| ID | Description |
|----|--------------|
| TR-201 | SwiftUI 5.9 interface additions on iOS ≥ 17.6: Connect view, badge button inside Music field, playlist picker sheet, playlist card in detail view. |
| TR-202 | Spotify Web API usage limited to playlist listing + metadata; no search or playback endpoints. |
| TR-203 | Token storage: iOS Keychain (secure), background refresh via refresh token. |
| TR-204 | Reuse existing TherapeuticSession fields (`spotifyPlaylistURI`, `spotifyPlaylistName`, `spotifyPlaylistImageURL`). |
| TR-205 | ViewModel isolation: `SpotifyAuthManager` + `SpotifyService` + `SpotifyAccountViewModel`. |
| TR-206 | UI: reflective tone, avoid "music recommendation" language, icon button uses official Spotify glyph. |
| TR-207 | Performance: launch < 2s; I/O < 16ms main thread (constitutional requirements). |

---

## QA Standards
**Constitutional Quality Gates (non-negotiable):**
- **Test Coverage**: Minimum 80% code coverage before any feature merge.
- **Public API Coverage**: 100% test coverage required for all public functions and methods.
- **Test-Driven Development (TDD)**: Red-Green-Refactor sequence mandatory for all public interfaces.
- **Accessibility**: VoiceOver compliance, Dynamic Type support testing.
- **Performance**: Memory usage profiling, battery impact assessment.
- **Privacy**: Local data encryption verification, no external data leakage testing.
- **UX Standards**: Calming, non-judgmental interface; reflective and neutral communication tone.
- **Integration-Specific**: Token storage security, metadata fetch accuracy, linking/unlinking workflows.
- **Privacy-Specific**: No Spotify analytics events or telemetry allowed.

---

## Risks & Mitigation
| Risk | Mitigation |
|------|-------------|
| Token misuse | Store tokens only in Keychain; auto-expire on logout. |
| Privacy perception | Clear consent copy; no background network after connect. |
| API change | Use lightweight wrapper with fallback message. |

---

## Dependencies
- Spotify Web API (OAuth 2.0 PKCE)
- Core Session Logging (001)

---

## Amendment Notes
Feature changes require governance committee review.
## UI Details
- **Music Row**: display current free-text Music field with a trailing Spotify icon button. If not connected, tapping icon prompts “Connect Spotify”; otherwise, it opens the playlist picker sheet.
- **Playlist Picker Sheet**: list of playlists with cover art, name, and description. Selecting a playlist closes the sheet and updates the session metadata.
- **Session Detail Playlist Card**: compact card with cover art thumbnail, playlist name, and “Open in Spotify” link (deep link).
- **Disconnect**: Connect screen and playlist card include a “Disconnect Spotify” action that clears tokens and session playlist metadata.
