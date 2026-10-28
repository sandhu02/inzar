# Inzar (إنذار)

> **Capture quickly. Verify intelligently. Alert locally.**

Inzar is a crowdsourced, AI-verified, real-time incident reporting and local awareness mobile application. It helps nearby residents stay informed about immediate local disruptions (fires, road accidents, flooding, gatherings, and blockages) through verified reports and privacy-respecting approximate locations.

---

## Key Features

- **Interactive Radar Map:** Dark night-mode map with real-time incident markers, cluster counts, configurable radius filtering (1–50 km), and instant preview sheets.
- **Incident Details:** Rich metadata inspection (reported time, distance, approximate location, status) with AI review and corroboration badges.
- **In-App Camera & Reporting Flow:** Native capture flow designed for quick reports without gallery uploads, extensible categories, and approximate location adjustment (~200 m fuzzing).
- **AI Verification Progress:** Transparent multi-step submission pipeline explaining publication, human-review, or denial outcomes.
- **Activity & History:** Filterable submissions dashboard (`All`, `Review`, `Live`, `Denied`) to track report statuses.
- **Onboarding & Permissions:** 3-step tour with visual radar graphic and transparent permission controls (Location, Camera, Notifications).
- **Authentication & Profile:** Clean Sign In and Sign Up flows with Google integration, anonymous-by-default notices, and personal report archives.
- **Settings & Privacy:** User profile card, custom alert radiuses, push notification preferences, permission management, and local emergency contact shortcuts (15 / 1122).

---

## Architecture & Tech Stack

The project follows **Clean Architecture** with separation of concerns:

```
lib/
├── app/               # Routing (GoRouter + StatefulShellRoute), DI (GetIt), Bootstrap
├── core/              # Design tokens (AppColors, AppTypography), UI components, errors
├── domain/            # Core entities (Incident, Category, ReviewStatus, ReportDraft)
├── features/          # Feature modules with BLoCs, views, and widgets
│   ├── map/           # Interactive radar canvas, preview sheet, radius selector
│   ├── incident_details/ # Incident metadata, directions, and safety disclaimer
│   ├── report/        # Camera capture, incident form, and AI review progress
│   ├── activity/      # Filterable submission history
│   ├── auth/          # Sign In, Sign Up views & AuthBloc
│   ├── onboarding/    # 3-step onboarding tour with radar graphic
│   ├── profile/       # User profile details, data download, account management
│   └── settings/      # Alert preferences, permissions, and theme mode
└── shell/             # Persistent bottom navigation shell with safe area handling
```

- **Framework:** Flutter (3.47+ / Dart 3.13+)
- **State Management:** `flutter_bloc`
- **Navigation:** `go_router` (Stateful Shell branches)
- **Dependency Injection:** `get_it`
- **Typography:** Google Fonts (`Inter` and `Roboto Mono`)

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.

### Run the App
```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Verification & Tests
```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```
