# Plan de Pruebas - Correcciones Atiora

## Objetivo
Verificar que los problemas reportados por los evaluadores fueron corregidos.

---

## 📱 PRUEBA 1: Contraste de botones en tema oscuro

**Problema**: Botones no visibles en tema oscuro

**Cómo probar**:
1. Instalar APK release en dispositivo
2. Ir a **Perfil** → togglear tema a **oscuro**
3. Ir a cualquier pantalla con botones (Login, Registro, Agregar libro)
4. Verificar que los botones tengan texto **negro sobre fondo verde** (contraste legible)

**Esperado**: Texto del botón legible en dark mode (fondo verde #19b399, texto #0F172A)

---

## 📷 PRUEBA 2: Guardado de portadas

**Problema**: No guarda las imágenes

**Cómo probar**:
1. Registrarse/Iniciar sesión
2. Ir a **Biblioteca** → **+** (agregar libro)
3. Tocar el área de portada (donde dice "Sin portada")
4. Elegir **Cámara** o **Galería**
5. Seleccionar una foto
6. Completar demás campos y guardar libro
7. Ir a detalles del libro
8. Verificar que la portada **se muestre**

**Esperado**: La imagen seleccionada aparece como portada del libro

---

## ✅ PRUEBA 3: Validación de campos vacíos

**Problema**: No validaba campos vacíos en páginas

**Cómo probar**:
1. Ir a agregar libro
2. Dejar campo "Total páginas" **vacío** o en **0**
3. Intentar guardar
4. Verificar que muestre **mensaje de error**

**Esperado**: Mensaje "Revisa el total de páginas y el progreso actual"

---

## 🧹 PRUEBA 4: Formulario limpia campos al discard

**Problema**: "Al borrar/limpiar el formulario no limpia cantidad de hojas"

**Cómo probar** (AUNQUE EL CÓDIGO SÍ LO HACE):
1. Ir a agregar libro
2. Cambiar "Total páginas" a **500**
3. Cambiar "Página actual" a **250**
4. Tocar **X** o "Descartar"
5. Confirmar que desea descartar
6. Volver a agregar libro
7. **Verificar que los campos muestren valor por defecto (1)**

**Esperado**: Campos muestran 1 (no 500/250)

---

## ⚡ PRUEBA 5: Velocidad APK

**Problema**: APK lenta/pesada

**Cómo probar**:
1. Instalar `app-release.apk` (55.8MB)
2. Abrir app
3. Medir tiempo hasta pantalla splash
4. Comparar con versión anterior

**Esperado**: Abre más rápido que debug APK

---

## 📋 Checklist

| # | Prueba | Estado | Notas |
|---|--------|--------|-------|
| 1 | Contrast dark mode | [ ] | |
| 2 | Guardado portadas | [ ] | |
| 3 | Validación vacío | [ ] | |
| 4 | Limpiar formulario | [ ] | |
| 5 | Velocidad APK | [ ] | |

---

## 📦 Archivos APK

- **Debug**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release**: `build/app/outputs/flutter-apk/app-release.apk` (recomendado)