# 📚 GitHub Copilot Customization System

Sistema de personalización de GitHub Copilot para el proyecto **Organic.Core** (Visual FoxPro 9).

## 🎯 Propósito

Este sistema organiza la documentación y configuración para que GitHub Copilot entienda mejor el proyecto y proporcione asistencia más precisa y contextualizada.

---

## 📁 Estructura

```
.github/
├── AGENTS.md                 # Índice de agentes disponibles
├── README.md                 # Esta guía
├── STRUCTURE.md              # Vista visual completa
├── copilot-instructions.md   # Configuración principal de Copilot
├── agents/                   # Agentes especializados (con frontmatter)
│   ├── developer.agent.md
│   ├── test-engineer.agent.md
│   ├── auditor.agent.md
│   └── refactor.agent.md
├── instructions/             # Reglas automáticas por tipo de archivo
│   ├── dovfp-build.instructions.md
│   ├── testing.instructions.md
│   └── vfp-development.instructions.md
├── skills/                   # Conocimiento reutilizable
│   ├── code-audit/
│   └── release-notes/
└── prompts/                  # Templates invocables manualmente
    ├── auditoria/
    ├── dev/
    ├── refactor/
    └── test/
```

---

## 🚀 Cómo Usar

### Invocar Prompts

Los prompts se invocan manualmente en Copilot Chat usando `#file:`:

```
#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md

Analiza el archivo CENTRALSS/mainCore2028.prg
```

### Usar Agents

Los agents proporcionan contexto especializado. Invócalos con `@workspace`:

```
@workspace Usando el agent developer, implementa un nuevo método para validar emails
```

O referencia directamente el archivo del agent:

```
#file:.github/agents/developer.agent.md

Necesito crear una clase para manejo de archivos
```

### Instructions (Automático)

Las instructions se aplican automáticamente según el tipo de archivo que estés editando:

| Archivo | Instruction aplicada |
|---------|---------------------|
| `*.prg`, `*.vcx` | `vfp-development.instructions.md` |
| `**/Tests/**` | `testing.instructions.md` |
| `*.vfpproj`, `*.ps1` | `dovfp-build.instructions.md` |

---

## 🤖 Agents Disponibles

| Agent | Propósito | Handoff a |
|-------|-----------|-----------|
| **developer** | Desarrollo de features VFP | test-engineer |
| **test-engineer** | Testing y QA | auditor |
| **auditor** | Code review y calidad | refactor |
| **refactor** | Mejoras y patrones SOLID | test-engineer |

### Flujo de Handoffs

```
developer → test-engineer → auditor → refactor
     ↑                                    │
     └────────────────────────────────────┘
```

---

## 📝 Prompts por Categoría

### Desarrollo (`prompts/dev/`)
- `vfp-development-expert.prompt.md` - Desarrollo experto VFP
- `dovfp-build-integration.prompt.md` - Build system DOVFP

### Auditoría (`prompts/auditoria/`)
- `code-audit-comprehensive.prompt.md` - Auditoría completa de código
- `promptops-audit.prompt.md` - Auditoría del sistema PromptOps

### Refactoring (`prompts/refactor/`)
- `refactor-patterns.prompt.md` - Patrones de refactoring VFP

### Testing (`prompts/test/`)
- `test-audit.prompt.md` - Auditoría de tests

---

## 🛠️ Skills Disponibles

| Skill | Propósito |
|-------|-----------|
| `code-audit` | Checklists y patrones de auditoría |
| `release-notes` | Generación de notas de versión |

---

## ⚙️ Configuración VS Code

Las configuraciones de Copilot están en `.vscode/settings.json`:

```json
{
    "chat.promptFiles": true,
    "chat.promptFilesLocations": [".github/prompts", ".github/skills"],
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

---

## 📋 Mantenimiento

### Trimestral
- [ ] Revisar que los prompts sigan siendo relevantes
- [ ] Actualizar instructions si cambian estándares
- [ ] Verificar que las rutas en AGENTS.md sean válidas
- [ ] Ejecutar `promptops-audit.prompt.md` para validar integridad

### Al agregar features
- [ ] Crear/actualizar prompts según necesidad
- [ ] Actualizar instructions si hay nuevos patrones
- [ ] Documentar en este README

---

## 📚 Referencias

- [AGENTS.md](AGENTS.md) - Índice completo de agentes
- [STRUCTURE.md](STRUCTURE.md) - Vista detallada de estructura
- [copilot-instructions.md](copilot-instructions.md) - Configuración principal
