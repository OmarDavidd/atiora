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

## Convenciones principales
- Imports: SDK, paquetes externos, `package:atiora/...`, relativos.
- UI: textos en español; tipografías configuradas en los temas (no cargar fuentes directamente en widgets).
- Manejo de estado con Bloc/Cubit; usa `bloc_concurrency` (`restartable` para libros, `droppable` para stats).
- Manejo de errores centralizado en `ErrorHandler` y mensajes amigables para la UI.
- Logs con `debugPrint`; evita emojis y mensajes temporales.
- Nunca compartas ni commitees `.env` u otros secretos.

## Flujo de desarrollo
1. Correr `flutter doctor` si es la primera vez o tras actualizar Flutter.
2. Trabajar en ramas descriptivas (`feat/`, `fix/`, `chore/`).
3. Mantener `git status` limpio (no mezclar cambios no relacionados).
4. Antes de abrir PR/merge: `flutter analyze && flutter test`.
5. Describir cambios y motivación en commits (modo imperativo, <72 caracteres).

## Testing
- Preferir `bloc_test` + `mocktail` para blocs y repositorios.
- Cubrir datasources (`books_remote_datasource_test.dart`, etc.) y helpers críticos.
- Tests de widgets: usar `pumpWidget` y `WidgetTester` para flujos clave.
- Para depurar o filtrar: `flutter test path/to/file.dart --plain-name "nombre exacto"`.
- Los commits usan formato `<tipo>(opcional): mensaje imperativo` con `feat|fix|chore|refactor|docs|test`, máximo ~72 caracteres.

---
Si necesitas más detalles operativos, revisa `AGENTS.md`.
