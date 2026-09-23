# POS Cafe Documentation

Dokumentasi ini menjadi acuan pengembangan POS kafe dengan kondisi awal:

- Satu Huawei Pad sebagai perangkat kasir.
- Satu printer thermal Bluetooth.
- Kasir mencatat order, pembayaran, dan kejadian stok.
- Pemilik memantau penjualan serta stok dari dashboard jarak jauh.
- POS harus tetap berjalan saat internet terputus.

## Struktur

```text
docs/
├── README.md
├── architecture/
│   ├── system-overview.md
│   └── data-model.md
├── flows/
│   ├── order-flow.md
│   └── inventory-sync-flow.md
├── hardware/
│   └── printer-plan.md
├── testing/
│   └── cashier-test.md
└── requirements/
    ├── mvp.md
    ├── next-phases.md
    └── roadmap.md
```

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

## Menjalankan Preview Web

Gunakan port terpisah dari website lain:

```powershell
flutter run -d chrome --web-port 5174
```

Chrome preview memakai katalog memory-only. Database SQLite persisten digunakan pada aplikasi native Huawei Pad.
