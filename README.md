# Masr Spaces — Mother Company App

This repository contains the code for **Masr Spaces**, a community platform designed to support neighbourhoods and businesses. The project is split into a **Flutter mobile app** and a **Dart backend**. Together they provide forums (similar to Reddit), groups, spaces, chat, user management and moderation features. Authentication and data storage are handled via [Supabase](https://supabase.com/).

## Project structure

```
journey/
├── lib/              # Flutter source code (screens, models, services)
├── analysis_options.yaml  # Lint configuration
├── pubspec.yaml      # Flutter dependencies and build configuration
├── packages/backend/ # Dart backend package
│   ├── bin/          # Entry point for the backend API server
│   ├── lib/handlers/ # Endpoint handlers (auth, posts, groups, spaces)
│   ├── lib/models/   # Backend data models
│   ├── lib/services/ # Supabase client wrapper
│   └── pubspec.yaml  # Backend dependencies
└── ... other platform directories (android, ios, linux, macos, windows, web)
```

## Features

### Authentication

- Email/password login and registration via Supabase.
- Distinct roles for **super admin** and **normal user**. Admins have elevated privileges to moderate content and manage users.
- Secure session management with logout support.

### Community & Content

- **Forums**: Users can create posts similar to Reddit threads, comment on posts and vote. Moderators can pin or delete posts.
- **Groups**: Organise people around a topic or location; group owners can manage membership.
- **Spaces**: Micro‑communities for neighbourhoods or businesses, with custom threads and events.
- **Chat**: Real‑time messaging between users and within groups/spaces (placeholder service included).

### CRUD operations

Every resource (users, posts, comments, groups, spaces) includes Create, Read, Update and Delete operations via the backend API. Data is persisted in Supabase tables, and role‑based access control ensures only authorised actions are allowed.

### Backend API

The backend is built with the `shelf` and `shelf_router` packages. It exposes REST endpoints under `/auth`, `/posts`, `/groups` and `/spaces`. Each handler validates requests, interacts with Supabase and returns JSON responses.

## Getting started

1. Install Flutter (≥3.0) and the Dart SDK.
2. Run the Flutter app:

   ```bash
   flutter pub get
   flutter run
   ```

3. For the backend, navigate to `packages/backend` and run:

   ```bash
   dart pub get
   dart run bin/server.dart
   ```

4. Create a project in Supabase and update the Supabase URL and anon key in `lib/services/supabase_service.dart` (Flutter client) and `packages/backend/lib/services/supabase_client.dart` (backend).

## Contributing

Feel free to fork the repository and open pull requests. Contributions of bug fixes, enhancements and new features are welcome. Before submitting a PR, please ensure that your code follows the existing style and includes tests where appropriate.

---

© 2026 Masr Spaces. Licensed under the MIT License.
