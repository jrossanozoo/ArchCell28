# Organic.Core - Instrucciones para GitHub Copilot

## Contexto del Proyecto

**Proyecto**: Organic.Core  
**Stack**: Visual FoxPro 9 + DOVFP (compilador .NET 6) + VS Code  
**CI/CD**: Azure DevOps  
**Sistema PromptOps**: 3 capas (Agents, Prompts, Instructions)

---

## Estructura del Proyecto

| Carpeta | Propósito | Editable |
|---------|-----------|----------|
| `Organic.BusinessLogic/` | Código de negocio (CENTRALSS/) | ✅ Sí |
| `Organic.Generated/` | Código generado automáticamente | ❌ NO |
| `Organic.Tests/` | Tests unitarios y funcionales | ✅ Sí |
| `Organic.Mocks/` | Mocks para testing | ✅ Sí |

### Archivos clave
- `*.vfpsln` - Solución que agrupa proyectos
- `*.vfpproj` - Proyecto individual
- `azure-pipelines.yml` - Pipeline CI/CD
- `Nuget.config` - Paquetes DOVFP

---

## 🤖 Agentes Disponibles

| Agent | Uso | Archivo |
|-------|-----|---------|
| **Developer** | Desarrollo de features | `#file:.github/agents/developer.agent.md` |
| **Test Engineer** | Testing y QA | `#file:.github/agents/test-engineer.agent.md` |
| **Auditor** | Code review | `#file:.github/agents/auditor.agent.md` |
| **Refactor** | Refactoring SOLID | `#file:.github/agents/refactor.agent.md` |

Ver índice completo: [AGENTS.md](AGENTS.md)

---

## 📜 Instructions (Automáticas)

| Archivo | Se aplica a | Propósito |
|---------|-------------|-----------|
| `vfp-development.instructions.md` | `*.prg`, `*.vcx`, `*.scx` | Estándares VFP |
| `testing.instructions.md` | `**/Tests/**`, `**/Mocks/**` | Testing y QA |
| `dovfp-build.instructions.md` | `*.vfpproj`, `*.ps1` | Build system |

---

## 📝 Prompts Disponibles

### Desarrollo
- `#file:.github/prompts/dev/vfp-development-expert.prompt.md`
- `#file:.github/prompts/dev/dovfp-build-integration.prompt.md`

### Auditoría
- `#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md`
- `#file:.github/prompts/auditoria/promptops-audit.prompt.md`

### Refactoring
- `#file:.github/prompts/refactor/refactor-patterns.prompt.md`

### Testing
- `#file:.github/prompts/test/test-audit.prompt.md`

---

## 🧠 Skills

| Skill | Propósito |
|-------|-----------|
| [code-audit](skills/code-audit/SKILL.md) | Checklists de auditoría |
| [release-notes](skills/release-notes/SKILL.md) | Generación de changelogs |

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

### ✅ Archivos permitidos
- **Raíz limpia**: Solo archivos esenciales de producción
- **.github/**: AGENTS.md, README.md, STRUCTURE.md, copilot-instructions.md + carpetas

### ❌ Archivos PROHIBIDOS
- **NO reportes**: FINAL-STATUS-REPORT.*, *-ANALYSIS.*, *-SUMMARY.*
- **NO temporales**: .tmp, .bak, .old, debug-*, test-*
- **NO en .github/**: *-LOG.md, *-COMPLETE.md, *-REPORT.md

---

## Comandos DOVFP

```bash
# Compilar
dovfp build Organic.Core.vfpsln

# Tests
dovfp test Organic.Tests/Organic.Tests.vfpproj

# Restaurar
dovfp restore
```

---

## 📚 Documentación

- [README.md](README.md) - Guía de uso del sistema
- [STRUCTURE.md](STRUCTURE.md) - Vista visual de estructura
- [AGENTS.md](AGENTS.md) - Índice de agentes