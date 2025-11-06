# Set and Setting Constitution

## Core Principles

### I. Privacy-First
Every feature must prioritize user privacy and data security. All sensitive therapeutic data remains on device by default. Any data sharing requires explicit user consent and clear purpose. No external analytics or tracking without user knowledge.

### II. SwiftUI + SwiftData Native
Build using modern Apple frameworks for consistency and performance. SwiftUI for all interfaces, SwiftData for local persistence. Leverage iOS capabilities while maintaining simplicity.

### III. Therapeutic Value-First
Every feature must directly support therapeutic reflection and insights. User interface should be calming and supportive. No gamification or features that could encourage substance misuse.

### IV. Offline-First Design
Core functionality must work without internet connection. Optional cloud sync and integrations are enhancements, not dependencies. Users maintain full control over their data.

### V. Simplicity and Focus
Start with essential features only. Each addition must serve a clear therapeutic purpose. Avoid feature creep that dilutes the core value proposition.

### VI. Test-Driven Quality (NON-NEGOTIABLE)
Every feature MUST include comprehensive testing with minimum 80% code coverage. Unit tests for all business logic and data models. UI tests for critical user workflows. Tests written first, implementation follows. No feature ships without meeting coverage requirements.

## Technical Constraints

### Platform Requirements
- **Minimum iOS Version**: 17.6
- **Target Devices**: iPhone and iPad with adaptive UI
- **Architecture**: SwiftUI + SwiftData + CloudKit (optional)
- **Third-party Dependencies**: Minimal, only for essential integrations (Spotify SDK)

### Data Management
- **Primary Storage**: SwiftData with local SQLite backing
- **Backup Strategy**: iCloud sync (user-controlled)
- **Export Options**: CSV, PDF for sharing with therapists
- **Privacy**: No telemetry, no user tracking, no external data collection

### Security Standards
- **Biometric Protection**: Face ID/Touch ID for app access (optional but recommended)
- **Data Encryption**: Leverage iOS built-in encryption for local data
- **API Security**: OAuth 2.0 for Spotify integration only
- **Audit Trail**: Log session access for user awareness

### Development Workflow

### Test-Driven Development (MANDATORY)
- **Coverage Requirement**: Minimum 80% code coverage for all features
- **Test-First Approach**: Write tests before implementation (Red-Green-Refactor)
- **Unit Tests**: Required for all SwiftData models, ViewModels, and Services
- **UI Tests**: Required for all critical user workflows and acceptance scenarios
- **Integration Tests**: Required for SwiftData persistence and complex workflows
- **Coverage Gates**: No feature merges without meeting 80% coverage threshold

### Feature Implementation Order
1. Core session logging (offline)
2. Local data persistence and viewing
3. Export functionality
4. Spotify integration
5. iCloud sync
6. Advanced analytics/insights

## Quality Gates

### User Experience
- All features must be accessible (VoiceOver, Dynamic Type)
- Interface should be calming and non-judgmental
- No dark patterns or manipulative design
- Clear data ownership and control for users

### Code Quality Gates
- **Test Coverage**: Minimum 80% code coverage before any feature merge
- **Test Types**: Unit tests (models, ViewModels, services), UI tests (user workflows), Integration tests (data persistence)
- **Performance**: Memory usage profiling, battery impact assessment
- **Accessibility**: VoiceOver compliance, Dynamic Type support testing
- **Privacy**: Local data encryption verification, no external data leakage testing

## Quality Gates

## Governance
Constitution supersedes all other practices. Amendments require documentation and rationale. Privacy and therapeutic value principles are non-negotiable.

**Version**: 1.0.0 | **Ratified**: 2025-11-05 | **Last Amended**: 2025-11-05
