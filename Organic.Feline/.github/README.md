# 🤖 Sistema PromptOps - Organic.Feline

Sistema de personalización de GitHub Copilot para el proyecto Visual FoxPro 9 Organic.Feline.

---

## 📋 Índice

- [Estructura](#estructura)
- [Cómo Usar](#cómo-usar)
- [Agents](#agents)
- [Instructions](#instructions)
- [Prompts](#prompts)
- [Skills](#skills)
- [Mantenimiento](#mantenimiento)

---

## 📁 Estructura

```
.github/
├── AGENTS.md                    # Agente principal (arquitecto)
├── README.md                    # Esta guía
├── STRUCTURE.md                 # Vista visual completa
├── copilot-instructions.md      # Configuración principal Copilot
├── instructions/                # Reglas automáticas por tipo de archivo
│   ├── vfp-development.instructions.md
│   ├── testing.instructions.md
│   └── dovfp-build.instructions.md
├── prompts/                     # Templates invocables manualmente
│   ├── auditoria/              # Auditorías de código y tests
│   ├── dev/                    # Desarrollo y features
│   ├── refactor/               # Refactorización
│   └── test/                   # Testing y cobertura
└── skills/                      # Conocimiento reutilizable
    ├── code-audit/
    └── release-notes/

Organic.*/AGENTS.md              # Agentes por proyecto (activación automática)
```

---

## 🚀 Cómo Usar

### 1. Instructions (Automático)

Las instructions se aplican **automáticamente** según el tipo de archivo que estés editando:

| Archivo | Instruction Aplicada |
|---------|---------------------|
| `*.prg`, `*.vcx`, `*.scx` | `vfp-development.instructions.md` |
| `*test*.prg`, `Tests/**` | `testing.instructions.md` |
| `*.vfpproj`, `*.vfpsln` | `dovfp-build.instructions.md` |

### 2. Prompts (Manual)

Invoca prompts manualmente en Copilot Chat:

```
# Usando el picker de VS Code
Ctrl+I → Escribe "prompt" → Selecciona el prompt deseado

# O referenciando directamente el archivo
@workspace #file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md
```

**Prompts disponibles:**

| Categoría | Prompt | Descripción |
|-----------|--------|-------------|
| **auditoria** | `code-audit-comprehensive` | Auditoría completa de calidad |
| **auditoria** | `test-audit` | Auditoría de cobertura de tests |
| **auditoria** | `promptops-audit` | Auditoría del sistema PromptOps |
| **dev** | `vfp-development-expert` | Desarrollo experto VFP |
| **dev** | `dovfp-build-integration` | Integración con DOVFP |
| **refactor** | `refactor-patterns` | Refactorización con patrones |
| **test** | `test-generation` | Generación de tests unitarios |
| **test** | `test-coverage-analysis` | Análisis de cobertura |

### 3. Agents (Por Ubicación)

Los agents se activan **automáticamente** según la carpeta donde trabajes:

| Ubicación | Agent Activo |
|-----------|--------------|
| Raíz del proyecto | Arquitecto de Soluciones |
| `Organic.BusinessLogic/` | Agente de Código VFP |
| `Organic.Tests/` | Agente de Testing |
| `Organic.Generated/` | Agente de Generación |
| `Organic.Hooks/` | Agente de Hooks |
| `Organic.Mocks/` | Agente de Mocks |

### 4. Skills (Referencia)

Los skills son conocimiento reutilizable que puedes referenciar:

```
@workspace #file:.github/skills/code-audit/SKILL.md Audita este archivo
```

---

## 🤖 Agents

### Arquitecto de Soluciones (Raíz)
- **Archivo**: `.github/AGENTS.md`
- **Responsabilidad**: Arquitectura general, CI/CD, gestión de dependencias
- **Activo cuando**: Trabajas en archivos de la raíz (`.vfpsln`, `azure-pipelines.yml`)

### Agente de Código VFP
- **Archivo**: `Organic.BusinessLogic/AGENTS.md`
- **Responsabilidad**: Desarrollo VFP, patrones, lógica de negocio
- **Activo cuando**: Trabajas en `Organic.BusinessLogic/**`

### Agente de Testing
- **Archivo**: `Organic.Tests/AGENTS.md`
- **Responsabilidad**: Tests unitarios, mocks, cobertura
- **Activo cuando**: Trabajas en `Organic.Tests/**`

### Agente de Generación
- **Archivo**: `Organic.Generated/AGENTS.md`
- **Responsabilidad**: Código generado, estructuras ADN
- **Activo cuando**: Trabajas en `Organic.Generated/**`

---

## 📜 Instructions

| Instruction | applyTo | Propósito |
|-------------|---------|-----------|
| `vfp-development` | `**/*.prg`, `**/*.vcx`, `**/*.scx` | Convenciones VFP, nomenclatura húngara |
| `testing` | `**/*test*`, `**/Tests/**` | Framework de testing, assertions |
| `dovfp-build` | `**/*.vfpproj`, `**/*.vfpsln` | Comandos DOVFP, configuración build |

---

## 📝 Prompts

### Auditoría (`prompts/auditoria/`)
- **code-audit-comprehensive**: Análisis exhaustivo de calidad, seguridad, performance
- **test-audit**: Evaluación de cobertura y calidad de tests
- **promptops-audit**: Verificación del sistema PromptOps

### Desarrollo (`prompts/dev/`)
- **vfp-development-expert**: Guía de desarrollo con mejores prácticas
- **dovfp-build-integration**: Configuración y uso de DOVFP

### Refactorización (`prompts/refactor/`)
- **refactor-patterns**: Aplicar patrones SOLID, eliminar code smells

### Testing (`prompts/test/`)
- **test-generation**: Generar tests unitarios para código existente
- **test-coverage-analysis**: Analizar y mejorar cobertura

---

## 🎯 Skills

### Code Audit (`skills/code-audit/`)
Checklists y patrones para auditoría de código VFP.

### Release Notes (`skills/release-notes/`)
Generación de notas de release y changesets.

---

## 🔧 Mantenimiento

### Revisión Trimestral

Cada 3 meses, ejecutar auditoría de PromptOps:

```
@workspace #file:.github/prompts/auditoria/promptops-audit.prompt.md
```

### Checklist de Mantenimiento

- [ ] Verificar que todas las referencias a archivos sean válidas
- [ ] Actualizar ejemplos de código si cambian patrones
- [ ] Agregar nuevos prompts para casos de uso frecuentes
- [ ] Revisar que los glob patterns en instructions sean correctos
- [ ] Sincronizar documentación con cambios en el proyecto

### Agregar Nuevo Contenido

**Nuevo Prompt:**
1. Crear archivo en `prompts/[categoria]/[nombre].prompt.md`
2. Agregar frontmatter con `description` y `tools`
3. Documentar en este README

**Nueva Instruction:**
1. Crear archivo en `instructions/[nombre].instructions.md`
2. Agregar frontmatter con `applyTo` y `description`
3. Documentar en este README

**Nuevo Skill:**
1. Crear carpeta en `skills/[nombre]/`
2. Crear `SKILL.md` con estructura estándar
3. Documentar en este README

---

## 📚 Referencias

- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [VS Code Copilot Chat](https://code.visualstudio.com/docs/copilot/copilot-chat)
- [DOVFP Documentation](https://dev.azure.com/ZooLogicSA/dovfp)
