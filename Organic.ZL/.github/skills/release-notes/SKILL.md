# Skill: Release Notes

## Descripción

Skill para generación de notas de versión y changesets para proyectos Visual FoxPro 9 compilados con DOVFP.

## Cuándo Usar

- Al preparar una nueva versión/release
- Al generar changelog para commits
- Al documentar cambios entre versiones
- Al crear notas para el equipo de QA
- Al preparar comunicación a usuarios

## Workflow de Release Notes

### 1. Recopilar Cambios

```powershell
# Obtener commits desde última versión
git log --oneline v1.2.0..HEAD

# Obtener archivos modificados
git diff --name-only v1.2.0..HEAD

# Obtener commits con mensaje detallado
git log --pretty=format:"%h - %s (%an)" v1.2.0..HEAD
```

### 2. Categorizar Cambios

| Categoría | Prefijo Commit | Emoji |
|-----------|----------------|-------|
| Nueva funcionalidad | feat: | ✨ |
| Corrección de bug | fix: | 🐛 |
| Mejora de performance | perf: | ⚡ |
| Refactorización | refactor: | ♻️ |
| Documentación | docs: | 📝 |
| Tests | test: | ✅ |
| Build/CI | build: | 🔧 |
| Estilo | style: | 💄 |

### 3. Formato de Release Notes

```markdown
# Release Notes - v[X.Y.Z]

**Fecha**: [YYYY-MM-DD]
**Versión anterior**: v[X.Y.Z-1]
**Commits incluidos**: [N]

---

## 🎯 Resumen

[Descripción breve de los cambios principales en 2-3 oraciones]

---

## ✨ Nuevas Funcionalidades

### [Nombre de la funcionalidad]
- **Descripción**: [Qué hace]
- **Archivos**: [Lista de archivos modificados]
- **Uso**: [Cómo se usa]

---

## 🐛 Correcciones

### [Título del bug corregido]
- **Síntoma**: [Qué problema resuelve]
- **Causa**: [Qué lo causaba]
- **Solución**: [Cómo se corrigió]
- **Archivos**: [Lista de archivos]

---

## ⚡ Mejoras de Performance

### [Área mejorada]
- **Antes**: [Comportamiento anterior]
- **Después**: [Comportamiento nuevo]
- **Impacto**: [Métricas de mejora si aplica]

---

## ♻️ Refactorizaciones

### [Área refactorizada]
- **Motivo**: [Por qué se hizo]
- **Cambios**: [Qué se cambió]
- **Impacto**: [Efecto en el código]

---

## ⚠️ Breaking Changes

### [Cambio incompatible]
- **Afecta a**: [Qué módulos/funciones]
- **Migración**: [Pasos para actualizar]

---

## 📋 Checklist de Despliegue

- [ ] Backup de base de datos
- [ ] Backup de ejecutables anteriores
- [ ] Actualizar archivos de configuración
- [ ] [Otros pasos específicos del proyecto]

---

## 🔗 Referencias

- **Commits**: [link a lista de commits]
- **Issues**: [links a issues cerrados]
- **Documentación**: [link a docs actualizados]
```

## Template de Changeset

```markdown
---
type: [feat|fix|perf|refactor|docs|test|build|style]
scope: [módulo afectado]
breaking: [true|false]
---

## Descripción

[Descripción clara del cambio]

## Archivos Modificados

- `path/to/file1.prg`: [descripción del cambio]
- `path/to/file2.prg`: [descripción del cambio]

## Testing

- [ ] Tests unitarios pasan
- [ ] Tests de integración pasan
- [ ] Probado manualmente

## Notas Adicionales

[Información extra relevante]
```

## Comandos Git Útiles

```powershell
# Ver historial de un archivo
git log --follow -p -- path/to/file.prg

# Comparar versiones
git diff v1.0.0..v1.1.0 -- path/to/file.prg

# Crear tag de versión
git tag -a v1.2.0 -m "Release v1.2.0"

# Ver tags existentes
git tag -l "v*"

# Ver cambios desde último tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

## Herramientas Recomendadas

- **run_in_terminal**: Ejecutar comandos git
- **read_file**: Leer archivos modificados
- **get_changed_files**: Ver cambios pendientes
- **grep_search**: Buscar cambios específicos

## Versionado Semántico

```
MAJOR.MINOR.PATCH

MAJOR: Cambios incompatibles (breaking changes)
MINOR: Nueva funcionalidad compatible
PATCH: Correcciones compatibles
```

### Ejemplos

- `1.0.0 → 1.0.1`: Bug fix
- `1.0.1 → 1.1.0`: Nueva feature
- `1.1.0 → 2.0.0`: Breaking change
