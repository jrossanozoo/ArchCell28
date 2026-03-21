# Organic.Dragonfish - Instrucciones para GitHub Copilot

## Contexto del Proyecto

Este es un proyecto **Visual FoxPro 9** de la familia **Organic**, una solución empresarial desarrollada en VS Code con herramientas modernas:
- **DOVFP**: Compilador .NET 6 para Visual FoxPro
- **VS Code + GitHub Copilot**: Entorno de desarrollo
- **PromptOps**: Sistema de 3 capas (Agents, Prompts, Instructions)
- **Azure DevOps**: CI/CD, repositorios, pipelines

---

## Estructura del Proyecto

### Proyectos principales

| Proyecto | Tipo | Descripción |
|----------|------|-------------|
| **Organic.BusinessLogic/** | Exe | Código de negocio principal (CENTRALSS/) |
| **Organic.Generated/** | PRG | Código generado automáticamente (**NO EDITAR**) |
| **Organic.Tests/** | Tests | Tests unitarios y funcionales |
| **Organic.Hooks/** | PRG | Extensiones e integraciones |
| **Organic.Mocks/** | PRG | Clases mock para testing |

### Archivos de solución

- `*.vfpsln`: Archivo de solución que agrupa proyectos
- `*.vfpproj`: Archivos de proyecto individual
- `azure-pipelines.yml`: Configuración CI/CD
- `Nuget.config`: Gestión de paquetes DOVFP

---

## Sistema PromptOps

### 🤖 Agents Disponibles

| Agent | Archivo | Propósito |
|-------|---------|-----------|
| Developer | [agents/developer.agent.md](agents/developer.agent.md) | Desarrollo VFP |
| Test Engineer | [agents/test-engineer.agent.md](agents/test-engineer.agent.md) | Testing y QA |
| Auditor | [agents/auditor.agent.md](agents/auditor.agent.md) | Auditoría de código |
| Refactor | [agents/refactor.agent.md](agents/refactor.agent.md) | Refactorización |

### 📋 Instructions (Automáticas)

| Archivo | Aplica a |
|---------|----------|
| [vfp-development.instructions.md](instructions/vfp-development.instructions.md) | `*.prg`, `*.vcx`, `*.scx`, `*.h` |
| [testing.instructions.md](instructions/testing.instructions.md) | `*Test*`, `Tests/` |
| [dovfp-build.instructions.md](instructions/dovfp-build.instructions.md) | `*.vfpproj`, `*.ps1` |

### 📝 Prompts (Manuales)

| Categoría | Prompts |
|-----------|---------|
| auditoria | code-audit-comprehensive, promptops-audit |
| dev | vfp-development-expert, dovfp-build-integration |
| refactor | refactor-patterns, fix-vcx-loadreference |
| test | test-coverage, test-generation |

### 📚 Skills

| Skill | Contenido |
|-------|-----------|
| [code-audit](skills/code-audit/SKILL.md) | Checklists de auditoría |
| [release-notes](skills/release-notes/SKILL.md) | Templates de changelog |

---

## Estándares de Código VFP

### Nomenclatura Húngara

```foxpro
* Parámetros de funciones/procedimientos
LPARAMETERS tcNombre, tnEdad, tlActivo, toObjeto, taArray
* tc = text character, tn = numeric, tl = logical, to = object, ta = array

* Variables locales
LOCAL lcVariable, lnContador, llFlag, loObjeto, laLista
* l = local

* Propiedades de clase
THIS.cPropiedad = ""   && character
THIS.nPropiedad = 0    && numeric
THIS.lPropiedad = .F.  && logical
THIS.oPropiedad = NULL && object
```

---

## Organización de Archivos - TOLERANCIA CERO

### Archivos permitidos

- **Raíz limpia**: Solo archivos esenciales de producción
- **.github/ limpio**: Estructura definida (agents/, instructions/, prompts/, skills/)
- **Proyectos**: Cada carpeta Organic.* tiene su estructura definida

### Archivos PROHIBIDOS

- **NO crear archivos de reporte**: FINAL-STATUS-REPORT.*, *-ANALYSIS.*, *-SUMMARY.*
- **NO crear archivos temporales**: .tmp, .bak, .old, debug-*, test-*
- **PROHIBIDO en .github/**: *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md, *-REPORT.md
- **NO carpeta docs/**: GitHub Copilot NO la lee automáticamente

---

## Referencias

- [README.md](README.md) - Guía completa de uso
- [STRUCTURE.md](STRUCTURE.md) - Vista visual de la estructura
- [AGENTS.md](AGENTS.md) - Índice de agentes