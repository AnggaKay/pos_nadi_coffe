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
└── requirements/
    ├── mvp.md
    └── roadmap.md
```

## Urutan Baca

1. `requirements/mvp.md`
2. `flows/order-flow.md`
3. `architecture/system-overview.md`
4. `architecture/data-model.md`
5. `flows/inventory-sync-flow.md`
6. `requirements/roadmap.md`
