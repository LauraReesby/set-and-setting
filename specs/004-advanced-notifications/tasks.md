# Task List — Advanced Notifications (001-AN)

## Phase 1 – Deep Link Handling
- [x] AN01 [US1] Register notification category and handle `sessionID` deep link on tap (cold/warm starts).  
- [x] AN02 [US1] Navigate to matching SessionDetail; fallback gracefully if missing.  
- [x] AN03 [US1] Unit tests for deep link routing + missing session handling.  

## Phase 2 – Quick Reflection Action
- [x] AN04 [US2] Add UNTextInputNotificationAction ("Add Reflection") to reminder category.  
- [x] AN05 [US2] Persist input to `TherapeuticSession` (prepend timestamped entry by default).  
- [x] AN06 [US2] Queue and replay reflection input when app launches if extension cannot save immediately.  
- [x] AN07 [US2] UI/UX: Toast or banner confirming reflection was saved on next open.  
- [x] AN08 [US2] Unit/UI tests for reflection action happy path + failure fallback.  

## Phase 3 – Polish & QA
- [x] AN09 [Polish] VoiceOver labels for actions; ensure neutral, privacy-safe copy.  
- [x] AN10 [Polish] Performance checks (deep link <1s; reflection save <300ms; replay <1s).  
- [x] AN11 [Polish] Governance review: no PII in payload; no network usage; retention of queued inputs documented.  
