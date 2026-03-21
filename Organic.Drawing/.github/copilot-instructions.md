# Organic.Drawing - GitHub Copilot Instructions

## Contexto del Proyecto

**Visual FoxPro 9** compilado con **DOVFP** (compilador .NET 6) en VS Code.

## 🤖 Agentes Disponibles

| Agent | Especialización | Invocar con |
|-------|-----------------|-------------|
| Developer | Desarrollo de features VFP | `@developer` |
| Test Engineer | Testing y QA | `@test-engineer` |
| Auditor | Code review y calidad | `@auditor` |
| Refactor | Mejoras SOLID y patrones | `@refactor` |

Ver detalles: [AGENTS.md](AGENTS.md)

## 📜 Instructions (Automáticas)

| Archivo | Se aplica a |
|---------|-------------|
| `vfp-development.instructions.md` | `*.prg, *.vcx, *.scx, *.frx` |
| `testing.instructions.md` | `Organic.Tests/**/*`, `Test_*.prg` |
| `dovfp-build.instructions.md` | `*.vfpproj, *.vfpsln` |

## 💬 Prompts (Invocar con #file:)

| Categoría | Prompt | Uso |
|-----------|--------|-----|
| **auditoria** | `code-audit-comprehensive.prompt.md` | Auditoría completa de código |
| **auditoria** | `promptops-audit.prompt.md` | Auditoría del sistema PromptOps |
| **dev** | `vfp-development-expert.prompt.md` | Desarrollo experto VFP |
| **dev** | `dovfp-build-integration.prompt.md` | Integración con DOVFP |
| **refactor** | `refactor-patterns.prompt.md` | Patrones de refactoring |
| **test** | `test-audit.prompt.md` | Auditoría de testing |

## 🧠 Skills

| Skill | Propósito |
|-------|-----------|\n| `code-audit/SKILL.md` | Checklists de auditoría |
| `release-notes/SKILL.md` | Generación de changelog |

## Estructura del Proyecto

```
Organic.Drawing/
├── Organic.BusinessLogic/   # Código de negocio (CENTRALSS/)
├── Organic.Generated/       # Código generado - NO EDITAR MANUALMENTE
├── Organic.Tests/           # Tests unitarios (FoxUnit)
├── .github/
│   ├── agents/              # Agentes especializados
│   ├── instructions/        # Reglas automáticas
│   ├── skills/              # Conocimiento reutilizable
│   └── prompts/             # Templates invocables
└── Organic.Drawing.vfpsln   # Solución principal
```

## Comandos DOVFP

```bash
# Compilar
dovfp build                              # Proyecto actual
dovfp build -build_debug 2               # Modo Release
dovfp build -build_force 1               # Forzar recompilación

# Ejecutar
dovfp run                                # Ejecutar proyecto
dovfp run -run_args "'config.xml', 123"  # Con argumentos

# Tests
dovfp test                               # Ejecutar tests
dovfp test -test_filter "Test*"          # Filtrar tests
dovfp test -test_coverage 1              # Con cobertura

# Mantenimiento
dovfp restore                            # Restaurar paquetes
dovfp clean                              # Limpiar artefactos
```

## Convenciones VFP

Nomenclatura húngara para parámetros y variables:
- `tc/lc` = character, `tn/ln` = numeric, `tl/ll` = logical, `to/lo` = object, `ta/la` = array
- `t` = parámetro (LPARAMETERS), `l` = local (LOCAL)
- Propiedades de clase: `THIS.cNombre`, `THIS.nEdad`, `THIS.lActivo`, `THIS.oObjeto`

## Reglas Críticas

1. **NO editar** archivos en `Organic.Generated/Generados/` - son auto-generados
2. **NO crear** archivos temporales (*-LOG.md, *-REPORT.md, *.tmp, *.bak)
3. **Usar TRY...CATCH** para operaciones críticas con `goServicios.Errores.LevantarExcepcion()`
4. **Preferir SQL** sobre SCAN...ENDSCAN para mejor rendimiento
5. **Liberar objetos** al final: `loObjeto = NULL`

## Recursos

- Guía de uso: [README.md](README.md)
- Índice de agentes: [AGENTS.md](AGENTS.md)
- Vista de estructura: [STRUCTURE.md](STRUCTURE.md)
- Instrucciones VFP: `.github/instructions/vfp-development.instructions.md`
- Instrucciones Testing: `.github/instructions/testing.instructions.md`
- Instrucciones DOVFP: `.github/instructions/dovfp-build.instructions.md`
