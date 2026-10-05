# Shared Backend (Planned)

This folder is reserved for the Supabase backend shared by `apps/cashier` and `apps/owner-web`.

Planned contents:

```text
supabase/
├── migrations/       # Versioned PostgreSQL schema and RLS policies
└── functions/        # Server-side sync and operational endpoints
```

No live backend is configured yet. Do not add service-role secrets to client apps. Establish outlet-scoped ownership, stable device identity, append-only operational events, idempotent sync, and RLS before connecting production data.
