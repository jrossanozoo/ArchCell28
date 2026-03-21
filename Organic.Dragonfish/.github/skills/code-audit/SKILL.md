# Skill: Code Audit

## Descripción

Conocimiento y checklists para realizar auditorías de código Visual FoxPro 9, detectando code smells, problemas de calidad y oportunidades de mejora.

## Cuándo Usar

- Antes de un release importante
- Al revisar código de terceros
- Durante code reviews
- Para evaluar deuda técnica
- Al onboardear nuevo código

## Checklist de Auditoría Rápida

### 1. Estructura
- [ ] Métodos < 50 líneas
- [ ] Clases < 500 líneas / < 15 métodos públicos
- [ ] Una responsabilidad por clase
- [ ] Sin código duplicado

### 2. Nomenclatura VFP
- [ ] Parámetros: `tc`, `tn`, `tl`, `to`, `ta`
- [ ] Locales: `lc`, `ln`, `ll`, `lo`, `la`
- [ ] Propiedades: `c`, `n`, `l`, `o`, `a`
- [ ] Nombres descriptivos (no x, tmp, aux)

### 3. Manejo de Errores
- [ ] TRY...CATCH en operaciones críticas
- [ ] Errores logueados (no silenciados)
- [ ] Recursos liberados en FINALLY
- [ ] Destroy() libera objetos

### 4. Performance
- [ ] SQL sobre SCAN/ENDSCAN
- [ ] Índices utilizados (SEEK, INDEXSEEK)
- [ ] Sin queries en loops (N+1)
- [ ] Buffering apropiado

### 5. Seguridad
- [ ] Sin concatenación de SQL (injection)
- [ ] Validación de entrada
- [ ] Sin credenciales en código
- [ ] Logs sin datos sensibles

## Severidades

| Severidad | Símbolo | Descripción |
|-----------|---------|-------------|
| Alta | 🔴 | Bugs potenciales, seguridad, memory leaks |
| Media | 🟡 | Performance, mantenibilidad |
| Baja | 🟢 | Estilo, documentación |

## Template de Reporte

```markdown
## [🔴/🟡/🟢] Título del Issue

**Archivo**: `ruta/archivo.prg`
**Línea**: 123
**Categoría**: [Code Smell | Performance | Seguridad | Estilo]

**Problema**: Descripción clara.

**Código actual**:
```foxpro
* código problemático
```

**Sugerencia**:
```foxpro
* código mejorado
```

**Impacto**: Efecto en el sistema.
```

## Herramientas Recomendadas

- `grep_search`: Buscar patrones problemáticos
- `read_file`: Leer código a auditar
- `list_code_usages`: Ver uso de funciones/clases
- `semantic_search`: Buscar código relacionado

## Patrones a Buscar con grep_search

```
# Magic numbers
grep: "[0-9]+" en archivos .prg

# Variables globales
grep: "PUBLIC|PRIVATE" (fuera de clases)

# SQL sin parámetros
grep: "SELECT.*\+" (concatenación)

# Métodos muy largos
grep: "ENDPROC" y contar líneas

# Sin manejo de errores
grep: "PROCEDURE.*\n(?!.*TRY)"
```
