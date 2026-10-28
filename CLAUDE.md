# Inzar - Development & Architecture Tracking (CLAUDE.md)

## 1. Project Overview
**Inzar** is a crowdsourced, AI-verified, real-time incident reporting and local awareness platform.
- **Core Principle:** Capture quickly. Verify intelligently. Alert locally.
- **Key Philosophy:** Map first, minimal interaction, speed over decoration, progressive disclosure, trust through transparency, privacy by default.

---

## 2. Visual Identity & Design Tokens

### Color Palette
- **Background:** `#101318` (Dark-first canvas)
- **Primary Surface / Cards:** `#191E25`
- **Elevated Surface / Dialogs / Sheets:** `#222A34`
- **Border / Subtle Divider:** `#28303C`
- **Primary Accent (Brand Action):** `#FF5B35` / `#FF5722` (Warm vibrant coral-orange for + Report, Submit, Diamond logo)
- **Secondary Action (Light Pill):** `#F0EDE6` (Cream/off-white with dark text `#101318` for "View details", "Directions", "Back to map")
- **Secondary Dark Surface:** `#222A34`
- **Main Text:** `#F3F5F7`
- **Secondary Text:** `#A2ABB8`
- **Muted Text:** `#6C7684`

### Incident Category Colors & Icons
1. **Fire:** `#FF5722` (Flame icon)
2. **Accident:** `#FFB300` (Warning triangle icon)
3. **Road block:** `#CFD8DC` (Road barrier / triple line icon)
4. **Flooding:** `#42A5F5` (Double water wave icon)
5. **Gathering:** `#AB47BC` (People / group icon)
6. **Other:** `#90A4AE` (Triangle hazard icon)

### Verification & Review Status Badges
- **AI Reviewed:** `#0F2628` surface, `#1B4E52` border, `#4DD0E1` text (Checkmark circle)
- **Not Independently Confirmed:** `#202731` surface, `#8E9AA8` text
- **Published / Live:** `#0D2B20` surface, `#38EF7D` text
- **Under Review:** `#2E220D` surface, `#F59E0B` text (Clock icon)
- **Not Approved / Denied:** `#2E1212` surface, `#EF4444` text (Cross-circle icon)

---

## 3. Architecture & Folder Structure

As defined in `folder_structure.md`:
```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp.router, theme from SettingsCubit
│   ├── router.dart                 # go_router + StatefulShellRoute (Map / Activity / Settings)
│   ├── di.dart                     # get_it registrations
│   └── bootstrap.dart              # init DI, error handling
├── core/
│   ├── theme/                      # AppColors, AppTypography, AppTheme
│   ├── design_system/              # AppButton, StatusBadge, CategoryChip, RadiusSelector, AppCard, IncidentMarkerView
│   ├── error/                      # AppFailure, Result<T>
│   ├── utils/                      # formatters, helpers
│   └── mock/                       # realistic sample incidents and data
├── domain/
│   ├── entities/                   # Incident, IncidentCategory, ReviewStatus, ReportDraft
│   └── usecases/                   # business logic
├── features/
│   ├── map/
│   │   ├── bloc/                   # MapBloc, events, states
│   │   ├── view/                   # MapPage
│   │   └── widgets/                # interactive radar map, markers, preview_sheet, radius_bar
│   ├── incident_details/           # IncidentDetailsPage, mini map, metadata grid, action buttons
│   ├── report/
│   │   ├── flow/                   # ReportFlowBloc, events, state
│   │   └── view/                   # camera_page, form_page, progress_page
│   ├── activity/                   # ActivityBloc, ActivityPage, filter chips, report history cards
│   └── settings/                   # SettingsCubit, SettingsPage, radius/notifications/privacy
└── shell/
    └── main_shell.dart             # 3-tab shell with bottom navigation & active orange indicator
```

---

## 4. UI Implementation Checklist
- [x] Design tokens, typography, theme definitions (`app_colors.dart`, `app_typography.dart`, `app_theme.dart`)
- [x] Reusable Design System components (`AppButton`, `StatusBadge`, `CategoryChip`, `RadiusSelector`, `AppCard`, `IncidentMarkerView`)
- [x] Domain entities & Mock data generator (`Incident`, `IncidentCategory`, `ReviewStatus`, `ReportDraft`, `MockIncidents`)
- [x] **Screen 1 — Main Map:**
  - Header with brand diamond logo, title "INZAR", location subtitle ("Margalla Rd · F-7"), and search icon button.
  - Incident count banner ("7 incidents · within 5 km").
  - Canvas-rendered dark map with stylized roads, radar circles, user location blue dot, recenter button, and interactive category pins.
  - Radius segmented selector (`1`, `5`, `10`, `25`, `50` km) with active state.
  - Prominent coral `+ Report` button.
  - Preview bottom sheet with category, distance, timestamp, photo thumbnail, title, "AI reviewed" badge, description, and "View details" button.
- [x] **Screen 2 — Incident Details:**
  - Back navigation & header tag (`INCIDENT · #A-2041`).
  - Category icon and name in amber.
  - Prominent incident title.
  - Badges: `[✓ AI reviewed]` and `[Not independently confirmed]`.
  - Reporter photo container with diagonal texture & capture timestamp.
  - Description body.
  - 2x2 Metadata grid: REPORTED, LAST UPDATE, DISTANCE, STATUS.
  - Mini map preview with incident location pin.
  - Primary actions: `Directions` (light cream pill) and `Share` (dark button).
  - Secondary links: `Report incorrect info` & `Mark resolved`.
  - Emergency disclaimer footnote.
- [x] **Screen 3 — Camera Capture:**
  - Full-screen viewfinder with dark mountain silhouettes.
  - Top controls: Close `X` and Flash toggle.
  - Guidance capsule: `Capture what's happening`.
  - Corner viewfinder brackets `[   ]`.
  - `Location on · shared approximately` indicator.
  - Dual-ring shutter button.
- [x] **Screen 4 — Incident Report Form:**
  - Captured photo summary card with thumbnail and `Retake` link.
  - Category selector 2x3 grid (Fire, Accident, Road block, Flooding, Gathering, Other) with selection border & subtle glow.
  - Multi-line description field with placeholder.
  - Location card with category glyph, address, `~200 m` precision note, and interactive `Adjust` modal.
  - Full-width `Submit report` action button.
- [x] **Screen 5 — Submission & AI Review Progress:**
  - Header `SUBMISSION · 14:23`.
  - Step card with green check for photo upload, current state for checking report, and pending outcome.
  - Review note explaining background tracking in Activity.
  - `POSSIBLE OUTCOMES` section detailing Published, Under review, and Not approved states.
  - Dual action buttons: `Back to map` and `Activity`.
- [x] **Screen 6 — Activity / My Reports:**
  - Title `Activity`.
  - Filter chips: `All`, `Review`, `Live`, `Denied`.
  - Report cards with photo thumbnail, category, title, metadata (`Just now · F-7`), and status badge.
  - Empty state support.
  - Link `Back to map to report`.
- [x] **Screen 7 — Settings (Updated):**
  - User Profile header card with avatar initials ("AK"), "Ayesha Khan", email, and navigation to `/profile`.
  - MAP section: Default radius (5 km), Map center (Current location), Map style (Dark).
  - ALERTS section: Nearby alerts toggle with active coral switch, Alert radius (10 km), Categories (All).
  - PERMISSIONS section: Location, Camera, and Notifications status indicators with toggle actions.
  - PRIVACY section: Privacy policy and How location is handled dialogues.
  - APPEARANCE section: Theme switcher (Dark / Light / System).
- [x] **Screen 8 — Onboarding (Pages 7 & 8):**
  - 3-step tour with top brand logo and "Skip" action.
  - Step 1: "See what's happening near you." with animated radar visual graphic, step tag "1 / 3", dot indicators, and "Next" pill button.
  - Step 2: "Capture quickly. Verify intelligently." with camera verification badge.
  - Step 3: "Allow only what you need." with Location, Camera, and Notifications permission request rows, full-width "Continue" button, and disclaimer.
- [x] **Screen 9 — Sign In (Page 9):**
  - Brand header with diamond logo and title "Welcome back."
  - Email and password fields with password visibility toggle.
  - "Forgot password?" shortcut.
  - Light cream "Sign in" button.
  - "OR" divider and "Continue with Google" social authentication button.
  - "New here? Create account" navigation link.
- [x] **Screen 10 — Sign Up (Page 10):**
  - Back navigation with title "Create your account." and subtitle "Your name is never shown on reports."
  - Name, Email, and Password form fields with password visibility toggle.
  - Light cream "Create account" button.
  - Google sign-in button and Terms/Privacy acknowledgment.
  - "Have an account? Sign in" navigation link.
- [x] **Screen 11 — Profile (Page 12):**
  - Back navigation with top title "Profile".
  - Large circle avatar initials ("AK"), name "Ayesha Khan", and "✓ Signed in with Google" badge.
  - Account info card: Display name, Email, Sign-in method, Password.
  - "Anonymous by default" privacy explanation card.
  - Reports & data card: "My reports (12)" and "Download my data".
  - "Sign out" button and "Delete account" destructive action.
- [x] **Shell & GoRouter Integration:**
  - Stateful 3-tab navigation (Map, Activity, Settings).
  - Active orange line indicator above selected tab (matching Page 6).
  - Bottom navigation bar wrapped in `SafeArea(top: false)` with background color extending edge-to-edge, preventing any obstruction by Android 3-button or gesture system navigation.
- [x] **Testing & Quality Assurance:**
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 13 tests passing (AuthBloc, MapBloc, ActivityBloc, ReportFlowBloc, InzarApp smoke test).

---

## 5. Future Backend Integration Points
When connecting to live APIs, integrate the following:
1. `data/incidents/`: Implement `IncidentRemoteSource` using `Dio` and map JSON responses to `Incident` entities.
2. `data/reports/`: Connect multipart image upload and metadata to `POST /reports`.
3. `core/location/`: Integrate `geolocator` with `fuzzCoordinate(lat, lng, ~200)` for reporter privacy.
4. `core/camera/`: Integrate camera hardware feed into `camera_page.dart` using `camera` package.

