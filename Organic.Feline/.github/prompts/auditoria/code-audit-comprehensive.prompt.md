---
description: "Auditoría comprehensiva de calidad de código para proyectos Visual FoxPro 9"
mode: "agent"
tools: ["read_file", "grep_search", "semantic_search", "list_code_usages", "get_errors"]
---

# 🔍 Auditoría Comprehensiva de Código VFP

## Objetivo
Realizar un análisis exhaustivo de calidad, mantenibilidad, seguridad y adherencia a best practices en código Visual FoxPro 9.

## Alcance del análisis

### 1. Calidad de código
- **Complejidad ciclomática**: Identificar métodos con alta complejidad (>10)
- **Duplicación de código**: Detectar bloques duplicados o similares
- **Longitud de métodos**: Señalar procedimientos/funciones >50 líneas
- **Anidamiento profundo**: Identificar IF/FOR anidados >3 niveles
- **Dead code**: Código comentado, variables no usadas, métodos obsoletos

### 2. Mantenibilidad
- **Nomenclatura**: Consistencia en nombres de variables, procedimientos, clases
- **Documentación**: Presencia y calidad de comentarios explicativos
- **Modularidad**: Cohesión alta y acoplamiento bajo
- **Separación de responsabilidades**: Principio SRP (Single Responsibility)
- **Magic numbers**: Detección de números hardcodeados sin constantes

### 3. Patrones y antipatrones

#### ✅ Patrones recomendados
- Uso de TRY/CATCH para manejo de errores
- Separación de UI y lógica de negocio
- Repository pattern para acceso a datos
- Dependency injection (cuando sea posible)
- Factory pattern para creación de objetos complejos

#### ❌ Antipatrones a detectar
- Variables públicas excesivas (PÚBLICO)
- Uso de GOTO/SKIP sin validación EOF()/BOF()
- Conexiones SQL sin cierre explícito
- SET TALK ON en código de producción
- Hardcoded paths y connection strings
- SELECT 0 sin control de alias

### 4. Seguridad
- **SQL Injection**: Detección de concatenación de SQL sin parametrización
- **Credenciales hardcodeadas**: Passwords, connection strings en código
- **Validación de entrada**: Falta de sanitización de datos de usuario
- **Permisos de archivos**: Operaciones de archivo sin validación de permisos

### 5. Performance
- **Cursores abiertos**: SELECT sin USE IN posterior
- **Loops ineficientes**: SCAN sin filtros, loops anidados pesados
- **Consultas N+1**: Múltiples queries en loops
- **Índices faltantes**: Búsquedas sin SEEK en tablas indexadas
- **Memoria**: Objetos no liberados, arrays grandes sin dimensionamiento inicial

## Formato de reporte

Para cada archivo analizado, genera:

```markdown
## [NombreArchivo.prg]

### 🔴 Crítico (0)
- **Tipo**: [Seguridad/Performance/Bug]
- **Línea**: X
- **Descripción**: [Descripción detallada]
- **Impacto**: [Alto/Medio/Bajo]
- **Recomendación**: [Acción específica]

### 🟡 Advertencia (0)
- **Tipo**: [Calidad/Mantenibilidad]
- **Línea**: X
- **Descripción**: [Descripción]
- **Recomendación**: [Sugerencia]

### 🟢 Mejora (0)
- **Tipo**: [Optimización/Refactor]
- **Línea**: X
- **Descripción**: [Oportunidad de mejora]
- **Beneficio**: [Beneficio esperado]

### ✅ Fortalezas
- [Aspectos positivos del código]

### 📊 Métricas
- **Líneas de código**: X
- **Complejidad ciclomática promedio**: X
- **Cobertura de tests**: X%
- **Documentación**: X%
```

## Ejemplos de detección

### Ejemplo 1: SQL Injection
```foxpro
*-- ❌ VULNERABLE
lcSQL = "SELECT * FROM clientes WHERE nombre = '" + tcNombre + "'"
SQLEXEC(gnHandle, lcSQL)

*-- ✅ CORRECTO
lcSQL = "SELECT * FROM clientes WHERE nombre = ?tcNombre"
SQLEXEC(gnHandle, lcSQL)
```

### Ejemplo 2: Recursos no liberados
```foxpro
*-- ❌ INCORRECTO
SELECT * FROM clientes WHERE activo = .T. INTO CURSOR curClientes
*-- ... procesamiento ...
*-- Falta: USE IN curClientes

*-- ✅ CORRECTO
SELECT * FROM clientes WHERE activo = .T. INTO CURSOR curClientes NOFILTER
TRY
    *-- ... procesamiento ...
FINALLY
    IF USED("curClientes")
        USE IN curClientes
    ENDIF
ENDTRY
```

### Ejemplo 3: Complejidad alta
```foxpro
*-- ❌ ALTA COMPLEJIDAD (>10)
PROCEDURE ProcesarFactura(tnId, tcTipo, tnCliente)
    IF NOT EMPTY(tnId)
        IF tcTipo = "A"
            IF tnCliente > 0
                IF THIS.ValidarCliente(tnCliente)
                    IF THIS.TieneCredito(tnCliente)
                        FOR i = 1 TO THIS.nItems
                            IF THIS.aItems[i].precio > 0
                                IF THIS.aItems[i].cantidad > 0
                                    *-- procesamiento...
                                ENDIF
                            ENDIF
                        ENDFOR
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF
ENDPROC

*-- ✅ REFACTORIZADO (complejidad baja)
PROCEDURE ProcesarFactura(tnId, tcTipo, tnCliente)
    IF NOT THIS.ValidarParametros(tnId, tcTipo, tnCliente)
        RETURN .F.
    ENDIF
    
    IF NOT THIS.ValidarClienteYCredito(tnCliente)
        RETURN .F.
    ENDIF
    
    RETURN THIS.ProcesarItems()
ENDPROC
```

## Criterios de priorización

### 🔴 Crítico (resolver inmediatamente)
- Vulnerabilidades de seguridad
- Bugs que causan pérdida de datos
- Performance blockers (>1 segundo de impacto)
- Código que puede causar crashes

### 🟡 Advertencia (resolver en próximo sprint)
- Code smells significativos
- Duplicación extensa
- Falta de manejo de errores
- Problemas de mantenibilidad

### 🟢 Mejora (backlog)
- Optimizaciones menores
- Mejoras de legibilidad
- Documentación faltante
- Refactors opcionales

## Métricas objetivo

```yaml
calidad:
  complejidad_ciclomatica_max: 10
  lineas_por_procedimiento_max: 50
  duplicacion_codigo_max: 5%
  
mantenibilidad:
  indice_mantenibilidad_min: 70
  documentacion_min: 80%
  
testing:
  cobertura_lineas_min: 70%
  cobertura_ramas_min: 60%

performance:
  cursores_abiertos_max: 5
  conexiones_simultaneas_max: 3
```

## Output esperado

Al finalizar la auditoría, genera:

1. **Resumen ejecutivo**: Estadísticas generales y top issues
2. **Reporte por archivo**: Detalle de cada archivo analizado
3. **Plan de acción**: Issues priorizados con estimación de esfuerzo
4. **Métricas comparativas**: Antes/después si hay auditorías previas

## Uso con GitHub Copilot Chat

Desde el chat de Copilot, referencia este prompt:

```
Usa el prompt de auditoría comprehensiva para analizar main2028.prg
```

O para analizar módulo completo:

```
Usa el prompt de auditoría para revisar todos los archivos en CENTRALSS/_Nucleo/
```

---

**Siguiente paso**: Usa el reporte generado con el prompt de refactoring para aplicar mejoras sistemáticas.
