# Atiora — Observabilidad y logging

## Objetivo
Poder diagnosticar en desarrollo por qué falló una operación (guardar, migrar, importar, buscar) sin exponer el contenido de lectura del usuario.

## Arquitectura
- El código registra a través de una abstracción única (`AppLogger` en `lib/core/`, a crear en la Fase 1) que escribe a `dart:developer` `log()`.
- No hay backend de logs ni crash reporting remoto. Agregar uno (por ejemplo Sentry) es una decisión de stack y requiere confirmación.
- Prohibido `print()` en `lib/`.

## Structured logging
- Mensaje fijo + datos como parámetros: `logger.error('book_save_failed', error: e, data: {'bookId': id})`.
- Nombre del evento en `snake_case`, en inglés.

## Correlation ID
No aplica: un solo proceso local sin llamadas encadenadas entre servicios.

## Niveles
- `debug`: detalles de desarrollo; no se emiten en release.
- `info`: hitos (migración aplicada, backup exportado).
- `warning`: algo inesperado que se recuperó (campo faltante de Open Library).
- `error`: operación del usuario que falló.

## Excepciones
- Se registra una vez, en el Bloc que la convierte en estado de error, con `cause` y `stackTrace` del `AppException`.
- Errores de validación esperados no se registran como `error`.
- `FlutterError.onError` y `PlatformDispatcher.instance.onError` en `main.dart` registran lo no controlado.

## Lo que NUNCA se registra
Títulos, autores, texto de notas o citas, rutas de imágenes del usuario y contenido de backups. Solo IDs, conteos y tipos de error.

## Health checks y métricas
No aplica (app local sin servidor).
