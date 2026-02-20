# Repository Guidelines

## Project Structure & Module Organization

- `lib/` Flutter source
  - `main.dart`: app entry + `Provider` wiring (`GlobalData`)
  - `models/`: app state and data models (e.g. `GlobalData`, `OvertimeRecord`)
  - `services/`: persistence/auth/sync abstractions (SharedPreferences + placeholders)
  - `screens/`: top-level pages (Home/Report/Settings/Onboarding)
  - `widgets/`: reusable UI components
- `test/`: widget/unit tests (`*_test.dart`)
- `docs/`: screenshots and assets (e.g. `docs/assets/icon.png`)
- Platform folders: `android/`, `ios/`, `web/`

## Build, Test, and Development Commands

- `flutter pub get` — install dependencies
- `flutter run` — run locally on a device/emulator
- `flutter test --no-version-check` — run automated tests
- `flutter analyze --no-version-check` — run lints (see `analysis_options.yaml`)
- `flutter build apk --release --split-per-abi` — build release APKs (matches CI)

## Coding Style & Naming Conventions

- Format before pushing: `dart format .` (Dart defaults; 2-space indentation).
- Naming: files `snake_case.dart`, classes/widgets `UpperCamelCase`, locals `lowerCamelCase`.
- Keep business logic in `models/` + `services/`; keep UI-only code in `screens/`/`widgets/`.

## Testing Guidelines

- Prefer small widget smoke tests that pump `MyApp` with a `ChangeNotifierProvider<GlobalData>`.
- Use `SharedPreferences.setMockInitialValues({})` to avoid platform IO in tests.
- Keep tests independent: `GlobalData` is a singleton, so reset state via mocked prefs/setup.

## Commit & Pull Request Guidelines

- Existing history uses short messages (often “update”); use clearer, imperative subjects.
  - Example: `fix: correct duplicate merge logic`
- PRs should include: a short summary, screenshots for UI changes (`docs/screenshots/`), and notes for any storage/model changes.

## Release Notes

- Pushing a tag matching `v*` triggers `.github/workflows/release.yml` to build and publish Android APKs to GitHub Releases.
