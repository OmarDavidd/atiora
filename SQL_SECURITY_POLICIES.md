# Políticas de Seguridad Supabase Storage

## ⚠️ Problema
El warning de Supabase indica que **cualquier cliente puede listar todos los archivos** del bucket `book-covers` porque la política SELECT es demasiado abierta.

## ✅ Solución

Ejecuta este SQL en el **SQL Editor** de tu proyecto Supabase:

```sql
-- =============================================
-- POLÍTICAS SEGURO PARA BOOK-COVERS BUCKET
-- =============================================

-- 1. ELIMINAR políticas anteriores (si existen)
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow All" ON storage.objects;
DROP POLICY IF EXISTS "anon can read" ON storage.objects;
DROP POLICY IF EXISTS "anon can upload" ON storage.objects;

-- 2. SELECT: Solo el propietario puede ver sus propias imágenes
CREATE POLICY "Owner can view own covers"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'book-covers' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 3. INSERT: Solo el propietario puede subir imágenes
CREATE POLICY "Owner can upload own covers"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'book-covers' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 4. UPDATE: Solo el propietario puede modificar sus imágenes
CREATE POLICY "Owner can update own covers"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'book-covers' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. DELETE: Solo el propietario puede eliminar sus imágenes
CREATE POLICY "Owner can delete own covers"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'book-covers' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

## 📋 Qué hace cada política:

| Política | Operación | Restricción |
|----------|-----------|-------------|
| Owner can view own covers | SELECT | Solo ve sus propias imágenes |
| Owner can upload own covers | INSERT | Solo sube a su carpeta |
| Owner can update own covers | UPDATE | Solo modifica sus archivos |
| Owner can delete own covers | DELETE | Solo elimina sus archivos |

## 🔒 Cómo funciona

El path de archivo debe ser: `{user_id}/{book_id}/{filename.jpg}`

Ejemplo: `abc123-def456-.../book-789/timestamp.jpg`

La política verifica que `storage.foldername(name))[1]` (primera carpeta) coincida con `auth.uid()` del usuario autenticado.

## ✅ Verificar

Después de ejecutar, ve a **Storage** → **book-covers** → debería mostrar "Segura" en verde sin warnings.