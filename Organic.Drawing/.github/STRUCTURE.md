# 🏗️ Estructura del Sistema Copilot

## Vista Completa

```
Organic.Drawing/
│
├── .github/
│   │
│   ├── copilot-instructions.md          # 🎯 Configuración principal (auto-carga)
│   ├── AGENTS.md                        # 📋 Índice de agentes
│   ├── README.md                        # 📖 Guía de uso
│   ├── STRUCTURE.md                     # 🏗️ Este archivo
│   │
│   ├── agents/                          # 🤖 Agentes especializados
│   │   ├── developer.agent.md           #    → Desarrollo de features
│   │   ├── test-engineer.agent.md       #    → Testing y QA
│   │   ├── auditor.agent.md             #    → Code review
│   │   └── refactor.agent.md            #    → Mejoras SOLID
│   │
│   ├── instructions/                    # 📜 Reglas automáticas
│   │   ├── vfp-development.instructions.md    # → *.prg, *.vcx, *.scx
│   │   ├── testing.instructions.md            # → Tests y Organic.Tests/
│   │   └── dovfp-build.instructions.md        # → *.vfpproj, *.vfpsln
│   │
│   ├── skills/                          # 🧠 Conocimiento reutilizable
│   │   ├── code-audit/
│   │   │   └── SKILL.md                 #    → Checklists de auditoría
│   │   └── release-notes/
│   │       └── SKILL.md                 #    → Generación de changelog
│   │
│   └── prompts/                         # 💬 Templates invocables
│       ├── auditoria/
│       │   ├── code-audit-comprehensive.prompt.md
│       │   └── promptops-audit.prompt.md
│       ├── dev/
│       │   ├── vfp-development-expert.prompt.md
│       │   └── dovfp-build-integration.prompt.md
│       ├── refactor/
│       │   └── refactor-patterns.prompt.md
│       └── test/
│           └── test-audit.prompt.md
│
├── AGENTS.md                            # 🏠 Agente raíz (Arquitecto)
│
├── Organic.BusinessLogic/
│   ├── AGENTS.md                        # 👨‍💻 Agente desarrollador VFP
│   └── CENTRALSS/                       #    Código fuente principal
│
├── Organic.Tests/
│   ├── AGENTS.md                        # 🧪 Agente testing
│   └── Tests/                           #    Tests unitarios
│
├── Organic.Generated/
│   ├── AGENTS.md                        # ⚙️ Agente generación
│   └── Generados/                       #    Código auto-generado
│
└── Organic.Mocks/
    ├── AGENTS.md                        # 🎭 Agente mocks
    └── Generados/                       #    Mocks generados
```

## Leyenda

| Icono | Tipo | Activación |
|-------|------|------------|
| 🎯 | copilot-instructions | Automática (siempre) |
| 📜 | instructions | Automática (por glob pattern) |
| 💬 | prompts | Manual (`#file:...`) |
| 🤖 | agents | Manual (`@agent`) o por contexto |
| 🧠 | skills | Manual (`#file:...`) |
| 🏠 | AGENTS.md nested | Automática (por directorio) |

## Relaciones

```
┌─────────────────────────────────────────────────────────────────┐
│                    copilot-instructions.md                       │
│                    (Siempre activo)                              │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  instructions/  │  │    agents/      │  │    prompts/     │
│  (Auto por      │  │  (Invocados     │  │  (Invocados     │
│   archivo)      │  │   con @)        │  │   con #file:)   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                         skills/                                  │
│                    (Conocimiento compartido)                     │
└─────────────────────────────────────────────────────────────────┘
```

## Extensiones de Archivo

| Extensión | Tipo | Ubicación |
|-----------|------|-----------|
| `.instructions.md` | Reglas automáticas | `.github/instructions/` |
| `.prompt.md` | Templates manuales | `.github/prompts/*/` |
| `.agent.md` | Agentes especializados | `.github/agents/` |
| `SKILL.md` | Conocimiento | `.github/skills/*/` |
| `AGENTS.md` | Agente por contexto | Cualquier directorio |
