# Set and Setting - Project Roadmap

**Project**: Private psychedelic therapy session logging app  
**Platform**: iOS 17.6+ (iPhone and iPad)  
**Stack**: SwiftUI + SwiftData + CloudKit (optional)  
**Created**: 2025-11-05

## Vision Statement

A private, therapeutic-focused app that helps users log and reflect on psychedelic-assisted therapy sessions by capturing the three key factors that influence outcomes: set (mindset), setting (environment), and music. The app prioritizes privacy, simplicity, and therapeutic value to support healing and integration work.

## Development Phases

### Phase 1: Core Foundation (MVP) 🎯
**Timeline**: 2-3 weeks  
**Goal**: Basic session logging and viewing functionality

**Features**:
- ✅ Core session logging (date, treatment type, dose, intentions)
- ✅ Environment and music capture
- ✅ Session history viewing
- ✅ Local data persistence with SwiftData
- ✅ Basic iPhone/iPad adaptive UI

**Deliverable**: Functional session logging app that works entirely offline

**Success Criteria**:
- Users can create, save, and view therapy sessions
- All data persists locally without data loss
- App works on both iPhone and iPad
- Interface is usable during altered states (large targets, clear text)
- **Minimum 80% code coverage achieved across all components**
- **All critical workflows covered by UI tests**
- **Comprehensive unit tests for all models and business logic**

---

### Phase 2: Enhanced Reflection Tools
**Timeline**: 1-2 weeks  
**Goal**: Add quantitative tracking and rich reflection capabilities

**Features**:
- Mood rating system (before/after session)
- Post-session reflection editing
- Enhanced session detail views
- Basic data visualization (mood trends)

**Deliverable**: App supports both immediate logging and delayed reflection work

---

### Phase 3: Data Export and Sharing
**Timeline**: 1-2 weeks  
**Goal**: Enable therapeutic collaboration and data portability

**Features**:
- CSV export for analysis
- PDF report generation for therapists
- Email integration for easy sharing
- Export customization (field selection, date ranges)

**Deliverable**: Users can share session insights with care providers

---

### Phase 4: Spotify Integration
**Timeline**: 2-3 weeks  
**Goal**: Rich music context and easy playlist association

**Features**:
- Spotify OAuth authentication
- Playlist search and association
- Rich playlist metadata (cover art, track count, duration)
- Direct playlist opening in Spotify app
- Offline playlist information caching

**Deliverable**: Seamless music integration enhances session context

---

### Phase 5: Privacy and Sync Features
**Timeline**: 2-3 weeks  
**Goal**: Enhanced privacy controls and optional cloud sync

**Features**:
- Face ID/Touch ID app protection
- iCloud sync (user-controlled)
- Data export for migration
- Enhanced privacy settings
- Audit trail for data access

**Deliverable**: Professional-grade privacy with optional sync convenience

---

### Phase 6: Advanced Analytics and Insights
**Timeline**: 2-4 weeks  
**Goal**: Pattern recognition and therapeutic insights

**Features**:
- Treatment effectiveness analysis
- Environmental factor correlations
- Music pattern recognition
- Long-term mood trend analysis
- Custom reflection prompts based on patterns

**Deliverable**: App provides meaningful insights to support therapeutic work

---

## Technical Architecture

### Data Layer
- **SwiftData**: Local persistence with relationship modeling
- **CloudKit**: Optional sync (user-controlled)
- **Core Data Migration**: Support for future schema changes

### UI Layer
- **SwiftUI**: Modern, accessible interface design
- **Adaptive Layout**: iPhone and iPad support
- **Accessibility**: VoiceOver, Dynamic Type, high contrast support

### Integration Layer
- **Spotify SDK**: Music integration with OAuth 2.0
- **iOS Share Sheet**: File export and sharing
- **Local Notifications**: Optional reminder system

### Security & Privacy
- **Local Encryption**: Leverage iOS built-in encryption
- **Biometric Protection**: Optional Face ID/Touch ID
- **No Analytics**: Zero user tracking or telemetry
- **Transparent Data Usage**: Clear privacy disclosures

---

## Success Metrics

### User Experience
- **Session Creation**: <60 seconds for basic entry
- **App Launch**: <2 seconds to session list
- **Data Reliability**: 100% session data persistence
- **Accessibility**: Full VoiceOver and Dynamic Type support

### Therapeutic Value
- **Privacy Assurance**: No external data sharing without consent
- **Integration Support**: Easy sharing with care providers
- **Pattern Recognition**: Meaningful insights from historical data
- **Reflection Enhancement**: Rich context supports therapeutic work

### Technical Performance
- **Battery Life**: Minimal impact on device battery
- **Storage Efficiency**: Optimal data storage and caching
- **Offline Capability**: Full functionality without internet
- **Sync Reliability**: 99%+ successful sync operations (when enabled)

---

## Risk Mitigation

### Privacy Risks
- **Mitigation**: Local-first design, transparent data handling, user control over all sharing
- **Backup Plan**: Comprehensive privacy audit before any cloud features

### Technical Risks
- **Mitigation**: SwiftData expertise development, extensive testing on target iOS versions
- **Backup Plan**: Core Data fallback if SwiftData limitations discovered

### Spotify API Risks
- **Mitigation**: Design app to work fully without Spotify, treat integration as enhancement
- **Backup Plan**: Manual music entry remains fully functional

### User Adoption Risks
- **Mitigation**: Focus on core therapeutic value, simple onboarding, clear value proposition
- **Backup Plan**: Gather user feedback early and often, prioritize requested features

---

## Development Principles

1. **Privacy First**: Every feature decision prioritizes user privacy and data security
2. **Therapeutic Value**: All features must directly support therapeutic reflection and insights
3. **Offline First**: Core functionality must work without internet connectivity
4. **Simplicity**: Avoid feature creep that dilutes the core value proposition
5. **Accessibility**: Interface must be inclusive and usable in various states of consciousness
6. **Test-Driven Quality (NON-NEGOTIABLE)**: Minimum 80% code coverage, comprehensive testing for all features, test-first development approach

---

## Next Steps

1. **Immediate**: Begin Phase 1 implementation with core session logging
2. **Week 1**: Complete SwiftData model design and basic UI framework
3. **Week 2**: Implement session creation and viewing workflows
4. **Week 3**: Complete MVP testing and prepare for Phase 2
5. **Ongoing**: Maintain constitution compliance and gather user feedback

This roadmap balances rapid MVP delivery with thoughtful feature progression, ensuring each phase delivers meaningful value while building toward a comprehensive therapeutic tool.