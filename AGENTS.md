# AGENTS GUIDE
This document is the onboarding contract for autonomous coding agents working inside `/home/davo/dev/notium`.
Keep it handy; it encodes the workflow, conventions, and safety rails for this Flutter/Supabase app.

## 0. Branding Snapshot
- Project name: **Atiora**.
- User-facing copy must refer to “Atiora” consistently (README, UI, bundle names, etc.).
- Supabase project keys live in `.env`; never share them.

## 1. Toolchain & Environment
- Primary stack: Flutter 3.24+/Dart 3.4+ (SDK constraint `^3.10.7`).
- Mobile targets: Android, iOS, macOS, Linux, Windows, Web; default focus is mobile.
- Package highlights: `flutter_bloc`, `get_it`, `supabase_flutter`, `hive`, `dio`, `carousel_slider`, `fl_chart`.
- Ensure `flutter` CLI is on PATH; run `flutter doctor` before large edits.
- Secrets live in `.env` (loaded via `flutter_dotenv`). Never commit or print these values.
- Run `flutter pub get` after editing `pubspec.yaml` or when dependencies drift.

## 2. Build, Lint, and Test Commands
- `flutter pub get` – instala dependencias.
- `dart format lib test` – aplica formato oficial.
- `flutter analyze` – valida lints (`flutter_lints`).
- `flutter test` – corre toda la suite.
- `flutter test path/to/file.dart` – test por archivo.
- `flutter test path/to/file.dart --plain-name "Nombre"` – test individual.
- `flutter test --coverage --reporter expanded` – cobertura detallada.
- No hay CI configurado: siempre corre `flutter analyze && flutter test` antes de push/PR.

## 3. Repo Layout Mental Map
- `lib/main.dart`: entry point, theme setup, router, top-level BlocProviders.
- `lib/core`: cross-cutting concerns (theme, navigation, DI, storage, utils, constants, colors, helpers, snackbars).
- `lib/data/models`: pure data objects built on `equatable` (`BookModel`, `NoteModel`, `ProfileModel`, `UserModel`).
- `lib/core/di`: `injection_container.dart` wires `get_it` and Supabase/Hive singletons.
- `lib/features`: split by domain (`auth`, `books`, `dashboards`). Each feature contains data, domain, and presentation layers when needed.
- `test/`: mirrors production structure; contains bloc, repository, model, and utility tests.
- Platform folders (`android`, `ios`, etc.) follow stock Flutter layout; avoid editing unless platform-specific work is required.

## 4. Dependency Injection & State Management
- Service locator `sl` (`GetIt.instance`) is initialized inside `init()` and awaited before `runApp`.
- Register lazy singletons for datasources/repositories, factories for blocs/cubits.
- In UI layers, prefer `BlocProvider.value(value: sl<BooksBloc>())` when reusing existing instances; otherwise `BlocProvider(create: (_) => sl<BooksBloc>()..add(LoadBooks()))`.
- Blocs favor `bloc_concurrency` transformers (`restartable` for book actions, `droppable` for stats) to avoid overlapping events; match the existing pattern when adding handlers.
- Cubits: only `ThemeCubit` currently; store theme mode via `SharedPreferences` helper in `AppTheme`.

## 5. Data Sources & Caching
- Remote reads routed through Supabase RPC/table queries (`BooksRemoteDataSource`).
- Local persistence via Hive boxes (books, notes, profiles) managed inside `HiveService`.
- Repository strategy: update local cache first, attempt remote sync when `_isOnline()` (now backed by `ConnectivityPlatform`). Register `MethodChannelConnectivity` in DI for runtime and inject simple stubs (see `_StubConnectivity` under `test/repositories/books_repository_test.dart`) to keep tests hermetic.
- When syncing, remote replaces local cache entirely; be cautious to avoid data loss if offline writes are planned.

## 6. Error Handling & Logging
- UI-friendly auth errors map through `ErrorHandler.handleAuthError`. Extend this helper for new code paths rather than sprinkling string checks.
- Wrap Supabase/Hive calls in `try/catch` and rethrow when higher layers must react; repository methods often swallow errors after logging—mirror that behavior unless user-facing failure is required.
- Avoid throwing raw `Exception` strings from UI-facing layers; convert to localized Spanish copy when surfaced to widgets.
- Usa `AppException` como único tipo custom y enruta los mensajes finales mediante `ErrorHandler.map` antes de mostrarlos en la UI.

## 7. Auth Flow Expectations
- `AuthBloc` handles sign-in/up/check events; relies on injected use cases and `AuthProvider` (Supabase wrapper).
- `CheckAuthEvent` runs on app boot to gate navigation inside `AuthWrapper`.
- When extending auth (password reset, MFA), add new use cases plus provider calls, wire them through DI, and keep tests in `test/blocs/auth_bloc_test.dart`.

## 8. Books Flow Expectations
- `BooksBloc` orchestrates list fetching and state updates (`LoadBooks`, `UpdateBookState`).
- Optimistic updates happen before hitting the repository; failing remote update triggers a reload (see `BooksBloc` for pattern).
- `BookModel` should stay immutable; extend via `copyWith` and keep new fields inside constructor and JSON adapters.
- Stats (`HomeStatsBloc`) rely on Supabase views and RPC (`get_current_streak`). Maintain the `HomeStatsData` struct for UI consumption.

## 9. UI & Theming Conventions
- Theming centralizes in `AppTheme.getTheme` with light/dark `ThemeData` definitions using Material 3 and `AppColors` palette.
- Use `GoogleFonts` only through theme definitions (see `DarkTheme`); widgets should pull typography from `Theme.of(context).textTheme`.
- Layout uses generous padding (`EdgeInsets.symmetric(horizontal: 30)`) and rounded cards (radius 16). Match these values for consistency.
- Widgets live under feature-specific `presentation/widgets`; keep them small and composable.
- Navigation handled by `AppRouter.generateRoute`; adding screens requires route entries plus registration in nav flows.

- Imports order: Dart SDK, third-party packages, internal `package:atiora/...`, then relative paths. Keep blank lines between groups.
- Prefer `const` constructors and widgets whenever inputs are compile-time constants.
- Embrace Dart null safety: mark optional fields with `?`, use required named params when possible.
- Types: never use `var` for public members; keep method signatures explicit.
- Naming: `PascalCase` for classes/widgets, `camelCase` for members/functions, `SCREAMING_SNAKE_CASE` for constants, and Spanish copy for user-facing strings to match existing UI.
- Avoid `dynamic` unless interfacing with Supabase/Hive raw data; immediately coerce into typed structures.
- Formatting: rely on `dart format`; do not hand-align code.
- Keep widgets under ~100 lines; extract stateless sub-widgets or helper methods when tree becomes hard to read.
- Bloc event/state classes stay in their own files; maintain `abstract class FooEvent {}` pattern.
## 10. Coding Style Guidelines
- Imports: Dart SDK → terceros → `package:atiora/...` → relativos (una línea en blanco entre grupos).
- Usa `const` en widgets/valores siempre que sea posible.
- Null safety obligatoria (`?`, `required`, evita `late` excepto cuando esté 100% controlado).
- Sin `var` en miembros públicos; tipa explícitamente funciones y propiedades.
- Nombres: `PascalCase` para clases/widgets, `camelCase` para métodos y variables, `SCREAMING_SNAKE_CASE` para constantes.
- La UI siempre en español; comentarios en inglés solo para aclarar lógica.
- Evita `dynamic` salvo cuando Supabase/Hive lo requiera, conviértelo inmediatamente a tipos concretos.
- `dart format` manda; no intentes alinear manualmente.
- Extrae sub-widgets cuando `build` supere ~100 líneas.
- Reutiliza patrones `bloc` (`abstract class FooEvent`, `FooState extends Equatable` cuando aplique).
- Imports order: Dart SDK, third-party packages, internal `package:atiora/...`, then relative paths. Keep blank lines between groups.
- Prefer `const` constructors and widgets whenever inputs are compile-time constants.
- Embrace Dart null safety: mark optional fields with `?`, use required named params when possible.
- Types: never use `var` for public members; keep method signatures explicit.
- Naming: `PascalCase` for classes/widgets, `camelCase` for members/functions, `SCREAMING_SNAKE_CASE` for constants, and Spanish copy for user-facing strings to match existing UI.
- Avoid `dynamic` unless interfacing with Supabase/Hive raw data; immediately coerce into typed structures.
- Formatting: rely on `dart format`; do not hand-align code.
- Keep widgets under ~100 lines; extract stateless sub-widgets or helper methods when tree becomes hard to read.
- Bloc event/state classes stay in their own files; maintain `abstract class FooEvent {}` pattern.

## 11. Error Boundaries & UX Resilience
- Toda UI que dependa de async debe mostrar estados `Loading`, `Loaded`, `Error`.
- Usa `CircularProgressIndicator` para cargas bloqueantes y `SizedBox.shrink()` como fallback limpio.
- Para reintentar, dispara eventos del bloc (no uses `setState` manual)
- Errores visibles en español y amigables: aprovecha `ErrorHandler.map`.

## 12. Networking & APIs
- Supabase client retrieved via `Supabase.instance.client` after `SupabaseProvider.initialize()` (called inside DI init).
- Keep queries scoped to the authenticated user via `.eq('user_id', currentUser.id)`; never fetch cross-user data.
- RPC results vary in type (int/list/map). Normalize before returning (see `_extractStreak`). Follow this defensive approach for new RPCs.
- When adding endpoints, place SQL function names and expected payload fields in comments to aid backend coordination.

## 13. Storage Notes
- Hive stores JSON maps, not generated adapters. When reading, convert dynamic keys to strings before `BookModel.fromJson`.
- Boxes open during app init; avoid reopening frequently. Inject `HiveService` via DI to access shared instance.
- Clearing/resyncing uses `HiveService.clearAllBooks()` followed by `saveAllBooks`; wrap bulk operations in try/catch to avoid corrupting caches.

## 14. Testing Philosophy
- Prefer `bloc_test` for bloc expectations (already used widely). Seed states with `seed: () => ...` when verifying updates.
- For repository tests, mock both local and remote datasources with `mocktail`, register fallback values for complex objects.
- Place new tests adjacent to implementation area (e.g., `test/features/books/...` if such folder emerges).
- Keep assertions descriptive; use `verify(() => mock.method()).called(1)` to protect behavior.
- Snapshot/Golden tests currently absent; add only if UI work justifies.

## 15. Running Targeted Tests Quickly
- Single bloc suite: `flutter test test/blocs/home_stats_bloc_test.dart`.
- Single test method (name match is case-sensitive): `flutter test test/utils/error_handler_test.dart --plain-name "should return friendly message for invalid_credentials"`.
- Debugging mode: `flutter test --coverage --reporter expanded` for verbose output.

## 16. Code Generation & Assets
- `build_runner` todavía no se usa; si activas generadores documenta el flujo.
- Assets: declara directorios completos (ya está `assets/`).
- `.env` debe existir localmente pero nunca se versiona.
- Para tipografías usa `google_fonts` desde los temas (no agregues TTFs a menos que sea imprescindible).

## 17. Styling, Imports, and Formatting Deep Dive
- Keep widget build methods pure; avoid async gaps inside `build`—delegate to bloc/cubit.
- When using extensions/helpers, place them under `lib/core/utils` and export via barrel file if usage becomes widespread.
- Avoid `part` files unless necessary; splitting via directories keeps navigation simpler for agents.
- Document non-obvious logic with concise comments; default language is English in code comments, Spanish for UI labels.

## 18. Error Messaging & Localization
- App currently mixes English identifiers with Spanish UI copy; continue this convention.
- Reuse `AppHelpers.formatDate` for date strings; align new formatting utilities with this helper.
- When surfacing Supabase errors, map their codes to friendly strings through `ErrorHandler` or a new helper.

## 19. Logging & Diagnostics
- Keep print volume low in production code, but `debugPrint` with emoji tags is acceptable during development.
- Remove `debugPrint` statements that leak secrets or user PII before merging.
- For long-running sync operations, log both start and completion to aid debugging.
- Usa `debugPrint` amigable para producción; evita emojis.

## 20. Git & Workflow Expectations
- Branch naming is up to you; align commit messages with change intent (feature/fix/chore).
- Never commit `.env`, platform secrets, or generated artifacts (`*.lock` already tracked; honor that).
- When tests fail locally, fix before handing work back; mention pending failures only if blocked by upstream issues.
- Commits siguen el formato `<tipo>(optional-scope): descripción en modo imperativo` usando prefijos como `feat`, `fix`, `chore`, `refactor`, `docs`, `test`; mantén el mensaje bajo 72 caracteres.

## 21. Cursor / Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` exist, so there are no external agent mandates beyond this file.
- If such rule files appear later, update this section and propagate key points upward in the doc.

## 22. Extending the System
- When adding features, follow the existing domain-driven folder split (data/domain/presentation).
- Introduce new blocs with dedicated event/state files, tests, and DI registrations.
- For UI additions, craft bespoke layouts; avoid generic Material scaffolds per repo instructions.
- Keep Supabase schema assumptions documented in code comments when referencing new tables/RPCs.

## 23. Failure Recovery & Offline Strategy
- Repositories should degrade gracefully when Supabase is unreachable (return cache, avoid crashes).
- When optimistic updates fail, revert UI state via reloads (pattern already present in `BooksBloc`).
- Consider exponential backoff or queued mutations if future tasks demand robust offline support.

## 24. When You’re Done
- Always run `flutter analyze` and relevant `flutter test` invocations before concluding substantial work.
- Update this `AGENTS.md` when conventions change; treat it as living documentation.
- Summarize changes succinctly for the user, referencing touched files and next steps (tests, builds, etc.).
- Las respuestas al usuario deben redactarse en español cuando el usuario lo especifique.

Stay deliberate, keep the UX intentional, and prefer clarity over cleverness.
