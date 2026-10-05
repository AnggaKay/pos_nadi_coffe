# Nadi Coffee Owner Web

Separate Next.js application for owner monitoring, intended for desktop and mobile browsers. It shares the future cloud backend with `apps/cashier`, but deploys independently.

## Current stage

This folder is the Owner web project scaffold. It uses clearly labeled demo data and has no live authentication or Supabase connection. Follow `../../docs/flows/owner-monitoring-flow.md` for the product flow. Never put a Supabase service-role key in browser code.

## Run locally

```powershell
npm install
npm run dev
```

Open `http://localhost:3000`.

## Project layout

```text
src/
├── app/          # Next.js routes and layouts
├── components/   # Shared UI and layout components
├── features/     # Feature-oriented Owner screens/data contracts
├── lib/          # Supabase clients, formatters, access helpers
├── services/     # Repositories and demo data
└── types/        # Shared frontend types
```

## Planned stack

- Next.js App Router and TypeScript.
- Tailwind CSS for styling.
- TanStack Query for server state when a live API is introduced.
- Supabase Auth/PostgreSQL with Row Level Security for the shared backend phase.
- Recharts for monitoring visualizations.
