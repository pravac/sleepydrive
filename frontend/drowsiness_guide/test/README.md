# Running Tests

From the project root (`\frontend\drowsiness_guide`), use:

- Run all tests:
  - `flutter test`

- Run only widget tests:
  - `flutter test test/widget`

- Run only unit tests:
  - `flutter test test/unit`

- Run the integration-style smoke test file:
  - `flutter test test/integration/login_smoke_test.dart`

Helpful options:
- Verbose output:
  - `flutter test -r expanded`
- Run one specific file:
  - `flutter test test/widget/login_screen_test.dart`
- Run tests matching a name:
  - `flutter test --plain-name "LoginScreen — validation"`

If dependencies are stale, run once first:
- `flutter pub get`