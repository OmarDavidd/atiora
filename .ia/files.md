# Atiora — Archivos

## Objetivo
La app maneja dos tipos de archivo: portadas de libros (elegidas del teléfono o descargadas de Open Library) y backups `.zip` (`data.json` + portadas).

## Principios
- Las portadas se guardan como archivos en el directorio de documentos de la app (`getApplicationDocumentsDirectory()/covers/<bookId>.jpg`); la base guarda solo la ruta relativa (`cover_path`).
- Nunca se guarda la imagen como blob en SQLite.
- Una portada descargada se guarda localmente para que funcione sin red.
- Legacy: hoy las portadas se suben a Supabase Storage; se migran a archivos locales en la Fase 2.

## Límites y tipos permitidos
- Portadas: JPEG, PNG o WebP de entrada; se guardan como JPEG redimensionado a máximo 600 px de alto (`image_picker` con `maxHeight`/`imageQuality`).
- Backup: un archivo `.zip` con `data.json` (versionado) y la carpeta `covers/`; se rechaza si `data.json` falta, no tiene versión o el zip supera 200 MB.

## Flujo de subida
1. El usuario elige una foto (`image_picker`) o un resultado de Open Library.
2. Se valida el tipo y se redimensiona.
3. Se escribe en `covers/<bookId>.jpg`, reemplazando la anterior.
4. Se guarda `cover_path` en la misma operación que el libro; si falla la escritura en la base, se borra el archivo.

## Flujo de descarga y vista previa
- Portadas: `Image.file`, con un placeholder si el archivo no existe.
- Open Library: la vista previa usa la URL remota; solo se descarga la portada que el usuario confirma.

## Borrado y retención
- Borrar un libro borra su portada (BR-BOOK-05).
- El backup incluye las portadas porque las fotos del usuario no se pueden volver a descargar (decidido 2026-11-08). Al importar, una portada que falte en el zip deja el libro sin portada.

## Pruebas
- Guardar y borrar portada contra un directorio temporal.
- Importar un backup inválido (sin versión, tipos erróneos) falla con `backupInvalid` sin escribir nada.
