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

Detailed execution order: `next-phases.md`.

## Fase 3: Prototype Owner Monitoring

Mulai sekarang untuk mempercepat rancangan produk; fase ini adalah UI prototype, bukan integrasi data aktual.

- Owner overview web di `apps/owner-web` dengan data demo berlabel.
- Rancangan tren penjualan dan transaksi terbaru.
- Rancangan stok kritis dan histori aktivitas operasional.
- Rancangan status device/sync beserta empty, error, dan stale states.
- Validasi flow dan hierarki informasi sebelum backend.

Flow acuan: `../flows/owner-monitoring-flow.md`. Flutter Owner preview tidak menjadi target produk; Owner adalah aplikasi web terpisah.

## Fase 4: Cloud dan Sync

- Supabase PostgreSQL.
- Authentication owner.
- Sync endpoint.
- Sync queue dan retry.
- Idempotency.
- Audit log.
- Device health.
- Backup.

## Fase 5: Owner Dashboard Terhubung

- Login owner.
- Sales overview.
- Detail transaksi.
- Monitoring stok.
- Produk habis.
- Waste dan adjustment.
- Filter tanggal.
- Export laporan.

## Fase 6: Pengembangan Bertahap

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
