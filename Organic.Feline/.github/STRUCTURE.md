# 📐 Estructura del Sistema PromptOps

Vista visual completa del sistema de personalización de GitHub Copilot.

---

## 🗂️ Árbol de Archivos

```
Organic.Feline/
│
├── .github/                              # 🏠 CENTRO DE PROMPTOPS
│   │
│   ├── AGENTS.md                         # 🤖 Agente Arquitecto (raíz)
│   ├── README.md                         # 📖 Guía de uso
│   ├── STRUCTURE.md                      # 📐 Este archivo
│   ├── copilot-instructions.md           # ⚙️ Configuración principal
│   │
│   ├── instructions/                     # 📜 REGLAS AUTOMÁTICAS
│   │   ├── vfp-development.instructions.md    # → *.prg, *.vcx, *.scx
│   │   ├── testing.instructions.md            # → *test*, Tests/**
│   │   └── dovfp-build.instructions.md        # → *.vfpproj, *.vfpsln
│   │
│   ├── prompts/                          # 📝 TEMPLATES MANUALES
│   │   ├── auditoria/
│   │   │   ├── code-audit-comprehensive.prompt.md
│   │   │   ├── test-audit.prompt.md
│   │   │   └── promptops-audit.prompt.md
│   │   ├── dev/
│   │   │   ├── vfp-development-expert.prompt.md
│   │   │   └── dovfp-build-integration.prompt.md
│   │   ├── refactor/
│   │   │   └── refactor-patterns.prompt.md
│   │   └── test/
│   │       ├── test-generation.prompt.md
│   │       └── test-coverage-analysis.prompt.md
│   │
│   └── skills/                           # 🎯 CONOCIMIENTO REUTILIZABLE
│       ├── code-audit/
│       │   └── SKILL.md
│       └── release-notes/
│           └── SKILL.md
│
├── .vscode/
│   └── settings.json                     # ⚙️ Config Copilot habilitada
│
├── Organic.BusinessLogic/
│   └── AGENTS.md                         # 🧑‍💻 Agente Código VFP
│
├── Organic.Tests/
│   └── AGENTS.md                         # 🧪 Agente Testing
│
├── Organic.Generated/
│   └── AGENTS.md                         # ⚙️ Agente Generación
│
├── Organic.Mocks/
│   └── AGENTS.md                         # 🎭 Agente Mocks
│
└── Organic.Hooks/
    └── AGENTS.md                         # 🔌 Agente Hooks
```

---

## 🔄 Flujo de Activación

```
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB COPILOT CHAT                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  copilot-instructions.md                        │
│              (Siempre activo - contexto base)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   INSTRUCTIONS  │ │     AGENTS      │ │     PROMPTS     │
│   (Automático)  │ │  (Por ubicación)│ │    (Manual)     │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Según extensión │ │ Según carpeta   │ │ #file:... o     │
│ del archivo     │ │ de trabajo      │ │ picker VS Code  │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## 📊 Matriz de Activación

### Instructions → Tipo de Archivo

| Extensión/Patrón | Instruction |
|------------------|-------------|
| `*.prg` | vfp-development |
| `*.vcx`, `*.vct` | vfp-development |
| `*.scx`, `*.sct` | vfp-development |
| `*.frx`, `*.frt` | vfp-development |
| `*test*.prg` | testing |
| `Tests/**/*.prg` | testing |
| `*.vfpproj` | dovfp-build |
| `*.vfpsln` | dovfp-build |
| `azure-pipelines.yml` | dovfp-build |

### Agents → Carpeta de Trabajo

| Carpeta | Agent |
|---------|-------|
| `/` (raíz) | Arquitecto (.github/AGENTS.md) |
| `Organic.BusinessLogic/` | Código VFP |
| `Organic.Tests/` | Testing |
| `Organic.Generated/` | Generación |
| `Organic.Mocks/` | Mocks |
| `Organic.Hooks/` | Hooks |

### Prompts → Caso de Uso

| Necesidad | Prompt |
|-----------|--------|
| Revisar calidad de código | `auditoria/code-audit-comprehensive` |
| Revisar tests | `auditoria/test-audit` |
| Verificar PromptOps | `auditoria/promptops-audit` |
| Desarrollar feature VFP | `dev/vfp-development-expert` |
| Configurar build | `dev/dovfp-build-integration` |
| Mejorar código existente | `refactor/refactor-patterns` |
| Crear tests nuevos | `test/test-generation` |
| Analizar cobertura | `test/test-coverage-analysis` |

---

## 🎨 Convenciones de Nombrado

### Archivos

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Instruction | `kebab-case.instructions.md` | `vfp-development.instructions.md` |
| Prompt | `kebab-case.prompt.md` | `code-audit-comprehensive.prompt.md` |
| Agent | `AGENTS.md` (MAYÚSCULAS) | `AGENTS.md` |
| Skill | `SKILL.md` en carpeta | `skills/code-audit/SKILL.md` |

### Carpetas de Prompts

| Categoría | Contenido |
|-----------|-----------|
| `auditoria/` | Revisiones, análisis, verificaciones |
| `dev/` | Desarrollo, features, implementación |
| `refactor/` | Mejoras, patrones, cleanup |
| `test/` | Testing, cobertura, mocks |

---

## 📈 Estadísticas

| Componente | Cantidad |
|------------|----------|
| **Agents** | 6 |
| **Instructions** | 3 |
| **Prompts** | 8 |
| **Skills** | 2 |
| **Total archivos PromptOps** | 19 |

---

## 🔗 Referencias Cruzadas

### Desde copilot-instructions.md
- → instructions/*.instructions.md
- → prompts/*/*.prompt.md
- → Organic.*/AGENTS.md

### Desde AGENTS.md (proyectos)
- → .github/instructions/
- → .github/prompts/

### Desde Prompts
- → instructions/ (para reglas)
- → skills/ (para checklists)
