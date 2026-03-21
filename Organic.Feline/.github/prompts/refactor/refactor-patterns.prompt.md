---
description: "Refactorización de código Visual FoxPro 9 legacy con patrones modernos"
mode: "agent"
tools: ["read_file", "grep_search", "list_code_usages", "replace_string_in_file", "semantic_search"]
---

# 🔄 Refactorización con Patrones Modernos

## Objetivo
Transformar código Visual FoxPro 9 legacy en código mantenible, testeable y escalable aplicando patrones de diseño modernos sin comprometer funcionalidad.

## Principios de refactorización

### 1. Refactorizar con seguridad
- ✅ **Tests primero**: Asegurar cobertura de tests antes de refactorizar
- ✅ **Pasos pequeños**: Refactors incrementales, no reescribir todo
- ✅ **Validar continuamente**: Ejecutar tests después de cada cambio
- ✅ **Mantener funcionalidad**: No cambiar comportamiento externo

### 2. Identificar code smells

#### 🔴 Critical smells (refactorizar inmediatamente)

**Long Method (Método largo >50 líneas)**
```foxpro
*-- ❌ ANTES: Método monolítico de 200 líneas
PROCEDURE ProcesarFactura(tnFacturaId)
    LOCAL lnHandle, lcSQL, i, lnTotal, lnImpuestos, lnDescuento
    
    *-- 50 líneas de validación
    IF EMPTY(tnFacturaId)
        RETURN .F.
    ENDIF
    *-- ... más validaciones ...
    
    *-- 100 líneas de cálculos
    lnTotal = 0
    FOR i = 1 TO THIS.nItems
        *-- ... cálculos complejos ...
    ENDFOR
    
    *-- 50 líneas de guardado
    lnHandle = SQLCONNECT("MiDSN")
    *-- ... múltiples queries ...
    =SQLDISCONNECT(lnHandle)
    
    RETURN .T.
ENDPROC

*-- ✅ DESPUÉS: Método descompuesto
PROCEDURE ProcesarFactura(tnFacturaId)
    IF NOT THIS.ValidarFactura(tnFacturaId)
        RETURN .F.
    ENDIF
    
    LOCAL loFactura
    loFactura = THIS.ObtenerFactura(tnFacturaId)
    
    THIS.CalcularTotales(loFactura)
    THIS.AplicarDescuentos(loFactura)
    THIS.CalcularImpuestos(loFactura)
    
    RETURN THIS.GuardarFactura(loFactura)
ENDPROC

PROTECTED PROCEDURE ValidarFactura(tnFacturaId)
    RETURN NOT EMPTY(tnFacturaId) AND THIS.FacturaExiste(tnFacturaId)
ENDPROC

PROTECTED PROCEDURE CalcularTotales(toFactura)
    LOCAL i, lnSubtotal
    lnSubtotal = 0
    
    FOR i = 1 TO ALEN(toFactura.aDetalles)
        lnSubtotal = lnSubtotal + THIS.CalcularLineaTotal(toFactura.aDetalles[i])
    ENDFOR
    
    toFactura.Subtotal = lnSubtotal
ENDPROC

*-- ... más métodos cohesivos pequeños ...
```

**Duplicated Code (Código duplicado)**
```foxpro
*-- ❌ ANTES: Lógica duplicada en múltiples lugares
PROCEDURE GuardarCliente
    lnHandle = SQLCONNECT("MiDSN")
    IF lnHandle < 0
        MESSAGEBOX("Error de conexión")
        RETURN .F.
    ENDIF
    *-- ... lógica de guardado ...
    =SQLDISCONNECT(lnHandle)
ENDPROC

PROCEDURE ActualizarCliente
    lnHandle = SQLCONNECT("MiDSN")
    IF lnHandle < 0
        MESSAGEBOX("Error de conexión")
        RETURN .F.
    ENDIF
    *-- ... lógica de actualización ...
    =SQLDISCONNECT(lnHandle)
ENDPROC

*-- ✅ DESPUÉS: Extraer método común
PROCEDURE GuardarCliente
    RETURN THIS.EjecutarEnConexion("GuardarClienteSQL")
ENDPROC

PROCEDURE ActualizarCliente
    RETURN THIS.EjecutarEnConexion("ActualizarClienteSQL")
ENDPROC

PROTECTED PROCEDURE EjecutarEnConexion(tcMetodo)
    LOCAL lnHandle, llSuccess
    
    lnHandle = THIS.AbrirConexion()
    IF lnHandle < 0
        THIS.MostrarErrorConexion()
        RETURN .F.
    ENDIF
    
    TRY
        llSuccess = EVALUATE("THIS." + tcMetodo + "(lnHandle)")
    FINALLY
        THIS.CerrarConexion(lnHandle)
    ENDTRY
    
    RETURN llSuccess
ENDPROC
```

**God Class (Clase todo-poderosa)**
```foxpro
*-- ❌ ANTES: Clase con demasiadas responsabilidades
DEFINE CLASS FacturaManager AS Custom
    *-- Gestión de clientes
    PROCEDURE ObtenerCliente
    PROCEDURE GuardarCliente
    
    *-- Gestión de productos
    PROCEDURE ObtenerProducto
    PROCEDURE ActualizarStock
    
    *-- Cálculos financieros
    PROCEDURE CalcularImpuestos
    PROCEDURE AplicarDescuentos
    
    *-- Impresión
    PROCEDURE ImprimirFactura
    PROCEDURE GenerarPDF
    
    *-- Envío email
    PROCEDURE EnviarPorEmail
    
    *-- ... 50 métodos más ...
ENDDEFINE

*-- ✅ DESPUÉS: Separar responsabilidades
DEFINE CLASS FacturaManager AS Custom
    oClienteService = .NULL.
    oProductoService = .NULL.
    oCalculadora = .NULL.
    oImpresora = .NULL.
    oNotificador = .NULL.
    
    PROCEDURE Init
        THIS.oClienteService = CREATEOBJECT("ClienteService")
        THIS.oProductoService = CREATEOBJECT("ProductoService")
        THIS.oCalculadora = CREATEOBJECT("CalculadoraFinanciera")
        THIS.oImpresora = CREATEOBJECT("ImpresoraFacturas")
        THIS.oNotificador = CREATEOBJECT("NotificadorEmail")
    ENDPROC
    
    PROCEDURE ProcesarFactura(tnFacturaId)
        *-- Delegar a servicios especializados
        LOCAL loCliente, loFactura
        loCliente = THIS.oClienteService.ObtenerPorId(tnClienteId)
        loFactura = THIS.CrearFactura(loCliente)
        
        THIS.oCalculadora.CalcularTotales(loFactura)
        THIS.GuardarFactura(loFactura)
        
        THIS.oImpresora.Imprimir(loFactura)
        THIS.oNotificador.EnviarFactura(loFactura, loCliente)
    ENDPROC
ENDDEFINE

DEFINE CLASS ClienteService AS Custom
    oRepository = .NULL.
    PROCEDURE ObtenerPorId(tnId)
        RETURN THIS.oRepository.GetById(tnId)
    ENDPROC
ENDDEFINE

*-- ... Clases separadas por responsabilidad ...
```

#### 🟡 Warning smells (refactorizar en próximo sprint)

**Magic Numbers (Números mágicos)**
```foxpro
*-- ❌ ANTES: Números hardcodeados
PROCEDURE CalcularDescuento(tnTotal)
    IF tnTotal > 1000
        RETURN tnTotal * 0.15
    ELSE
        RETURN tnTotal * 0.05
    ENDIF
ENDPROC

*-- ✅ DESPUÉS: Constantes nombradas
#DEFINE UMBRAL_DESCUENTO_GRANDE 1000
#DEFINE PORCENTAJE_DESCUENTO_GRANDE 0.15
#DEFINE PORCENTAJE_DESCUENTO_BASICO 0.05

PROCEDURE CalcularDescuento(tnTotal)
    LOCAL lnPorcentaje
    
    lnPorcentaje = IIF(tnTotal > UMBRAL_DESCUENTO_GRANDE, ;
                       PORCENTAJE_DESCUENTO_GRANDE, ;
                       PORCENTAJE_DESCUENTO_BASICO)
    
    RETURN tnTotal * lnPorcentaje
ENDPROC
```

**Feature Envy (Envidiando features de otra clase)**
```foxpro
*-- ❌ ANTES: Método que usa mucho de otra clase
DEFINE CLASS FacturaReporte AS Custom
    PROCEDURE GenerarLinea(toFactura)
        LOCAL lcLinea
        lcLinea = TRANSFORM(toFactura.Numero) + " - " + ;
                  toFactura.oCliente.Nombre + " - " + ;
                  DTOC(toFactura.Fecha) + " - " + ;
                  THIS.FormatearMonto(toFactura.Total)
        RETURN lcLinea
    ENDPROC
ENDDEFINE

*-- ✅ DESPUÉS: Mover comportamiento a clase apropiada
DEFINE CLASS Factura AS Custom
    PROCEDURE ObtenerResumen
        LOCAL lcResumen
        lcResumen = TRANSFORM(THIS.Numero) + " - " + ;
                    THIS.oCliente.Nombre + " - " + ;
                    DTOC(THIS.Fecha) + " - " + ;
                    THIS.FormatearTotal()
        RETURN lcResumen
    ENDPROC
    
    PROTECTED PROCEDURE FormatearTotal
        RETURN "$" + TRANSFORM(THIS.Total, "999,999.99")
    ENDPROC
ENDDEFINE

DEFINE CLASS FacturaReporte AS Custom
    PROCEDURE GenerarLinea(toFactura)
        RETURN toFactura.ObtenerResumen()
    ENDPROC
ENDDEFINE
```

## Patrones de refactorización

### 1. Extract Method (Extraer método)
**Cuándo**: Método muy largo o bloque de código reutilizable

```foxpro
*-- ANTES
PROCEDURE ProcesarPedido
    *-- Validar stock
    LOCAL i, llStockOk
    llStockOk = .T.
    FOR i = 1 TO ALEN(aItems)
        IF aItems[i].Cantidad > aItems[i].StockDisponible
            llStockOk = .F.
            EXIT
        ENDIF
    ENDFOR
    IF NOT llStockOk
        RETURN .F.
    ENDIF
    *-- ... más código ...
ENDPROC

*-- DESPUÉS
PROCEDURE ProcesarPedido
    IF NOT THIS.ValidarStock(aItems)
        RETURN .F.
    ENDIF
    *-- ... más código ...
ENDPROC

PROTECTED PROCEDURE ValidarStock(taItems)
    LOCAL i
    FOR i = 1 TO ALEN(taItems)
        IF NOT THIS.TieneStock(taItems[i])
            RETURN .F.
        ENDIF
    ENDFOR
    RETURN .T.
ENDPROC

PROTECTED PROCEDURE TieneStock(toItem)
    RETURN toItem.Cantidad <= toItem.StockDisponible
ENDPROC
```

### 2. Replace Conditional with Polymorphism
**Cuándo**: Switch/case o IF múltiples por tipo de objeto

```foxpro
*-- ❌ ANTES: Condicionales por tipo
DEFINE CLASS CalculadoraDescuento AS Custom
    PROCEDURE CalcularDescuento(toCliente, tnMonto)
        LOCAL lnDescuento
        
        DO CASE
            CASE toCliente.Tipo = "VIP"
                lnDescuento = tnMonto * 0.20
            CASE toCliente.Tipo = "GOLD"
                lnDescuento = tnMonto * 0.15
            CASE toCliente.Tipo = "SILVER"
                lnDescuento = tnMonto * 0.10
            OTHERWISE
                lnDescuento = 0
        ENDCASE
        
        RETURN lnDescuento
    ENDPROC
ENDDEFINE

*-- ✅ DESPUÉS: Polimorfismo
DEFINE CLASS ClienteBase AS Custom
    ABSTRACT PROCEDURE CalcularDescuento(tnMonto)
ENDDEFINE

DEFINE CLASS ClienteVIP AS ClienteBase
    PROCEDURE CalcularDescuento(tnMonto)
        RETURN tnMonto * 0.20
    ENDPROC
ENDDEFINE

DEFINE CLASS ClienteGold AS ClienteBase
    PROCEDURE CalcularDescuento(tnMonto)
        RETURN tnMonto * 0.15
    ENDPROC
ENDDEFINE

DEFINE CLASS ClienteSilver AS ClienteBase
    PROCEDURE CalcularDescuento(tnMonto)
        RETURN tnMonto * 0.10
    ENDPROC
ENDDEFINE

*-- Uso
loCliente = THIS.ClienteFactory.CrearCliente(tcTipo)
lnDescuento = loCliente.CalcularDescuento(tnMonto)
```

### 3. Introduce Parameter Object
**Cuándo**: Método con muchos parámetros

```foxpro
*-- ❌ ANTES: 7 parámetros
PROCEDURE CrearFactura(tnClienteId, tdFecha, tcTipo, tcMoneda, ;
                       tnDescuento, tcFormaPago, tcObservaciones)
    *-- ...
ENDPROC

*-- ✅ DESPUÉS: Objeto de parámetros
DEFINE CLASS FacturaParams AS Custom
    ClienteId = 0
    Fecha = {}
    Tipo = ""
    Moneda = ""
    Descuento = 0
    FormaPago = ""
    Observaciones = ""
ENDDEFINE

PROCEDURE CrearFactura(toParams)
    IF NOT THIS.ValidarParams(toParams)
        RETURN .NULL.
    ENDIF
    
    LOCAL loFactura
    loFactura = CREATEOBJECT("Factura")
    loFactura.ClienteId = toParams.ClienteId
    loFactura.Fecha = toParams.Fecha
    *-- ...
    RETURN loFactura
ENDPROC

*-- Uso
loParams = CREATEOBJECT("FacturaParams")
loParams.ClienteId = 123
loParams.Fecha = DATE()
loParams.Tipo = "A"
loFactura = THIS.CrearFactura(loParams)
```

### 4. Replace Nested Conditional with Guard Clauses
**Cuándo**: IFs anidados dificultan lectura

```foxpro
*-- ❌ ANTES: Anidamiento profundo
PROCEDURE ProcesarPago(toFactura)
    IF NOT ISNULL(toFactura)
        IF toFactura.Total > 0
            IF THIS.TieneSaldo(toFactura.ClienteId)
                IF THIS.ValidarFormaPago(toFactura.FormaPago)
                    *-- Procesamiento real aquí (profundidad 4)
                    RETURN THIS.EjecutarPago(toFactura)
                ENDIF
            ENDIF
        ENDIF
    ENDIF
    RETURN .F.
ENDPROC

*-- ✅ DESPUÉS: Guard clauses (early return)
PROCEDURE ProcesarPago(toFactura)
    *-- Validaciones con early return
    IF ISNULL(toFactura)
        RETURN .F.
    ENDIF
    
    IF toFactura.Total <= 0
        RETURN .F.
    ENDIF
    
    IF NOT THIS.TieneSaldo(toFactura.ClienteId)
        RETURN .F.
    ENDIF
    
    IF NOT THIS.ValidarFormaPago(toFactura.FormaPago)
        RETURN .F.
    ENDIF
    
    *-- Procesamiento principal sin anidamiento
    RETURN THIS.EjecutarPago(toFactura)
ENDPROC
```

### 5. Introduce Null Object
**Cuándo**: Muchos chequeos de NULL

```foxpro
*-- ❌ ANTES: Chequeos NULL en todos lados
PROCEDURE MostrarCliente(toCliente)
    IF ISNULL(toCliente)
        ? "Sin cliente"
    ELSE
        ? toCliente.Nombre
    ENDIF
ENDPROC

PROCEDURE EnviarEmail(toCliente)
    IF NOT ISNULL(toCliente) AND NOT EMPTY(toCliente.Email)
        THIS.oMailer.Enviar(toCliente.Email, "Mensaje")
    ENDIF
ENDPROC

*-- ✅ DESPUÉS: Null Object Pattern
DEFINE CLASS ClienteNull AS ClienteBase
    Nombre = "Sin asignar"
    Email = ""
    
    PROCEDURE IsNull
        RETURN .T.
    ENDPROC
    
    PROCEDURE RecibirEmail(tcMensaje)
        *-- No hace nada, pero no explota
    ENDPROC
ENDDEFINE

PROCEDURE MostrarCliente(toCliente)
    ? toCliente.Nombre  && Siempre funciona
ENDPROC

PROCEDURE EnviarEmail(toCliente)
    toCliente.RecibirEmail("Mensaje")  && Polimórfico
ENDPROC

*-- Factory retorna NullObject en lugar de NULL
PROCEDURE ObtenerCliente(tnId)
    LOCAL loCliente
    loCliente = THIS.oRepository.GetById(tnId)
    
    IF ISNULL(loCliente)
        loCliente = CREATEOBJECT("ClienteNull")
    ENDIF
    
    RETURN loCliente
ENDPROC
```

## Proceso de refactorización paso a paso

### Checklist de refactoring seguro

1. **Pre-refactoring**
   - [ ] Identificar código a refactorizar
   - [ ] Asegurar que existe test coverage (>=70%)
   - [ ] Ejecutar todos los tests (deben pasar 100%)
   - [ ] Crear branch de refactoring
   - [ ] Hacer commit del estado actual

2. **Durante refactoring**
   - [ ] Refactorizar en pasos pequeños (<30 min por paso)
   - [ ] Ejecutar tests después de cada paso
   - [ ] Commit frecuente (cada paso completado)
   - [ ] No cambiar funcionalidad y estructura al mismo tiempo
   - [ ] Documentar cambios significativos

3. **Post-refactoring**
   - [ ] Ejecutar suite completa de tests
   - [ ] Validar performance (no debe degradar)
   - [ ] Code review con par de desarrollo
   - [ ] Actualizar documentación
   - [ ] Merge a rama principal

## Uso con GitHub Copilot Chat

```
Usa el prompt de refactorización para mejorar el método ProcesarFactura en FacturaManager.prg
```

```
Identifica code smells en CENTRALSS/_Nucleo/ y propone refactorings
```

```
Aplica el patrón Repository a mi código de acceso a datos legacy
```

---

**Referencias**:
- Auditoría previa: `.github/prompts/auditoria/code-audit-comprehensive.prompt.md`
- Desarrollo: `.github/prompts/dev/vfp-development-expert.prompt.md`
- Testing: `.github/prompts/auditoria/test-audit.prompt.md`
