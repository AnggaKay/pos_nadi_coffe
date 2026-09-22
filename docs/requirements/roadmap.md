# Roadmap

## Fase 1: Fondasi POS

- Flutter app.
- SQLite/Drift schema.
- Produk, kategori, modifier.
- Order dan payment.
- Nomor antrean.
- Bluetooth ESC/POS.
- Status order.
- Offline operation.

## Fase 2: Fondasi Stok

- Ingredient dan unit.
- Recipe dan recipe version.
- Stock ledger.
- Konsumsi otomatis dari payment.
- Void/refund reversal.
- Waste.
- Adjustment.
- Stock opname.
- Minimum stock.

## Fase 3: Cloud dan Sync

- Supabase PostgreSQL.
- Authentication owner.
- Sync endpoint.
- Sync queue dan retry.
- Idempotency.
- Audit log.
- Device health.
- Backup.

## Fase 4: Owner Dashboard

- Login owner.
- Sales overview.
- Detail transaksi.
- Monitoring stok.
- Produk habis.
- Waste dan adjustment.
- Filter tanggal.
- Export laporan.

## Fase 5: Pengembangan Bertahap

Tambahkan berdasarkan kebutuhan nyata:

- Notifikasi stok kritis.
- Edit menu dan resep dari dashboard.
- Purchase order.
- KDS atau printer kitchen kedua.
- Tablet kasir kedua.
- Multi-outlet.
- Payment gateway.
- Integrasi akuntansi.

## Aturan Evolusi

- Jangan mengubah makna order final.
- Jangan menghapus stock ledger.
- Pertahankan recipe version.
- Tambahkan fitur melalui event atau movement baru.
- Dashboard boleh berubah tanpa mengubah alur transaksi kasir.
- Upgrade hardware dilakukan ketika antrean menjadi bottleneck, bukan dengan menambah kompleksitas MVP.
