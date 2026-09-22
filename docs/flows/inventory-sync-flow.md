# Inventory and Sync Flow

## Pengurangan Stok dari Penjualan

```text
Payment berhasil
→ Ambil recipe version
→ Hitung konsumsi setiap ingredient
→ Tulis StockLedger lokal
→ Perbarui tampilan stok
→ Tandai event untuk sinkronisasi
```

Contoh:

```text
Iced Latte dibayar
→ Kopi -18 gram
→ Susu -180 ml
→ Cup -1 pcs
```

## Kejadian Stok Manual

Kasir dengan izin dapat mencatat:

- Barang masuk.
- Waste.
- Stok opname.
- Adjustment dengan alasan.

Contoh alasan waste:

```text
EXPIRED
DAMAGED
SPILLAGE
WRONG_PREPARATION
REMAKE
OTHER
```

Tidak ada perubahan stok tanpa movement dan alasan.

## Produk Habis

Jika bahan wajib mencapai nol atau di bawah batas aman:

```text
Ingredient habis
→ Produk terkait menjadi unavailable
→ Produk tidak dapat dipilih kasir
→ Event availability dicatat
```

Produk dapat diaktifkan kembali setelah stok diperbarui.

## Offline Sync

```text
Transaksi dibuat di SQLite
→ SyncQueue status PENDING
→ Internet tersedia
→ Kirim batch ke cloud
→ Server validasi idempotency key
→ Server mengembalikan ACK
→ Lokal menandai SYNCED
```

Setiap event wajib memiliki:

```text
local_id
idempotency_key
sync_status
created_at
synced_at
```

Status sync:

```text
PENDING
SYNCED
FAILED
CONFLICT
```

Order, payment, dan stock movement dari satu transaksi dikirim sebagai satu paket logis. Retry tidak boleh membuat order atau movement ganda.

## Monitoring Kesehatan Sync

POS dan dashboard menampilkan:

- Waktu sync terakhir.
- Jumlah event pending.
- Jumlah sync gagal.
- Waktu perangkat terakhir online.
- Versi aplikasi dan device ID.
