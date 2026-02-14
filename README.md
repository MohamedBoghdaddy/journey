# Masr Spaces — Egypt’s Neighborhood OS

Masr Spaces is a mobile-first community platform built for real Egyptian daily life: local spaces, trusted conversations, and practical utilities that layer into transactions over time.

The product starts with **Spaces + posts + chat** to drive real usage, then expands into **marketplace, trust & moderation, and AI utilities**. It is designed to scale from a university/area pilot to millions of users with strong governance, safety, and performance.

---

## What this repo contains

This repository contains the **Masr Spaces Flutter app** and supporting backend components. Data, auth, realtime, storage, and security are powered by **Supabase (Postgres + RLS + Realtime + Storage + RPC)**.

---

## Product vision

**Community → Trust → Utilities → Transactions**

- **Community**: neighborhood-based Spaces and feeds  
- **Trust**: reputation, roles, moderation, reports, bans, mutes, blocks  
- **Utilities**: AI-assisted features and local tools  
- **Transactions**: marketplace listings, buyer–seller chat, orders, disputes, reviews  

---

## Core features (current + planned-ready architecture)

### 1) Identity & roles
- Email/password authentication via Supabase Auth
- Profile system (display name, avatar, neighborhood linkage)
- Platform roles: user, moderator, admin, superadmin
- Space roles: owner, moderator, member

### 2) Spaces & community
- Spaces with visibility options (public/private/invite-only)
- Space membership management
- Templates for structured posting inside spaces

### 3) Content system
- Posts, comments, likes, saves, votes
- Counters maintained via triggers for fast feeds and trending
- Soft delete support for moderation workflows

### 4) Universal chat
Single chat system supports three conversation types:
- **DM chat** (user ↔ user)
- **Space chat** (group chat tied to a Space)
- **Product chat** (buyer ↔ seller tied to a listing)

Includes:
- Conversation inbox views
- Last message tracking
- Message media support (optional)

### 5) Inbox + unread tracking
- `conversation_members.last_read_at`
- `v_inbox_unread` view adds `unread_count`
- `v_inbox_display` view provides display-ready title/subtitle/avatar for UI
- RPC: `mark_conversation_read(conversation_id)`

### 6) Marketplace
- Products + product images
- Product deactivation (owner or admin)
- Buyer–seller chat per listing

### 7) Orders + disputes + reviews
- Orders with status transitions
- Order items snapshotting product details at purchase time
- Dispute workflow (open → reviewing → resolved/rejected)
- Reviews per order with reputation impact
- Seller rating view with weighted rating

### 8) Trust, safety & moderation
- Reports queue (admin triage + action)
- Global bans (hard deny writes via triggers)
- Space bans & mutes
- User blocks (DM safety)
- Conversation mutes
- Admin/mod RPC endpoints for enforcement

### 9) Reputation v2
- Reputation ledger (`reputation_events`)
- Daily caps per event type
- Level calculation logic
- Monthly decay mechanism
- Penalties tied to moderation and transaction disputes

### 10) Trending feed
- Materialized view `mv_trending_posts_24h`
- Refresh function `refresh_trending_24h()`
- Designed to be scheduled via cron

---

## Tech stack

### Mobile
- Flutter (mobile-first)
- Supabase Flutter SDK
- MVVM-friendly structure (screens/models/services)

### Backend & data
- Supabase Postgres (tables, views, triggers, functions)
- Row Level Security (RLS) for access control
- RPC functions (security definer) for atomic operations
- Supabase Storage for media (product images bucket)

Optional backend components can exist for custom APIs, but the primary logic is intentionally designed to live in **Postgres + RLS + RPC** for consistency, scalability, and security.

---

## Repository structure

```
journey/
├── lib/
│   ├── main.dart
│   ├── app.dart
│
│   ├── bootstrap/
│   │   ├── env.dart
│   │   ├── supabase_bootstrap.dart
│   │   └── dependencies.dart
│
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── routes.dart
│   │   │   ├── theme.dart
│   │   │   └── constants.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── failure.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── debounce.dart
│   │   │   ├── logger.dart
│   │   │   └── uuid.dart
│   │   ├── widgets/
│   │   │   ├── app_scaffold.dart
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── loading.dart
│   │   │   ├── error_view.dart
│   │   │   └── avatar.dart
│   │   └── navigation/
│   │       ├── app_router.dart
│   │       └── route_guards.dart
│
│   ├── shared/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── paged_result.dart
│   │   │   │   └── media_asset.dart
│   │   │   ├── mappers/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   │       ├── storage_service.dart
│   │   │       └── realtime_service.dart
│   │   └── presentation/
│   │       ├── state/
│   │       └── widgets/
│
│   ├── features/
│   │
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_profile_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── auth_repository.dart
│   │   │   │   │   └── profile_repository.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── auth_remote_ds.dart
│   │   │   │       └── profile_remote_ds.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_profile.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in.dart
│   │   │   │       ├── sign_up.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       ├── get_me.dart
│   │   │   │       └── update_profile.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── register_page.dart
│   │   │       │   └── auth_gate.dart
│   │   │       ├── widgets/
│   │   │       │   ├── login_form.dart
│   │   │       │   └── register_form.dart
│   │   │       └── state/
│   │   │           ├── auth_controller.dart
│   │   │           └── auth_state.dart
│   │
│   │   ├── spaces/
│   │   ├── posts/
│   │   ├── social/
│   │   ├── chat/
│   │   ├── marketplace/
│   │   └── trust/
│   │       (each feature follows the same clean architecture pattern:
│   │        data/ → domain/ → presentation/)
│
│   ├── ui/
│   │   ├── shell/
│   │   │   ├── main_shell.dart
│   │   │   ├── bottom_nav.dart
│   │   │   └── app_drawer.dart
│   │   └── screens/
│   │       └── home_page.dart
│
│   └── l10n/
│       ├── app_ar.arb
│       └── app_en.arb
│
├── pubspec.yaml
├── analysis_options.yaml
└── android/ ios/ web/ macos/ windows/ linux/

```

---

## Setup

### 1) Supabase project
1. Create a Supabase project
2. Copy:
   - Project URL
   - Anon public key

### 2) Database schema
Run the unified SQL script in:
- Supabase Dashboard → **SQL Editor** → paste → **Run**

This script creates:
- tables, enums, policies, triggers
- views for inbox + admin queues
- RPC functions (join space, open dm, product chat, orders, disputes, etc.)
- trending materialized view

### 3) Storage bucket
Create this bucket:
- `product-images`

Expected upload path format:
- `products/<user_id>/<file>`

Your storage policies depend on this folder structure.

### 4) Flutter env
Create a `.env` file at the project root:

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

Install deps and run:

```bash
flutter pub get
flutter run
```

---

## Operational notes (important)

### Trending refresh
`refresh_trending_24h()` uses a materialized view. For concurrent refresh you must have a unique index:

```sql
create unique index if not exists uq_mv_trending_post_id
on public.mv_trending_posts_24h (post_id);
```

Then schedule:

```sql
select public.refresh_trending_24h();
```

### Reputation decay
`apply_reputation_decay(user_id)` should run after login (once per app launch or periodically).

---

## Security model (high level)

- **RLS is the default gate** on every table.
- Clients are allowed to read/write only what policies permit.
- Sensitive actions are done via **RPC (security definer)**:
  - join space
  - open dm
  - open product chat
  - mark read
  - create orders / disputes / reviews
  - moderation actions
- Global ban triggers enforce hard-deny on writes across the platform.

---

## Roadmap (execution order)

1) **Spaces + feed + posting + chat inbox**  
2) **Moderation & trust** (reports, mutes, bans, blocks, reputation)  
3) **Marketplace** (listings + product chat)  
4) **Orders + disputes + reviews**  
5) **AI utilities layer** (RAG/assistants inside spaces and tools)  

---

## Contributing

This is a startup-grade codebase focused on shipping fast with strong security boundaries.
If you contribute:
- keep changes small and reviewable
- preserve RLS-first design
- prefer RPC for multi-step operations
- add migrations / SQL updates with idempotency

---

## License

MIT License

© 2026 Masr Spaces
