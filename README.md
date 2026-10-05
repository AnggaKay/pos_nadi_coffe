# Nadi Coffee Workspace

Monorepo untuk aplikasi kasir Nadi Coffee dan Owner Dashboard web.

```text
apps/
├── cashier/     # Flutter POS untuk tablet; offline-first
└── owner-web/   # Next.js dashboard Owner untuk browser
docs/            # Arsitektur, requirement, dan flow lintas aplikasi
supabase/        # Migrasi skema dan fungsi backend bersama (tahap integrasi)
```

## Project

### Cashier — Flutter

```powershell
cd apps/cashier
flutter pub get
flutter run
flutter test
```

SQLite lokal menjadi sumber operasional POS. Preview web Flutter dapat dijalankan dengan `flutter run -d chrome --web-port 5174`.

### Owner Web — Next.js

Setup aplikasi Owner dijelaskan di [`apps/owner-web/README.md`](apps/owner-web/README.md). Prototype memakai data demo berlabel; autentikasi dan backend belum dikonfigurasi.

## Shared Backend

POS dan Owner Web dirancang memakai backend/cloud bersama. Supabase PostgreSQL/Auth/RLS adalah target rancangan; skema dan integrasi sync belum dianggap siap sampai implementasinya selesai dan diuji. Jangan menaruh secret service-role di aplikasi klien.

## Documentation

Mulai dari [`docs/README.md`](docs/README.md), kemudian lihat [`docs/flows/owner-monitoring-flow.md`](docs/flows/owner-monitoring-flow.md) untuk rancangan monitoring Owner.
