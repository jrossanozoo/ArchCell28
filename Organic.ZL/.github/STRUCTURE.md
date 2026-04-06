# 📂 Estructura del Sistema Copilot Customization

Vista visual de la organización completa.

```
.github/
│
├── 📄 README.md                           # Guía de uso del sistema
├── 📄 STRUCTURE.md                        # Este archivo
├── 📄 AGENTS.md                           # Índice de agentes
├── 📄 copilot-instructions.md             # Configuración principal
│
├── 🤖 agents/                             # AGENTES ESPECIALIZADOS
│   ├── developer.agent.md                 # 💻 Desarrollo de features
│   ├── test-engineer.agent.md             # 🧪 Testing y validación
│   ├── auditor.agent.md                   # 🔍 Code review y calidad
│   └── refactor.agent.md                  # 🔄 Mejora de código
│
├── 📋 instructions/                       # REGLAS AUTOMÁTICAS
│   ├── vfp-coding-standards.instructions.md   # Estándares VFP
│   ├── vfp-development.instructions.md        # Guía desarrollo
│   ├── testing.instructions.md                # Guía testing
│   └── dovfp-build.instructions.md            # Build system
│
├── 📝 prompts/                            # TEMPLATES INVOCABLES
│   ├── auditoria/                         # Auditoría de código
│   │   ├── code-audit-comprehensive.prompt.md
│   │   └── promptops-audit.prompt.md
│   ├── dev/                               # Desarrollo
│   │   ├── vfp-development-expert.prompt.md
│   │   └── dovfp-build-integration.prompt.md
│   ├── refactor/                          # Refactorización
│   │   └── refactor-patterns.prompt.md
│   └── test/                              # Testing
│       └── test-audit.prompt.md
│
└── 🧠 skills/                             # CONOCIMIENTO REUTILIZABLE
    ├── code-audit/                        # Auditoría
    │   └── SKILL.md
    └── release-notes/                     # Notas de versión
        └── SKILL.md
```

---

## 🔗 Flujo de Handoffs entre Agents

```
┌─────────────┐     Crear Tests     ┌──────────────────┐
│  developer  │ ──────────────────► │  test-engineer   │
│   💻        │                     │       🧪         │
└─────────────┘                     └──────────────────┘
       │                                    │
       │ Revisar Código                     │ Auditar Tests
       ▼                                    ▼
┌─────────────┐     Refactorizar    ┌──────────────────┐
│   auditor   │ ◄─────────────────► │     refactor     │
│     🔍      │                     │        🔄        │
└─────────────┘                     └──────────────────┘
```

---

## 📊 Matriz de Aplicación de Instructions

| Archivo | vfp-coding | vfp-dev | testing | dovfp-build |
|---------|:----------:|:-------:|:-------:|:-----------:|
| `*.prg` | ✅ | ✅ | - | - |
| `*.vcx` | ✅ | ✅ | - | - |
| `*.scx` | ✅ | ✅ | - | - |
| `*.frx` | ✅ | - | - | - |
| `*Test*.prg` | ✅ | ✅ | ✅ | - |
| `*.vfpproj` | - | - | - | ✅ |
| `*.vfpsln` | - | - | - | ✅ |

---

## 🎯 Guía Rápida de Uso

### Invocar un Agent
```
@workspace Usando el agente [nombre], [tarea]
```

### Invocar un Prompt
```
#file:.github/prompts/[categoria]/[nombre].prompt.md
[Tu solicitud específica]
```

### Referenciar un Skill
```
Usando el skill de [nombre], [tarea]
```

---

## 📍 AGENTS.md por Proyecto

Además del índice central, cada proyecto tiene su propio AGENTS.md:

```
Organic.ZL/
├── .github/AGENTS.md              # Índice central
├── Organic.BusinessLogic/AGENTS.md    # Agent de código VFP
├── Organic.Tests/AGENTS.md            # Agent de testing
└── Organic.Generated/AGENTS.md        # Agent de código generado
```

Estos agents se activan **automáticamente** según la ubicación del archivo que estés editando.
