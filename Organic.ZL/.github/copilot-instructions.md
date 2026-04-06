# Organic.ZL - Instrucciones para GitHub Copilot

> Para guía completa del sistema, ver [README.md](.github/README.md)

## Contexto del Proyecto

Este es un proyecto **Visual FoxPro 9** de la familia **Organic**, una solución empresarial desarrollada en VS Code con herramientas modernas:
- **DOVFP**: Compilador .NET 6 para Visual FoxPro
- **VS Code + GitHub Copilot**: Entorno de desarrollo
- **PromptOps**: Sistema de 4 capas (Agents, Instructions, Prompts, Skills)
- **Azure DevOps**: CI/CD, repositorios, pipelines

---

## 🤖 Agents Disponibles

| Agent | Archivo | Propósito |
|-------|---------|-----------|
| Developer | `agents/developer.agent.md` | Desarrollo de features VFP |
| Test Engineer | `agents/test-engineer.agent.md` | Testing y validación |
| Auditor | `agents/auditor.agent.md` | Code review y calidad |
| Refactor | `agents/refactor.agent.md` | Mejora de código |

**Uso**: `@workspace Usando el agente [nombre], [tarea]`

---

## 📋 Instructions Activas

| Archivo | Se aplica a | Propósito |
|---------|-------------|-----------|
| `vfp-coding-standards` | `**/*.{prg,vcx,scx,frx}` | Estándares de código |
| `vfp-development` | Desarrollo general | Guía de desarrollo |
| `testing` | Archivos de test | Guía de testing |
| `dovfp-build` | Build system | Compilación DOVFP |

---

## 📝 Prompts por Categoría

### Auditoría
- `prompts/auditoria/code-audit-comprehensive.prompt.md`
- `prompts/auditoria/promptops-audit.prompt.md`

### Desarrollo
- `prompts/dev/vfp-development-expert.prompt.md`
- `prompts/dev/dovfp-build-integration.prompt.md`

### Refactoring
- `prompts/refactor/refactor-patterns.prompt.md`

### Testing
- `prompts/test/test-audit.prompt.md`

**Uso**: `#file:.github/prompts/[categoria]/[nombre].prompt.md`

---

## 🧠 Skills Disponibles

| Skill | Propósito |
|-------|-----------|
| `skills/code-audit/SKILL.md` | Checklists de auditoría |
| `skills/release-notes/SKILL.md` | Generación de changelog |

---

## Estructura del Proyecto

### Proyectos principales

- **Organic.BusinessLogic/**: Código de negocio principal (CENTRALSS/)
- **Organic.Generated/**: Código generado automáticamente (**NO EDITAR MANUALMENTE**)
- **Organic.Tests/**: Tests unitarios y funcionales
- **Organic.Assets/**: Recursos y assets

### Archivos de solución

- `*.vfpsln`: Archivo de solución que agrupa proyectos
- `*.vfpproj`: Archivos de proyecto individual
- `azure-pipelines.yml`: Configuración CI/CD
- `Nuget.config`: Gestión de paquetes DOVFP

---

## Estándares de Código VFP

### Nomenclatura Húngara

```foxpro
* Parámetros de funciones/procedimientos
LPARAMETERS tcNombre, tnEdad, tlActivo, toObjeto, taArray

* Variables locales
LOCAL lcVariable, lnContador, llFlag, loObjeto, laLista

* Propiedades de clase
THIS.cPropiedad = ""   && character
THIS.nPropiedad = 0    && numeric
THIS.lPropiedad = .F.  && logical
THIS.oPropiedad = NULL && object
```

### Prefijos de Variables

| Prefijo | Tipo | Ejemplo |
|---------|------|---------|
| `c` | Character | `lcNombre`, `THIS.cNombre` |
| `n` | Numeric | `lnContador`, `THIS.nEdad` |
| `l` | Logical | `llActivo`, `THIS.lFlag` |
| `d` | Date | `ldFecha`, `THIS.dCreacion` |
| `t` | DateTime | `ltFechaHora` |
| `o` | Object | `loObjeto`, `THIS.oConexion` |
| `a` | Array | `laLista`, `THIS.aItems` |

### Ámbito de Variables

| Prefijo | Ámbito | Uso |
|---------|--------|-----|
| `l` | Local | Variables dentro de procedimiento |
| `p` | Parameter | Parámetros recibidos |
| `t` | Parameter | Alternativa para parámetros (LPARAMETERS) |
| `g` | Global/Public | Variables públicas (EVITAR) |

---

## Organización de Archivos - TOLERANCIA CERO

### Archivos permitidos

- **Raíz limpia**: Solo archivos esenciales de producción
- **.github/ limpio**: Sistema Copilot organizado
- **Proyectos**: Cada carpeta Organic.* tiene su estructura definida

### Archivos PROHIBIDOS

- **NO crear archivos de reporte**: FINAL-STATUS-REPORT.*, *-ANALYSIS.*, *-SUMMARY.*
- **NO crear archivos temporales**: .tmp, .bak, .old, debug-*, test-*
- **PROHIBIDO en .github/**: *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md, *-REPORT.md
- **NO carpeta docs/**: GitHub Copilot NO la lee automáticamente

---

Cuando trabajes con este proyecto, **SIEMPRE mantén estos estándares** y **NUNCA crees archivos temporales** que violen la política de workspace limpio.