# Atiora — Convenciones de código

## Idioma
- Identificadores, comentarios, logs, nombres de prueba y commits: inglés.
- Texto visible al usuario (labels, mensajes, diálogos): español neutro, tuteando.
- Documentación (`.ia/`, `odd/`): español.

## Nombres por lenguaje

### Dart
- Archivos: `snake_case.dart`; las pruebas terminan en `_test.dart`.
- Tipos, enums y extensiones: `PascalCase`. Miembros, variables y constantes: `camelCase` (sin `SCREAMING_CASE`).
- Blocs: `XBloc`, `XEvent` (sealed, verbos en pasado o imperativo: `BookAdded`, `LoadBooks`), `XState`.
- Repositorios: interfaz `XRepository` en `domain/`, implementación `XRepositoryImpl` en `data/`.
- Datasources: `XLocalDataSource`, `XRemoteDataSource`.
- Tipos de retorno explícitos en todo lo público; `final` por defecto; evitar `late` (excepción legacy: `HiveService`).

## Base de datos
- Tablas Drift: clase en plural `PascalCase` (`Books`, `ReadingSessions`, `Notes`); en SQL quedan `snake_case` plural.
- Columnas: `snake_case` en SQL, `camelCase` en Dart (lo genera Drift).

## Booleanos, fechas, IDs y nullability
- Booleanos con prefijo `is`/`has` (`isFavorite`).
- IDs: UUID v4 (`uuid`) como `String`, generados en el cliente.
- Fechas: `DateTime` en UTC al guardar; se convierten a hora local solo al mostrar. Un "día de lectura" se calcula en la zona horaria local del dispositivo (ver `business-rules.md`).
- Ausencia: `null` explícito; nunca `''`, `0` o `-1` como "sin valor".

## Comentarios
- Solo para explicar el porqué de una regla o un caso borde, en inglés. Las reglas de negocio citan su ID (`// BR-STREAK-02`).

## Git
- Rama principal de trabajo: `dev`. Una rama por fase o feature (`refactor/<fase>`, `feat/<feature>`), que se mergea a `dev` por PR.
- Conventional Commits: `<type>(<scope>): imperative` (`feat`, `fix`, `refactor`, `test`, `chore`, `docs`).
- PRs de menos de ~400 líneas cuando se pueda; si no, PRs encadenados.
- `.env`, `README.md`, `AGENTS.md` y `CHANGELOG.md` están en `.gitignore` pero `README.md` y `AGENTS.md` están trackeados: sus cambios sí aparecen en `git status`.
