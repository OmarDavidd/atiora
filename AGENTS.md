# AGENTS GUIDE

Atiora: Flutter/Supabase reading tracker app. On current branch `dev`.

## Commands

```bash
flutter pub get          # Install deps
dart format lib test    # Format code
flutter analyze        # Lint + typecheck
flutter test           # Full suite
flutter test path/to/file.dart --plain-name "TestName"  # Single test
```

**Always run `flutter analyze && flutter test`** before push/PR.

## Repo Layout

```
lib/
  main.dart              - Entry point (theme, router, BlocProviders)
  core/                  - Theme, navigation, DI, storage, utils
  data/models/           - Equatable models (BookModel, NoteModel, UserModel)
  data/datasources/      - Remote (Supabase), local (Hive)
  data/repositories/     - Repository implementations
  features/              - auth, books, dashboards, library, profile
test/                    - blocs/, repositories/, models/
```

## Important Conventions

- **Imports order**: Dart SDK → third-party → `package:atiora/...` → relative
- **UI text**: Spanish only (localized friendly messages)
- **Comments**: English (logic clarification)
- **Exceptions**: Use `AppException` + `ErrorHandler.map()`, never expose raw messages
- **State**: `emit(state.copyWith(...))`, never mutate directly
- **Null safety**: Explicit return types, avoid `late`, use `final` for immutables

## Data & Caching

- Remote: Supabase via client `Supabase.instance.client`. Always scope `.eq('user_id', currentUser.id)`
- Local: Hive with AES encryption (key in FlutterSecureStorage)
- Strategy: update local cache first, sync remote when online
- Return consistent format from both sources

## DI & State

- GetIt: `sl` for singletons (datasources/repos), factories (blocs/cubits)
- Blocs: `bloc_concurrency` with `restartable` (actions), `droppable` (stats)
- Cubits: ThemeCubit only; theme via SharedPreferences

## Testing

- Use `bloc_test`, seed with `seed: () => ...`
- Repository tests: mocktail for datasources
- Tests adjacent to implementation
- Test error paths, not just success

## Git

- Branch: `dev` (main work), feature branches off `main`
- Commits: `<type>(<scope>): imperative` (feat, fix, chore, refactor, test)
- Never commit `.env` or secrets
- Run `flutter analyze` after merge to main

## Key Files

- Config: `pubspec.yaml` (SDK `^3.10.7`, dependencies)
- Entry: `lib/main.dart` (calls `init()` then `runApp`)
- DI: `lib/core/di/injection_container.dart`
- Theme: `lib/core/theme/app_theme.dart` (Material 3 + AppColors)
- Storage: `lib/core/storage/hive_service.dart` (AES encryption)

## Known Work

- AES encryption for Hive complete (merged to dev)

---

Keep UX intentional; prefer clarity over cleverness. Stay deliberate.