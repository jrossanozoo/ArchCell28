---
description: Auditoría completa de código Visual FoxPro 9 - Analiza calidad, estándares, seguridad y mantenibilidad
tools: ["read_file", "grep_search", "list_code_usages", "get_errors", "semantic_search"]
applyTo: 
  - "**/*.prg"
  - "**/*.vcx"
  - "**/*.scx"
argument-hint: Especifica el archivo o módulo a auditar
version: 1.0.0
category: auditoria
---

# 🔍 Auditoría Completa de Código VFP

## 🎯 Objetivo

Realizar un análisis exhaustivo de calidad, seguridad, mantenibilidad y cumplimiento de estándares en código Visual FoxPro 9.

## 📋 Áreas de Auditoría

### 1. **Calidad de Código**

Analizar y reportar:

- ✅ **Complejidad ciclomática**: Métodos con más de 10 puntos de decisión
- ✅ **Longitud de métodos**: Procedimientos con más de 100 líneas
- ✅ **Duplicación de código**: Bloques similares repetidos
- ✅ **Magic numbers**: Valores hardcodeados sin constantes
- ✅ **Dead code**: Código comentado o inalcanzable

### 2. **Estándares de Codificación**

Validar cumplimiento de:

```foxpro
* Convenciones de nombres
- Variables locales: lcNombre, lnContador, llFlag, ldFecha
- Variables privadas: pcParam, pnValor, plFlag
- Variables públicas: gcGlobal, gnConfig
- Propiedades: This.cPropiedad, This.nValor

* Estructura de procedimientos
- Headers descriptivos con propósito y parámetros
- Manejo de errores con TRY...CATCH
- Documentación de valores de retorno
- Uso adecuado de LOCAL/PRIVATE/PUBLIC
```

### 3. **Seguridad**

Identificar vulnerabilidades:

- 🚨 **SQL Injection**: Concatenación directa en queries
- 🚨 **Path Traversal**: Rutas de archivos no validadas
- 🚨 **Credenciales hardcodeadas**: Passwords en código
- 🚨 **Datos sensibles en logs**: Información PII expuesta
- 🚨 **Permisos inseguros**: Archivos con acceso total

### 4. **Performance**

Detectar problemas de rendimiento:

- ⚡ **SCAN loops**: Uso de SCAN donde SQL SELECT es más eficiente
- ⚡ **Indexes no utilizados**: Queries sin aprovechar índices
- ⚡ **String concatenation**: Uso ineficiente de operador +
- ⚡ **Recursos no liberados**: Cursors, tablas o conexiones abiertas
- ⚡ **Queries N+1**: Consultas repetitivas en loops

### 5. **Mantenibilidad**

Evaluar facilidad de mantenimiento:

- 📚 **Documentación**: Comentarios adecuados y actualizados
- 📚 **Cohesión**: Una responsabilidad por clase/procedimiento
- 📚 **Acoplamiento**: Dependencias excesivas entre módulos
- 📚 **Naming clarity**: Nombres descriptivos y consistentes
- 📚 **Modularización**: Funciones reutilizables vs código repetido

### 6. **Gestión de Recursos**

Verificar manejo correcto:

```foxpro
* Cerrar cursors y tablas
USE IN SELECT("curTemporal")
CLOSE TABLES ALL

* Liberar objetos
loObjeto = NULL
RELEASE loObjeto

* Cerrar conexiones
SQLDISCONNECT(lnHandle)
```

### 7. **Compatibilidad DOVFP**

Validar que el código:

- ✅ Se compila sin errores en DOVFP
- ✅ No usa características no soportadas
- ✅ Referencias a bibliotecas están resueltas
- ✅ No tiene dependencias circulares

## 📊 Formato de Reporte

```markdown
# REPORTE DE AUDITORÍA DE CÓDIGO VFP
Fecha: [YYYY-MM-DD HH:MM:SS]
Archivos analizados: [N]
Líneas de código: [N]

## 🔴 CRÍTICO (deben corregirse AHORA)
1. [Archivo.prg:45] SQL Injection vulnerability
   - SELECT * FROM clientes WHERE id = + pcId
   - Usar TEXTMERGE o parámetros preparados

2. [OtraClase.prg:123] Credenciales hardcodeadas
   - lcPassword = "admin123"
   - Mover a configuración segura

## 🟡 ADVERTENCIAS (corregir pronto)
1. [Helper.prg:67] Complejidad ciclomática alta (15 puntos)
   - Procedimiento CalcularTotal tiene demasiadas decisiones
   - Refactorizar en funciones más pequeñas

2. [Business.prg:234] Recurso no liberado
   - Cursor curTemporal no cerrado al finalizar
   - Agregar USE IN curTemporal

## 🔵 SUGERENCIAS (mejoras recomendadas)
1. [Utils.prg:89] Magic number
   - IF lnValor > 100
   - Crear constante #DEFINE LIMITE_MAXIMO 100

2. [Forms.prg:456] Código duplicado
   - Bloque repetido en líneas 456-478 y 501-523
   - Extraer a función común

## 📈 MÉTRICAS GENERALES
- Complejidad promedio: 7.3 (buena)
- Líneas por método: 42 (aceptable)
- Cobertura de documentación: 65%
- Cumplimiento de estándares: 78%

## ✅ FORTALEZAS DETECTADAS
- Manejo consistente de errores con TRY...CATCH
- Buena separación de responsabilidades
- Uso adecuado de constantes en mayoría de casos

## 🎯 RECOMENDACIONES PRIORITARIAS
1. Corregir vulnerabilidades de seguridad (2 críticas)
2. Refactorizar métodos complejos (5 casos)
3. Liberar recursos correctamente (8 casos)
4. Eliminar código muerto (12 bloques comentados)
5. Mejorar documentación (15 procedimientos sin headers)
```

## 🛠️ Ejemplo de Uso

```
@workspace /audit Realizar auditoría completa del proyecto Organic.BusinessLogic
enfocándome en seguridad y performance. Priorizar archivos en CENTRALSS/_Nucleo/
```

## 🔗 Referencias

- **Estándares de codificación**: `.github/instructions/vfp-coding-standards.instructions.md`
- **Agente especializado**: `Organic.BusinessLogic/AGENTS.md`
- **Best practices**: `docs/vfp-best-practices.md`

---

**Última revisión**: 2025-10-15  
**Mantenido por**: Equipo de Arquitectura Organic.ZL
