---
description: "Auditoría exhaustiva de código VFP: análisis de calidad, patrones, convenciones y mejores prácticas para **/*.prg, **/*.vcx, **/*.scx en Organic.BusinessLogic y Organic.Tests"
---

# 🔍 Comprehensive Code Audit - Visual FoxPro

## Objective
Perform a comprehensive audit of Visual FoxPro 9 code to identify quality issues, technical debt, anti-patterns, and improvement opportunities.

---

## 📋 Audit Checklist

### 1. **Code Structure & Organization**

#### File Organization
- [ ] ¿Los archivos están organizados lógicamente?
- [ ] ¿Se respeta la separación de responsabilidades?
- [ ] ¿Los nombres de archivos son descriptivos?
- [ ] ¿Hay archivos muy grandes (>1000 líneas)?

#### Function/Procedure Organization
```vfp
* ✅ BIEN: Función bien estructurada
FUNCTION CalcularTotal(pcTabla, pnDescuento)
  LOCAL lnTotal, lnSubtotal
  
  * Validar parámetros
  IF EMPTY(pcTabla)
    RETURN 0
  ENDIF
  
  * Calcular
  lnSubtotal = ObtenerSubtotal(pcTabla)
  lnTotal = lnSubtotal * (1 - pnDescuento/100)
  
  RETURN lnTotal
ENDFUNC

* ❌ MAL: Función monolítica sin estructura
FUNCTION Procesar()
  * 500 líneas de código sin separación...
ENDFUNC
```

---

### 2. **Naming Conventions**

#### Variables
```vfp
* ✅ BIEN: Notación húngara VFP
LOCAL lcNombre      && Character
LOCAL lnContador    && Numeric
LOCAL ldFecha       && Date
LOCAL llActivo      && Logical
LOCAL loObjeto      && Object

* ❌ MAL: Sin prefijos o inconsistente
LOCAL nombre
LOCAL x
LOCAL temp
```

#### Functions & Procedures
```vfp
* ✅ BIEN: PascalCase descriptivo
FUNCTION GenerarAbmAvanzado()
FUNCTION ValidarDocumento()
FUNCTION ObtenerClientePorId()

* ❌ MAL: Nombres ambiguos
FUNCTION hacer()
FUNCTION proc1()
```

#### Constants
```vfp
* ✅ BIEN: UPPER_SNAKE_CASE
#DEFINE MAX_INTENTOS 3
#DEFINE RUTA_REPORTES "C:\Reportes\"

* ❌ MAL: Sin definir o hardcoded
lnMax = 3  && Debería ser constante
```

---

### 3. **Code Quality**

#### Complejidad Ciclomática
- [ ] ¿Hay funciones con > 10 niveles de anidamiento?
- [ ] ¿Se usan muchos IF/ELSE anidados?
- [ ] ¿Podría simplificarse con early returns?

```vfp
* ❌ MAL: Anidamiento excesivo
FUNCTION Validar(pcDato)
  IF !EMPTY(pcDato)
    IF TYPE("pcDato") = "C"
      IF LEN(pcDato) > 5
        IF ValidarFormato(pcDato)
          IF ExisteEnBD(pcDato)
            RETURN .T.
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  RETURN .F.
ENDFUNC

* ✅ BIEN: Early returns
FUNCTION Validar(pcDato)
  IF EMPTY(pcDato) OR TYPE("pcDato") != "C"
    RETURN .F.
  ENDIF
  
  IF LEN(pcDato) <= 5
    RETURN .F.
  ENDIF
  
  IF !ValidarFormato(pcDato)
    RETURN .F.
  ENDIF
  
  RETURN ExisteEnBD(pcDato)
ENDFUNC
```

#### DRY (Don't Repeat Yourself)
- [ ] ¿Hay código duplicado?
- [ ] ¿Se repiten bloques similares?
- [ ] ¿Podrían extraerse funciones comunes?

```vfp
* ❌ MAL: Código duplicado
FUNCTION ProcesarCliente()
  IF !USED("clientes")
    USE clientes IN 0
  ENDIF
  SELECT clientes
  * proceso...
ENDFUNC

FUNCTION ProcesarProveedor()
  IF !USED("proveedores")
    USE proveedores IN 0
  ENDIF
  SELECT proveedores
  * proceso similar...
ENDFUNC

* ✅ BIEN: Extraer lógica común
FUNCTION AbrirTabla(pcTabla)
  IF !USED(pcTabla)
    USE (pcTabla) IN 0
  ENDIF
  SELECT (pcTabla)
ENDFUNC

FUNCTION ProcesarCliente()
  AbrirTabla("clientes")
  * proceso...
ENDFUNC
```

---

### 4. **Error Handling**

#### Try-Catch Pattern
```vfp
* ✅ BIEN: Manejo robusto de errores
FUNCTION GuardarDatos(pcTabla)
  LOCAL llExito, lcError
  llExito = .F.
  
  TRY
    * Operación crítica
    SELECT (pcTabla)
    REPLACE campo WITH valor
    llExito = .T.
    
  CATCH TO loException
    lcError = "Error guardando: " + loException.Message
    LogError(lcError)
    
  FINALLY
    * Limpiar recursos
    
  ENDTRY
  
  RETURN llExito
ENDFUNC

* ❌ MAL: Sin manejo de errores
FUNCTION GuardarDatos(pcTabla)
  SELECT (pcTabla)
  REPLACE campo WITH valor
  RETURN .T.  && ¿Y si falla?
ENDFUNC
```

#### Error Propagation
- [ ] ¿Los errores se propagan correctamente?
- [ ] ¿Se registran (log) los errores?
- [ ] ¿Se informa al usuario apropiadamente?

---

### 5. **Performance**

#### Database Operations
```vfp
* ❌ MAL: Operaciones ineficientes
SCAN FOR tipo = "A"
  * procesar cada registro
ENDSCAN

* ✅ BIEN: Usar filtros e índices
SET FILTER TO tipo = "A"
GO TOP
SCAN
  * procesar solo registros filtrados
ENDSCAN
SET FILTER TO
```

#### String Operations
```vfp
* ❌ MAL: Concatenación en loop
lcResultado = ""
FOR lnI = 1 TO 1000
  lcResultado = lcResultado + lcLinea
ENDFOR

* ✅ BIEN: Usar técnicas eficientes
LOCAL laLineas[1000]
FOR lnI = 1 TO 1000
  laLineas[lnI] = lcLinea
ENDFOR
lcResultado = ArrayToString(laLineas)
```

#### Memory Management
- [ ] ¿Se liberan objetos (RELEASE)?
- [ ] ¿Se cierran tablas no utilizadas (USE IN)?
- [ ] ¿Hay memory leaks potenciales?

---

### 6. **Documentation**

#### Function Headers
```vfp
* ✅ BIEN: Header completo
*-- ============================================
*-- Función: GenerarReporte
*-- Propósito: Genera reporte PDF de ventas
*-- Parámetros:
*--   pcTipo: Tipo de reporte (C) - "MENSUAL"/"ANUAL"
*--   pdFechaDesde: Fecha inicio (D)
*--   pdFechaHasta: Fecha fin (D)
*-- Retorna: 
*--   .T. si generó exitosamente (L)
*-- Excepciones:
*--   Lanza error si fechas inválidas
*-- Ejemplo:
*--   llOk = GenerarReporte("MENSUAL", {^2025-01-01}, {^2025-01-31})
*-- ============================================
FUNCTION GenerarReporte(pcTipo, pdFechaDesde, pdFechaHasta)

* ❌ MAL: Sin documentación
FUNCTION GenerarReporte(pcTipo, pdFechaDesde, pdFechaHasta)
```

#### Inline Comments
- [ ] ¿Hay comentarios donde el código es complejo?
- [ ] ¿Los comentarios explican el "por qué" no el "qué"?
- [ ] ¿Están actualizados con el código?

---

### 7. **Security**

#### SQL Injection
```vfp
* ❌ MAL: Vulnerable a injection
lcSQL = "SELECT * FROM clientes WHERE nombre = '" + pcNombre + "'"
SQLEXEC(lnHandle, lcSQL)

* ✅ BIEN: Usar parámetros
lcSQL = "SELECT * FROM clientes WHERE nombre = ?pcNombre"
SQLEXEC(lnHandle, lcSQL, pcNombre)
```

#### Sensitive Data
- [ ] ¿Hay contraseñas hardcoded?
- [ ] ¿Se registran datos sensibles en logs?
- [ ] ¿Se encriptan datos críticos?

---

### 8. **Testing**

#### Testability
- [ ] ¿Las funciones son puras (sin side effects)?
- [ ] ¿Se pueden aislar para testing?
- [ ] ¿Hay dependencias difíciles de mockear?

#### Test Coverage
- [ ] ¿Existen tests unitarios?
- [ ] ¿Cubren casos edge?
- [ ] ¿Hay tests de regresión?

---

### 9. **VFP-Specific Issues**

#### Obsolete Commands
```vfp
* ❌ Evitar comandos obsoletos
SET TALK ON
SET CONSOLE ON
@ 10,10 SAY "Texto"

* ✅ Usar métodos modernos
MESSAGEBOX("Texto", 64, "Título")
```

#### Resource Management
```vfp
* ✅ BIEN: Limpiar recursos
LOCAL loForm
loForm = CREATEOBJECT("MiForm")
TRY
  loForm.Show()
FINALLY
  IF TYPE("loForm") = "O"
    loForm.Release()
    loForm = NULL
  ENDIF
ENDTRY
```

---

## 🎯 Reporting

### Issues Found Format
```markdown
## Critical Issues
1. **[SEGURIDAD]** SQL Injection en `generadorabm.prg:145`
   - **Severidad:** ALTA
   - **Impacto:** Vulnerabilidad de seguridad
   - **Recomendación:** Usar parámetros en SQLEXEC

2. **[PERFORMANCE]** Loop ineficiente en `procesador.prg:234`
   - **Severidad:** MEDIA
   - **Impacto:** Rendimiento degradado con >1000 registros
   - **Recomendación:** Usar SET FILTER o índices

## Warnings
1. **[CODE QUALITY]** Función muy larga `ProcesarTodo()` - 850 líneas
   - **Recomendación:** Refactorizar en funciones más pequeñas

## Suggestions
1. **[DOCUMENTATION]** Falta header en `utilidades.prg:funciones`
   - **Recomendación:** Agregar documentación estándar
```

### Metrics to Report
- Total lines of code
- Average function length
- Cyclomatic complexity
- Code duplication percentage
- Test coverage percentage
- Number of critical/warning/info issues

---

## 💡 Usage

```
@workspace /ask using #file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md
Perform a comprehensive code audit of Organic.BusinessLogic
```

---

**Last Updated:** 2025-10-15  
**Version:** 1.0.0
