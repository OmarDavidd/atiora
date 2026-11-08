# Atiora — Arquitectura

## Vista general

```text
Estado objetivo (después de la Fase 2):

 ┌──────────── App Flutter (un proceso, un dispositivo) ────────────┐
 │  Widgets ──evento──> Bloc ──> Repository (domain) ──> DataSource │
 │                                         │                 │      │
 │                         lógica pura (racha, stats)        │      │
 │                                                   ┌───────┴────┐ │
 │                                                   │ Drift      │ │
 │                                                   │ (SQLite)   │ │
 │                                                   └────────────┘ │
 │  Portadas: archivos en el directorio de documentos de la app    │
 │  Backup: .zip (data.json + covers/) exportado por el usuario  │
 └───────────────────────────────┬──────────────────────────────────┘
                                 │ HTTPS (solo búsqueda, Fase 3)
                          Open Library API

Estado actual (legacy, hasta la Fase 2):
 Repository ──> RemoteDataSource (Supabase) + LocalDataSource (Hive cifrado)
            └─> cola de operaciones pendientes (pendingOpsBox)
```

## Estructura del repositorio

```text
lib/
  main.dart            entrada: carga config, llama init() (DI) y runApp
  core/                di/, errors/, navigation/, screens/, storage/, theme/, utils/, widgets/
  data/models/         modelos compartidos (BookModel, NoteModel, ProfileModel, UserModel)
  features/
    auth/              data/domain/presentation (se elimina en Fase 2)
    books/             data/domain/presentation: libros, notas, sesiones
    dashboards/        presentation (+ Blocs de inicio y estadísticas)
    library/           presentation
    profile/           presentation
test/                  blocs/, repositories/, models/, usecases/, utils/, core/, features/
scripts/check.sh       quality gates
.ia/                   instrucciones para agentes
```

Las carpetas vacías `features/notes/` y `features/stats/` se eliminan o se llenan durante el refactor; no se crean más carpetas vacías.

## Capas y dependencias
- **presentation** (widgets, Blocs) → **domain** (interfaces de repositorio, entidades, lógica pura) ← **data** (implementaciones, datasources, tablas Drift).
- `presentation` no importa nada de `data/`; obtiene repositorios por `sl` y los pasa a los Blocs.
- `domain` no importa Flutter ni Drift.
- Una feature no importa la `presentation` de otra; lo compartido va a `core/` o `data/models/`.
- Blocs: `restartable()` para acciones del usuario, `droppable()` para cargas y estadísticas.
- DI en `lib/core/di/injection_container.dart`: datasources y repositorios como singletons perezosos, Blocs como factories.

## Integraciones externas
| Servicio | Uso | Desde |
|----------|-----|-------|
| Open Library Search/Books API | Buscar por título o ISBN; autor, páginas y portada | Fase 3 |
| Open Library Covers | Descargar la portada elegida y guardarla localmente | Fase 3 |
| Supabase (Auth, Postgres, Storage) | Legacy: se retira en Fase 2 | Actual |

## Decisiones arquitectónicas (registro)

| Fecha | Decisión | Motivo | Alternativas descartadas |
|-------|----------|--------|--------------------------|
| 2026-11-07 | App local-first con Drift/SQLite, sin cuenta | El login bloqueaba el primer uso; la sincronización manual Hive + Supabase + cola era la mayor fuente de bugs | Mantener Supabase; Supabase como sincronización opcional desde el día 1 |
| 2026-11-07 | Cada avance de lectura es una `ReadingSession` | Racha, ritmo y páginas por periodo solo se pueden calcular con sesiones fechadas | Guardar solo `currentPage` en el libro (el modelo actual, que produce rachas falsas) |
| 2026-11-07 | Estado del libro como enum `BookStatus` | El código mezcla `'Completado'`/`'completado'` y `'Leyendo'`/`'leyendo'`, lo que rompe consultas | Normalizar strings en tiempo de ejecución |
| 2026-11-07 | Mantener Bloc + GetIt | Ya en uso y con pruebas | Riverpod |
