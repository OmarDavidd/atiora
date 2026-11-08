# Atiora

Aplicación Flutter para seguir lecturas, progreso y estadísticas personales.

## Tabla de contenido
- [Stack y requisitos](#stack-y-requisitos)
- [Configuración rápida](#configuración-rápida)
- [Scripts útiles](#scripts-útiles)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Seguridad](#seguridad)
- [Testing](#testing)

## Stack y requisitos
- Flutter 3.24+ / Dart 3.4+ (constraint `^3.10.7`).
- Supabase como backend (auth y datos).
- Hive para cache local.
- Paquetes destacados: `flutter_bloc`, `get_it`, `supabase_flutter`, `hive`, `dio`, `carousel_slider`, `fl_chart`.

## Configuración rápida
```bash
git clone <repo>
cd atiora
flutter pub get
cp .env.example .env   # crea el archivo con tus claves Supabase
flutter run
```

## Scripts útiles
| Acción | Comando |
| --- | --- |
| APK Release | `flutter build apk --release` |
| Actualizar dependencias | `flutter pub get` |
| Formatear código | `dart format lib test` |
| Análisis estático | `flutter analyze` |
| Tests completos | `flutter test` |

## Estructura del proyecto
- `lib/main.dart`: punto de entrada, inyección de dependencias y theming.
- `lib/core`: navegación, tema, helpers, almacenamiento local, constantes y utilidades.
- `lib/data/models`: modelos basados en `equatable` (`BookModel`, `UserModel`, etc.).
- `lib/features`: dividido por dominio (`auth`, `books`, `dashboards`), cada uno con data/domain/presentation.
- `test/`: espeja la estructura de `lib/`.

## Seguridad
- **Auth**: Supabase Auth (JWT) - contraseñas nunca almacenadas localmente
- **BD**: Row Level Security (RLS) con políticas por `user_id`
- **Storage**: Bucket `book-covers` con políticas de acceso
- **Contraseñas**: Toggle mostrar/ocultar en login y registro

## Testing
```bash
flutter test                    # Todos los tests
flutter test --coverage         # Con cobertura
flutter analyze                 # Análisis estático
```
