# Cashier Test Setup

## Database

Android/native uses a persistent SQLite file managed by `path_provider`:

```text
nadi_coffee.sqlite
```

The app creates and migrates the database automatically. No manual SQLite setup is required.

Schema migrations currently run through version 6 and create:

- Catalog: categories, products.
- Sales: orders, order_items, payments.
- Inventory: units, ingredients, recipe_versions, recipe_items, stock_ledger.
- Operations: shifts, audit_logs, sync_queue.

The first native launch seeds demo catalog, demo recipes, and opening stock. Do not treat seed values as real cafe stock.

Chrome is preview-only and uses memory catalog data. It does not represent the production database.

## Cashier Test Flow

1. Launch the Android app.
2. Open `Pengaturan`.
3. Open a shift with cashier name and opening cash.
4. Go to `Kasir`.
5. Add one or more menu items.
6. Test `Tunai`: enter received cash, confirm change.
7. Test `QRIS`: customer scans the static QRIS at the front table.
8. Verify merchant name and exact amount on the payment evidence.
9. Press `Pembayaran terverifikasi` only after checking the evidence.
10. Open `Pesanan` and verify the order appears as paid.
11. Open `Stok` and verify recipe ingredients decreased.
12. Open `Pengaturan`, enter physical cash, and close the shift.

## Static QRIS Disclaimer

The POS cannot verify static QRIS payment automatically. The cashier is responsible for checking:

- Merchant name.
- Exact transaction amount.
- Successful payment status.
- Payment timestamp when relevant.

The `Pembayaran terverifikasi` button is a manual cashier confirmation. Do not press it based only on the customer screenshot if the merchant account has not received or shown the payment.

## Reset Test Data

For a clean Android test, clear the app storage from Android settings. This deletes the local SQLite database and recreates seeded demo data on the next launch. Do this only on a test device; it deletes local transactions not yet synced.

## Expected Result

```text
Order saved locally
Payment recorded
Recipe stock deducted
HPP/profit snapshot saved
Sync queue entry created
Order visible in Pesanan
Shift cash total updated for cash payments only
```
