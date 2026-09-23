# Printer Plan

Printer implementation stays hardware-agnostic until the printer model is confirmed.

## Required Device Details

- Brand and model.
- Bluetooth Classic, BLE, USB, or Wi-Fi.
- Paper width: 58 mm or 80 mm.
- Android pairing behavior.
- Whether the printer supports ESC/POS.

## Implementation Stages

1. Build a receipt domain model from the completed order snapshot.
2. Build an ESC/POS formatter with text, alignment, columns, totals, and cut command.
3. Add receipt snapshot tests using fixed orders.
4. Add print preview in the POS app.
5. Add local printer settings and test-print action.
6. Add connection discovery and pairing flow for the confirmed transport.
7. Print after payment without blocking transaction persistence.
8. Store print status and allow reprint.

## Safety Rules

- Save the transaction before attempting to print.
- Printer failure must not cancel or duplicate an order.
- Reprint must reuse the original receipt snapshot.
- Do not assume Bluetooth Classic and BLE use the same plugin or protocol.
- Do not add a printer dependency before the hardware transport is confirmed.

## Acceptance Criteria

- Receipt matches the order total and payment details.
- 58 mm and 80 mm layouts do not overflow.
- Missing printer does not block checkout.
- Failed print is visible and retryable.
- Successful print is recorded.
- Duplicate print does not create a duplicate order.

## Required Tests

- Formatter output for cash, QRIS, and debit.
- Long product names and multiple quantities.
- Discount or tax fields when introduced.
- 58 mm line-width wrapping.
- 80 mm line-width wrapping.
- Empty or unavailable printer.
- Connection timeout.
- Retry after failure.
- Reprint from a saved receipt snapshot.
