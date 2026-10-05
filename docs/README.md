# POS Cafe Documentation

Dokumentasi ini menjadi acuan pengembangan workspace Nadi Coffee dengan kondisi awal:

- Satu Huawei Pad sebagai perangkat kasir.
- Satu printer thermal Bluetooth.
- Kasir mencatat order, pembayaran, dan kejadian stok.
- Pemilik memantau penjualan serta stok dari dashboard jarak jauh.
- POS harus tetap berjalan saat internet terputus.
- Owner Dashboard dibangun sebagai aplikasi web terpisah di `apps/owner-web`.

## Struktur

```text
docs/
├── README.md
├── architecture/
│   ├── system-overview.md
│   └── data-model.md
├── flows/
│   ├── order-flow.md
│   ├── inventory-sync-flow.md
│   └── owner-monitoring-flow.md
├── hardware/
│   └── printer-plan.md
├── testing/
│   └── cashier-test.md
└── requirements/
    ├── mvp.md
    ├── next-phases.md
    └── roadmap.md
```

Source aplikasi berada di `apps/cashier` (Flutter) dan `apps/owner-web` (Next.js). Backend bersama direncanakan di `supabase/` pada fase integrasi.

## Urutan Baca

1. `requirements/mvp.md`
2. `flows/order-flow.md`
3. `architecture/system-overview.md`
4. `architecture/data-model.md`
5. `flows/inventory-sync-flow.md`
6. `requirements/roadmap.md`
7. `requirements/next-phases.md`
8. `hardware/printer-plan.md`
9. `testing/cashier-test.md`
10. `flows/owner-monitoring-flow.md`

## Menjalankan Preview Web

Gunakan port terpisah dari website lain:

```powershell
flutter run -d chrome --web-port 5174
```

Chrome preview memakai katalog memory-only. Database SQLite persisten digunakan pada aplikasi native Huawei Pad.
