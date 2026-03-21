# Skill: Release Notes

## Descripción
Generación de notas de release y changesets para versiones de Organic.Feline. Incluye categorización de cambios, formato estándar y plantillas.

## Cuándo Usar
- Antes de cada release
- Al cerrar un sprint
- Para documentar hotfixes
- Generación de changelog

## Categorías de Cambios

### ✨ Features (Nuevas funcionalidades)
Funcionalidad completamente nueva que agrega capacidades al sistema.

### 🐛 Bug Fixes (Correcciones)
Corrección de comportamiento incorrecto o errores.

### ⚡ Performance (Mejoras de rendimiento)
Optimizaciones que mejoran velocidad o uso de recursos.

### 🔧 Maintenance (Mantenimiento)
Refactoring, actualización de dependencias, cleanup de código.

### 📚 Documentation (Documentación)
Cambios en documentación, comentarios, READMEs.

### 🔒 Security (Seguridad)
Correcciones de vulnerabilidades o mejoras de seguridad.

### ⚠️ Breaking Changes (Cambios incompatibles)
Cambios que requieren modificaciones en código dependiente.

## Workflow de Generación

### 1. Recopilar Commits
```powershell
# Obtener commits desde última release
git log --oneline v1.0.0..HEAD

# Con más detalle
git log --pretty=format:"%h - %s (%an)" v1.0.0..HEAD
```

### 2. Categorizar Cambios
Revisar cada commit y asignar categoría según prefijo o contenido:
- `feat:` → Features
- `fix:` → Bug Fixes
- `perf:` → Performance
- `refactor:`, `chore:` → Maintenance
- `docs:` → Documentation
- `security:` → Security

### 3. Generar Notas

## Plantilla de Release Notes

```markdown
# Release Notes - v[X.Y.Z]

**Fecha**: [YYYY-MM-DD]
**Proyecto**: Organic.Feline

---

## ✨ Nuevas Funcionalidades

- **[Módulo]**: Descripción de la funcionalidad (#issue)
- **[Módulo]**: Descripción de la funcionalidad (#issue)

## 🐛 Correcciones

- **[Módulo]**: Descripción del bug corregido (#issue)
- **[Módulo]**: Descripción del bug corregido (#issue)

## ⚡ Mejoras de Rendimiento

- **[Área]**: Descripción de la optimización

## 🔧 Mantenimiento

- Actualización de [dependencia] a versión X.Y
- Refactoring de [módulo/clase]

## ⚠️ Cambios Incompatibles

- **[Cambio]**: Descripción y guía de migración

## 📋 Notas de Instalación

1. Ejecutar `dovfp restore` para actualizar dependencias
2. Ejecutar scripts de migración en `ScriptDB/`
3. Recompilar solución con `dovfp build`

## 🔗 Referencias

- [Azure DevOps Sprint X](link)
- [Issues cerrados](link)
```

## Plantilla de Changeset Individual

```markdown
## [Tipo]: Título breve

**Commit**: abc1234
**Autor**: Nombre
**Fecha**: YYYY-MM-DD

### Descripción
Descripción detallada del cambio.

### Archivos Modificados
- `path/to/file1.prg` - Descripción del cambio
- `path/to/file2.prg` - Descripción del cambio

### Testing
- [ ] Tests unitarios agregados/actualizados
- [ ] Tests manuales realizados

### Impacto
- Módulos afectados: [lista]
- Requiere migración: Sí/No
```

## Checklist Pre-Release

- [ ] Todos los tests pasan (`dovfp test`)
- [ ] Build completo sin errores (`dovfp build`)
- [ ] Versión actualizada en `.vfpproj`
- [ ] Changelog generado
- [ ] Tag de Git creado
- [ ] Pipeline de Azure DevOps ejecutado

## Herramientas Recomendadas
- `run_in_terminal`: Para ejecutar comandos git
- `get_changed_files`: Para ver archivos modificados
- `read_file`: Para revisar contenido de cambios
- `grep_search`: Para buscar referencias a issues

## Versionado Semántico

| Tipo de Cambio | Versión |
|----------------|---------|
| Breaking change | MAJOR (X.0.0) |
| Nueva feature | MINOR (0.X.0) |
| Bug fix | PATCH (0.0.X) |

## Referencias
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
