# 🤖 Índice de Agentes - Organic.Core

Este archivo es el índice centralizado de todos los agentes disponibles para GitHub Copilot en el proyecto Organic.Core (Visual FoxPro 9).

---

## 📋 Agentes Formales (con frontmatter)

Ubicados en `.github/agents/` con formato completo de agent:

| Agent | Archivo | Propósito | Handoff a |
|-------|---------|-----------|-----------|
| **Developer VFP** | [developer.agent.md](agents/developer.agent.md) | Desarrollo de features | test-engineer |
| **Test Engineer** | [test-engineer.agent.md](agents/test-engineer.agent.md) | Testing y QA | auditor |
| **Auditor** | [auditor.agent.md](agents/auditor.agent.md) | Code review y calidad | refactor |
| **Refactor Specialist** | [refactor.agent.md](agents/refactor.agent.md) | Refactoring SOLID | test-engineer |

### Flujo de Handoffs

```
┌─────────────┐     ┌─────────────────┐     ┌───────────┐     ┌────────────┐
│  developer  │ ──→ │  test-engineer  │ ──→ │  auditor  │ ──→ │  refactor  │
└─────────────┘     └─────────────────┘     └───────────┘     └────────────┘
       ↑                                                            │
       └────────────────────────────────────────────────────────────┘
```

### Cómo usar

```
#file:.github/agents/developer.agent.md

Implementa una clase para validación de emails
```

---

## 📁 Agentes Contextuales (por carpeta)

Documentación específica de cada área del proyecto:

| Ubicación | Rol | Propósito |
|-----------|-----|-----------|
| [Organic.BusinessLogic/AGENTS.md](../Organic.BusinessLogic/AGENTS.md) | Desarrollador VFP | Código de negocio |
| [Organic.BusinessLogic/CENTRALSS/AGENTS.md](../Organic.BusinessLogic/CENTRALSS/AGENTS.md) | Source Code Specialist | Código fuente VFP |
| [Organic.Tests/AGENTS.md](../Organic.Tests/AGENTS.md) | Testing Agent | Tests unitarios |
| [Organic.Generated/AGENTS.md](../Organic.Generated/AGENTS.md) | Generated Code Agent | Código generado |
| [Organic.Mocks/AGENTS.md](../Organic.Mocks/AGENTS.md) | Mocks Agent | Mocks para testing |

---

## 🎯 Agente Arquitecto (Este archivo)

**Contexto**: Raíz del proyecto  
**Responsabilidad**: Arquitectura general, compilación, CI/CD

### Capacidades

- **Gestión de soluciones (.vfpsln)**: Coordinar proyectos VFP
- **Compilación con DOVFP**: Build system personalizado
- **Azure DevOps**: Pipelines CI/CD
- **Estructura de workspace**: Organización del proyecto

### Comandos clave

```bash
# Compilar solución
dovfp build Organic.Core.vfpsln

# Restaurar paquetes
dovfp restore

# Ejecutar tests
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

---

## 📚 Recursos Relacionados

### Instructions (se aplican automáticamente)
- [vfp-development.instructions.md](instructions/vfp-development.instructions.md) → `*.prg`, `*.vcx`
- [testing.instructions.md](instructions/testing.instructions.md) → `**/Tests/**`
- [dovfp-build.instructions.md](instructions/dovfp-build.instructions.md) → `*.vfpproj`, `*.ps1`

### Prompts (invocación manual)
- [Desarrollo VFP](prompts/dev/vfp-development-expert.prompt.md)
- [Build DOVFP](prompts/dev/dovfp-build-integration.prompt.md)
- [Auditoría de código](prompts/auditoria/code-audit-comprehensive.prompt.md)
- [Refactoring](prompts/refactor/refactor-patterns.prompt.md)
- [Testing](prompts/test/test-audit.prompt.md)

### Skills
- [Code Audit](skills/code-audit/SKILL.md) - Checklists de auditoría
- [Release Notes](skills/release-notes/SKILL.md) - Generación de changelogs

---

## 📖 Documentación del Sistema

- [README.md](README.md) - Guía de uso completa
- [STRUCTURE.md](STRUCTURE.md) - Vista visual de la estructura
- [copilot-instructions.md](copilot-instructions.md) - Configuración principal
