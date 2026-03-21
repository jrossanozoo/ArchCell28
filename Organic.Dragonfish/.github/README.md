# 📚 Sistema de Personalización GitHub Copilot

Este directorio contiene la configuración completa de PromptOps para el proyecto **Organic.Dragonfish**.

## 🚀 Inicio Rápido

### Usar un Prompt
```
@workspace #file:.github/prompts/dev/vfp-development-expert.prompt.md
```

### Usar un Agent
Los agents se activan automáticamente según la ubicación del archivo o se pueden invocar:
```
@workspace Usando el agent developer, implementa [funcionalidad]
```

### Ver Instructions Activas
Las instructions se aplican automáticamente según el tipo de archivo que estés editando.

---

## 📁 Estructura

```
.github/
├── copilot-instructions.md    # Configuración principal (siempre activo)
├── AGENTS.md                  # Índice de agentes
├── README.md                  # Esta guía
├── STRUCTURE.md               # Vista visual de la estructura
│
├── agents/                    # Agentes especializados
│   ├── developer.agent.md     # Desarrollo VFP
│   ├── test-engineer.agent.md # Testing y QA
│   ├── auditor.agent.md       # Auditoría de código
│   └── refactor.agent.md      # Refactorización
│
├── instructions/              # Reglas automáticas por contexto
│   ├── vfp-development.instructions.md  # *.prg, *.vcx, *.scx
│   ├── testing.instructions.md          # *Test*, Tests/
│   └── dovfp-build.instructions.md      # *.vfpproj, *.ps1
│
├── prompts/                   # Templates invocables manualmente
│   ├── auditoria/            # Auditorías y análisis
│   ├── dev/                  # Desarrollo
│   ├── refactor/             # Refactorización
│   └── test/                 # Testing
│
└── skills/                    # Conocimiento reutilizable
    ├── code-audit/           # Checklists de auditoría
    └── release-notes/        # Generación de changelogs
```

---

## 🎯 Guía de Uso

### 1. Instructions (Automáticas)

Las instructions se activan automáticamente según el archivo que estés editando:

| Archivo | Instruction Activa |
|---------|-------------------|
| `*.prg`, `*.vcx`, `*.scx` | vfp-development.instructions.md |
| `*Test*`, `Tests/` | testing.instructions.md |
| `*.vfpproj`, `*.ps1` | dovfp-build.instructions.md |

### 2. Prompts (Manuales)

Invoca prompts con `#file:` en el chat:

```
@workspace #file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md
Audita el archivo CENTRALSS/MiClase.prg
```

**Prompts disponibles:**

| Categoría | Prompt | Uso |
|-----------|--------|-----|
| auditoria | code-audit-comprehensive | Auditoría integral de código |
| auditoria | promptops-audit | Auditar sistema PromptOps |
| dev | vfp-development-expert | Desarrollo experto VFP |
| dev | dovfp-build-integration | Configuración DOVFP |
| refactor | refactor-patterns | Patrones de refactorización |
| refactor | fix-vcx-loadreference | Corregir referencias VCX |
| test | test-coverage | Análisis de cobertura |
| test | test-generation | Generar tests |

### 3. Agents (Contextuales)

Los agents proporcionan contexto especializado:

| Agent | Cuándo Usar |
|-------|-------------|
| developer | Implementar funcionalidades |
| test-engineer | Crear/mejorar tests |
| auditor | Revisar calidad de código |
| refactor | Modernizar código legacy |

### 4. Skills (Conocimiento)

Los skills contienen checklists y templates reutilizables:

| Skill | Contenido |
|-------|-----------|
| code-audit | Checklists de auditoría, severidades |
| release-notes | Templates de changelog |

---

## ⚙️ Configuración VS Code

El archivo `.vscode/settings.json` tiene las siguientes configuraciones de Copilot:

```json
{
    "chat.promptFiles": true,
    "chat.promptFilesLocations": [".github/prompts", ".github/skills"],
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

---

## 🔄 Flujo de Trabajo Recomendado

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│Test Engineer│────▶│   Auditor   │────▶│   Refactor  │
│             │     │             │     │             │     │             │
│ Implementar │     │ Crear tests │     │  Revisar    │     │  Mejorar    │
│ feature     │     │ unitarios   │     │  calidad    │     │  código     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                                                                   ▼
                                                          ┌─────────────┐
                                                          │Test Engineer│
                                                          │             │
                                                          │  Validar    │
                                                          │  regresión  │
                                                          └─────────────┘
```

---

## 📋 Mantenimiento Trimestral

Cada 3 meses, ejecutar:

1. **Auditoría PromptOps**: `#file:.github/prompts/auditoria/promptops-audit.prompt.md`
2. **Verificar referencias rotas**
3. **Actualizar patrones obsoletos**
4. **Revisar nuevas capacidades de Copilot**

---

## 🚫 Reglas del Workspace

- **NO crear archivos temporales** en `.github/`
- **NO crear reportes** (*-REPORT.md, *-SUMMARY.md)
- **NO usar carpeta docs/** (Copilot no la lee)
- **Mantener estructura limpia**
