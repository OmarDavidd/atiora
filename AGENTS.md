# AGENTS.md — Atiora

<!-- ia-kit: 5a67fad -->

Punto de entrada para cualquier agente de IA (Claude Code, Codex, OpenCode u otro) que trabaje en este repositorio.

La arquitectura, las convenciones, la infraestructura, la estrategia de pruebas y el flujo de trabajo están definidos en `.ia/`. **Leer y respetar esos documentos antes de modificar el proyecto es obligatorio.**

## 1. Qué es Atiora

Atiora es una app móvil en Flutter para registrar lo que lees: libros, avance por sesión, notas y citas, y estadísticas reales de hábito (racha, ritmo, meta anual). Está en transición de un prototipo escolar con Supabase y login hacia una app **local-first**: los datos viven en el teléfono (SQLite con Drift), sin cuenta obligatoria y funcionando sin conexión. El plan por fases está en `.ia/project.md`.

- Requisitos funcionales: `.ia/business-rules.md`
- Contexto para agentes: `.ia/project.md`

## 2. Orden de lectura obligatorio

1. `.ia/README.md`
2. `.ia/project.md`
3. `.ia/architecture.md`
4. `.ia/workflow.md`

Después, los documentos de la tarea:

| Tarea | Leer además |
|-------|-------------|
| Pantallas, widgets, Blocs | `.ia/frontend.md`, `.ia/conventions.md`, `.ia/errors.md` |
| Modelo de datos, tablas, migraciones Drift | `.ia/database.md`, `.ia/business-rules.md` |
| Racha, estados, meta, estadísticas | `.ia/business-rules.md`, `.ia/testing.md` |
| Portadas, imágenes, backup/export | `.ia/files.md`, `.ia/security.md` |
| Búsqueda de libros (Open Library) | `.ia/architecture.md` §Integraciones, `.ia/errors.md` |
| Pruebas | `.ia/testing.md`, `.ia/quality-gates.md` |
| Build, CI, release del APK | `.ia/infrastructure.md`, `.ia/quality-gates.md` |
| Logs y diagnóstico | `.ia/observability.md` |

## 3. Stack oficial (resumen)

| Capa | Tecnología |
|------|------------|
| App | Flutter 3.47.9 / Dart 3.13.7 (Android primero) |
| Estado | flutter_bloc 9.1.1 + bloc_concurrency 0.3.0 |
| DI | get_it 9.2.0 |
| Datos locales | Drift + SQLite (objetivo, Fase 1). Legacy: Hive 2.2.3 + Supabase 2.12.0 (se retiran en Fase 2) |
| Integración | Open Library API (búsqueda por título/ISBN, Fase 3) |
| Pruebas | flutter_test, bloc_test 10.0.0, mocktail 1.0.4 |

El detalle y lo que está prohibido introducir están en `.ia/README.md`.

**Comandos:** `./scripts/check.sh` (gates), `flutter pub get`, `flutter run`, `flutter test path/to/file_test.dart --plain-name "nombre"`.

**Quality gates:** `./scripts/check.sh` antes de terminar cualquier tarea (detalle en `.ia/quality-gates.md`).

## 4. Reglas de idioma

- **Código en inglés**: identificadores, endpoints, tablas, logs, tests y mensajes técnicos.
- **Interfaz en español (tú, neutro)**: todo texto visible para el usuario.
- **Documentación en español**: `.ia/`, `docs/`, `odd/`.
- **Commits en inglés** con Conventional Commits.

## 5. Nunca sin preguntar

El agente DEBE pedir confirmación antes de:

- hacer `git push`, abrir, aprobar o mergear un PR;
- crear, modificar o eliminar migraciones o cambiar el modelo de datos;
- agregar, quitar o actualizar dependencias;
- cambiar un contrato público (API, eventos, CLI, formatos de archivo);
- cambiar la arquitectura, la autenticación o la autorización;
- ejecutar operaciones destructivas sobre datos o sobre el repositorio;
- tocar la CI, el despliegue de producción o los secretos;
- desactivar un quality gate, bajar un umbral, agregar una supresión o saltear hooks.

Los commits locales en la rama de trabajo están permitidos cuando la tarea lo requiera.

## 6. Carpetas que no se tocan

- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: generadas por Flutter; solo se cambian para permisos, íconos o configuración de build, y con confirmación.
- `correcciones/`: observaciones de la evaluación escolar; solo lectura.
- `.ia/_legacy/`: respaldo del AGENTS.md anterior; solo lectura.

## 7. Flujo de trabajo

El flujo completo está en `.ia/workflow.md`. Resumen:

1. Leer los documentos que corresponden.
2. Inspeccionar el código existente antes de crear algo nuevo.
3. Para features grandes, usar el documento ODD en `odd/tasks/<feature>.md` (local, no se sube).
4. Prueba primero (RED → GREEN) en reglas de negocio.
5. Cambio mínimo, sin refactors no pedidos.
6. Correr las pruebas relacionadas y `./scripts/check.sh`, y reportar el resultado real.
7. Resumir qué cambió, qué se probó y qué queda pendiente.

### Automático (skills de ia-kit)

El agente encadena estos pasos solo, sin que el usuario los pida. Si la skill no está instalada en el agente, avisarlo una vez y seguir el mismo criterio a mano.

| Cuándo | Qué hace el agente |
|--------|--------------------|
| Al empezar una feature grande | `ia-spec`: escribe las specs `S#` en el documento ODD antes de tocar código |
| Antes de terminar un cambio que toca la UI | `ia-design-check` sobre los archivos cambiados (solo si existe `.ia/design/`) |
| Antes de terminar cualquier tarea | `./scripts/check.sh` y reporta la salida real |
| Al notar que este `AGENTS.md` o `.ia/` contradice el código | Lo informa y ofrece `ia-sync` |
| Cuando el usuario pregunta cómo va el proyecto | `ia-metrics` sobre la rama principal |

Lo que exige confirmación (§5) sigue pidiéndola aunque el paso sea automático.

## 8. Precedencia

1. Instrucción explícita y actual del usuario.
2. `.ia/` (este repositorio).
3. Código existente.

Si `.ia/` y el código se contradicen, el agente no elige en silencio: informa la contradicción y pregunta cuando afecta la arquitectura, la seguridad, los datos o los contratos. Durante la transición (Fases 1–2) el código todavía usa Supabase y Hive: eso es estado legacy esperado, no una contradicción.
