# Atiora — Flujo de trabajo para agentes de IA

## Objetivo

Cómo debe trabajar cualquier agente antes, durante y después de modificar el proyecto, para evitar cambios de arquitectura accidentales, duplicación, dependencias innecesarias y decisiones que contradigan al equipo.

## 1. Antes de modificar código

Leer `.ia/README.md`, `project.md`, `architecture.md`, este archivo, y los documentos de la tarea (tabla en `AGENTS.md` §2).

## 2. Inspeccionar antes de crear

Antes de crear algo, buscar lo que ya existe: el módulo o la feature responsable, interfaces y servicios, tipos y DTOs (incluidos los generados), componentes reutilizables, utilidades y convenciones en uso.

No crear una segunda implementación de algo que ya existe. Cuando varias partes modifican el mismo estado compartido, reutilizar **la misma** función, nunca reimplementarla.

## 3. Identificar la frontera

- ¿Qué feature es dueña del cambio (`books`, `dashboards`, `library`, `profile`) o es compartido (`core/`, `data/models/`)?
- ¿Es una regla de negocio (va en `domain/`, pura y con prueba `BR-*`), persistencia (`data/`, Drift) o presentación (Bloc o widget)?
- ¿Toca código legacy (Supabase, Hive, cola de pendientes) que se retira en la Fase 2? Entonces no se extiende: se cambia lo mínimo o se migra al modelo nuevo.
- ¿Necesita red? Solo la búsqueda de Open Library puede; el resto funciona sin conexión.

## 4. ODD (features grandes)

Se usa Organic Driven Development (ODD):

- **Tarea chica** (entendida, de riesgo acotado y retomable solo con el diff): se hace directo, sin documento.
- **`odd/` es local**: está en `.gitignore` y no se sube al repositorio.
- **Feature grande**: `odd/tasks/<feature>.md` antes de escribir código, con:
  - un encabezado de 2 o 3 líneas (objetivo, rama, runners);
  - `## Specs`: `S1…Sn`, citando literalmente lo que pidió el usuario y los IDs de reglas y requisitos;
  - `## Tasks`: una tabla con el ID, los `S#`, la ruta, el estado y el commit;
  - `## Log`: `L1` = el pedido original textual, y después las correcciones, la evidencia y las decisiones, con fecha.
- Las tareas se marcan como hechas solo con la evidencia observada (pruebas corridas, commit).

## 5. Prueba primero

En las reglas de negocio y las clases con lógica:

1. Escribir la prueba que falla (RED) y verla fallar.
2. Implementar lo mínimo (GREEN).
3. Refactorizar con las pruebas en verde.

Por cada comportamiento existente que toque el cambio (opciones, parsers o helpers compartidos), agregar una prueba que demuestre que sigue funcionando igual.

Una prueba nunca se borra, se saltea ni se debilita solo para que la suite pase. Si una prueba contradice una regla, se informa.

## 6. Cambio mínimo

- Modificar solo lo necesario para la tarea.
- Nada de refactors no pedidos en áreas no relacionadas.
- No actualizar dependencias ni versiones por iniciativa propia.

## 7. Respetar los límites

```text
Widget -> Bloc -> Repository (domain) -> LocalDataSource -> Drift/SQLite
Bloc -> BookSearchRepository -> OpenLibraryDataSource -> HTTPS
Repository -> lógica de dominio pura (racha, estados, stats)
Widget -> Repository / DataSource / sl<...>()     (nunca)
domain -> Flutter, Drift o http                   (nunca)
feature A presentation -> feature B presentation  (nunca; compartir vía core/)
código nuevo -> Supabase o Hive                   (nunca; son legacy)
```

## 8. Seguridad

Antes de terminar, revisar que el cambio no introduzca:

- identidad tomada de datos del cliente en lugar de la sesión;
- operaciones protegidas sin autorización o sin verificar la pertenencia;
- secretos en el código, en el cliente o en los logs;
- contenido de usuarios renderizado sin escapar;
- títulos, notas o citas del usuario en logs;
- permisos de Android nuevos sin justificación;
- datos de un backup importado escritos sin validar.

## 9. Datos

1. Identificar la entidad y su módulo.
2. Revisar las relaciones, los índices y las restricciones.
3. **Pedir confirmación antes de crear una migración.**
4. No editar migraciones aplicadas.

## 10. Contratos

- Un cambio de contrato (API, eventos, CLI) se coordina en el mismo PR entre quien expone el contrato y quienes lo usan, y en ese mismo cambio se regeneran los clientes, tipos y artefactos generados que dependen de él.
- **Pedir confirmación** antes de cambiar o quitar algo del contrato público (agregar campos opcionales no requiere confirmación).

## 11. Validación antes de terminar

```text
[ ] La tarea pedida está completa.
[ ] La arquitectura se respetó.
[ ] No se introdujeron tecnologías no autorizadas.
[ ] No hay duplicación evidente.
[ ] Se respetaron las reglas de idioma.
[ ] No se expusieron secretos.
[ ] Los logs siguen el structured logging.
[ ] Las pruebas se crearon o actualizaron (RED observado en las reglas nuevas).
[ ] Las pruebas se ejecutaron: resultado real reportado.
[ ] Los gates de quality-gates.md pasaron, o el fallo se reportó con evidencia.
[ ] Los textos de ayuda y los docs se actualizaron si cambió un comando, una opción o un mensaje.
[ ] Si cambió un contrato, los clientes, tipos y artefactos generados se regeneraron.
[ ] Si el cambio alteró algo descrito en .ia/ (regla, variable de entorno, flujo, comando, diseño), .ia/ se actualizó en el mismo commit, verificado contra el código.
```

## 12. Detenerse y preguntar

El agente **pide confirmación** antes de:

- `git push`, abrir, aprobar o mergear PRs;
- crear, modificar o eliminar migraciones;
- agregar, quitar o actualizar dependencias;
- cambiar un contrato público;
- cambiar la arquitectura, la autenticación, la autorización, la seguridad o el modelo de datos;
- cambiar la estrategia de despliegue, la CI o la producción;
- desactivar un quality gate, bajar un umbral, agregar una supresión o saltear hooks;
- conectarse a un servidor remoto (SSH, copia de archivos, comandos) o cambiar su firewall;
- cambios destructivos sobre datos o sobre el repositorio;
- implementar una decisión no documentada con consecuencias relevantes.

También pregunta cuando hay dos decisiones razonables con consecuencias distintas y ninguna está documentada.

## 13. Lo que no requiere preguntar

Decisiones locales y reversibles que respetan las reglas: nombres internos coherentes, extraer una función privada pequeña, la organización interna de un componente, implementar una validación ya definida, elegir un componente existente, commits locales en la rama de trabajo.

No convertir cada detalle en una pregunta.

## 14. Contradicciones

Si `.ia/`, el código, los requisitos y la tarea se contradicen:

1. identificar la contradicción;
2. no ocultarla;
3. priorizar la instrucción explícita actual del usuario cuando la resuelve;
4. si afecta la arquitectura, la seguridad, los datos o los contratos y no está resuelta, preguntar.

No "corregir" requisitos en silencio según las preferencias del agente.

## 15. Cierre de una tarea

Resumen breve: qué se modificó, los archivos principales, las pruebas ejecutadas y su resultado **real**, las decisiones pendientes o los riesgos, y `Risk: none` o `Risk: <qué puede romperse y por qué>`.

No afirmar que algo se probó si no se ejecutó.
