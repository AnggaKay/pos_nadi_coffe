# Order Flow

## Flow Utama

```text
Customer memesan
→ Kasir memilih menu
→ Kasir memilih modifier
→ Kasir mengonfirmasi item dan total
→ Customer membayar
→ POS menyimpan order sebagai PAID
→ Stok dikurangi dari resep
→ Nomor antrean dibuat
→ Printer mencetak customer copy dan kitchen ticket
→ Kitchen menyiapkan pesanan
→ Nomor dipanggil
→ Customer mengambil pesanan
→ Order COMPLETED
```

## Layar Kasir

- Kategori dan menu populer selalu terlihat.
- Satu tap menambah produk.
- Modifier menggunakan pilihan terbatas.
- Keranjang dan total selalu terlihat.
- Tombol `Bayar` selalu tersedia.
- Tidak perlu input nama customer pada MVP.

## Printer Tunggal

Satu pekerjaan cetak menghasilkan dua bagian:

```text
SALINAN CUSTOMER
- Nomor antrean
- Daftar item
- Total

TIKET KITCHEN
- Nomor antrean
- Daftar item
- Modifier dan catatan
```

Kasir memberikan customer copy kepada customer dan menyerahkan kitchen ticket ke kitchen.

## Pembayaran

Kitchen hanya menerima order setelah pembayaran berhasil. Jika pembayaran gagal, order tetap `UNPAID` dan tidak mengurangi stok.

Setelah `PAID`:

1. Buat payment.
2. Buat stock movement berdasarkan recipe version.
3. Buat nomor antrean.
4. Masukkan print job ke printer queue.
5. Masukkan event ke sync queue.

## Void dan Refund

### Sebelum bayar

Order dapat dibatalkan tanpa perubahan stok.

### Setelah bayar

Gunakan void atau refund dengan alasan. Jangan menghapus order. Buat reversal stock movement jika bahan belum atau tidak jadi digunakan.

## Order Siap

Kitchen menandai tiket secara fisik atau memberi informasi kepada kasir. Kasir memanggil nomor antrean. Saat pesanan diserahkan, kasir menandai `COMPLETED`.

Nomor antrean wajib ditulis pada cup atau kemasan untuk mencegah pesanan tertukar.
