# Atiora — Reglas de pruebas

## Objetivo
Garantizar que las reglas de negocio (racha, estados, meta, estadísticas), la persistencia y los flujos principales de UI no se rompan durante el refactor por fases.

## Principios
- Prueba primero en reglas de negocio: la prueba cita el ID de la regla (`'BR-STREAK-02: ...'`).
- Probar por la interfaz pública (Bloc, repositorio, función de dominio), no detalles internos.
- Determinismo: la fecha actual se inyecta (un `clock` o parámetro `now`), los IDs se pueden fijar, sin red real y sin esperas fijas.
- Cada prueba crea sus propios datos; nada depende de otra prueba.

## Pirámide
- Mayoría unitarias: lógica de dominio pura y Blocs.
- Integración: repositorios contra Drift en memoria (base real, no mock).
- Pocas de widget para pantallas clave; sin E2E por ahora.

## Herramientas y ubicación
- flutter_test, bloc_test 10.0.0, mocktail 1.0.4.
- `test/` refleja `lib/`. Las pruebas existentes en `test/blocs/`, `test/repositories/`, `test/models/`, `test/usecases/`, `test/utils/` se mantienen; las nuevas van en la ruta espejo (`test/features/<feature>/...`).

## Qué probar
- Dominio: cada regla `BR-*` con casos borde (cambio de día, zona horaria, años bisiestos, listas vacías).
- Blocs: estados emitidos en éxito y en error.
- Repositorios: contra `NativeDatabase.memory()`; no se mockea Drift.
- Migraciones Drift: con las utilidades de `drift_dev` desde la primera versión del esquema.
- Open Library: datasource contra respuestas HTTP simuladas; nunca la API real.

## Datos de prueba
- Builders o factories en `test/helpers/` (por ejemplo `aBook(status: BookStatus.reading)`).
- Una base en memoria nueva por prueba, cerrada en `tearDown`.

## Ejecución
```bash
flutter test                                                   # suite completa
flutter test test/blocs/books_bloc_test.dart                   # un archivo
flutter test test/blocs/books_bloc_test.dart --plain-name "X"  # una prueba
flutter test --coverage                                        # cobertura en coverage/
```

## Antes de terminar una tarea
Correr las pruebas del área tocada y después `./scripts/check.sh`.

Además, el comando único de `quality-gates.md` pasa en verde.
