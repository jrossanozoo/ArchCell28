# 🤖 Agentes - Organic.Dragonfish

Sistema de agentes especializados para el proyecto Visual FoxPro 9.

---

## 📋 Agentes Disponibles

### Agentes Globales (`.github/agents/`)

| Agente | Rol | Cuándo Usar |
|--------|-----|-------------|
| [developer](agents/developer.agent.md) | 👨‍💻 Desarrollador VFP | Implementar funcionalidades, código de negocio |
| [test-engineer](agents/test-engineer.agent.md) | 🧪 Ingeniero QA | Crear tests, validar cobertura |
| [auditor](agents/auditor.agent.md) | 🔍 Auditor | Revisar calidad, detectar code smells |
| [refactor](agents/refactor.agent.md) | 🔄 Refactorizador | Modernizar código legacy |

### Agentes de Proyecto (AGENTS.md en cada carpeta)

| Proyecto | Agente | Responsabilidad |
|----------|--------|-----------------|
| [Organic.BusinessLogic](../Organic.BusinessLogic/AGENTS.md) | Desarrollador | Lógica de negocio principal |
| [Organic.Generated](../Organic.Generated/AGENTS.md) | Gestor | Código auto-generado (NO EDITAR) |
| [Organic.Tests](../Organic.Tests/AGENTS.md) | Tester | Tests unitarios y funcionales |
| [Organic.Hooks](../Organic.Hooks/AGENTS.md) | Extensiones | Hooks e integraciones |
| [Organic.Mocks](../Organic.Mocks/AGENTS.md) | Mocks | Clases mock para testing |

---

## 🔄 Flujo de Handoffs

```
┌─────────────┐
│  Developer  │──────────────────────────────────────┐
│             │                                      │
│ Implementar │                                      │
└──────┬──────┘                                      │
       │                                             │
       │ Funcionalidad completa                      │
       ▼                                             │
┌─────────────┐                                      │
│Test Engineer│◀─────────────────────────────────────┤
│             │                                      │
│ Crear tests │                                      │
└──────┬──────┘                                      │
       │                                             │
       │ Tests completos                             │
       ▼                                             │
┌─────────────┐                                      │
│   Auditor   │                                      │
│             │                                      │
│ Revisar     │                                      │
└──────┬──────┘                                      │
       │                                             │
       │ Issues de refactor detectados               │
       ▼                                             │
┌─────────────┐                                      │
│  Refactor   │──────────────────────────────────────┘
│             │    Validar cambios
│ Modernizar  │
└─────────────┘
```

---

## 🎯 Uso con GitHub Copilot Chat

### Invocar Agente Específico
```
@workspace Usando el agent developer, implementa una validación de email
```

### Usar Prompt con Agente
```
@workspace #file:.github/prompts/dev/vfp-development-expert.prompt.md
Implementa la clase EmailValidator
```

### Activación Automática
Los agentes de proyecto se activan automáticamente al trabajar en archivos de su carpeta.

---

## 📚 Recursos Relacionados

- [README.md](README.md) - Guía de uso del sistema
- [STRUCTURE.md](STRUCTURE.md) - Vista visual de la estructura
- [copilot-instructions.md](copilot-instructions.md) - Configuración principal

### Instructions
- [vfp-development.instructions.md](instructions/vfp-development.instructions.md) - Desarrollo VFP
- [testing.instructions.md](instructions/testing.instructions.md) - Testing
- [dovfp-build.instructions.md](instructions/dovfp-build.instructions.md) - Build system

### Prompts
- [Auditoría](prompts/auditoria/) - code-audit, promptops-audit
- [Desarrollo](prompts/dev/) - vfp-expert, dovfp-integration
- [Refactor](prompts/refactor/) - patterns, fix-vcx
- [Testing](prompts/test/) - coverage, generation

### Skills
- [code-audit](skills/code-audit/SKILL.md) - Checklists de auditoría
- [release-notes](skills/release-notes/SKILL.md) - Generación de changelogs