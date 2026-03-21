---
description: Auditoria de PromptOps - verifica integridad, consistencia y calidad de documentacion de agentes, prompts e instructions
argument-hint: "Opcional: especifica área a auditar (referencias, nomenclatura, comandos)"
---

# Auditoria PromptOps

## Objetivo

Ejecutar auditoria completa del sistema PromptOps (Agents, Prompts, Instructions) verificando integridad de referencias, consistencia de nomenclatura, eliminacion de duplicaciones y alineacion con mejores practicas.

## Checklist de Auditoria

### 1. Integridad de Referencias

**Verificar:**
- Todas las rutas de archivos mencionadas existen
- Links entre documentos funcionan correctamente
- Referencias a prompts/instructions son validas
- No hay referencias a archivos/carpetas eliminados

**Archivos criticos:**
- `AGENTS.md` (raiz del repo)
- `.github/copilot-instructions.md`
- `.github/instructions/*.instructions.md`
- `Organic.*/AGENTS.md`

### 2. Consistencia de Nomenclatura

**Convenciones:**
- Prompts: `nombre-descriptivo.prompt.md` (kebab-case)
- Instructions: `nombre-descriptivo.instructions.md` (kebab-case)
- Agentes: `AGENTS.md` (mayusculas)
- Categorias prompts: auditoria/, dev/, refactor/, test/

### 3. Deteccion de Duplicacion

**Areas propensas:**
- Nomenclatura hungara VFP (debe estar solo en instructions)
- Ejemplos de comandos DOVFP
- Estructura de clases VFP

**Regla:** Si el contenido es identico, consolidar en un solo lugar.

### 4. Formato de Archivos

**Instructions (.instructions.md):**
```yaml
---
applyTo: "patron-glob"
description: Descripcion breve
---
```

**Prompts (.prompt.md):**
```yaml
---
description: Descripcion breve
---
```

**AGENTS.md:** Sin frontmatter, se activa por ubicacion en el arbol de directorios.

### 5. Comandos DOVFP Verificados

Siempre validar con `dovfp help -command <comando>` antes de documentar.

**Comandos principales:**
- `dovfp build` - Compilar proyecto
- `dovfp run` - Ejecutar proyecto
- `dovfp test` - Ejecutar tests
- `dovfp restore` - Restaurar dependencias
- `dovfp clean` - Limpiar artefactos

### 6. Reglas Criticas

- NO crear archivos temporales (*-LOG.md, *-REPORT.md)
- NO documentar estructuras de archivos inventadas
- NO usar opciones de comandos sin verificar
- NO referencias a carpeta `docs/` (no existe)

## Plantilla de Reporte

```markdown
## Auditoria PromptOps - [Fecha]

**Workspace:** Organic.Drawing

### Resumen
- Referencias verificadas: X/X
- Nomenclatura correcta: X/X
- Duplicaciones encontradas: X
- Errores criticos: X

### Acciones Requeridas
1. [Accion prioritaria]
2. [Siguiente accion]
```

## Uso del Prompt

```
@workspace #prompt:promptops-audit Ejecuta auditoria completa del sistema PromptOps

@workspace #prompt:promptops-audit Verifica solo integridad de referencias

@workspace #prompt:promptops-audit Verifica comandos DOVFP en toda la documentacion
```
