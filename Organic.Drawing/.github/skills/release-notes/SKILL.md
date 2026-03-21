# Skill: Release Notes

## Descripción

Conocimiento para generar notas de versión (changelog, release notes) de manera consistente y profesional para el proyecto Organic.Drawing.

## Cuándo Usar

- Al preparar una nueva versión/release
- Al cerrar un sprint o milestone
- Para documentar cambios significativos
- Al generar changelog automático desde commits

## Categorías de Cambios

### Tipos Estándar

| Emoji | Tipo | Descripción |
|-------|------|-------------|
| ✨ | **Added** | Nueva funcionalidad |
| 🔄 | **Changed** | Cambio en funcionalidad existente |
| 🗑️ | **Deprecated** | Funcionalidad marcada para eliminación |
| 🔥 | **Removed** | Funcionalidad eliminada |
| 🐛 | **Fixed** | Corrección de bug |
| 🔒 | **Security** | Corrección de vulnerabilidad |
| ⚡ | **Performance** | Mejora de rendimiento |
| 📚 | **Docs** | Cambios en documentación |
| 🔧 | **Refactor** | Refactoring sin cambio funcional |
| 🧪 | **Tests** | Cambios en tests |

### Mapeo desde Commits

```
feat:     → ✨ Added
fix:      → 🐛 Fixed
docs:     → 📚 Docs
style:    → 🔧 Refactor
refactor: → 🔧 Refactor
perf:     → ⚡ Performance
test:     → 🧪 Tests
chore:    → (no incluir normalmente)
```

## Plantilla de Release Notes

```markdown
# Release Notes - v{VERSION}

**Fecha**: {YYYY-MM-DD}
**Proyecto**: Organic.Drawing

## Resumen

[Descripción breve de los cambios principales en esta versión]

## ✨ Nuevas Funcionalidades

- **[Módulo]**: Descripción del feature ([#123](link-al-ticket))
- **[Módulo]**: Otra funcionalidad nueva

## 🔄 Cambios

- **[Módulo]**: Descripción del cambio
- Actualizada dependencia X de v1 a v2

## 🐛 Correcciones

- **[BUG-456]**: Descripción del bug corregido
- Corregido error en cálculo de descuentos

## ⚡ Mejoras de Rendimiento

- Optimizada consulta de ventas (50% más rápido)
- Reducido uso de memoria en proceso X

## 🔒 Seguridad

- Corregida vulnerabilidad en validación de inputs

## 💥 Breaking Changes

> ⚠️ **Atención**: Los siguientes cambios requieren acción

- `MetodoAntiguo()` renombrado a `MetodoNuevo()`
- Parámetro `tnOld` eliminado de `ClaseX.Procesar()`

## 🗑️ Deprecaciones

- `ClaseObsoleta` será eliminada en v3.0
- Método `HacerAlgoViejo()` marcado como deprecated

## 📋 Notas de Migración

### Desde v{VERSION_ANTERIOR}

1. Ejecutar script de migración: `scripts/migrate-v{VERSION}.sql`
2. Actualizar configuración en `config.xml`
3. Recompilar con `dovfp rebuild`

## 📦 Dependencias

| Paquete | Versión Anterior | Versión Nueva |
|---------|------------------|---------------|
| Package1 | 1.0.0 | 1.2.0 |

## 🙏 Agradecimientos

- @contributor1 por reportar bug #123
- @contributor2 por PR #456
```

## Plantilla Corta (Patch/Hotfix)

```markdown
# v{VERSION} - Patch Release

**Fecha**: {YYYY-MM-DD}

## 🐛 Correcciones

- [BUG-123] Descripción breve del fix

## 📋 Actualización

```bash
dovfp restore
dovfp rebuild
```
```

## Workflow para Generar Release Notes

### 1. Recopilar Información

```bash
# Ver commits desde última versión
git log v1.0.0..HEAD --oneline

# Ver tags existentes
git tag -l "v*"

# Ver archivos modificados
git diff --stat v1.0.0..HEAD
```

### 2. Clasificar Cambios

Para cada commit:
1. Identificar tipo (feat, fix, etc.)
2. Asignar categoría (Added, Fixed, etc.)
3. Extraer ticket si existe (#123)
4. Redactar descripción user-friendly

### 3. Identificar Breaking Changes

Buscar en commits:
- Cambios de firma de métodos
- Eliminación de métodos públicos
- Cambios en estructura de datos
- Cambios de configuración requeridos

### 4. Validar Completitud

```
□ Todas las features documentadas
□ Todos los bugs corregidos listados
□ Breaking changes identificados
□ Instrucciones de migración incluidas
□ Dependencias actualizadas documentadas
□ Fecha y versión correctas
```

## Convenciones del Proyecto

### Versionado Semántico

```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: Nueva funcionalidad (backward compatible)
PATCH: Bug fixes (backward compatible)
```

### Ejemplos

- `1.0.0 → 2.0.0`: Breaking change (API modificada)
- `1.0.0 → 1.1.0`: Nuevo feature sin romper nada
- `1.0.0 → 1.0.1`: Bug fix

### Nomenclatura de Versiones

```
v1.0.0        - Release estable
v1.1.0-beta   - Pre-release beta
v1.1.0-rc.1   - Release candidate 1
```

## Herramientas Recomendadas

- `run_in_terminal`: Ejecutar comandos git
- `grep_search`: Buscar cambios específicos
- `read_file`: Leer commits o archivos modificados

## Queries Útiles

```bash
# Commits por tipo
git log --oneline | grep "feat:"
git log --oneline | grep "fix:"

# Archivos más modificados
git diff --stat v1.0.0..HEAD | sort -k3 -n -r | head -20

# Contributors
git shortlog -sn v1.0.0..HEAD
```
