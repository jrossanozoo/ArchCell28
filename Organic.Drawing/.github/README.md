# 📚 Sistema GitHub Copilot Customization

## Descripción

Este sistema organiza la personalización de GitHub Copilot para el proyecto **Organic.Drawing** (Visual FoxPro 9 con DOVFP).

## 🗂️ Estructura

```
.github/
├── copilot-instructions.md     # Configuración principal (carga automática)
├── AGENTS.md                   # Índice de agentes disponibles
├── README.md                   # Esta guía
├── STRUCTURE.md                # Vista visual completa
├── agents/                     # Agentes especializados (.agent.md)
├── instructions/               # Reglas automáticas por tipo de archivo
├── skills/                     # Conocimiento reutilizable
└── prompts/                    # Templates invocables manualmente
    ├── auditoria/              # Auditorías de código y sistema
    ├── dev/                    # Desarrollo de features
    ├── refactor/               # Refactoring y mejoras
    └── test/                   # Testing y cobertura
```

## 🚀 Uso Rápido

### Invocar un Prompt

En el chat de Copilot, usa `#file:` seguido de la ruta:

```
#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md

Audita la clase ServicioVentas
```

### Usar un Skill

Los skills proveen contexto adicional:

```
#file:.github/skills/code-audit/SKILL.md

Revisa este código aplicando el checklist
```

### Agentes Disponibles

Los agentes en `.github/agents/` se invocan con `@`:

```
@developer implementa validación de cliente
@test-engineer genera tests para ServicioVentas
```

## 📋 Componentes

### Instructions (Automáticas)

Se aplican **automáticamente** según el tipo de archivo:

| Archivo | Se aplica a | Propósito |
|---------|-------------|-----------|
| `vfp-development.instructions.md` | `*.prg, *.vcx, *.scx, *.frx` | Desarrollo VFP |
| `testing.instructions.md` | `Organic.Tests/**/*`, `Test_*.prg` | Testing |
| `dovfp-build.instructions.md` | `*.vfpproj, *.vfpsln, azure-pipelines.yml` | Build system |

### Prompts (Manuales)

Se invocan explícitamente con `#file:`:

| Categoría | Prompts | Uso |
|-----------|---------|-----|
| **auditoria/** | `code-audit-comprehensive`, `promptops-audit` | Auditorías |
| **dev/** | `vfp-development-expert`, `dovfp-build-integration` | Desarrollo |
| **refactor/** | `refactor-patterns` | Mejoras de código |
| **test/** | `test-audit` | Testing |

### Agents (Con @)

| Agent | Especialización | Handoff a |
|-------|-----------------|-----------|
| `@developer` | Desarrollo de features VFP | `@test-engineer` |
| `@test-engineer` | Testing y QA | `@auditor` |
| `@auditor` | Code review y calidad | `@refactor` |
| `@refactor` | Mejoras SOLID | `@test-engineer` |

### Skills (Conocimiento)

| Skill | Propósito |
|-------|-----------|
| `code-audit/` | Checklists y patrones de auditoría |
| `release-notes/` | Generación de notas de versión |

## ⚙️ Configuración VS Code

Asegúrate de tener en `.vscode/settings.json`:

```json
{
    "chat.promptFiles": true,
    "chat.promptFilesLocations": [".github/prompts", ".github/skills"],
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

## 🔄 Mantenimiento

### Trimestral
- [ ] Revisar que los prompts sigan siendo relevantes
- [ ] Actualizar ejemplos de código
- [ ] Validar comandos DOVFP con `dovfp help`
- [ ] Sincronizar con cambios del proyecto

### Al agregar funcionalidad
- [ ] Crear/actualizar instructions si hay nuevo patrón
- [ ] Agregar prompt si es flujo repetitivo
- [ ] Documentar en este README

## 📖 Referencias

- [copilot-instructions.md](copilot-instructions.md) - Configuración principal
- [AGENTS.md](AGENTS.md) - Índice de agentes
- [STRUCTURE.md](STRUCTURE.md) - Vista visual completa
