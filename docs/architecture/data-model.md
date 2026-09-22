# Data Model

## Entitas Utama

```text
Product
Category
Modifier
Ingredient
Unit
Recipe
RecipeItem
RecipeVersion

Order
OrderItem
Payment
Refund
Void

StockLedger
StockAdjustment
WasteRecord
StockCount

User
Device
Shift
AuditLog
SyncQueue
```

## Produk dan Resep

Produk jual mengacu pada resep bahan. Resep wajib memiliki versi agar transaksi lama tidak berubah ketika takaran diperbarui.

```text
Iced Latte
├── Biji kopi: 18 gram
├── Susu: 180 ml
├── Cup 16 oz: 1 pcs
└── Es batu: 150 gram
```

Modifier yang mengubah konsumsi harus memiliki efek resep. Contoh `Extra Shot` menambah konsumsi kopi.

## Order Snapshot

`OrderItem` menyimpan snapshot berikut:

- `product_name_snapshot`
- `price_snapshot`
- `quantity`
- `modifiers_snapshot`
- `note`
- `recipe_version`

Perubahan nama, harga, atau resep tidak boleh mengubah laporan transaksi lama.

## Stock Ledger

Setiap pergerakan stok minimal menyimpan:

```text
ingredient_id
quantity
unit
movement_type
reference_type
reference_id
reason
user_id
device_id
created_at
```

Jenis movement:

```text
OPENING
PURCHASE
SALE_CONSUMPTION
WASTE
ADJUSTMENT_IN
ADJUSTMENT_OUT
VOID_REVERSAL
REFUND_REVERSAL
STOCK_COUNT
```

Stok dihitung dari ledger:

```text
Stok saat ini = stok awal + inflow - outflow
```

## Order State

```text
DRAFT
→ UNPAID
→ PAID
→ SENT_TO_KITCHEN
→ PREPARING
→ READY
→ COMPLETED
```

State pembatalan:

```text
CANCELLED
VOIDED
REFUNDED
```

Order `PAID` atau setelahnya tidak boleh dihapus.

## Payment

Payment menyimpan nominal, metode, status, waktu, kasir, dan reference pembayaran jika ada.

Metode awal:

```text
CASH
QRIS
TRANSFER
CARD
OTHER
```

Nilai uang disimpan sebagai integer dalam satuan terkecil mata uang. Jangan memakai floating point.
