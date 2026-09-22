# MVP Requirements

## Tujuan MVP

Mendukung operasional counter-service dengan satu Huawei Pad dan satu printer thermal, serta menyediakan data yang cukup untuk monitoring owner tanpa mengubah fondasi kasir di masa depan.

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
