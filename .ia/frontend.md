# Atiora — Reglas del frontend

## Objetivo
App móvil Flutter (Android primero), una sola instancia por dispositivo.

## Stack
- Material 3; tema en `lib/core/theme/` (`light_theme.dart`, `dark_theme.dart`, `AppColors` en `lib/core/utils/app_colors.dart`).
- Estado: flutter_bloc; `ThemeCubit` es el único Cubit (tema persistido en SharedPreferences).
- Gráficas: fl_chart.
- Fuentes: google_fonts (en Fase 6 se empaquetan como assets para no descargarlas en tiempo de ejecución).
- No agregar paquetes de UI nuevos sin confirmación.

## Estructura
```text
features/<feature>/presentation/
  bloc/      <x>_bloc.dart, <x>_event.dart, <x>_state.dart
  screens/   pantallas completas
  widgets/   piezas de la pantalla; un widget público por archivo
```

## Componentes
- Pantallas = contenedores: leen Blocs con `BlocBuilder`/`BlocListener` y pasan datos a widgets.
- Widgets = presentacionales: reciben datos y callbacks; no hacen `sl<...>()` ni llaman a repositorios.
- Archivos de más de ~300 líneas se dividen (hoy `add_book_modal.dart` y `add_note_modal.dart` superan ese límite).
- Componentes compartidos van a `lib/core/widgets/`.

## Rutas
- Definidas en `lib/core/navigation/app_router.dart`; navegación principal por pestañas en `lib/core/screens/main_nav_page.dart`.
- Tras la Fase 2 no hay rutas protegidas: la app abre directo en el inicio.

## Estado
- Todo dato persistente vive en la base local; los Blocs mantienen solo la vista actual.
- Estado efímero (texto de un campo, pestaña elegida) va en el `State` del widget.
- Estados con `copyWith`; nunca se mutan.

## API
- La única red es Open Library (Fase 3), detrás de un repositorio; el Bloc recibe resultados o un `AppException.network`.

## Formularios y validación
- Validadores en `lib/core/utils/input_validator.dart` y `features/books/presentation/helpers/`; las reglas de valor (páginas, calificación) siguen `business-rules.md` y se validan también en el repositorio.

## Estilos y diseño
- Colores solo desde `Theme.of(context).colorScheme` o `AppColors`; nada de `Color(0x…)` sueltos en widgets.
- Todo componente se revisa en tema claro y oscuro (observación de evaluación: botones invisibles en oscuro).

## Accesibilidad y testids
- Botones de solo ícono con `tooltip` o `Semantics(label:)` en español.
- Áreas táctiles de al menos 48×48.
- Widgets que las pruebas buscan llevan `Key('<feature>_<element>')`.

## Estados de UI
- Cada pantalla con datos cubre: carga (`skeleton_loader.dart`), vacío (mensaje + acción para agregar), error (mensaje de `ErrorHandler.map()` + reintentar) y contenido.
- Éxito y errores puntuales con `NotificationHelper`; confirmaciones con `DialogHelper`.
- Después de un `await`, comprobar `context.mounted` antes de usar el `context`.

## Pruebas
- Blocs con `bloc_test`; widgets con `testWidgets` para estados vacío, error y contenido.
