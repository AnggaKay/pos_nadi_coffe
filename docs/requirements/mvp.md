# MVP Requirements

## Tujuan MVP

Mendukung operasional counter-service dengan satu Huawei Pad dan satu printer thermal, serta menyediakan data yang cukup untuk monitoring owner tanpa mengubah fondasi kasir di masa depan.

## Status Saat Ini

UI kasir dan laporan lokal sudah cukup untuk preview dan uji alur utama. Untuk mempercepat penyelesaian rancangan produk, pengembangan berikutnya dimulai dari flow Owner Monitoring. Butir kasir yang belum siap operasional tetap dicatat sebagai backlog dan dikerjakan setelah rancangan Owner disepakati.

Dashboard Owner yang sedang dirancang adalah prototype UI. Angka contoh/demo tidak mewakili data outlet dan tidak berasal dari backend.

## Wajib Kasir

### Order

- Kategori dan produk.
- Menu populer.
- Modifier dasar.
- Keranjang.
- Catatan item.
- Nomor antrean.
- Status order.

### Pembayaran

- Cash.
- QRIS/manual confirmation.
- Transfer/manual confirmation.
- Print customer copy.
- Print kitchen ticket.

### Stok

- Ingredient dan unit.
- Konversi unit dasar.
- Recipe dan recipe version.
- Pengurangan otomatis setelah payment berhasil.
- Stock ledger.
- Barang masuk.
- Waste.
- Adjustment beralasan.
- Stock opname.
- Minimum stock.
- Status produk tersedia/habis.

### Kontrol

- PIN kasir.
- Shift sederhana.
- Void dengan alasan.
- Refund/reversal dengan otorisasi.
- Audit log.
- Offline operation.
- Sync queue.
- Export CSV sebagai fallback.

## Data yang Wajib Dikirim ke Cloud

- Order dan item.
- Payment.
- Void/refund.
- Stock movement.
- Waste.
- Stock adjustment.
- Stock count.
- Product availability.
- User dan device event.
- Sync health.

## Owner Monitoring Awal

Dashboard awal minimal menyediakan:

- Omzet hari ini.
- Jumlah transaksi.
- Produk terlaris.
- Penjualan berdasarkan metode pembayaran.
- Stok saat ini.
- Stok menipis/habis.
- Riwayat stock movement.
- Waste dan adjustment.
- Void/refund.
- Last sync dan pending sync.

## Non-Goals MVP

- Multi-outlet.
- Loyalty.
- Delivery.
- Table management.
- KDS khusus.
- Purchase order.
- Payment gateway.
- Akuntansi.
- Customer database.

## Acceptance Criteria Utama

1. Kasir dapat membuat order tanpa internet.
2. Pembayaran berhasil menghasilkan nomor antrean.
3. Printer mencetak customer copy dan kitchen ticket.
4. Payment menghasilkan stock movement sesuai recipe version.
5. Void/refund membuat reversal atau koreksi yang dapat diaudit.
6. Sync dapat diulang tanpa duplikasi.
7. Owner dapat melihat penjualan dan stok dari luar kafe.
8. Owner dapat melihat kapan data terakhir tersinkronisasi.

## Backlog Kasir Sebelum Operasional Penuh

Backlog ini bukan penghalang untuk memulai rancangan Owner. Prioritas dapat disesuaikan setelah prototype Owner ditinjau.

### P0 — Selesaikan sebelum penggunaan operasional

- [ ] Uji end-to-end di Huawei Pad dengan database persisten dan data outlet yang benar.
- [ ] Validasi alur stok: opening stock, restock, resep per versi, konsumsi penjualan, waste, adjustment, opname, dan reversal.
- [ ] Lengkapi otorisasi PIN/role untuk void, refund, dan tindakan sensitif.
- [ ] Uji pemulihan setelah aplikasi ditutup paksa, perangkat restart, dan penyimpanan penuh.
- [ ] Integrasikan dan uji printer thermal untuk customer receipt dan kitchen ticket; preview struk saja belum memenuhi kebutuhan cetak.
- [ ] Pastikan angka penjualan, HPP, laba kotor, pembayaran, dan rekonsiliasi shift konsisten dengan transaksi sumber.

### P1 — Dibutuhkan sebelum monitoring lintas perangkat

- [ ] Tetapkan identitas outlet, user, dan device yang stabil.
- [ ] Implementasikan sync queue, retry, idempotency, dan penanganan event gagal/konflik.
- [ ] Implementasikan autentikasi Owner dan backend/cloud, termasuk aturan akses data.
- [ ] Sinkronkan order, payment, void/refund, stock movement, shift, audit, dan status sync.
- [ ] Uji kondisi offline-ke-online agar data tidak hilang atau terduplikasi.
- [ ] Implementasikan export laporan sebagai fallback.

### P2 — Penyempurnaan setelah flow inti

- [ ] Perbaiki analitik rentang tanggal khusus dan ekspor berdasarkan filter.
- [ ] Tambahkan alert stok kritis dan notifikasi operasional.
- [ ] Evaluasi kebutuhan multi-device/outlet setelah alur satu perangkat terbukti stabil.
