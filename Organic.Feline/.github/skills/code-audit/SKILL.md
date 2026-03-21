# Skill: Code Audit

## Descripción
Conocimiento estructurado para realizar auditorías de código Visual FoxPro 9. Incluye checklists, patrones a buscar y formatos de reporte.

## Cuándo Usar
- Antes de un release mayor
- Al heredar código legacy
- Revisiones de código periódicas
- Evaluación de calidad de nuevos desarrollos
- Identificación de deuda técnica

## Checklist de Auditoría

### 🔴 Seguridad (Crítico)
- [ ] SQL Injection: Buscar concatenación de SQL sin parametrización
- [ ] Credenciales hardcodeadas: Passwords, connection strings en código
- [ ] Validación de entrada: Datos de usuario sin sanitizar
- [ ] Permisos de archivos: Operaciones sin validación

### 🟡 Performance (Importante)
- [ ] Cursores abiertos: SELECT sin USE IN posterior
- [ ] Loops ineficientes: SCAN sin filtros, loops anidados
- [ ] Consultas N+1: Queries en loops
- [ ] Índices: Búsquedas sin SEEK en tablas indexadas
- [ ] Memoria: Objetos no liberados, arrays sin DIMENSION inicial

### 🟢 Mantenibilidad (Buenas Prácticas)
- [ ] Métodos largos: >50 líneas
- [ ] Complejidad ciclomática: >10 paths
- [ ] Duplicación de código: Bloques repetidos
- [ ] Anidamiento profundo: IF/FOR >3 niveles
- [ ] Magic numbers: Números sin constantes
- [ ] Nomenclatura: Consistencia en nombres

### ✅ Documentación
- [ ] Comentarios en procedimientos complejos
- [ ] Headers de clase con propósito
- [ ] Parámetros documentados

## Patrones a Buscar con grep_search

```
# SQL Injection potencial
"SELECT.*\+.*tc|tn"

# Credenciales hardcodeadas
"password|pwd|secret|token.*=.*['\"]"

# SET TALK ON (debe estar OFF en producción)
"SET TALK ON"

# Variables públicas excesivas
"^PUBLIC "

# Conexiones sin cerrar
"SQLCONNECT.*[^SQLDISCONNECT]"
```

## Formato de Reporte

```markdown
## [NombreArchivo.prg]

### 🔴 Crítico (N)
| Línea | Tipo | Descripción | Recomendación |
|-------|------|-------------|---------------|
| X | Seguridad | [Descripción] | [Acción] |

### 🟡 Advertencia (N)
| Línea | Tipo | Descripción | Recomendación |
|-------|------|-------------|---------------|
| X | Performance | [Descripción] | [Acción] |

### 🟢 Mejora (N)
| Línea | Tipo | Descripción | Beneficio |
|-------|------|-------------|-----------|
| X | Refactor | [Descripción] | [Beneficio] |

### ✅ Fortalezas
- [Aspectos positivos]

### 📊 Métricas
- Líneas de código: X
- Complejidad promedio: X
- Cobertura de tests: X%
```

## Herramientas Recomendadas
- `read_file`: Para leer código fuente completo
- `grep_search`: Para buscar patrones específicos
- `semantic_search`: Para encontrar código relacionado
- `list_code_usages`: Para ver dónde se usa una función
- `get_errors`: Para ver errores de compilación

## Severidades

| Severidad | Acción | Timeframe |
|-----------|--------|-----------|
| 🔴 Crítico | Corregir inmediatamente | Sprint actual |
| 🟡 Advertencia | Planificar corrección | Próximo sprint |
| 🟢 Mejora | Backlog de tech debt | Cuando sea posible |

## Referencias
- [code-audit-comprehensive.prompt.md](../../prompts/auditoria/code-audit-comprehensive.prompt.md)
- [vfp-development.instructions.md](../../instructions/vfp-development.instructions.md)
