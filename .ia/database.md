# Atiora — Reglas de base de datos

## Objetivo
SQLite local vía Drift (desde la Fase 1). Es la única fuente de verdad de los datos del usuario. Hasta la Fase 2 conviven Supabase (Postgres remoto) y Hive como legacy; no se agregan tablas ni boxes nuevos ahí.

## Nombres
- Tablas en inglés, plural, `snake_case` en SQL (`books`, `reading_sessions`, `notes`, `reading_goals`).
- Columnas `snake_case`; en Dart, `camelCase` generado por Drift.

## Claves
- PK: `id TEXT` con UUID v4 generado en el cliente.
- FKs con `ON DELETE CASCADE` desde `reading_sessions` y `notes` hacia `books` (BR-BOOK-05). Las FKs se activan con `PRAGMA foreign_keys = ON` al abrir la base.

## Modelo
| Tabla | Columnas principales |
|-------|----------------------|
| `books` | id, title, author, isbn, genres (JSON), total_pages, current_page, status, rating, cover_path, started_at, finished_at, created_at, updated_at |
| `reading_sessions` | id, book_id, start_page, end_page, pages_read, duration_seconds, read_at, created_at |
| `notes` | id, book_id, kind (`note`/`quote`), text, page, created_at, updated_at |
| `reading_goals` | year (PK), target_books |

`pages_read` se guarda calculado (BR-SESSION-02) para que las agregaciones sean SQL simples.

## Tipos
- Fechas: `DateTime` de Drift guardado como entero Unix (por defecto de Drift); siempre en UTC.
- Enums (`status`, `kind`): `textEnum` de Drift con el nombre en inglés del valor.
- Listas (`genres`): texto JSON con un `TypeConverter`.
- Calificación: `REAL`.

## Soft delete, auditoría y concurrencia
- Sin soft delete: borrar es borrar (con confirmación en la UI).
- `created_at` y `updated_at` en `books` y `notes`.
- Un solo proceso escribe: no hay control de concurrencia optimista. Las operaciones que tocan varias tablas (sesión + `current_page` + estado) van en una transacción.

## Índices
- `reading_sessions(book_id)`, `reading_sessions(read_at)`, `notes(book_id)`, `books(status)`.
- Índice nuevo solo cuando una consulta real lo justifique.

## Migraciones
- `schemaVersion` en la clase de la base; cada cambio de esquema incrementa la versión y agrega un paso en `MigrationStrategy.onUpgrade`.
- Se usa `drift_dev` para guardar snapshots del esquema y generar pruebas de migración.
- Nunca se edita un paso de migración ya publicado.
- **Pedir confirmación** antes de crear o cambiar una migración.

## Seed
Sin datos iniciales. Las pruebas usan una base en memoria (`NativeDatabase.memory()`).
