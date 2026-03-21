# Skill: Release Notes

## Descripción

Conocimiento y templates para generar notas de versión (changelogs) profesionales para releases de Organic.Core.

---

## Cuándo Usar

- Al preparar una nueva versión/release
- Al documentar cambios para stakeholders
- Para mantener historial de cambios
- En comunicación con usuarios finales

---

## Categorías de Cambios

### ✨ Features (Nuevas funcionalidades)
Funcionalidades completamente nuevas que agregan capacidades al sistema.

### 🐛 Bug Fixes (Correcciones)
Correcciones de errores reportados o descubiertos.

### 🔧 Improvements (Mejoras)
Mejoras a funcionalidades existentes sin cambiar comportamiento.

### ⚡ Performance (Rendimiento)
Optimizaciones de velocidad, memoria o recursos.

### 🔒 Security (Seguridad)
Parches de seguridad y mejoras de protección.

### 📝 Documentation (Documentación)
Cambios en documentación, comentarios o guías.

### 🔨 Refactoring (Refactorización)
Cambios internos sin afectar funcionalidad externa.

### ⚠️ Breaking Changes (Cambios incompatibles)
Cambios que requieren modificación de código cliente.

### 🗑️ Deprecated (Deprecado)
Funcionalidades marcadas para eliminación futura.

---

## Template de Release Notes

```markdown
# Release Notes - Organic.Core vX.Y.Z

**Fecha de Release**: [YYYY-MM-DD]
**Versión anterior**: X.Y.Z-1

## 📋 Resumen

[Descripción breve de 2-3 oraciones sobre el release]

---

## ✨ Nuevas Funcionalidades

### [Nombre de Feature]
[Descripción de la funcionalidad]

**Archivos afectados**:
- `ruta/archivo.prg`

**Uso**:
```foxpro
* Ejemplo de uso
loObjeto.NuevoMetodo()
```

---

## 🐛 Correcciones

### [#123] Descripción del bug
**Problema**: [Qué fallaba]
**Solución**: [Cómo se corrigió]
**Archivos**: `archivo.prg`

---

## 🔧 Mejoras

- Mejorado rendimiento de [componente]
- Actualizado [dependencia] a versión X

---

## ⚠️ Breaking Changes

### [Cambio]
**Antes**:
```foxpro
* Código anterior
```

**Después**:
```foxpro
* Código nuevo
```

**Migración**: [Instrucciones para actualizar]

---

## 🗑️ Deprecaciones

- `MetodoAntiguo()` - Usar `MetodoNuevo()` en su lugar
  - Será eliminado en: vX.Y.Z

---

## 📦 Dependencias

| Paquete | Versión anterior | Versión nueva |
|---------|------------------|---------------|
| Package1 | 1.0.0 | 1.1.0 |

---

## 🔧 Configuración Requerida

[Si hay cambios de configuración necesarios]

---

## 📝 Notas de Actualización

1. Hacer backup de datos
2. Ejecutar `dovfp restore`
3. Recompilar con `dovfp build`
4. [Pasos adicionales]

---

## 🙏 Agradecimientos

- [Contribuidores]
```

---

## Workflow para Generar Release Notes

### 1. Recolectar Cambios
```
- Revisar commits desde último release
- Identificar PRs/merges
- Listar issues cerrados
```

### 2. Categorizar
```
- Agrupar por tipo (feature, fix, etc.)
- Ordenar por importancia
- Identificar breaking changes
```

### 3. Redactar
```
- Usar lenguaje claro para usuarios
- Incluir ejemplos de código si aplica
- Documentar pasos de migración
```

### 4. Revisar
```
- Verificar que no falten cambios importantes
- Validar rutas de archivos
- Confirmar versiones de dependencias
```

---

## Comandos Útiles

### Ver commits desde último tag
```bash
git log v1.0.0..HEAD --oneline
```

### Buscar archivos modificados
```bash
git diff --name-only v1.0.0..HEAD
```

### Listar contributors
```bash
git shortlog -sn v1.0.0..HEAD
```

---

## Herramientas Recomendadas

| Herramienta | Uso |
|-------------|-----|
| `run_in_terminal` | Ejecutar comandos git |
| `grep_search` | Buscar TODOs, FIXMEs |
| `read_file` | Leer changelogs anteriores |
| `get_changed_files` | Ver archivos modificados |
