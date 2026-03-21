# 🏗️ Estructura del Sistema Copilot Customization

Vista visual completa de la organización del sistema de personalización de GitHub Copilot.

---

## 📁 Árbol de Directorios

```
.github/
│
├── 📄 AGENTS.md                          # Índice principal de agentes
├── 📄 README.md                          # Guía de uso del sistema
├── 📄 STRUCTURE.md                       # Este archivo
├── 📄 copilot-instructions.md            # Configuración principal Copilot
│
├── 🤖 agents/                            # Agentes especializados
│   ├── developer.agent.md                # Desarrollo de features
│   ├── test-engineer.agent.md            # Testing y QA
│   ├── auditor.agent.md                  # Code review
│   └── refactor.agent.md                 # Refactoring SOLID
│
├── 📜 instructions/                      # Reglas automáticas
│   ├── dovfp-build.instructions.md       # → *.vfpproj, *.ps1, azure-pipelines.yml
│   ├── testing.instructions.md           # → **/Tests/**, **/Mocks/**
│   └── vfp-development.instructions.md   # → *.prg, *.vcx, *.scx, *.frx
│
├── 🧠 skills/                            # Conocimiento reutilizable
│   ├── code-audit/
│   │   └── SKILL.md                      # Checklists de auditoría
│   └── release-notes/
│       └── SKILL.md                      # Generación de changelogs
│
└── 📝 prompts/                           # Templates invocables
    ├── auditoria/
    │   ├── code-audit-comprehensive.prompt.md
    │   └── promptops-audit.prompt.md
    ├── dev/
    │   ├── dovfp-build-integration.prompt.md
    │   └── vfp-development-expert.prompt.md
    ├── refactor/
    │   └── refactor-patterns.prompt.md
    └── test/
        └── test-audit.prompt.md
```

---

## 🔗 Relación entre Componentes

### Instructions → Archivos

```
vfp-development.instructions.md
    └─→ **/*.prg
    └─→ **/*.vcx
    └─→ **/*.scx
    └─→ **/*.frx
    └─→ **/*.mnx

testing.instructions.md
    └─→ **/Organic.Tests/**
    └─→ **/Tests/**/*.prg
    └─→ **/Mocks/**/*.prg

dovfp-build.instructions.md
    └─→ **/*.vfpproj
    └─→ **/*.vfpsln
    └─→ **/azure-pipelines.yml
    └─→ **/*.ps1
```

### Agents → Handoffs

```
┌─────────────┐     ┌─────────────────┐     ┌───────────┐     ┌────────────┐
│  developer  │ ──→ │  test-engineer  │ ──→ │  auditor  │ ──→ │  refactor  │
└─────────────┘     └─────────────────┘     └───────────┘     └────────────┘
       ↑                                                            │
       └────────────────────────────────────────────────────────────┘
```

### Prompts → Categorías

```
prompts/
├── auditoria/    # Análisis y revisión de código
├── dev/          # Desarrollo y construcción
├── refactor/     # Mejoras y modernización
└── test/         # Testing y cobertura
```

---

## 📊 Documentación Distribuida

Además de `.github/`, existen AGENTS.md contextuales en cada proyecto:

```
Organic.Core/
├── .github/
│   └── AGENTS.md                    # Índice centralizado
│
├── Organic.BusinessLogic/
│   ├── AGENTS.md                    # Contexto: Desarrollo VFP
│   └── CENTRALSS/
│       └── AGENTS.md                # Contexto: Código fuente
│
├── Organic.Tests/
│   └── AGENTS.md                    # Contexto: Testing
│
├── Organic.Generated/
│   └── AGENTS.md                    # Contexto: Código generado
│
└── Organic.Mocks/
    └── AGENTS.md                    # Contexto: Mocks
```

**Nota**: Los AGENTS.md en subcarpetas proporcionan contexto específico cuando trabajas en esa área. El índice centralizado está en `.github/AGENTS.md`.

---

## 🎯 Uso Rápido

| Necesito... | Usar |
|-------------|------|
| Desarrollar feature | `#file:.github/agents/developer.agent.md` |
| Escribir tests | `#file:.github/agents/test-engineer.agent.md` |
| Revisar código | `#file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md` |
| Refactorizar | `#file:.github/prompts/refactor/refactor-patterns.prompt.md` |
| Entender builds | `#file:.github/prompts/dev/dovfp-build-integration.prompt.md` |

---

## 📋 Archivos por Tipo

### Con Frontmatter YAML

| Tipo | Frontmatter | Ejemplo |
|------|-------------|---------|
| `.instructions.md` | `applyTo`, `description` | `applyTo: "**/*.prg"` |
| `.prompt.md` | `description`, `tools` | `tools: ["read_file"]` |
| `.agent.md` | `name`, `description`, `tools`, `handoffs` | Ver agents/ |

### Sin Frontmatter

| Tipo | Propósito |
|------|-----------|
| `SKILL.md` | Conocimiento/checklists reutilizables |
| `AGENTS.md` (raíz) | Documentación contextual de carpeta |
| `README.md` | Guías de uso |
