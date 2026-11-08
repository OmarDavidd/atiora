# AGENTS GUIDE

Atiora: Flutter/Supabase reading tracker app. Working branch: `dev`.

## Commands

```bash
flutter pub get          # Install deps
dart format lib test     # Format code
flutter analyze          # Lint + typecheck
flutter test             # Full suite
flutter test path/to/file.dart --plain-name "TestName"  # Single test
```

**Always run `flutter analyze && flutter test` before push/PR.**

## Repo Layout

```
lib/
  main.dart              - Entry point (loads .env, calls init(), runApp)
  core/                  - Theme, navigation, DI, storage, utils, errors
  data/models/           - Shared Equatable models (BookModel, NoteModel, UserModel, ProfileModel)
  features/              - auth, books, dashboards, library, notes, profile, stats
    auth|books|dashboards|notes  -> data/domain/presentation clean arch
    library|profile|stats        -> presentation only
test/                    - Mirrors lib/ (blocs/, repositories/, models/, features/, utils/)
```

## Conventions

- **UI text**: Spanish only (localized friendly messages)
- **Comments**: English (logic clarification)
- **Exceptions**: Use `AppException` + `ErrorHandler.map()`, never expose raw messages
- **State**: `emit(state.copyWith(...))` for models, never mutate directly
- **Null safety**: Explicit return types, avoid `late`, use `final` for immutables

## Data & Caching

- Remote: Supabase via `Supabase.instance.client`. Always scope `.eq('user_id', currentUser.id)`.
- Local: Hive with AES encryption (key in FlutterSecureStorage)
- Strategy: update local cache first, sync remote when online
- Return consistent format from both sources

## DI & State

- GetIt: `sl` for singletons (datasources/repos), factories (blocs/cubits)
- Blocs: `bloc_concurrency` with `restartable` (actions), `droppable` (stats/loaders)
- Cubits: ThemeCubit only; theme persisted via SharedPreferences

## Testing

- Use `bloc_test`, seed with `seed: () => ...`
- Repository tests: mocktail for datasources
- Tests live in `test/` mirroring `lib/`
- Test error paths, not just success

## Git

- Branch: `dev` (main work), feature branches off `main`
- Commits: `<type>(<scope>): imperative` (feat, fix, chore, refactor, test)
- Never commit `.env` or secrets (`.env` is gitignored)
- `.gitignore` also ignores `README.md`, `AGENTS.md`, `CHANGELOG.md`, but these files are tracked, so changes still appear in `git status`
- Run `flutter analyze` after merge to main

## Key Files

- Config: `pubspec.yaml` (SDK `^3.10.7`, dependencies)
- Entry: `lib/main.dart` (calls `init()` then `runApp`)
- DI: `lib/core/di/injection_container.dart`
- Theme: `lib/core/theme/app_theme.dart` (Material 3 + AppColors)
- Storage: `lib/core/storage/hive_service.dart` (AES encryption)

## Quirks & Gotchas

- `.env.example` does not exist despite README saying `cp .env.example .env`. Required vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- `build_runner` is in `dependencies` (should be `dev_dependencies`). No generated code or `build.yaml` exists; it appears unused.
- No CI workflows exist for this project.

---
Keep UX intentional; prefer clarity over cleverness. Stay deliberate.
