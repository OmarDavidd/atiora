# Atiora — Reglas de negocio

## 1. Actores
Ver `project.md` §Actores: un único lector por dispositivo.

## 2. Libros (BR-BOOK)
- **BR-BOOK-01**: Un libro tiene título obligatorio (no vacío tras recortar espacios); autor, géneros, portada e ISBN son opcionales.
- **BR-BOOK-02**: `totalPages` es un entero ≥ 0; 0 significa "desconocido" y desactiva el porcentaje de avance.
- **BR-BOOK-03**: `currentPage` está entre 0 y `totalPages` (si `totalPages` > 0).
- **BR-BOOK-04**: Calificación de 0 a 5 en pasos de 0.5; 0 significa "sin calificar".
- **BR-BOOK-05**: Al borrar un libro se borran sus sesiones, notas y su portada local.

## 3. Estados (BR-STATUS)
- **BR-STATUS-01**: Estados válidos (enum `BookStatus`): `pending` ("Por leer"), `reading` ("Leyendo"), `paused` ("Pausado"), `completed` ("Completado"). Los textos en español solo existen en la UI.
- **BR-STATUS-02**: Registrar avance en un libro `pending` o `paused` lo pasa a `reading` y fija `startedAt` si no tenía.
- **BR-STATUS-03**: Llegar a `currentPage == totalPages` (con `totalPages` > 0) propone marcarlo `completed`; el usuario confirma.
- **BR-STATUS-04**: Marcar `completed` fija `finishedAt`; salir de `completed` lo borra.

## 4. Sesiones de lectura (BR-SESSION)
- **BR-SESSION-01**: Todo avance de páginas crea una `ReadingSession` con libro, fecha, página inicial, página final y duración opcional.
- **BR-SESSION-02**: Páginas leídas de la sesión = página final − página inicial, nunca negativo; retroceder páginas corrige `currentPage` sin crear páginas negativas.
- **BR-SESSION-03**: El día de una sesión es su fecha en la zona horaria local del dispositivo.

## 5. Racha (BR-STREAK)
- **BR-STREAK-01**: Un día cuenta para la racha si tiene al menos una sesión con páginas leídas > 0.
- **BR-STREAK-02**: La racha actual es el número de días consecutivos que cuentan, terminando hoy o ayer; si el último día que cuenta es anterior a ayer, la racha es 0.
- **BR-STREAK-03**: La mejor racha es la secuencia más larga de días consecutivos que cuentan en todo el historial.

## 6. Meta anual (BR-GOAL)
- **BR-GOAL-01**: La meta es un número de libros por año calendario (≥ 1), opcional.
- **BR-GOAL-02**: Un libro cuenta para el año de su `finishedAt`.
- **BR-GOAL-03**: El avance "a tiempo" compara libros terminados contra `meta × (día del año / días del año)`.

## 7. Estadísticas (BR-STATS)
- **BR-STATS-01**: Toda estadística se calcula desde sesiones y libros guardados; ninguna cifra es un valor fijo o aproximado.
- **BR-STATS-02**: Páginas de un periodo = suma de páginas leídas de las sesiones de ese periodo.

## 8. Notas (BR-NOTE)
- **BR-NOTE-01**: Una nota pertenece a un libro, tiene texto no vacío, tipo `note` o `quote`, y página opcional.

## 9. Backup (BR-BACKUP)
- **BR-BACKUP-01**: Exportar genera un único archivo `.zip` con `data.json` versionado (libros, sesiones, notas y metas) y las portadas (ver `files.md`).
- **BR-BACKUP-02**: Importar valida la versión del archivo y nunca borra datos existentes sin confirmación explícita.
- **BR-BACKUP-03**: Importar reemplaza todos los datos actuales, no los fusiona. Antes de reemplazar se genera automáticamente un backup de los datos actuales (decidido 2026-11-08).
