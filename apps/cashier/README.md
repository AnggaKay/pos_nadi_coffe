# Nadi Coffee Cashier

Flutter POS application for the Nadi Coffee tablet cashier. It uses a local-first workflow; Owner monitoring in this app is only a UI prototype. The production Owner experience is the separate `apps/owner-web` application.

## Run and test

```powershell
flutter pub get
flutter run
flutter test
```

For a browser preview, run `flutter run -d chrome --web-port 5174`. Browser preview uses runtime demo data and is not the persistent native SQLite environment.

See the workspace root README and `../../docs/testing/cashier-test.md` for more details.
