# Next Phases

The local cashier flow remains the source of truth. To move the project forward quickly, Owner UI prototyping can proceed with clearly labeled demo data while cashier and backend gaps remain tracked. Do not present prototype values as live monitoring.

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

## Phase 5: Owner Monitoring Prototype — Start Now

1. Set up separate Next.js Owner web app at `apps/owner-web`.
2. Define dashboard hierarchy, navigation, and responsive layout.
3. Build overview with clearly labeled demo data.
4. Design sales trends, recent transactions, and transaction detail.
5. Design low-stock, waste, adjustment, void/refund, and stock ledger views.
6. Include loading, empty, stale, offline, and error states.
7. Review Owner flow before wiring cloud data.

Flow: `../flows/owner-monitoring-flow.md`.

## Phase 6: Owner Monitoring Integration

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

- Continue Owner prototype UI and review its navigation and monitoring priorities.
- Cashier operational backlog is tracked in `mvp.md`; it does not block Owner UI design.
- Before live monitoring: finish reliable inventory/order event data, printer/device verification as needed, then sync and authentication foundation.
