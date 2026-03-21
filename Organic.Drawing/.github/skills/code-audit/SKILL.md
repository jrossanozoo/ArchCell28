# Skill: Code Audit

## Descripción

Conocimiento y checklists para realizar auditorías de código Visual FoxPro 9 de manera sistemática y exhaustiva.

## Cuándo Usar

- Al revisar código nuevo antes de merge
- En auditorías periódicas de calidad
- Para evaluar código legacy antes de refactoring
- Al onboardear nuevo código al proyecto

## Checklist de Auditoría Completo

### 1. 📝 Nomenclatura y Convenciones

```
□ Parámetros usan prefijo 't' (tc, tn, tl, to, ta)
□ Variables locales usan prefijo 'l' (lc, ln, ll, lo, la)
□ Propiedades de clase usan THIS.{tipo}Nombre
□ Nombres son descriptivos y en español/inglés consistente
□ Constantes en MAYUSCULAS (#DEFINE)
□ Sin magic numbers (usar constantes)
□ Comentarios actualizados y útiles
```

### 2. 🏗️ Estructura y Arquitectura

```
□ Una responsabilidad por clase/método (SRP)
□ Métodos < 50 líneas
□ Clases < 500 líneas
□ Máximo 3-4 niveles de indentación
□ Sin dependencias circulares
□ Bajo acoplamiento entre módulos
□ Alta cohesión dentro de clases
```

### 3. 🛡️ Manejo de Errores

```
□ TRY...CATCH en operaciones de BD
□ TRY...CATCH en operaciones de archivo
□ TRY...CATCH en llamadas externas
□ Errores específicos (no catch genérico)
□ Logging de errores con contexto
□ Recursos liberados en FINALLY
□ Mensajes de error informativos
```

### 4. 🗄️ Acceso a Datos

```
□ SQL preferido sobre SCAN/LOCATE
□ Índices utilizados en búsquedas frecuentes
□ Cursores cerrados después de uso
□ Tablas cerradas cuando no se necesitan
□ Transacciones para operaciones múltiples
□ Sin concatenación directa de parámetros en SQL
□ Uso de alias explícitos
```

### 5. 🧠 Memoria y Recursos

```
□ Objetos liberados (loObj = NULL)
□ Archivos cerrados (FCLOSE)
□ Cursores cerrados (USE IN)
□ Sin variables PUBLIC innecesarias
□ Sin variables PRIVATE (preferir LOCAL)
□ Arrays dimensionados correctamente
□ RELEASE usado apropiadamente
```

### 6. ⚡ Performance

```
□ Sin SCAN sobre tablas grandes (usar SQL)
□ Sin creación de objetos en loops
□ Sin operaciones de BD en loops
□ Índices en campos de búsqueda
□ SET DELETED ON configurado
□ Sin funciones lentas en WHERE
□ Consultas optimizadas (EXPLAIN si aplica)
```

### 7. 🔒 Seguridad

```
□ Inputs validados antes de procesar
□ Sin credenciales hardcodeadas
□ Sin rutas absolutas expuestas
□ Permisos de archivo apropiados
□ Datos sensibles no logueados
□ Sin información debug en producción
```

### 8. 📚 Documentación

```
□ Encabezado de clase con propósito
□ Métodos públicos documentados
□ Parámetros documentados
□ Valores de retorno documentados
□ TODOs con ticket asociado
□ Sin código comentado (usar Git)
```

## Plantilla de Reporte

```markdown
# 📊 Reporte de Auditoría

**Proyecto**: Organic.Drawing
**Archivo(s)**: [rutas]
**Fecha**: [fecha]
**Auditor**: [nombre]

## Resumen Ejecutivo

| Categoría | Estado | Issues |
|-----------|--------|--------|
| Nomenclatura | ✅/⚠️/❌ | X |
| Arquitectura | ✅/⚠️/❌ | X |
| Errores | ✅/⚠️/❌ | X |
| Datos | ✅/⚠️/❌ | X |
| Memoria | ✅/⚠️/❌ | X |
| Performance | ✅/⚠️/❌ | X |
| Seguridad | ✅/⚠️/❌ | X |
| Documentación | ✅/⚠️/❌ | X |

## Issues Detallados

### 🔴 Críticos (Bloquean release)
[Lista o "Ninguno"]

### 🟠 Altos (Deben corregirse)
[Lista o "Ninguno"]

### 🟡 Medios (Deberían corregirse)
[Lista o "Ninguno"]

### 🟢 Bajos (Sugerencias)
[Lista o "Ninguno"]

## Recomendaciones Priorizadas

1. [Más urgente]
2. [Segunda prioridad]
3. [Tercera prioridad]

## Veredicto

- [ ] ✅ APROBADO
- [ ] ⚠️ APROBADO CON OBSERVACIONES
- [ ] ❌ REQUIERE CAMBIOS
```

## Patrones Comunes a Buscar

### Code Smells VFP

```foxpro
* 🔴 Función muy larga
PROCEDURE HacerTodo()
    * 200+ líneas...
ENDPROC

* 🔴 DO CASE extenso (usar polimorfismo)
DO CASE
    CASE tipo = "A"
    CASE tipo = "B"
    CASE tipo = "C"
    * ... 20 casos más
ENDCASE

* 🔴 Parámetros excesivos (usar objeto)
PROCEDURE Crear(tc1, tc2, tc3, tn1, tn2, td1, tl1, tl2)

* 🔴 Variables globales
PUBLIC gnContador, gcRuta, goApp

* 🟠 SCAN en tabla grande
SCAN FOR condicion
    * proceso lento
ENDSCAN

* 🟠 Sin manejo de errores
loFile = FOPEN(tcRuta)
* Sin verificar si falló
```

### Patrones Correctos

```foxpro
* ✅ Función corta y enfocada
PROCEDURE ValidarCliente(tnId)
    RETURN THIS.ExisteCliente(tnId) AND THIS.TieneCredito(tnId)
ENDPROC

* ✅ SQL en lugar de SCAN
SELECT * FROM Clientes WHERE Id = ?tnId INTO CURSOR csrCliente

* ✅ Manejo de errores
TRY
    loFile = FOPEN(tcRuta)
    IF loFile < 0
        THROW "No se pudo abrir archivo"
    ENDIF
CATCH TO loError
    THIS.LogError("AbrirArchivo", loError)
FINALLY
    IF loFile > 0
        FCLOSE(loFile)
    ENDIF
ENDTRY
```

## Herramientas Recomendadas

- `grep_search`: Buscar patrones problemáticos
- `read_file`: Leer código a auditar
- `list_code_usages`: Ver uso de métodos/clases
- `semantic_search`: Encontrar código relacionado

## Queries de Búsqueda Útiles

```
# Buscar funciones largas (manual review)
grep: "PROCEDURE|FUNCTION" para listar y revisar tamaños

# Buscar SCAN sin SQL alternativo
grep: "SCAN FOR|SCAN ALL"

# Buscar variables globales
grep: "PUBLIC |PRIVATE "

# Buscar código sin TRY
grep: "FOPEN|FCREATE|INSERT INTO|UPDATE |DELETE FROM"
# Verificar que tengan TRY cerca
```
