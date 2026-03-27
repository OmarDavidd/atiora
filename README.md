# Atiora

Aplicación Flutter para seguir lecturas, progreso y estadísticas personales.

## Tabla de contenido
- [Stack y requisitos](#stack-y-requisitos)
- [Configuración rápida](#configuración-rápida)
- [Scripts útiles](#scripts-útiles)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Convenciones principales](#convenciones-principales)
- [Flujo de desarrollo](#flujo-de-desarrollo)
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
| Actualizar dependencias | `flutter pub get` |
| Formatear código | `dart format lib test` |
| Análisis estático | `flutter analyze` |
| Tests completos | `flutter test` |
| Test por archivo | `flutter test test/blocs/books_bloc_test.dart` |
| Test por nombre | `flutter test test/blocs/books_bloc_test.dart --plain-name "emits [BooksLoading, BooksLoaded] when LoadBooks succeeds"` |
| Cobertura detallada | `flutter test --coverage --reporter expanded` |

## Estructura del proyecto
- `lib/main.dart`: punto de entrada, inyección de dependencias y theming.
- `lib/core`: navegación, tema, helpers, almacenamiento local, constantes y utilidades.
- `lib/data/models`: modelos basados en `equatable` (`BookModel`, `UserModel`, etc.).
- `lib/features`: dividido por dominio (`auth`, `books`, `dashboards`), cada uno con data/domain/presentation.
- `test/`: espeja la estructura de `lib/`.

---
