# Owner Monitoring Flow

## Tujuan

Owner dapat memahami kondisi outlet dengan cepat: performa penjualan, transaksi terbaru, stok yang perlu diperhatikan, dan apakah data kasir sudah tersinkronisasi. Flow ini menjadi acuan prototype UI sebelum backend monitoring tersedia.

## Status Prototype

- Dashboard Owner dimulai sebagai rancangan UI menggunakan data demo yang diberi label jelas.
- Prototype tidak memerlukan login sungguhan dan tidak menampilkan data operasional aktual.
- Autentikasi, cloud API, sync, dan izin akses dikerjakan pada fase integrasi berikutnya.

## Navigasi Utama

```text
Login Owner (fase integrasi)
→ Dashboard
  → Ringkasan penjualan
  → Aktivitas/transaksi
  → Stok dan peringatan
  → Kesehatan sinkronisasi
→ Detail transaksi
→ Detail bahan / riwayat pergerakan stok
```

Untuk prototype, layar login boleh dilewati agar review rancangan lebih cepat. Jangan meminta kredensial yang tampak sungguhan atau menyimpan password demo.

## Dashboard

### Header dan filter

- Sapaan dan konteks outlet.
- Status data: Demo, terakhir diperbarui, atau status sinkronisasi.
- Filter periode: hari ini, 7 hari, bulan ini, dan rentang khusus pada fase lanjutan.
- Semua kartu dan grafik mengikuti periode yang sama.

### Ringkasan bisnis

- Omzet penjualan bersih sesuai definisi laporan.
- Jumlah transaksi lunas.
- Rata-rata nilai transaksi.
- Laba kotor tercatat/HPP jika data resep tersedia; tampilkan sebagai belum tersedia bila tidak lengkap.
- Perbandingan periode hanya tampil jika periode pembanding dan datanya valid.

### Tren dan aktivitas

- Tren omzet sepanjang periode terpilih.
- Metode pembayaran.
- Produk terlaris.
- Daftar transaksi terbaru yang membuka detail.

### Operasional

- Bahan stok menipis atau habis berdasarkan minimum stock.
- Waste, adjustment, void, dan refund terbaru dengan alasan/waktu.
- Shift berjalan/terakhir ditutup jika informasinya tersedia.

### Kesehatan data

- Status device kasir.
- Waktu sync terakhir yang berhasil.
- Jumlah event pending dan gagal.
- Tindakan “Lihat detail” menuju penjelasan status, tanpa mengizinkan edit transaksi dari Owner Dashboard.

## Detail Transaksi

1. Owner memilih transaksi dari daftar atau ringkasan periode.
2. Tampilkan nomor order, waktu, status, item dan kuantitas, total, metode pembayaran, shift/kasir, dan status sync.
3. Void/refund ditampilkan sebagai event koreksi terpisah; transaksi final tidak dihapus.
4. Pada fase monitoring, detail bersifat read-only.

## Detail Stok

1. Owner membuka alert bahan menipis/habis atau memilih bahan.
2. Tampilkan saldo, satuan, batas minimum, dan waktu pembaruan data.
3. Tampilkan histori stock ledger: pembelian/restock, konsumsi, waste, adjustment, opname, dan reversal.
4. Bedakan stok terakhir tersinkronisasi dari stok real-time apabila device sedang offline.

## Empty, Error, dan Stale States

- Belum ada transaksi pada periode: tampilkan empty state dan saran memilih periode lain.
- Stok atau HPP tidak lengkap: jangan mengarang nilai; beri label data belum tersedia.
- Sync tertunda/gagal: pertahankan data tersinkronisasi terakhir dan tampilkan waktu serta jumlah antrean.
- Data lama: tampilkan timestamp yang terlihat dan status stale.
- Gagal memuat dashboard: tampilkan pesan dan tombol coba lagi tanpa menyamarkan kegagalan sebagai nilai nol.

## Aturan Data dan Akses

- Dashboard hanya membaca data yang sudah diterima backend dan sesuai hak akses Owner.
- Semua angka mengikuti zona waktu outlet dan definisi laporan yang konsisten dengan POS.
- Data transaksi historis mempertahankan snapshot saat checkout.
- Demo seed, estimasi, dan data aktual harus dapat dibedakan secara visual.
- Export dan filter rentang khusus menjadi pengembangan lanjutan setelah sumber data cloud stabil.

## Kriteria Review Prototype

- Owner memahami status dan periode data tanpa bantuan.
- Prioritas terlihat: omzet, transaksi, stok kritis, dan sync.
- Detail dapat dibuka dari daftar transaksi dan alert stok.
- Demo/stale/error states tidak membuat data tampak sebagai angka aktual.
- Tampilan tetap terbaca pada desktop dan tablet landscape.
