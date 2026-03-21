# Skill: Release Notes

## Descripción

Conocimiento para generar notas de release, changelogs y documentación de versiones para el proyecto Organic.Dragonfish.

## Cuándo Usar

- Al preparar un nuevo release
- Para documentar cambios en una versión
- Al generar changelog automático
- Para comunicar cambios a usuarios

## Formato de Release Notes

```markdown
# Release [MAJOR].[MINOR].[BUILD]

**Fecha**: YYYY-MM-DD
**Tipo**: Major | Minor | Patch | Hotfix

## 🚀 Nuevas Funcionalidades
- [FEATURE-001] Descripción de la nueva funcionalidad

## 🐛 Correcciones
- [BUG-001] Descripción del bug corregido

## ⚡ Mejoras de Performance
- Descripción de la mejora

## 🔧 Cambios Técnicos
- Refactorizaciones, actualizaciones de dependencias

## ⚠️ Breaking Changes
- Cambios que requieren acción del usuario

## 📋 Notas de Migración
Pasos necesarios para actualizar desde versión anterior.
```

## Categorías de Cambios

| Emoji | Categoría | Descripción |
|-------|-----------|-------------|
| 🚀 | Feature | Nueva funcionalidad |
| 🐛 | Bugfix | Corrección de errores |
| ⚡ | Performance | Mejoras de rendimiento |
| 🔧 | Technical | Cambios internos |
| ⚠️ | Breaking | Cambios incompatibles |
| 📚 | Docs | Documentación |
| 🧪 | Tests | Pruebas |
| 🔒 | Security | Seguridad |

## Workflow de Release

1. **Recopilar** commits desde último release
2. **Categorizar** cambios por tipo
3. **Redactar** descripciones claras para usuarios
4. **Identificar** breaking changes
5. **Documentar** pasos de migración si aplica
6. **Revisar** con stakeholders

## Comandos Git Útiles

```bash
# Commits desde último tag
git log v1.0.0..HEAD --oneline

# Archivos modificados
git diff --name-only v1.0.0..HEAD

# Commits por autor
git shortlog v1.0.0..HEAD

# Generar changelog básico
git log v1.0.0..HEAD --pretty=format:"- %s (%h)"
```

## Template de Commit para Release

```
[TIPO] Descripción corta

Descripción detallada del cambio.

Refs: #123
Breaking: Sí/No
```

## Herramientas Recomendadas

- `run_in_terminal`: Ejecutar comandos git
- `read_file`: Leer archivos modificados
- `grep_search`: Buscar TODOs, FIXMEs
- `get_changed_files`: Ver cambios pendientes

## Checklist Pre-Release

- [ ] Todos los tests pasan
- [ ] Build en modo Release exitoso
- [ ] Versiones actualizadas (build.h, Generated)
- [ ] Changelog generado
- [ ] Breaking changes documentados
- [ ] Notas de migración escritas
- [ ] Review por stakeholders
