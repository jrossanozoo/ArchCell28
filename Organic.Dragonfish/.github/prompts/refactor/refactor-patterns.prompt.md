---
description: "Guía de patrones de refactorización para código Visual FoxPro 9 legacy, modernización y mejora de mantenibilidad"
tools: ["read_file", "grep_search", "list_code_usages", "replace_string_in_file", "semantic_search"]
applyTo: ["**/*.prg", "**/*.vcx"]
argument-hint: "Especifica la clase o método a refactorizar"
---

# 🔄 Patrones de Refactorización VFP

## 🎯 Objetivo

Transformar código VFP legacy en código moderno, mantenible y testeable aplicando patrones de refactorización probados.

---

## 📚 Catálogo de Refactorizaciones

### 1. Extract Method (Extraer Método)

**Cuándo aplicar**: Método largo (> 50 líneas) o lógica que se puede nombrar significativamente.

**Antes**:
```foxpro
PROCEDURE ProcesarVenta()
    * Validar cliente
    IF EMPTY(THIS.cCliente)
        MESSAGEBOX("Cliente requerido")
        RETURN .F.
    ENDIF
    
    * Calcular total
    LOCAL lnTotal
    lnTotal = 0
    SELECT Detalle
    SCAN
        lnTotal = lnTotal + (Cantidad * Precio)
    ENDSCAN
    
    * Aplicar descuento
    IF THIS.nDescuento > 0
        lnTotal = lnTotal * (1 - THIS.nDescuento / 100)
    ENDIF
    
    * Guardar
    INSERT INTO Ventas VALUES (THIS.cCliente, lnTotal, DATE())
ENDPROC
```

**Después**:
```foxpro
PROCEDURE ProcesarVenta() AS Boolean
    IF !THIS.ValidarCliente()
        RETURN .F.
    ENDIF
    
    LOCAL lnTotal AS Number
    lnTotal = THIS.CalcularTotal()
    lnTotal = THIS.AplicarDescuento(lnTotal)
    
    RETURN THIS.GuardarVenta(lnTotal)
ENDPROC

PROTECTED PROCEDURE ValidarCliente() AS Boolean
    IF EMPTY(THIS.cCliente)
        MESSAGEBOX("Cliente requerido")
        RETURN .F.
    ENDIF
    RETURN .T.
ENDPROC

PROTECTED PROCEDURE CalcularTotal() AS Number
    LOCAL lnTotal AS Number
    lnTotal = 0
    
    SELECT Detalle
    SCAN
        lnTotal = lnTotal + (Cantidad * Precio)
    ENDSCAN
    
    RETURN lnTotal
ENDPROC
```

---

### 2. Replace Magic Number with Symbolic Constant

**Cuándo aplicar**: Números literales sin significado obvio.

**Antes**:
```foxpro
IF THIS.nEstado = 3
    * Procesando...
ENDIF
```

**Después**:
```foxpro
#DEFINE ESTADO_PENDIENTE 1
#DEFINE ESTADO_APROBADO 2
#DEFINE ESTADO_PROCESANDO 3
#DEFINE ESTADO_COMPLETADO 4

IF THIS.nEstado = ESTADO_PROCESANDO
    * Procesando...
ENDIF
```

---

### 3. Replace Conditional with Polymorphism

**Cuándo aplicar**: Múltiples IF/CASE basados en tipo de objeto.

**Antes**:
```foxpro
PROCEDURE CalcularImpuesto(tcTipo AS String, tnMonto AS Number) AS Number
    LOCAL lnImpuesto
    
    DO CASE
        CASE tcTipo = "IVA"
            lnImpuesto = tnMonto * 0.21
        CASE tcTipo = "IIBB"
            lnImpuesto = tnMonto * 0.035
        CASE tcTipo = "GANANCIAS"
            lnImpuesto = tnMonto * 0.06
    ENDCASE
    
    RETURN lnImpuesto
ENDPROC
```

**Después**:
```foxpro
* Clase base
DEFINE CLASS CalculadorImpuesto AS Custom
    PROCEDURE Calcular(tnMonto AS Number) AS Number
        * Implementar en subclases
        RETURN 0
    ENDPROC
ENDDEFINE

* Implementaciones específicas
DEFINE CLASS CalculadorIVA AS CalculadorImpuesto
    PROCEDURE Calcular(tnMonto AS Number) AS Number
        RETURN tnMonto * 0.21
    ENDPROC
ENDDEFINE

DEFINE CLASS CalculadorIIBB AS CalculadorImpuesto
    PROCEDURE Calcular(tnMonto AS Number) AS Number
        RETURN tnMonto * 0.035
    ENDPROC
ENDDEFINE

* Uso
LOCAL loCalculador
loCalculador = CREATEOBJECT("CalculadorIVA")
lnImpuesto = loCalculador.Calcular(tnMonto)
```

---

### 4. Introduce Parameter Object

**Cuándo aplicar**: Métodos con muchos parámetros (> 3).

**Antes**:
```foxpro
PROCEDURE CrearFactura(tcCliente, tcDireccion, tcCUIT, tnTotal, tdFecha, tcObservaciones)
    * ...
ENDPROC
```

**Después**:
```foxpro
DEFINE CLASS DatosFactura AS Custom
    cCliente = ""
    cDireccion = ""
    cCUIT = ""
    nTotal = 0
    dFecha = {}
    cObservaciones = ""
ENDDEFINE

PROCEDURE CrearFactura(toDatos AS DatosFactura)
    * Acceder a toDatos.cCliente, toDatos.nTotal, etc.
ENDPROC
```

---

### 5. Replace Error Code with Exception

**Cuándo aplicar**: Retornar códigos de error en lugar de manejar excepciones.

**Antes**:
```foxpro
PROCEDURE AbrirArchivo(tcRuta AS String) AS Number
    IF !FILE(tcRuta)
        RETURN -1  && Error: archivo no existe
    ENDIF
    
    * Intentar abrir
    ON ERROR lnError = ERROR()
    USE (tcRuta) IN 0
    ON ERROR
    
    IF lnError != 0
        RETURN -2  && Error al abrir
    ENDIF
    
    RETURN 0  && Éxito
ENDPROC
```

**Después**:
```foxpro
PROCEDURE AbrirArchivo(tcRuta AS String) AS Boolean
    TRY
        IF !FILE(tcRuta)
            ERROR "Archivo no existe: " + tcRuta
        ENDIF
        
        USE (tcRuta) IN 0
        RETURN .T.
        
    CATCH TO loEx
        THIS.LogError("Error al abrir archivo: " + loEx.Message)
        THROW
    ENDTRY
ENDPROC
```

---

### 6. Decompose Conditional

**Cuándo aplicar**: Condicionales complejos difíciles de leer.

**Antes**:
```foxpro
IF (THIS.nEdad >= 18 AND THIS.nEdad <= 65) AND ;
   (THIS.nIngreso >= 20000 OR THIS.lTieneTrabajo) AND ;
   !THIS.lTieneDeudas
    * Aprobar crédito
ENDIF
```

**Después**:
```foxpro
IF THIS.EsEdadApropiada() AND ;
   THIS.TieneSolvenciaEconomica() AND ;
   !THIS.TieneDeudas()
    * Aprobar crédito
ENDIF

PROTECTED PROCEDURE EsEdadApropiada() AS Boolean
    RETURN BETWEEN(THIS.nEdad, 18, 65)
ENDPROC

PROTECTED PROCEDURE TieneSolvenciaEconomica() AS Boolean
    RETURN THIS.nIngreso >= 20000 OR THIS.lTieneTrabajo
ENDPROC
```

---

### 7. Introduce Null Object

**Cuándo aplicar**: Múltiples chequeos de NULL u EMPTY.

**Antes**:
```foxpro
LOCAL loCliente
loCliente = THIS.BuscarCliente(tnId)

IF !ISNULL(loCliente)
    lcNombre = loCliente.cNombre
ELSE
    lcNombre = "[Sin cliente]"
ENDIF

IF !ISNULL(loCliente)
    lnDescuento = loCliente.nDescuento
ELSE
    lnDescuento = 0
ENDIF
```

**Después**:
```foxpro
DEFINE CLASS ClienteNulo AS Cliente
    cNombre = "[Sin cliente]"
    nDescuento = 0
    
    PROCEDURE EsNulo() AS Boolean
        RETURN .T.
    ENDPROC
ENDDEFINE

* Uso
LOCAL loCliente
loCliente = THIS.BuscarCliente(tnId)
IF ISNULL(loCliente)
    loCliente = CREATEOBJECT("ClienteNulo")
ENDIF

lcNombre = loCliente.cNombre
lnDescuento = loCliente.nDescuento
```

---

## 🔧 Refactorizaciones para Testabilidad

### 8. Extract Interface / Dependency Injection

**Cuándo aplicar**: Para facilitar unit testing con mocks.

**Antes**:
```foxpro
DEFINE CLASS ServicioFacturacion AS Custom
    PROCEDURE ProcesarFactura()
        LOCAL loAccesoDatos
        loAccesoDatos = CREATEOBJECT("AccesoDatosSQL")
        * Acoplamiento fuerte
    ENDPROC
ENDDEFINE
```

**Después**:
```foxpro
DEFINE CLASS ServicioFacturacion AS Custom
    oAccesoDatos = .NULL.  && Dependencia inyectable
    
    PROCEDURE Init(toAccesoDatos AS Object)
        THIS.oAccesoDatos = toAccesoDatos
    ENDPROC
    
    PROCEDURE ProcesarFactura()
        * Usar THIS.oAccesoDatos (puede ser mock en tests)
    ENDPROC
ENDDEFINE

* En producción
loServicio = CREATEOBJECT("ServicioFacturacion", CREATEOBJECT("AccesoDatosSQL"))

* En tests
loServicio = CREATEOBJECT("ServicioFacturacion", CREATEOBJECT("AccesoDatosMock"))
```

---

## 📋 Checklist de Refactorización

Antes de refactorizar:
- [ ] ¿Existen tests unitarios? Si no, crear primero
- [ ] ¿El código compila y funciona? Verificar
- [ ] ¿Entiendes completamente el código? Agregar comentarios si es necesario

Durante la refactorización:
- [ ] Hacer cambios pequeños e incrementales
- [ ] Ejecutar tests después de cada cambio
- [ ] Commitear frecuentemente con mensajes descriptivos

Después de refactorizar:
- [ ] Todos los tests pasan
- [ ] El código es más legible
- [ ] Se eliminaron duplicaciones
- [ ] Se mejoró la modularidad

---

## 🎯 Prioridades de Refactorización

1. **Alta prioridad**: Código crítico, frecuentemente modificado, con bugs recurrentes
2. **Media prioridad**: Código complejo pero estable
3. **Baja prioridad**: Código legacy que funciona y rara vez se toca

---

## 📚 Referencias

- *Refactoring: Improving the Design of Existing Code* - Martin Fowler
- *Clean Code* - Robert C. Martin
- *Working Effectively with Legacy Code* - Michael Feathers
