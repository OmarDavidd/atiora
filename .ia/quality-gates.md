# Atiora — Quality gates

## Objetivo

Los controles automáticos que todo cambio debe pasar antes de mergearse. Son deterministas: los ejecuta una máquina, no dependen del criterio del agente. La revisión humana o del agente evalúa diseño y criterio; los gates evalúan lo que se puede verificar con un comando.

Una regla que ningún comando verifica es una sugerencia. Si una regla de `.ia/` se puede automatizar, su gate vive acá.

## Punto de entrada único

```text
./scripts/check.sh
```

El agente corre este comando antes de dar por terminada una tarea y reporta la salida real.

## Niveles

El proyecto adopta un nivel y lo sube cuando lo necesita. Cada nivel incluye los anteriores.

| Nivel | Gates | Cuándo adoptarlo |
|-------|-------|------------------|
| 1. Base | Formato, lint, typecheck, pruebas | Siempre |
| 2. Seguridad | Secretos, dependencias vulnerables (SCA), análisis estático de seguridad (SAST) | Código en producción, datos de usuarios o dependencias de terceros |
| 3. Plataforma de calidad | Cobertura del código nuevo, duplicación, complejidad, historial (SonarQube o similar) | Equipo, proyecto de larga vida o requisito del cliente |
| 4. Runtime | Análisis dinámico (DAST) contra la app corriendo, por ejemplo OWASP ZAP | App web expuesta a internet |

Nivel adoptado: **1. Base** (decidido 2026-11-07). Proyecto personal de un solo desarrollador y sin backend tras la Fase 2. Se reevalúa el nivel 2 antes de publicar en una tienda.

## Gates

| Gate | Herramienta | Comando | Dónde corre | ¿Bloquea? |
|------|-------------|---------|-------------|-----------|
| Formato | dart format (Dart 3.13.7) | `dart format --output=none --set-exit-if-changed lib test` | local (`check.sh`), CI en PR y push a `dev` | Sí |
| Lint + typecheck | flutter analyze + flutter_lints 6.0.0 | `flutter analyze --fatal-infos` | local, CI | Sí |
| Pruebas | flutter test | `flutter test` | local, CI | Sí |
| Código generado (desde Fase 1) | build_runner + drift_dev | regenerar y fallar si `git status --porcelain` muestra cambios | CI | Sí, cuando exista código generado |

## Umbrales

- Formato: cero archivos por formatear.
- Análisis: cero issues, incluidos los `info` (`--fatal-infos`).
- Pruebas: todas pasan; sin umbral de cobertura por ahora.

Un gate sin nada que verificar falla: el runner de pruebas termina con error si no encuentra pruebas (en Vitest y Jest, `passWithNoTests` desactivado; en pytest, el código 5 no se acepta), y un linter o escáner que no analiza ningún archivo es un error de configuración.

## Excepciones

Un hallazgo falso positivo o aceptado se suprime solo:

- en el archivo de configuración de la herramienta o con la anotación propia de la herramienta, nunca desactivando el gate entero;
- con un comentario que explica el motivo;
- con aprobación del usuario.

Supresiones de lint: en `analysis_options.yaml` (reglas) o con `// ignore: <regla>` junto a la línea, con el motivo en el mismo comentario.

## Reglas para el agente

- Correr `./scripts/check.sh` antes de terminar una tarea; si falla, arreglar la causa, no el gate.
- Una prueba nunca se borra, se saltea ni se debilita para que un gate pase.
- **Pedir confirmación** antes de desactivar un gate, bajar un umbral, agregar una supresión, saltear hooks (`--no-verify`) o modificar la configuración de la CI.
- No marcar una tarea como terminada con un gate bloqueante en rojo.
- Leer la salida, no solo el código de salida: "0 pruebas", "no files found" o "0 archivos analizados" es un gate vacío y se reporta como fallo.
- Si un gate falla por algo ajeno al cambio (ya fallaba en la rama base), reportarlo como tal, con la evidencia, en lugar de ocultarlo.
- Un hallazgo de seguridad (secreto, CVE, SAST) se reporta siempre, aunque no bloquee.
