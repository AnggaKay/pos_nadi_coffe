# Next Phases

The local cashier flow is the current source of truth. Cloud and dashboard work waits until local stock behavior is reliable.

## Phase 2: Inventory Foundation

1. Add ingredients and units.
2. Add recipe and immutable recipe versions.
3. Add opening stock and stock adjustment flows.
4. Connect paid order items to recipe-based ingredient consumption.
5. Add waste and refund reversal movements.
6. Add stock balance queries and low-stock thresholds.
7. Add inventory tests around every ledger movement.

## Phase 3: Cashier Operations

1. Add order number and shift/session.
2. Add active order history.
3. Add void and refund with permission checks.
4. Add audit log for sensitive actions.
5. Add receipt formatter and printer preview.
6. Integrate the confirmed printer hardware.

## Phase 4: Sync Preparation

1. Finalize local sync payloads.
2. Add device ID and schema version to local records.
3. Add retry metadata and idempotency tests.
4. Define Supabase tables and Row Level Security.
5. Upload completed orders and ledger events.
6. Verify offline-to-online recovery without duplicate records.

## Phase 5: Owner Monitoring

1. Add owner authentication.
2. Add sales overview.
3. Add order and payment detail.
4. Add stock, waste, and adjustment monitoring.
5. Add date filters and exports.
6. Add device sync health.

## Execution Rules

- Keep checkout local-first.
- Treat stock ledger as append-only.
- Preserve order and payment snapshots.
- Test each phase before starting the next.
- Delay multi-device conflict handling until one-device sync is proven.

## Current Queue

- Inventory tables: ingredients, recipes, recipe versions, units.
- Recipe-based stock consumption.
- Opening stock and adjustment UI.
- Order number and shift foundation.
- Printer formatter and tests: `docs/hardware/printer-plan.md`.
