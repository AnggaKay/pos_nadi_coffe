# System Overview

## Tujuan

Menyediakan POS counter-service yang cepat untuk kasir, tetap dapat digunakan offline, mencetak struk dan tiket kitchen, serta mengirim data penjualan dan stok ke cloud agar dapat dipantau pemilik.

## Arsitektur

```text
Customer
   │
   ▼
Huawei Pad POS
├── Order dan pembayaran
├── Nomor antrean
├── SQLite lokal
├── Stock ledger lokal
├── Sync queue
└── Bluetooth ESC/POS printer
        │
        │ HTTPS saat online
        ▼
Cloud Backend
├── Authentication
├── PostgreSQL
├── Order dan payment
├── Stock movement
├── Audit log
└── Sync endpoint
        │
        ▼
Owner Dashboard
├── Penjualan
├── Stok
├── Produk habis
├── Waste dan adjustment
└── Status perangkat/sinkronisasi
```

## Stack

### POS

- Flutter dan Dart.
- Riverpod untuk state management.
- Drift dan SQLite untuk penyimpanan lokal.
- `go_router` untuk navigasi.
- ESC/POS untuk printer thermal.
- Kotlin Android bridge bila plugin Bluetooth tidak memenuhi kebutuhan printer.

### Cloud

- Supabase PostgreSQL.
- Supabase Auth untuk owner.
- Row Level Security.
- REST API untuk sync.
- Realtime opsional untuk update dashboard.

### Dashboard

- Next.js dan TypeScript.
- Tailwind CSS.
- TanStack Query.
- Recharts atau ECharts.

## Prinsip Sistem

1. POS tidak menunggu cloud untuk menyelesaikan transaksi.
2. SQLite menjadi sumber kerja lokal saat operasional berlangsung.
3. Cloud menjadi sumber monitoring dan backup.
4. Order final tidak dihapus; koreksi memakai void, refund, atau reversal.
5. Stok disimpan sebagai ledger pergerakan, bukan overwrite angka tanpa histori.
6. Harga dan resep transaksi disimpan sebagai snapshot/version.
7. Semua aksi sensitif memiliki user, waktu, perangkat, dan alasan.

## Batas MVP

Belum termasuk multi-outlet, loyalty, delivery, table management, KDS khusus, purchase order, dan payment gateway.
