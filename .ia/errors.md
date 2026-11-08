# Atiora — Manejo de errores

## Objetivo
Un solo tipo de error entre capas (`AppException`) y una sola forma de convertirlo en mensaje para el usuario (`ErrorHandler.map()`), para que nunca se muestre un mensaje técnico.

## Formato
`lib/core/errors/app_exception.dart`:

```dart
AppException(
  type: AppExceptionType.validation,
  message: 'totalPages must be >= 0', // technical, for logs only
  cause: originalError,
  stackTrace: stackTrace,
)
```

## Códigos
`AppExceptionType` actual: `auth`, `unauthorized`, `network`, `validation`, `cache`, `unknown`.

Tras la Fase 2 se retiran `auth` y `unauthorized`, y se agregan:
- `storage`: fallo al leer o escribir la base local o un archivo.
- `notFound`: el libro, la sesión o la nota no existe.
- `backupInvalid`: archivo de backup con formato o versión no soportada.

Agregar o quitar un tipo requiere actualizar `ErrorHandler.map()` y su prueba.

## Mapeo
- Datasources capturan excepciones de Drift, IO o HTTP y las envuelven en `AppException` con `cause`.
- Repositorios validan reglas de negocio y lanzan `AppException.validation`.
- Blocs capturan `AppException` y emiten un estado de error con el mensaje de `ErrorHandler.map()`.
- Una excepción que no sea `AppException` se trata como `unknown`.

## Cliente
- `ErrorHandler.map(e)` devuelve un texto en español, corto y accionable ("No pudimos guardar el libro. Intenta de nuevo.").
- Errores de una acción: `NotificationHelper`. Errores que bloquean una pantalla: estado de error con botón de reintentar.
- `network` solo puede aparecer en la búsqueda de Open Library; el resto de la app no depende de red.

## Pruebas
- `test/utils/error_handler_test.dart` cubre un mensaje por tipo.
- Cada Bloc prueba al menos un camino de error.
