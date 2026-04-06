---
description: Patrones de refactoring para Visual FoxPro 9 - Moderniza código legacy aplicando mejores prácticas y patrones de diseño
tools: ["read_file", "grep_search", "list_code_usages", "run_in_terminal"]
applyTo: ["**/*.prg", "**/*.vcx"]
argument-hint: Especifica el código o patrón a refactorizar
version: 1.0.0
category: refactor
---

# 🔄 Patrones de Refactoring VFP

## 🎯 Objetivo

Transformar código Visual FoxPro legacy en código moderno, mantenible y eficiente, aplicando patrones de diseño y mejores prácticas contemporáneas.

## 📋 Catálogo de Refactorings

### 1. **Replace SCAN with SQL SELECT**

**Problema**: SCAN loops son lentos y procedurales

```foxpro
* ❌ ANTES (lento)
USE clientes
lnTotal = 0
SCAN FOR activo = .T.
    lnTotal = lnTotal + 1
ENDSCAN
USE
```

```foxpro
* ✅ DESPUÉS (rápido)
SELECT COUNT(*) as Total ;
    FROM clientes ;
    WHERE activo = .T. ;
    INTO CURSOR curTotal
lnTotal = curTotal.Total
USE IN curTotal
```

**Impacto**: 10-100x más rápido en grandes datasets

---

### 2. **Extract Method / Procedure**

**Problema**: Métodos largos con múltiples responsabilidades

```foxpro
* ❌ ANTES (método de 200 líneas)
PROCEDURE ProcesarVenta()
    * Validar cliente (30 líneas)
    * Validar productos (40 líneas)
    * Calcular totales (50 líneas)
    * Guardar factura (40 líneas)
    * Imprimir (40 líneas)
ENDPROC
```

```foxpro
* ✅ DESPUÉS (modular)
PROCEDURE ProcesarVenta()
    IF NOT THIS.ValidarCliente()
        RETURN .F.
    ENDIF
    
    IF NOT THIS.ValidarProductos()
        RETURN .F.
    ENDIF
    
    lnTotal = THIS.CalcularTotales()
    lnIdFactura = THIS.GuardarFactura(lnTotal)
    THIS.ImprimirFactura(lnIdFactura)
    
    RETURN .T.
ENDPROC

PROTECTED PROCEDURE ValidarCliente()
    * ... 30 líneas de validación
    RETURN llValido
ENDPROC

PROTECTED PROCEDURE ValidarProductos()
    * ... 40 líneas de validación
    RETURN llValido
ENDPROC
```

**Beneficios**: Código testeable, reutilizable, más legible

---

### 3. **Replace Magic Numbers with Constants**

**Problema**: Valores hardcodeados sin contexto

```foxpro
* ❌ ANTES
IF lnTipo = 1
    lcDescripcion = "Factura A"
ENDIF
IF lnPrecio > 5000
    lnDescuento = lnPrecio * 0.15
ENDIF
```

```foxpro
* ✅ DESPUÉS
#DEFINE TIPO_FACTURA_A 1
#DEFINE LIMITE_DESCUENTO_ESPECIAL 5000
#DEFINE PORCENTAJE_DESCUENTO_ESPECIAL 0.15

IF lnTipo = TIPO_FACTURA_A
    lcDescripcion = "Factura A"
ENDIF

IF lnPrecio > LIMITE_DESCUENTO_ESPECIAL
    lnDescuento = lnPrecio * PORCENTAJE_DESCUENTO_ESPECIAL
ENDIF
```

**Beneficios**: Mantenibilidad, claridad, un solo punto de cambio

---

### 4. **Introduce Error Handling**

**Problema**: Código sin manejo de errores

```foxpro
* ❌ ANTES (crashea en error)
USE tabla
DELETE FOR id = pnId
USE
```

```foxpro
* ✅ DESPUÉS (robusto)
PROCEDURE EliminarRegistro(pnId)
    LOCAL llExito, loEx
    llExito = .F.
    
    TRY
        USE tabla IN 0 EXCLUSIVE
        SELECT tabla
        DELETE FOR id = pnId
        PACK
        USE IN tabla
        llExito = .T.
        
    CATCH TO loEx
        * Log error
        THIS.LogError("Error eliminando ID " + TRANSFORM(pnId) + ;
                      ": " + loEx.Message)
        
        * Cleanup
        IF USED("tabla")
            USE IN tabla
        ENDIF
        
    ENDTRY
    
    RETURN llExito
ENDPROC
```

**Beneficios**: Aplicación no crashea, errores manejados, cleanup garantizado

---

### 5. **Replace String Concatenation with TEXTMERGE**

**Problema**: Concatenación manual de strings largos

```foxpro
* ❌ ANTES (difícil de leer y mantener)
lcSQL = "SELECT c.id, c.nombre, f.numero, f.total " + ;
        "FROM clientes c " + ;
        "INNER JOIN facturas f ON c.id = f.id_cliente " + ;
        "WHERE c.activo = .T. " + ;
        "AND f.fecha >= " + CTOD(ldFechaDesde) + ;
        "AND f.total > " + STR(lnMontoMinimo)
```

```foxpro
* ✅ DESPUÉS (claro y mantenible)
TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
    SELECT c.id, c.nombre, f.numero, f.total
    FROM clientes c
    INNER JOIN facturas f ON c.id = f.id_cliente
    WHERE c.activo = .T.
      AND f.fecha >= '<<DTOC(ldFechaDesde)>>'
      AND f.total > <<lnMontoMinimo>>
ENDTEXT
```

**Beneficios**: Legibilidad, SQL resaltado, menos errores de sintaxis

---

### 6. **Replace Procedure Parameters with Parameter Object**

**Problema**: Demasiados parámetros dificultan uso y mantenimiento

```foxpro
* ❌ ANTES (8 parámetros - confuso)
PROCEDURE GenerarReporte(pcCliente, pdFechaDesde, pdFechaHasta, ;
                         plIncluirDetalle, plExportarPDF, pcRutaSalida, ;
                         pnFormato, plEnviarEmail)
    * ...
ENDPROC

* Llamar es confuso
GenerarReporte("CLI001", DATE()-30, DATE(), .T., .T., "C:\Reports", 1, .F.)
```

```foxpro
* ✅ DESPUÉS (objeto de configuración)
DEFINE CLASS ReporteConfig AS Custom
    cCliente = ""
    dFechaDesde = {}
    dFechaHasta = {}
    lIncluirDetalle = .F.
    lExportarPDF = .F.
    cRutaSalida = ""
    nFormato = 1
    lEnviarEmail = .F.
ENDDEFINE

PROCEDURE GenerarReporte(poConfig)
    * Acceso claro: poConfig.cCliente, poConfig.dFechaDesde, etc.
    * ...
ENDPROC

* Llamar es claro y extensible
loConfig = CREATEOBJECT("ReporteConfig")
loConfig.cCliente = "CLI001"
loConfig.dFechaDesde = DATE()-30
loConfig.dFechaHasta = DATE()
loConfig.lIncluirDetalle = .T.
loConfig.lExportarPDF = .T.
GenerarReporte(loConfig)
```

**Beneficios**: Extensible, autoexplicativo, fácil de testear

---

### 7. **Replace Conditional with Polymorphism**

**Problema**: Grandes bloques DO CASE según tipo

```foxpro
* ❌ ANTES (lógica dispersa)
PROCEDURE CalcularTotal(poItem)
    LOCAL lnTotal
    DO CASE
        CASE poItem.cTipo = "PRODUCTO"
            lnTotal = poItem.nPrecio * poItem.nCantidad
        CASE poItem.cTipo = "SERVICIO"
            lnTotal = poItem.nHoras * poItem.nTarifa
        CASE poItem.cTipo = "COMBO"
            lnTotal = poItem.nPrecioBase * (1 - poItem.nDescuento)
    ENDCASE
    RETURN lnTotal
ENDPROC
```

```foxpro
* ✅ DESPUÉS (polimorfismo)
DEFINE CLASS Item AS Custom
    PROCEDURE CalcularTotal()
        * Método abstracto
    ENDPROC
ENDDEFINE

DEFINE CLASS Producto AS Item
    PROCEDURE CalcularTotal()
        RETURN THIS.nPrecio * THIS.nCantidad
    ENDPROC
ENDDEFINE

DEFINE CLASS Servicio AS Item
    PROCEDURE CalcularTotal()
        RETURN THIS.nHoras * THIS.nTarifa
    ENDPROC
ENDDEFINE

DEFINE CLASS Combo AS Item
    PROCEDURE CalcularTotal()
        RETURN THIS.nPrecioBase * (1 - THIS.nDescuento)
    ENDPROC
ENDDEFINE

* Uso
lnTotal = poItem.CalcularTotal()  && Sin necesidad de DO CASE
```

**Beneficios**: Open/Closed principle, fácil agregar nuevos tipos

---

### 8. **Replace Global Variables with Dependency Injection**

**Problema**: Variables públicas dificultan testing y mantenimiento

```foxpro
* ❌ ANTES
PUBLIC gcConnectionString
gcConnectionString = "Server=..."

PROCEDURE GuardarCliente()
    lnHandle = SQLSTRINGCONNECT(gcConnectionString)
    * ...
ENDPROC
```

```foxpro
* ✅ DESPUÉS
DEFINE CLASS ClienteBusiness AS Custom
    oDataAccess = NULL
    
    PROCEDURE Init(poDataAccess)
        THIS.oDataAccess = poDataAccess
    ENDPROC
    
    PROCEDURE GuardarCliente()
        lnHandle = THIS.oDataAccess.GetConnection()
        * ...
    ENDPROC
ENDDEFINE

* Uso (con inyección)
loDataAccess = CREATEOBJECT("DataAccess", "Server=...")
loClienteBusiness = CREATEOBJECT("ClienteBusiness", loDataAccess)
```

**Beneficios**: Testeable (inyectar mock), sin globals, IoC

---

### 9. **Replace Procedural with Object-Oriented**

**Problema**: Código procedural difícil de mantener

```foxpro
* ❌ ANTES (procedural)
PROCEDURE ValidarCliente(pnId)
    USE clientes
    LOCATE FOR id = pnId
    llValido = FOUND() AND !DELETED() AND activo
    USE
    RETURN llValido
ENDPROC

PROCEDURE GuardarCliente(pnId, pcNombre, pcEmail)
    USE clientes
    IF SEEK(pnId)
        REPLACE nombre WITH pcNombre, email WITH pcEmail
    ELSE
        INSERT INTO clientes VALUES (pnId, pcNombre, pcEmail, .T.)
    ENDIF
    USE
ENDPROC
```

```foxpro
* ✅ DESPUÉS (OOP)
DEFINE CLASS ClienteRepository AS Custom
    cTabla = "clientes"
    
    PROCEDURE Validar(pnId)
        LOCAL llValido
        USE (THIS.cTabla) IN 0 SHARED
        SELECT (THIS.cTabla)
        LOCATE FOR id = pnId
        llValido = FOUND() AND !DELETED() AND activo
        USE IN (THIS.cTabla)
        RETURN llValido
    ENDPROC
    
    PROCEDURE Guardar(poCliente)
        LOCAL llExito
        TRY
            USE (THIS.cTabla) IN 0
            SELECT (THIS.cTabla)
            
            IF SEEK(poCliente.nId)
                REPLACE nombre WITH poCliente.cNombre, ;
                        email WITH poCliente.cEmail
            ELSE
                INSERT INTO (THIS.cTabla) VALUES ;
                    (poCliente.nId, poCliente.cNombre, poCliente.cEmail, .T.)
            ENDIF
            
            USE IN (THIS.cTabla)
            llExito = .T.
        CATCH
            llExito = .F.
        ENDTRY
        RETURN llExito
    ENDPROC
ENDDEFINE
```

**Beneficios**: Encapsulación, reutilización, testeable

---

### 10. **Introduce Guard Clauses**

**Problema**: Nested IFs dificultan lectura

```foxpro
* ❌ ANTES (anidado)
PROCEDURE ProcesarPedido(poPedido)
    IF NOT ISNULL(poPedido)
        IF poPedido.nTotal > 0
            IF NOT EMPTY(poPedido.cCliente)
                * ... 50 líneas de lógica
            ELSE
                RETURN .F.
            ENDIF
        ELSE
            RETURN .F.
        ENDIF
    ELSE
        RETURN .F.
    ENDIF
ENDPROC
```

```foxpro
* ✅ DESPUÉS (guard clauses)
PROCEDURE ProcesarPedido(poPedido)
    * Early returns para casos inválidos
    IF ISNULL(poPedido)
        RETURN .F.
    ENDIF
    
    IF poPedido.nTotal <= 0
        RETURN .F.
    ENDIF
    
    IF EMPTY(poPedido.cCliente)
        RETURN .F.
    ENDIF
    
    * Lógica principal sin indentación excesiva
    * ... 50 líneas de lógica
    RETURN .T.
ENDPROC
```

**Beneficios**: Código más plano, lógica principal destacada

---

## 🛠️ Proceso de Refactoring

### Reglas de Oro

1. ✅ **Refactorizar con tests**: Crear tests antes de refactorizar
2. ✅ **Cambios pequeños**: Un refactoring a la vez
3. ✅ **Compilar frecuentemente**: Verificar que no rompe nada
4. ✅ **Commit incremental**: Commit después de cada refactoring exitoso
5. ✅ **No cambiar comportamiento**: Solo cambiar estructura interna

### Workflow Recomendado

```
1. Identificar código problemático
   └─> Complejidad alta, duplicación, magic numbers, etc.

2. Escribir tests para código actual
   └─> Asegurar comportamiento actual está cubierto

3. Aplicar refactoring
   └─> Usar patrón apropiado del catálogo

4. Ejecutar tests
   └─> Verificar que comportamiento no cambió

5. Compilar con DOVFP
   └─> dovfp build Organic.ZL.vfpsln

6. Commit
   └─> git commit -m "refactor: Replace SCAN with SQL SELECT in ProcesarVentas"

7. Repetir con siguiente refactoring
```

## 🎯 Métricas de Mejora

Después de refactoring, deberías ver:

- 📉 **Complejidad ciclomática**: < 10 por método
- 📉 **Líneas por método**: < 100 líneas
- 📉 **Duplicación de código**: < 5%
- 📈 **Cobertura de tests**: > 70%
- 📈 **Performance**: Mejora medible en operaciones críticas

## 🔗 Referencias

- **Prompt de auditoría**: `.github/prompts/auditoria/code-audit-comprehensive.prompt.md`
- **Agente de código**: `Organic.BusinessLogic/AGENTS.md`
- **Best practices**: `docs/vfp-best-practices.md`

---

**Última revisión**: 2025-10-15  
**Basado en**: Refactoring (Martin Fowler), Clean Code (Robert C. Martin)
