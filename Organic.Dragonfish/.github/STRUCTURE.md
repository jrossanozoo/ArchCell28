# 🗂️ Estructura del Sistema PromptOps

Vista visual de la organización de archivos de personalización de GitHub Copilot.

```
.github/
│
├── 📄 copilot-instructions.md          # Contexto principal del proyecto
│                                        # ✅ Siempre activo
│
├── 📄 AGENTS.md                         # Índice de agentes disponibles
│                                        # Referencias a agents/ y proyectos
│
├── 📄 README.md                         # Guía de uso del sistema
│
├── 📄 STRUCTURE.md                      # Este archivo
│
├── 🤖 agents/                           # AGENTES ESPECIALIZADOS
│   │                                    # Formato: *.agent.md con frontmatter
│   │
│   ├── developer.agent.md              # 👨‍💻 Desarrollo VFP
│   │   └── tools: read_file, grep_search, replace_string_in_file...
│   │
│   ├── test-engineer.agent.md          # 🧪 Testing y QA  
│   │   └── tools: read_file, create_file, run_in_terminal...
│   │
│   ├── auditor.agent.md                # 🔍 Auditoría de código
│   │   └── tools: read_file, grep_search, list_code_usages...
│   │
│   └── refactor.agent.md               # 🔄 Refactorización
│       └── tools: read_file, replace_string_in_file, semantic_search...
│
├── 📋 instructions/                     # REGLAS AUTOMÁTICAS
│   │                                    # Formato: *.instructions.md con applyTo
│   │
│   ├── vfp-development.instructions.md
│   │   └── applyTo: **/*.prg, **/*.vcx, **/*.scx, **/*.frx, **/*.h
│   │
│   ├── testing.instructions.md
│   │   └── applyTo: **/Tests/**, **/*Test*.prg, **/Organic.Tests/**
│   │
│   └── dovfp-build.instructions.md
│       └── applyTo: **/*.vfpproj, **/*.vfpsln, **/*.ps1
│
├── 📝 prompts/                          # TEMPLATES MANUALES
│   │                                    # Formato: *.prompt.md con frontmatter
│   │
│   ├── auditoria/
│   │   ├── code-audit-comprehensive.prompt.md    # Auditoría integral
│   │   └── promptops-audit.prompt.md             # Auditar PromptOps
│   │
│   ├── dev/
│   │   ├── vfp-development-expert.prompt.md      # Desarrollo experto
│   │   └── dovfp-build-integration.prompt.md     # Integración DOVFP
│   │
│   ├── refactor/
│   │   ├── refactor-patterns.prompt.md           # Patrones refactor
│   │   └── fix-vcx-loadreference.prompt.md       # Fix referencias VCX
│   │
│   └── test/
│       ├── test-coverage.prompt.md               # Análisis cobertura
│       └── test-generation.prompt.md             # Generar tests
│
└── 📚 skills/                           # CONOCIMIENTO REUTILIZABLE
    │                                    # Formato: SKILL.md (sin frontmatter)
    │
    ├── code-audit/
    │   └── SKILL.md                     # Checklists de auditoría
    │
    └── release-notes/
        └── SKILL.md                     # Templates de changelog
```

## 📍 Agentes en Proyectos

Además de los agents en `.github/agents/`, cada proyecto tiene su AGENTS.md contextual:

```
Organic.Dragonfish/
│
├── Organic.BusinessLogic/
│   └── AGENTS.md                        # 👨‍💻 Desarrollador lógica de negocio
│
├── Organic.Generated/
│   └── AGENTS.md                        # ⚙️ Gestor código generado
│
├── Organic.Tests/
│   └── AGENTS.md                        # 🧪 Ingeniero de testing
│
├── Organic.Hooks/
│   └── AGENTS.md                        # 🔌 Desarrollador de extensiones
│
└── Organic.Mocks/
    └── AGENTS.md                        # 🎭 Gestor de mocks
```

## 🔗 Relación entre Componentes

```
┌────────────────────────────────────────────────────────────────┐
│                    copilot-instructions.md                      │
│                    (Siempre activo - contexto base)            │
└────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│   instructions/   │ │     prompts/      │ │     skills/       │
│                   │ │                   │ │                   │
│ Automático según  │ │ Manual via        │ │ Conocimiento      │
│ tipo de archivo   │ │ #file:...         │ │ compartido        │
└──────────────────┘ └──────────────────┘ └──────────────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              ▼
                    ┌──────────────────┐
                    │     agents/       │
                    │                   │
                    │ Especializados    │
                    │ por rol           │
                    └──────────────────┘
```
