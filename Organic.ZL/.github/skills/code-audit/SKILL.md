# Skill: Code Audit VFP

## Descripción

Skill de auditoría de código para proyectos Visual FoxPro 9. Proporciona checklists, patrones de búsqueda y formatos de reporte para análisis de calidad.

## Cuándo Usar

- Al revisar código antes de merge/PR
- Al evaluar calidad de código existente
- Al buscar vulnerabilidades de seguridad
- Al identificar problemas de performance
- Al verificar cumplimiento de estándares

## Checklist de Auditoría

### 1. Seguridad

- [ ] **SQL Injection**: Buscar concatenación directa en queries
  ```foxpro
  * Patrón a buscar: SELECT.*\+.*pcParametro
  * Patrón a buscar: WHERE.*=.*'.*\+
  ```
- [ ] **Credenciales hardcodeadas**: Buscar passwords en código
  ```foxpro
  * Buscar: password|pwd|clave|secret|token
  ```
- [ ] **Path traversal**: Rutas de usuario sin validar
- [ ] **Datos sensibles en logs**: PII expuesta

### 2. Performance

- [ ] **SCAN loops**: Buscar `SCAN FOR` que pueden ser SQL
- [ ] **Recursos no liberados**: `USE` sin correspondiente `USE IN`
- [ ] **String concatenation**: Uso excesivo de operador `+`
- [ ] **Queries N+1**: SELECT dentro de loops

### 3. Calidad

- [ ] **Métodos largos**: Buscar procedimientos >100 líneas
- [ ] **Complejidad**: Contar IF/CASE/FOR/WHILE anidados
- [ ] **Magic numbers**: Valores numéricos sin constantes
- [ ] **Código muerto**: Bloques comentados o inalcanzables

### 4. Estándares

- [ ] **Nomenclatura húngara**: Variables con prefijos correctos
- [ ] **Headers**: Archivos y procedimientos documentados
- [ ] **Error handling**: TRY...CATCH en operaciones riesgosas
- [ ] **LOCAL declaradas**: Variables locales explícitas

## Comandos de Búsqueda

```powershell
# Buscar SQL Injection potencial
grep -rn "SELECT.*\+" *.prg

# Buscar SCAN que podrían ser SQL
grep -rn "SCAN FOR" *.prg

# Buscar credenciales
grep -rni "password\|pwd\|clave" *.prg

# Buscar recursos no cerrados
grep -rn "USE " *.prg | grep -v "USE IN"

# Contar líneas por procedimiento
# (usar herramienta específica de análisis)
```

## Formato de Reporte

```markdown
# REPORTE DE AUDITORÍA
Fecha: [YYYY-MM-DD HH:MM:SS]
Auditor: GitHub Copilot
Alcance: [Archivos analizados]

## RESUMEN EJECUTIVO
- Total archivos: [N]
- Líneas de código: [N]
- Críticos: [N] | Advertencias: [N] | Sugerencias: [N]

## 🔴 CRÍTICO (Severidad Alta)

### [ID] Título del hallazgo
- **Archivo**: [ruta:línea]
- **Descripción**: [Qué es el problema]
- **Impacto**: [Consecuencias]
- **Código problemático**:
  ```foxpro
  [código]
  ```
- **Solución recomendada**:
  ```foxpro
  [código corregido]
  ```

## 🟡 ADVERTENCIAS (Severidad Media)
[Mismo formato]

## 🔵 SUGERENCIAS (Severidad Baja)
[Mismo formato]

## 📊 MÉTRICAS

| Métrica | Valor | Estado |
|---------|-------|--------|
| Cumplimiento estándares | XX% | ✅/⚠️/🔴 |
| Complejidad promedio | X.X | ✅/⚠️/🔴 |
| Cobertura documentación | XX% | ✅/⚠️/🔴 |
| Deuda técnica estimada | Xh | ✅/⚠️/🔴 |

## ✅ FORTALEZAS DETECTADAS
- [Buena práctica 1]
- [Buena práctica 2]

## 🎯 PLAN DE ACCIÓN RECOMENDADO
1. **Inmediato** (esta semana): [Críticos]
2. **Corto plazo** (este sprint): [Advertencias]
3. **Mediano plazo** (próximo mes): [Sugerencias]
```

## Herramientas Recomendadas

- **read_file**: Leer contenido de archivos a auditar
- **grep_search**: Buscar patrones específicos en código
- **semantic_search**: Encontrar código relacionado
- **list_code_usages**: Ver usos de funciones/clases
- **get_errors**: Detectar errores de compilación

## Thresholds Recomendados

| Métrica | Bueno | Aceptable | Mejorar |
|---------|-------|-----------|---------|
| Complejidad método | <10 | 10-15 | >15 |
| Líneas por método | <50 | 50-100 | >100 |
| Profundidad anidación | <3 | 3-4 | >4 |
| Cumplimiento estándares | >90% | 70-90% | <70% |
