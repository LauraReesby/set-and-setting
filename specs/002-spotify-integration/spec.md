# Feature Specification: Spotify Integration

**Feature Branch**: `002-spotify-integration`  
**Created**: 2025-11-05  
**Status**: Draft  
**Input**: User description: "Use Spotify API to link your account (OAuth), save a reference to a playlist URI for each session, optionally fetch playlist name, cover image, and duration. You could even open the playlist in Spotify directly from the session entry."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Connect Spotify Account (Priority: P1)

A user wants to link their Spotify account to the app so they can easily associate playlists with their therapy sessions.

**Why this priority**: Foundation requirement for all other Spotify features. Must be secure and user-controlled.

**Independent Test**: User can authenticate with Spotify using OAuth, grant permissions, and see confirmation that account is connected. Connection status persists between app launches.

**Acceptance Scenarios**:

1. **Given** app is open and user has no Spotify connection, **When** user navigates to Spotify settings, **Then** "Connect Spotify" button is displayed
2. **Given** user taps "Connect Spotify", **When** Spotify OAuth flow completes successfully, **Then** app displays confirmation and stores access tokens securely
3. **Given** Spotify is connected, **When** user reopens app, **Then** Spotify connection status is maintained and visible
4. **Given** Spotify is connected, **When** user chooses to disconnect, **Then** tokens are cleared and connection status updated

---

### User Story 2 - Associate Playlist with Session (Priority: P1)

During session creation, a user wants to search for and select a Spotify playlist to associate with their therapy session.

**Why this priority**: Core integration value - linking music to sessions for pattern recognition and easy replay.

**Independent Test**: User can search Spotify playlists by name, select one, and save playlist reference with session. Playlist information is retrievable later.

**Acceptance Scenarios**:

1. **Given** session form is open and Spotify is connected, **When** user taps "Add Playlist" in music section, **Then** Spotify playlist search interface appears
2. **Given** playlist search is open, **When** user types playlist name, **Then** relevant Spotify playlists appear in results
3. **Given** search results are displayed, **When** user selects a playlist, **Then** playlist name and URI are saved to session
4. **Given** playlist is selected, **When** user saves session, **Then** playlist reference is stored and displayed in session details

---

### User Story 3 - View Playlist Details in Session (Priority: P2)

When viewing a past session, a user wants to see rich playlist information including cover art, track count, and duration to better remember their session context.

**Why this priority**: Enhanced context for reflection - visual and detailed music information aids memory and pattern recognition.

**Independent Test**: User can view session with associated playlist and see cover image, playlist name, track count, and total duration fetched from Spotify API.

**Acceptance Scenarios**:

1. **Given** session has associated playlist, **When** user views session details, **Then** playlist cover image is displayed
2. **Given** session details show playlist, **When** user views playlist section, **Then** playlist name, track count, and duration are visible
3. **Given** playlist details are cached, **When** user views session offline, **Then** cached playlist information is still available

---

### User Story 4 - Open Playlist in Spotify (Priority: P3)

From a session detail view, a user wants to open the associated playlist directly in Spotify to listen to the same music that accompanied their session.

**Why this priority**: Enables re-experiencing session context for integration work, but not essential for core logging functionality.

**Independent Test**: User can tap playlist in session details and Spotify app opens to the specific playlist.

**Acceptance Scenarios**:

1. **Given** session has associated playlist, **When** user taps playlist cover or "Open in Spotify" button, **Then** Spotify app launches to the specific playlist
2. **Given** Spotify app is not installed, **When** user tries to open playlist, **Then** App Store opens to Spotify download page or web player opens
3. **Given** playlist is no longer available on Spotify, **When** user tries to open it, **Then** graceful error message is displayed

---

### User Story 5 - Manage Spotify Permissions (Priority: P2)

A user wants control over their Spotify integration, including the ability to revoke access, understand what data is accessed, and manage privacy settings.

**Why this priority**: Privacy-first principle requires transparent data usage and user control over integrations.

**Independent Test**: User can view current Spotify permissions, understand what data is accessed, and revoke access at any time.

**Acceptance Scenarios**:

1. **Given** Spotify is connected, **When** user views integration settings, **Then** current permissions and data usage are clearly explained
2. **Given** user wants to revoke access, **When** they tap "Disconnect Spotify", **Then** local tokens are cleared and user is informed about data retention
3. **Given** Spotify access is revoked, **When** user views past sessions with playlists, **Then** cached playlist information remains visible but new API calls are disabled

---

### Edge Cases

- What happens when Spotify access token expires? (Auto-refresh or prompt for re-authentication)
- How does system handle deleted or private playlists? (Show cached info with status indicator)
- What if user's Spotify subscription lapses? (Graceful degradation, no premium features required)
- How does system behave when Spotify API is down? (Use cached data, show offline indicator)
- What happens when user searches for non-existent playlist? (Show "no results" message)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST implement Spotify OAuth 2.0 authentication flow
- **FR-002**: System MUST securely store and manage Spotify access tokens
- **FR-003**: System MUST allow users to search their Spotify playlists by name
- **FR-004**: System MUST save Spotify playlist URI references with session entries
- **FR-005**: System MUST fetch and cache playlist metadata (name, cover image, track count, duration)
- **FR-006**: System MUST provide direct link to open playlists in Spotify app
- **FR-007**: System MUST gracefully handle offline scenarios with cached playlist data
- **FR-008**: System MUST allow users to disconnect Spotify integration at any time
- **FR-009**: System MUST handle expired tokens with automatic refresh or re-authentication prompt
- **FR-010**: System MUST respect Spotify API rate limits and implement appropriate throttling
- **FR-011**: System MUST work with free Spotify accounts (no premium features required)
- **FR-012**: System MUST cache playlist information for offline viewing
- **FR-013**: System MUST handle playlist privacy changes gracefully
- **FR-014**: System MUST provide clear privacy disclosure for Spotify data usage

### Testing Requirements (MANDATORY)

- **TR-001**: MUST achieve minimum 80% code coverage across all Spotify integration components
- **TR-002**: MUST include unit tests for SpotifyConnection model and authentication flow
- **TR-003**: MUST include unit tests for PlaylistReference model and caching logic
- **TR-004**: MUST include unit tests for Spotify API service layer with mock responses
- **TR-005**: MUST include unit tests for token management (storage, refresh, expiration)
- **TR-006**: MUST include UI tests for complete Spotify authentication workflow
- **TR-007**: MUST include UI tests for playlist search and selection workflow
- **TR-008**: MUST include UI tests for playlist viewing in session details
- **TR-009**: MUST include integration tests for OAuth flow and token persistence
- **TR-010**: MUST include integration tests for API rate limiting and error handling
- **TR-011**: MUST include tests for offline playlist viewing with cached data
- **TR-012**: MUST include tests for privacy controls and data disconnection
- **TR-013**: MUST include performance tests for playlist search and metadata fetching
- **TR-014**: MUST include security tests for token storage and API communication

### Key Entities

- **SpotifyConnection**: Authentication state, tokens, user preferences for Spotify integration
- **PlaylistReference**: Spotify playlist URI, cached metadata, association with therapy sessions
- **SpotifyPlaylist**: Cached playlist data including name, cover image URL, track count, duration

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete Spotify authentication in under 30 seconds
- **SC-002**: Playlist search returns results in under 3 seconds for connected users
- **SC-003**: Playlist selection and association with session takes under 10 seconds
- **SC-004**: 95% of playlist opens successfully launch Spotify app
- **SC-005**: Cached playlist information displays correctly when offline
- **SC-006**: Zero unauthorized access to user's Spotify data beyond stated permissions

### Testing Success Criteria (MANDATORY)

- **TSC-001**: Achieve and maintain minimum 80% code coverage across all Spotify integration code
- **TSC-002**: 100% of OAuth authentication flows covered by integration tests
- **TSC-003**: All Spotify API interactions thoroughly tested with mock services
- **TSC-004**: UI tests verify complete playlist search and selection workflows
- **TSC-005**: Security tests confirm proper token storage and handling
- **TSC-006**: Performance tests validate playlist search and metadata fetch speeds
- **TSC-007**: Offline tests verify cached playlist data accessibility and accuracy
- **TSC-008**: Error handling tests cover all API failure scenarios and rate limiting