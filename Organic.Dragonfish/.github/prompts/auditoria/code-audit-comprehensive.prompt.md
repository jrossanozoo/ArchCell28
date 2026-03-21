---
description: "Auditoría integral de calidad de código Visual FoxPro, análisis arquitectural y detección de code smells"
tools: ["read_file", "grep_search", "list_code_usages", "semantic_search", "get_errors"]
applyTo: ["**/*.prg", "**/*.vcx", "**/*.scx", "**/*.frx"]
argument-hint: "Especifica el archivo o carpeta a auditar"
---

# 🔍 Auditoría Integral de Código VFP

Realiza una auditoría completa del código Visual FoxPro 9 enfocándote en:

## 1. 📊 Análisis de Arquitectura

- **Separación de responsabilidades**: ¿Las clases tienen una única responsabilidad clara?
- **Acoplamiento**: ¿Hay dependencias circulares o acoplamiento innecesario?
- **Cohesión**: ¿Los métodos de una clase están relacionados entre sí?
- **Principios SOLID**: ¿Se respetan los principios básicos de diseño?

## 2. 🐛 Code Smells y Anti-patrones

Detecta y reporta:
- **Métodos largos**: > 50 líneas de código
- **Clases god**: > 500 líneas o > 15 métodos públicos
- **Código duplicado**: Lógica repetida en múltiples lugares
- **Magic numbers**: Constantes numéricas sin nombre descriptivo
- **Comentarios obsoletos**: Comentarios que contradicen el código
- **Variables globales**: Uso excesivo de PUBLIC o GLOBAL
- **Nombres crípticos**: Variables con nombres poco descriptivos (x, tmp, aux)

## 3. 🚨 Problemas de Calidad

- **Manejo de errores**: 
  - Falta de `TRY...CATCH`
  - `ON ERROR` sin restauración
  - Errores silenciados sin logging
- **Memory leaks**: Objetos no liberados con `.NULL.`
- **SQL injection**: Construcción de queries con concatenación directa
- **Recursos no cerrados**: Cursores, conexiones, archivos abiertos

## 4. 📝 Documentación

- **Comentarios de clase**: `* Class: ...`
- **Documentación de métodos**: Propósito, parámetros, return values
- **Ejemplos de uso**: En clases complejas
- **TODOs y FIXMEs**: Deuda técnica documentada

## 5. ⚡ Performance

- **Queries N+1**: Consultas en loops
- **SELECT sin WHERE**: Lectura de tablas completas
- **Falta de índices**: Lookups sin SEEK o INDEXSEEK
- **String concatenation en loops**: Usar StringBuilder pattern
- **Cursores no optimizados**: BUFFERING incorrecto

## 6. 🔒 Seguridad

- **Validación de entrada**: Parámetros sin validar
- **Permisos**: Acceso sin verificación de roles
- **Logs sensibles**: Información confidencial en logs
- **Hardcoded credentials**: Contraseñas en código

## 7. 🎨 Convenciones y Estilo

- **Naming**: PascalCase para clases, camelCase para métodos/vars
- **Indentación**: Consistente (2 o 4 espacios)
- **LPARAMETERS**: Declaración explícita de parámetros
- **AS Type**: Tipado explícito cuando sea posible
- **ENDDEFINE, ENDPROC**: Siempre presentes y alineados

## 📋 Formato de Reporte

Para cada issue encontrado, reporta:

```
## [CATEGORIA] Nombre del Issue

**Archivo**: `ruta/al/archivo.prg`
**Línea**: 123
**Severidad**: 🔴 Alta / 🟡 Media / 🟢 Baja

**Descripción**: 
Explicación del problema encontrado.

**Código actual**:
```foxpro
* Código problemático
PROCEDURE MetodoLargo()
    * ... 200 líneas de código ...
ENDPROC
```

**Sugerencia**:
```foxpro
* Refactorizar en métodos más pequeños
PROCEDURE MetodoRefactorizado()
    THIS.PasoUno()
    THIS.PasoDos()
    THIS.PasoTres()
ENDPROC
```

**Impacto**: Describir el impacto en mantenibilidad, performance o seguridad.
```

## 🎯 Priorización

1. 🔴 **Crítico**: Problemas de seguridad, memory leaks, data corruption
2. 🟡 **Importante**: Code smells severos, performance issues
3. 🟢 **Mejora**: Estilo, naming, documentación

## 📊 Resumen Ejecutivo

Al final de la auditoría, incluye:

- **Total de issues**: Por categoría y severidad
- **Archivos más problemáticos**: Top 10
- **Métricas de calidad**: 
  - Complejidad ciclomática promedio
  - Líneas de código por método (promedio)
  - Cobertura de manejo de errores
  - % de código documentado
- **Recomendaciones prioritarias**: Top 5 acciones a tomar
