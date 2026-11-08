# Atiora — Seguridad

## 1. Principios
- Mínimo privilegio: la app pide solo los permisos que usa una función activa.
- Los datos del usuario no salen del dispositivo salvo que él exporte un backup.
- Toda entrada (formularios, backup importado, respuestas de Open Library) se valida antes de guardarse.

## 2. Secretos
- Tras la Fase 2 la app no necesita secretos: Open Library no usa API key.
- Legacy: `SUPABASE_URL` y `SUPABASE_ANON_KEY` en `.env` (ignorado por git), empaquetado como asset en `pubspec.yaml`. Todo lo que esté en `.env` termina dentro del APK; ahí solo puede ir la anon key. El asset `.env` se elimina en la Fase 2.
- Nunca se commitea `.env` ni archivos `*.jks`/`key.properties`.

## 3. Validación de entrada
- Formularios: validadores en `core/utils/input_validator.dart` y en el repositorio (doble validación).
- Backup importado: se valida estructura, versión, tipos y rangos (BR-BACKUP-02) antes de escribir.
- Open Library: se toleran campos faltantes o con tipo inesperado sin lanzar errores.

## 4. Contenido de usuarios
- Notas y citas se muestran como texto plano (`Text`), nunca como HTML o Markdown interpretado.
- Imágenes elegidas por el usuario o descargadas: ver `files.md` (tipo, tamaño y redimensionado).

## 5. Rate limiting y bloqueo
- Búsqueda en Open Library con debounce (≥ 400 ms) y sin reintentos automáticos agresivos.

## 6. Contraseñas y sesiones
- No aplica después de la Fase 2 (no hay cuentas). Legacy: Supabase Auth.

## 7. Base de datos
- Consultas por la API tipada de Drift; SQL crudo solo con variables enlazadas, nunca concatenando texto.
- Base sin cifrar: guarda datos de lectura, no datos sensibles. Si eso cambia, se reevalúa (SQLCipher).

## 8. Transporte y navegador
- Solo HTTPS hacia Open Library; sin `usesCleartextTraffic`.

## 9. Dependencias
- Nuevas dependencias solo con confirmación y versión fijada.
- Revisión manual de `flutter pub outdated` al inicio de cada fase; el escaneo automático (nivel 2) no está adoptado.

## 10. Datos personales
- Se guarda: libros, avance, notas y metas, solo en el dispositivo.
- Permisos Android actuales: `INTERNET`, `CAMERA`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`. En la Fase 6 se revisan: los de almacenamiento externo no son necesarios con el selector de fotos moderno.
- Desinstalar la app borra todo; esto se explica junto a la opción de backup.
