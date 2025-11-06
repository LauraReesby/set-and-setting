# Implementation Plan: Core Session Logging

**Branch**: `001-core-session-logging` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-core-session-logging/spec.md`

## Summary

Implement the core session logging functionality for a psychedelic therapy reflection app. Users can create, view, and edit therapy session entries that capture set (mindset), setting (environment), and music - the key factors influencing therapeutic outcomes. All data stored locally using SwiftData with offline-first design.

## Technical Context

**Language/Version**: Swift 5.9+ / iOS 17.6+  
**Primary Dependencies**: SwiftUI, SwiftData, Foundation  
**Storage**: SwiftData with local SQLite backing, prepared for future CloudKit sync  
**Testing**: XCTest for unit tests (80% minimum coverage), XCUITest for UI tests, SwiftUI previews for UI development  
**Target Platform**: iOS 17.6+ (iPhone and iPad with adaptive UI)  
**Project Type**: Mobile - single iOS app  
**Performance Goals**: <2s app launch, <60s session creation, responsive UI during altered states  
**Constraints**: Offline-first, privacy-focused, no external dependencies for core functionality  
**Scale/Scope**: Personal use app, ~100-500 sessions per user, simple data relationships

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✅ **Privacy-First**: All data stored locally, no external tracking  
✅ **SwiftUI + SwiftData Native**: Using modern Apple frameworks exclusively  
✅ **Therapeutic Value-First**: Core session logging directly supports reflection  
✅ **Offline-First Design**: No internet dependency for core functionality  
✅ **Simplicity and Focus**: Starting with essential session logging only  
✅ **Test-Driven Quality**: Comprehensive testing with 80% coverage requirement included in all phases  

## Project Structure

### Documentation (this feature)

```text
specs/001-core-session-logging/
├── plan.md              # This file
├── research.md          # Phase 0 output - SwiftData modeling research
├── data-model.md        # Phase 1 output - Core entities and relationships
├── quickstart.md        # Phase 1 output - Development setup and testing
├── contracts/           # Phase 1 output - API contracts for data layer
└── tasks.md             # Phase 2 output - Implementation tasks breakdown
```

### Source Code (repository root)

```text
SetAndSetting/
├── Models/              # SwiftData models
│   ├── TherapySession.swift
│   ├── TreatmentType.swift
│   └── MoodRating.swift
├── Views/               # SwiftUI views
│   ├── SessionListView.swift
│   ├── SessionDetailView.swift
│   ├── SessionFormView.swift
│   └── Components/
│       ├── MoodRatingView.swift
│       ├── TreatmentTypePicker.swift
│       └── EnvironmentInputView.swift
├── ViewModels/          # Observable objects for complex views
│   ├── SessionListViewModel.swift
│   └── SessionFormViewModel.swift
├── Services/            # Data access and business logic
│   ├── SessionDataService.swift
│   └── DataManager.swift
└── Resources/           # Assets and configuration
    ├── Assets.xcassets
    └── Localizable.strings

SetAndSettingTests/
├── ModelTests/          # Unit tests for SwiftData models (80% coverage)
│   ├── TherapySessionTests.swift
│   ├── TreatmentTypeTests.swift
│   └── MoodRatingTests.swift
├── ServiceTests/        # Tests for data services (80% coverage)
│   ├── SessionDataServiceTests.swift
│   └── DataManagerTests.swift
├── ViewModelTests/      # Tests for view models (80% coverage)
│   ├── SessionListViewModelTests.swift
│   └── SessionFormViewModelTests.swift
├── IntegrationTests/    # End-to-end workflow tests
│   ├── SessionPersistenceTests.swift
│   └── DataMigrationTests.swift
└── PerformanceTests/    # Performance and memory tests
    ├── AppLaunchTests.swift
    └── LargeDatasetTests.swift

SetAndSettingUITests/
├── SessionCreationUITests.swift     # Complete session creation workflows
├── SessionListUITests.swift         # Session viewing and navigation
├── SessionEditingUITests.swift      # Session editing and reflection workflows
├── AccessibilityUITests.swift       # VoiceOver and Dynamic Type testing
└── PerformanceUITests.swift         # App launch and interaction performance
```

**Structure Decision**: Standard iOS single app structure with clear separation of concerns. Models use SwiftData for persistence, Views are pure SwiftUI, ViewModels handle complex state, Services abstract data access. This supports testing and maintains clean architecture.

## Phase 0: Research Tasks

### SwiftData Model Design Research
- Research SwiftData relationships and migration strategies
- Investigate CloudKit integration patterns for future sync
- Determine optimal data model structure for therapy sessions
- Research iOS 17.6 SwiftData capabilities and limitations

### UI/UX Pattern Research  
- Research accessibility best practices for therapy apps
- Investigate SwiftUI form patterns for data entry during altered states
- Research mood rating UI patterns (sliders vs emoji vs numeric)
- Study adaptive UI patterns for iPhone/iPad

### Performance and Privacy Research
- Research SwiftData performance with hundreds of records
- Investigate local encryption options for sensitive data
- Research background app refresh and data persistence
- Study iOS privacy frameworks and best practices

## Phase 1: Design Tasks

### Data Model Design
- Design SwiftData schema for TherapySession entity
- Define TreatmentType enumeration and storage
- Design MoodRating system (numeric + emoji mapping)
- Plan data relationships and query patterns

### UI/UX Design
- Design session list interface with mood indicators
- Create session form layout with logical grouping
- Design session detail view for reading/editing
- Create empty states and loading indicators

### API Contracts
- Define SessionDataService interface
- Create view model protocols
- Design data validation rules
- Plan error handling strategies

## Complexity Tracking

> **No constitutional violations identified - proceeding with standard implementation**