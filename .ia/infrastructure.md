# Atiora — Infraestructura

## Objetivo
Cómo se prepara el entorno, se corren los gates y se genera el APK. No hay servidores propios.

## Entornos
- **dev**: equipo del desarrollador (CachyOS) con Flutter 3.47.9 y un dispositivo o emulador Android.
- **ci**: GitHub Actions (`ubuntu-latest`) con la misma versión de Flutter.
- **release**: APK firmado que se instala en el teléfono.

## Servicios
- Legacy hasta la Fase 2: proyecto de Supabase (Auth, Postgres con RLS documentado en `SQL_SECURITY_POLICIES.md`, Storage para portadas).
- Externo desde la Fase 3: Open Library (público).

## Exposición de red
No aplica: la app no expone puertos ni servicios.

## Comandos
| Comando | Qué hace |
|---------|----------|
| `flutter pub get` | Instala dependencias |
| `./scripts/check.sh` | Formato, análisis y pruebas (gates de nivel 1) |
| `dart format lib test` | Aplica formato |
| `flutter run` | Corre la app en el dispositivo conectado |
| `dart run build_runner build --delete-conflicting-outputs` | Regenera el código de Drift (desde la Fase 1) |
| `flutter build apk --release --split-per-abi` | APKs por arquitectura (más livianos) |
| `dart run flutter_launcher_icons` | Regenera íconos desde `assets/icon.png` |

## Variables de entorno
- Legacy: `.env` con `SUPABASE_URL` y `SUPABASE_ANON_KEY` (no existe `.env.example`). En CI se crea vacío porque `pubspec.yaml` lo declara como asset.
- Tras la Fase 2: ninguna.

## Persistencia y backups
- Datos en la base SQLite y la carpeta de portadas del directorio de documentos de la app.
- Backup: exportación manual a `.zip` por el usuario (BR-BACKUP-01); el único backup automático es el previo a una importación (BR-BACKUP-03).

## CI/CD
- `.github/workflows/quality.yml`: en cada PR y push a `dev`, instala Flutter 3.47.9 y corre `./scripts/check.sh`.
- Sin bots de dependencias. Sin protección de rama en `dev` (decidido 2026-11-08): el agente igual corre `./scripts/check.sh` y no mergea con la CI en rojo.

## Despliegue
- Manual: `flutter build apk --release --split-per-abi` sobre un commit con los gates en verde, e instalación del APK.
- Rollback: reinstalar el APK anterior. Una migración de esquema ya aplicada no se revierte: un APK viejo no abre una base con `schemaVersion` mayor, por eso cada migración se prueba antes de publicar.

- Firma de release (decidido 2026-11-08, se configura en la Fase 6): keystore propio fuera del repositorio y `android/key.properties` (ya ignorados en `android/.gitignore`), referenciados desde `android/app/build.gradle`. Perder el keystore impide actualizar la app instalada: se respalda fuera del equipo.

## Prohibiciones
- No commitear keystores, `key.properties` ni `.env`.
- No cambiar `android/` (applicationId, permisos, firma) sin confirmación.
- No publicar un APK con gates en rojo.
