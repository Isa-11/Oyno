# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run          # Run the app in development
flutter build apk    # Build Android release APK
flutter build ios    # Build iOS release
flutter test         # Run all tests
flutter analyze      # Dart static analysis / linting
```

## Architecture

**Oyno** is a Flutter mobile app (iOS & Android) for sports booking and player matching, targeting Russian-speaking markets (UI text is in Russian/Cyrillic; place names reference Bishkek/Kyrgyzstan).

State management uses **GetX** (`get: ^4.6.6`) for reactive state and navigation (`Get.to()`).

### Structure

- `lib/main.dart` — Entry point; `MainShell` widget hosts bottom navigation (4 tabs)
- `lib/controllers/nav_controller.dart` — GetX controller managing active tab state
- `lib/theme/app_theme.dart` — Centralized design system (colors, typography via Oswald/Google Fonts)
- `lib/models/models.dart` — All data models (`PlayerGroup`, `Venue`, `GameItem`, `ChatItem`) + `MockData` static class with in-memory test fixtures
- `lib/screens/` — Full-page widgets; each screen is self-contained and navigated to via `Get.to()`
- `lib/widgets/` — Reusable card/list components shared across screens

### Design System

Dark theme throughout. Key tokens from `AppTheme`:
- Background: `#111111`, Card: `#1E1E1E`, Accent: `#CCFF00` (lime green)
- Typography: Oswald font family via `google_fonts`

### Data Layer

Currently all data is mocked via `MockData` in `models.dart` — no backend integration exists yet.
