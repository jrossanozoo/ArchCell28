# Skill: Code Audit

## Descripción

Conocimiento y checklists para realizar auditorías de código en proyectos Visual FoxPro. Incluye patrones a buscar, métricas de calidad y formato de reportes.

---

## Cuándo Usar

- Al revisar código antes de merge/PR
- En auditorías periódicas de calidad
- Al evaluar código legacy para refactoring
- Cuando hay dudas sobre calidad de implementación

---

## Checklist Completo de Auditoría VFP

### 📋 Variables y Nomenclatura

```
□ Todas las variables declaradas como LOCAL
□ Nomenclatura húngara correcta:
  - tc/lc = character
  - tn/ln = numeric
  - tl/ll = logical
  - to/lo = object
  - ta/la = array
□ Nombres descriptivos (no abreviaciones crípticas)
□ Sin variables PRIVATE/PUBLIC innecesarias
```

### 📋 Estructura de Clases

```
□ DEFINE CLASS ... AS ParentClass OF archivo.prg
□ Propiedades declaradas antes de métodos
□ Init() llama DODEFAULT()
□ Destroy() llama DODEFAULT()
□ Destroy() libera recursos (objetos = NULL)
□ Métodos protegidos marcados con PROTECTED
□ Herencia máximo 4 niveles
```

### 📋 Manejo de Errores

```
□ TRY/CATCH en operaciones críticas:
  - Acceso a archivos
  - Conexiones de base de datos
  - Llamadas a API externas
  - Operaciones de red
□ FINALLY para limpieza de recursos
□ Excepciones logueadas apropiadamente
□ Mensajes de error descriptivos
```

### 📋 Acceso a Datos

```
□ SQL preferido sobre SCAN/ENDSCAN
□ Cursores cerrados después de uso
□ USE ... IN 0 SHARED cuando posible
□ Transacciones (BEGIN/END TRANSACTION) para operaciones múltiples
□ Índices utilizados en WHERE clauses
□ SET DELETED ON activo
```

### 📋 Performance

```
□ Sin concatenación de strings en loops
□ Arrays dimensionados apropiadamente
□ Objetos reutilizados vs recreados
□ Consultas SQL optimizadas
□ Sin SELECT * (listar campos específicos)
```

### 📋 Documentación

```
□ Header de archivo con propósito
□ Comentarios en lógica compleja
□ Parámetros documentados
□ Return values documentados
```

---

## Patrones de Búsqueda (grep_search)

### Buscar Variables No Declaradas
```regex
^\s*(PROCEDURE|FUNCTION).*\n(?!.*LOCAL)
```

### Buscar SCAN sin SQL alternativo
```regex
SCAN\s+(FOR|WHILE)?
```

### Buscar Concatenación en Loops
```regex
(FOR|SCAN|DO WHILE)[\s\S]*?\+\s*["']
```

### Buscar TRY sin CATCH
```regex
TRY\s*\n(?![\s\S]*?CATCH)
```

---

## Métricas de Calidad

| Métrica | Objetivo | Crítico |
|---------|----------|---------|
| Líneas por método | < 50 | > 100 |
| Complejidad ciclomática | < 10 | > 20 |
| Niveles de herencia | < 4 | > 5 |
| Parámetros por método | < 5 | > 7 |
| Nivel de anidamiento | < 3 | > 5 |

---

## Template de Reporte

```markdown
# Reporte de Auditoría de Código

**Fecha**: [YYYY-MM-DD]
**Archivo(s)**: [rutas]
**Auditor**: GitHub Copilot

## Resumen Ejecutivo

| Categoría | Problemas | Severidad |
|-----------|-----------|-----------|
| Variables | X | 🔴/🟡/🟢 |
| Clases | X | 🔴/🟡/🟢 |
| Errores | X | 🔴/🟡/🟢 |
| Performance | X | 🔴/🟡/🟢 |

## Hallazgos Detallados

### 🔴 Críticos (Bloquean)
1. [Descripción] - Línea X
   - **Problema**: ...
   - **Solución**: ...

### 🟡 Importantes (Corregir pronto)
1. [Descripción] - Línea X

### 🟢 Menores (Mejora)
1. [Descripción] - Línea X

## Recomendaciones Prioritarias
1. ...
2. ...
3. ...

## Métricas Calculadas
- Líneas de código: X
- Métodos: X
- Complejidad promedio: X
```

---

## Herramientas Recomendadas

| Herramienta | Uso |
|-------------|-----|
| `grep_search` | Buscar patrones problemáticos |
| `read_file` | Leer código para análisis |
| `list_code_usages` | Ver usos de métodos/clases |
| `get_errors` | Identificar errores de compilación |
| `semantic_search` | Buscar código relacionado |
