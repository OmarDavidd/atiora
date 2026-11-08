# Atiora — Contexto del proyecto

## Propósito
Atiora ayuda a lectores comunes a registrar qué leen y a sostener el hábito. Registrar un libro o un avance tiene que costar segundos, funcionar sin internet y sin crear cuenta, y devolver algo útil a cambio: racha real, ritmo de lectura, meta anual y las notas y citas guardadas.

## Equipo
- Omar David García Ventura: dueño del producto y único desarrollador. Decide alcance, arquitectura y dependencias.

## Hito
Nació como proyecto escolar (versión `v0.1-escuela`, con Supabase y login). Ya no tiene restricciones escolares. El próximo hito es una versión local-first usable a diario, publicada como APK.

Sin fecha objetivo ni publicación en tienda por ahora; se distribuye como APK firmado (decidido 2026-11-08).

## Objetivos funcionales principales
Plan por fases; cada fase deja la app funcionando y con `./scripts/check.sh` en verde.

| Fase | Objetivo |
|------|----------|
| 0 | Red de seguridad: tag `v0.1-escuela`, `.ia/` y CI de nivel 1 |
| 1 | Capa de datos nueva: Drift con `Book`, `ReadingSession`, `Note` y enum `BookStatus` |
| 2 | Quitar auth y Supabase; la app abre directo al inicio; backup y restauración por archivo `.zip` (datos + portadas) |
| 3 | Agregar libros buscando en Open Library por título o ISBN y escaneando el código de barras; captura manual como respaldo |
| 4 | Uso diario: "Leí hoy" en 2 toques, temporizador opcional, racha real, meta anual, recordatorio local |
| 5 | Estadísticas reales calculadas desde sesiones |
| 6 | Pulido: tema oscuro, peso del APK, dependencias sin uso, firma de release |

## Actores
- **Lector**: único usuario del dispositivo. Crea, edita y borra sus libros, sesiones, notas y metas; exporta e importa su backup.
- **Open Library** (sistema externo, Fase 3): solo lectura de metadatos y portadas.

## Decisiones de alcance
Fuera del alcance hasta que se decida lo contrario:
- Cuentas de usuario, login y sincronización en la nube.
- Funciones sociales (seguir, compartir reseñas, clubes).
- Importación desde Goodreads y widgets de pantalla de inicio (posteriores a la Fase 6).
- iOS, web y escritorio como plataformas publicadas.

## Restricciones técnicas
- Sin backend propio ni costos recurrentes.
- Debe funcionar completo sin conexión; solo la búsqueda en Open Library requiere red.
- El APK debe ser ligero (observación de la evaluación: "esta pesadita").

## Principios del proyecto
1. Registrar cuesta segundos: cada toque de más es un usuario menos.
2. Offline primero: la red es un extra, nunca un requisito.
3. Números honestos: ninguna estadística se muestra si no sale de datos reales.
4. Los datos son del usuario: siempre se pueden exportar.
5. Cada fase deja la app funcionando.
