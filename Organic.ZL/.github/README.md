# 📚 Sistema GitHub Copilot Customization - Guía de Uso

Este directorio contiene el sistema completo de personalización de GitHub Copilot para el proyecto **Organic.ZL** (Visual FoxPro 9).

## 🎯 Qué es este sistema

Un framework de 4 capas que mejora la experiencia con GitHub Copilot:

| Capa | Propósito | Activación |
|------|-----------|------------|
| **Agents** | Perfiles especializados con herramientas y handoffs | Manual: `@agent-name` |
| **Instructions** | Reglas automáticas por tipo de archivo | Automática por glob pattern |
| **Prompts** | Templates invocables para tareas específicas | Manual: `#file:.github/prompts/...` |
| **Skills** | Conocimiento reutilizable y checklists | Referencia en conversaciones |

---

## 🚀 Cómo Usar

### Agents (.agent.md)

Los agents son perfiles especializados con herramientas predefinidas y capacidad de handoff entre ellos.

**Agents disponibles:**

| Agent | Ubicación | Propósito |
|-------|-----------|-----------|
| `developer` | `.github/agents/developer.agent.md` | Desarrollo de features VFP |
| `test-engineer` | `.github/agents/test-engineer.agent.md` | Testing y validación |
| `auditor` | `.github/agents/auditor.agent.md` | Code review y calidad |
| `refactor` | `.github/agents/refactor.agent.md` | Mejora de código existente |

**Uso:**
```
@workspace Usando el agente developer, implementa una clase para...
```

### Instructions (.instructions.md)

Las instructions se aplican automáticamente según el tipo de archivo que estés editando.

**Instructions activas:**

| Archivo | Se aplica a | Propósito |
|---------|-------------|-----------|
| `vfp-coding-standards` | `**/*.{prg,vcx,scx,frx}` | Estándares de código VFP |
| `vfp-development` | Todos los archivos | Guía de desarrollo |
| `testing` | Archivos de test | Guía de testing |
| `dovfp-build` | Archivos de build | Compilación DOVFP |

### Prompts (.prompt.md)

Los prompts son templates invocables manualmente para tareas específicas.

**Prompts disponibles:**

```
# Auditoría
#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md
#file:.github/prompts/auditoria/promptops-audit.prompt.md

# Desarrollo
#file:.github/prompts/dev/vfp-development-expert.prompt.md
#file:.github/prompts/dev/dovfp-build-integration.prompt.md

# Refactoring
#file:.github/prompts/refactor/refactor-patterns.prompt.md

# Testing
#file:.github/prompts/test/test-audit.prompt.md
```

**Uso en Copilot Chat:**
```
#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md

Audita el archivo ClienteBusiness.prg
```

### Skills (SKILL.md)

Skills son conocimiento reutilizable con checklists y templates.

**Skills disponibles:**

| Skill | Ubicación | Propósito |
|-------|-----------|-----------|
| Code Audit | `.github/skills/code-audit/SKILL.md` | Checklists de auditoría |
| Release Notes | `.github/skills/release-notes/SKILL.md` | Generación de changelog |

**Uso:**
```
Usando el skill de code-audit, revisa la seguridad del módulo de ventas
```

---

## 📁 Estructura del Directorio

```
.github/
├── README.md                    # Esta guía
├── STRUCTURE.md                 # Vista visual de la estructura
├── AGENTS.md                    # Índice de agentes disponibles
├── copilot-instructions.md      # Configuración principal Copilot
├── agents/                      # Agentes especializados
│   ├── developer.agent.md
│   ├── test-engineer.agent.md
│   ├── auditor.agent.md
│   └── refactor.agent.md
├── instructions/                # Reglas automáticas
│   ├── vfp-coding-standards.instructions.md
│   ├── vfp-development.instructions.md
│   ├── testing.instructions.md
│   └── dovfp-build.instructions.md
├── prompts/                     # Templates invocables
│   ├── auditoria/
│   ├── dev/
│   ├── refactor/
│   └── test/
└── skills/                      # Conocimiento reutilizable
    ├── code-audit/
    └── release-notes/
```

---

## 🔄 Flujo de Trabajo Recomendado

### Desarrollo de Nueva Feature

1. **Iniciar** con `developer` agent
2. **Implementar** código siguiendo instructions de VFP
3. **Handoff** a `test-engineer` para crear tests
4. **Handoff** a `auditor` para revisión de código

### Corrección de Bug

1. **Analizar** con `auditor` agent
2. **Handoff** a `developer` para implementar fix
3. **Handoff** a `test-engineer` para test de regresión

### Refactorización

1. **Identificar** con `auditor` agent
2. **Handoff** a `refactor` para aplicar mejoras
3. **Handoff** a `test-engineer` para validar comportamiento

---

## ⚙️ Configuración VS Code

Las siguientes configuraciones están en `.vscode/settings.json`:

```json
{
    "chat.promptFiles": true,
    "chat.useAgentSkills": true,
    "chat.useNestedAgentsMdFiles": true,
    "chat.promptFilesLocations": [".github/prompts", ".github/skills"],
    "github.copilot.chat.codesearch.enabled": true,
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

---

## 🛠️ Mantenimiento

### Trimestral

- [ ] Revisar y actualizar agents según nuevas necesidades
- [ ] Validar que instructions reflejan estándares actuales
- [ ] Actualizar prompts con nuevos casos de uso
- [ ] Refrescar skills con aprendizajes del equipo

### Al Agregar Nuevo Módulo

1. Actualizar instructions si hay patrones específicos
2. Crear prompts si hay tareas repetitivas
3. Documentar en AGENTS.md si afecta flujo de trabajo

---

## 📖 Referencias

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot Chat Custom Instructions](https://docs.github.com/en/copilot/customizing-copilot)
- Estándares del proyecto: `.github/instructions/vfp-coding-standards.instructions.md`
