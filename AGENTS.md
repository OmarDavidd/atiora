# AGENTS GUIDE
Onboarding contract for autonomous coding agents in `/home/davo/dev/notium`. Flutter/Supabase app named **Atiora**.

## 1. Toolchain & Commands
- **Flutter 3.24+ / Dart 3.4+** (SDK `^3.10.7`)
- `flutter pub get` – install dependencies
- `dart format lib test` – format code
- `flutter analyze` – validate lints
- `flutter test` – full suite
- `flutter test path/to/file.dart` – single file
- `flutter test path/to/file.dart --plain-name "Name"` – single test (case-sensitive)
- `flutter test --coverage --reporter expanded` – coverage
- **Always run `flutter analyze && flutter test`** before push/PR

## 2. Repo Layout
```
lib/
  main.dart              - Entry point, theme, router, BlocProviders
  core/                  - Theme, navigation, DI, storage, utils, constants
  data/models/           - Equatable models (BookModel, NoteModel, ProfileModel, UserModel)
  data/datasources/      - Remote (Supabase) and local (Hive) data sources
  data/repositories/     - Repository implementations wrapping datasources
  features/              - auth, books, dashboards, library, profile (each with blocs/pages/widgets)
test/
  blocs/, repositories/, models/, utils/
```

## 3. Dependency Injection (get_it)
- `sl` (GetIt.instance) initialized in `init()` before `runApp`
- Lazy singletons for datasources/repositories
- Factories for blocs/cubits
- UI: `BlocProvider.value(value: sl<BooksBloc>())` or `BlocProvider(create: (_) => sl<BooksBloc>()..add(LoadBooks()))`

## 4. State Management
- **Blocs** use `bloc_concurrency`: `restartable` for book actions, `droppable` for stats
- Pattern: `abstract class FooEvent {}` + `FooState extends Equatable`
- Events/states in separate files
- **Cubits**: `ThemeCubit` only; theme stored via SharedPreferences
- Use `emit(state.copyWith(...))` for state updates; never mutate state directly

## 5. Data Sources & Caching
- Remote: Supabase RPC/table queries via `BooksRemoteDataSource`
- Local: Hive boxes managed by `HiveService` (stores JSON maps, not adapters)
- Strategy: update local cache first, sync remote when `_isOnline()`
- On sync, remote replaces local cache entirely
- Return data in consistent format from both sources

## 6. Error Handling
- Use `AppException` as sole custom exception type
- Map errors via `ErrorHandler.map()` before UI display
- `ErrorHandler.handleAuthError` for auth-specific messages
- Wrap Supabase/Hive in try/catch; rethrow when higher layers need to react
- UI errors in **Spanish** (friendly, localized)
- Never expose raw exception messages to users

## 7. Async UI States
- Every async-dependent UI shows: `Loading`, `Loaded`, `Error`
- Use `CircularProgressIndicator` for blocking loads
- Retry via bloc events (no manual `setState`)
- `SizedBox.shrink()` as clean fallback
- Consider ` BlocBuilder` with distinct state widgets

## 8. Networking & APIs
- Supabase client: `Supabase.instance.client`
- Always scope queries to user via `.eq('user_id', currentUser.id)`
- RPC results vary (int/list/map) – normalize before returning
- Handle offline scenarios gracefully with cached data

## 9. Testing
- Use `bloc_test`; seed states with `seed: () => ...`
- Repository tests: mocktail for local/remote datasources
- Place tests adjacent to implementation
- Assertions: `verify(() => mock.method()).called(1)`
- Test error paths, not just success paths

## 10. Code Style

### Imports (in order, blank line between groups)
1. Dart SDK (`dart:ui`, `dart:async`, etc.)
2. Third-party packages (`package:flutter_bloc/...`, `package:equatable/...`)
3. `package:atiora/...`
4. Relative paths (`../widgets/...`, `./bloc/...`)

### Naming Conventions
- **Classes/Widgets**: `PascalCase` (e.g., `BookCard`, `HomeScreen`)
- **Methods/Variables**: `camelCase` (e.g., `loadBooks()`, `isLoading`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_BOOKS`, `API_BASE_URL`)
- **Files**: `snake_case.dart` (e.g., `book_repository.dart`)
- **BLoC classes**: `XxxBloc`, `XxxEvent`, `XxxState`

### Types & Null Safety
- No `var` for public members; explicit return types required
- Use `?` for nullable types, `required` for mandatory params
- Avoid `late` (only when 100% controlled by initialization flow)
- Prefer `final` over `var` for immutable variables

### Const & Dynamic
- Prefer `const` constructors/widgets where possible
- Only use `dynamic` for Supabase/Hive raw data; coerce immediately to concrete types

### Formatting & Style
- Use `dart format` only; never hand-align code
- Max line length: 80 characters (soft limit)
- Extract stateless widgets if widget exceeds ~100 lines

### UI & Copy
- UI text in **Spanish**
- Comments in English for logic clarification
- Use `Theme.of(context).textTheme` for typography

### Widget Guidelines
- Keep widgets under ~100 lines
- Extract sub-widgets to separate files
- Prefer stateless widgets where state isn't needed

## 11. UI & Theming
- `AppTheme.getTheme` with Material 3 and `AppColors` palette
- `GoogleFonts` via theme definitions only
- Standard padding: `EdgeInsets.symmetric(horizontal: 30)`
- Card radius: 16
- Typography from `Theme.of(context).textTheme`
- Custom layouts preferred over generic Material scaffolds

## 12. Git Workflow
- Commits: `<type>(<scope>): imperative description` (feat, fix, chore, refactor, docs, test)
- Keep messages under 72 chars
- Never commit `.env` or secrets
- Branch naming: `feature/xxx`, `fix/xxx`, `chore/xxx`

## 13. General Rules
- Keep `debugPrint` volume low; remove PII/secrets before merge
- Avoid `part` files; prefer directory splits
- Document Supabase schema assumptions in code comments
- Extensions/helpers: `lib/core/utils/`
- Immutable models via `copyWith`
- Optimistic updates: failing remote triggers reload

## 14. Extending Features
- Follow domain-driven split: data/datasources → data/repositories → features/xxx
- New blocs need event/state files, tests, DI registration
- Custom layouts (avoid generic Material scaffolds)
- Update this file when conventions change

Stay deliberate, keep UX intentional, prefer clarity over cleverness.