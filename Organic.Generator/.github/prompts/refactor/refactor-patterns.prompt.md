---
description: "Patrones y estrategias de refactorización para código VFP: modernización, mejora de calidad y reducción de deuda técnica"
---

# 🔄 Refactor Patterns - Visual FoxPro Modernization

## Objective
Apply modern refactoring patterns to Visual FoxPro 9 code to improve maintainability, readability, performance, and reduce technical debt.

---

## 🎯 Refactoring Categories

### 1. **Extract Method/Function**

#### When to Apply
- Función muy larga (>50 líneas)
- Código duplicado
- Bloque de código con responsabilidad clara
- Difícil de testear

#### Pattern
```vfp
* ❌ ANTES: Función monolítica
FUNCTION ProcesarVenta(pnIdVenta)
  LOCAL loVenta, lnTotal, lnDescuento, lnImpuestos
  
  * Validar venta (20 líneas)
  IF !USED("ventas")
    USE ventas IN 0
  ENDIF
  SELECT ventas
  LOCATE FOR id = pnIdVenta
  IF !FOUND()
    MESSAGEBOX("Venta no encontrada")
    RETURN .F.
  ENDIF
  * ... más validaciones
  
  * Calcular totales (30 líneas)
  lnTotal = 0
  SELECT detalles
  SCAN FOR id_venta = pnIdVenta
    lnTotal = lnTotal + cantidad * precio
  ENDSCAN
  * ... más cálculos
  
  * Aplicar descuentos (25 líneas)
  IF ventas.cliente_vip
    lnDescuento = lnTotal * 0.15
  ELSE
    lnDescuento = lnTotal * 0.05
  ENDIF
  * ... más lógica
  
  * Calcular impuestos (20 líneas)
  * ...
  
  RETURN .T.
ENDFUNC

* ✅ DESPUÉS: Funciones extraídas
FUNCTION ProcesarVenta(pnIdVenta)
  LOCAL loVenta
  
  * Validar
  IF !ValidarVenta(pnIdVenta)
    RETURN .F.
  ENDIF
  
  * Procesar
  loVenta = ObtenerVenta(pnIdVenta)
  loVenta.Total = CalcularTotal(pnIdVenta)
  loVenta.Descuento = CalcularDescuento(loVenta)
  loVenta.Impuestos = CalcularImpuestos(loVenta)
  
  * Guardar
  RETURN GuardarVenta(loVenta)
ENDFUNC

FUNCTION ValidarVenta(pnIdVenta)
  IF !AbrirTabla("ventas")
    RETURN .F.
  ENDIF
  
  SELECT ventas
  LOCATE FOR id = pnIdVenta
  
  IF !FOUND()
    MostrarError("Venta no encontrada")
    RETURN .F.
  ENDIF
  
  RETURN .T.
ENDFUNC

FUNCTION CalcularTotal(pnIdVenta)
  LOCAL lnTotal
  lnTotal = 0
  
  AbrirTabla("detalles")
  SELECT detalles
  SCAN FOR id_venta = pnIdVenta
    lnTotal = lnTotal + cantidad * precio
  ENDSCAN
  
  RETURN lnTotal
ENDFUNC
```

---

### 2. **Replace Conditional with Polymorphism**

#### When to Apply
- Múltiples IF/CASE basados en tipo
- Comportamiento varía según tipo de objeto
- Código difícil de extender

#### Pattern
```vfp
* ❌ ANTES: Condicionales complejos
FUNCTION CalcularDescuento(poCliente, pnMonto)
  LOCAL lnDescuento
  
  DO CASE
    CASE poCliente.Tipo = "VIP"
      lnDescuento = pnMonto * 0.20
      
    CASE poCliente.Tipo = "PREMIUM"
      IF pnMonto > 10000
        lnDescuento = pnMonto * 0.15
      ELSE
        lnDescuento = pnMonto * 0.10
      ENDIF
      
    CASE poCliente.Tipo = "REGULAR"
      lnDescuento = pnMonto * 0.05
      
    OTHERWISE
      lnDescuento = 0
  ENDCASE
  
  RETURN lnDescuento
ENDFUNC

* ✅ DESPUÉS: Polimorfismo con clases
DEFINE CLASS ClienteBase AS Custom
  Tipo = ""
  
  FUNCTION CalcularDescuento(pnMonto)
    RETURN 0  && Default: sin descuento
  ENDFUNC
ENDDEFINE

DEFINE CLASS ClienteVIP AS ClienteBase
  Tipo = "VIP"
  
  FUNCTION CalcularDescuento(pnMonto)
    RETURN pnMonto * 0.20
  ENDFUNC
ENDDEFINE

DEFINE CLASS ClientePremium AS ClienteBase
  Tipo = "PREMIUM"
  
  FUNCTION CalcularDescuento(pnMonto)
    IF pnMonto > 10000
      RETURN pnMonto * 0.15
    ELSE
      RETURN pnMonto * 0.10
    ENDIF
  ENDFUNC
ENDDEFINE

DEFINE CLASS ClienteRegular AS ClienteBase
  Tipo = "REGULAR"
  
  FUNCTION CalcularDescuento(pnMonto)
    RETURN pnMonto * 0.05
  ENDFUNC
ENDDEFINE

* Uso simplificado
FUNCTION ProcesarDescuento(poCliente, pnMonto)
  RETURN poCliente.CalcularDescuento(pnMonto)
ENDFUNC
```

---

### 3. **Replace Magic Numbers with Constants**

#### When to Apply
- Números hardcoded sin contexto
- Valores reutilizados en múltiples lugares
- Difícil de mantener y entender

#### Pattern
```vfp
* ❌ ANTES: Magic numbers
FUNCTION ValidarCUIT(pcCUIT)
  IF LEN(pcCUIT) != 11
    RETURN .F.
  ENDIF
  
  IF VAL(LEFT(pcCUIT, 2)) < 20 OR VAL(LEFT(pcCUIT, 2)) > 34
    RETURN .F.
  ENDIF
  
  RETURN .T.
ENDFUNC

FUNCTION CalcularComision(pnMonto)
  IF pnMonto > 50000
    RETURN pnMonto * 0.03
  ELSE
    RETURN pnMonto * 0.05
  ENDIF
ENDFUNC

* ✅ DESPUÉS: Constantes nombradas
#DEFINE CUIT_LONGITUD 11
#DEFINE CUIT_PREFIJO_MIN 20
#DEFINE CUIT_PREFIJO_MAX 34
#DEFINE MONTO_DESCUENTO_ALTO 50000
#DEFINE COMISION_ALTO 0.03
#DEFINE COMISION_NORMAL 0.05

FUNCTION ValidarCUIT(pcCUIT)
  IF LEN(pcCUIT) != CUIT_LONGITUD
    RETURN .F.
  ENDIF
  
  LOCAL lnPrefijo
  lnPrefijo = VAL(LEFT(pcCUIT, 2))
  
  IF lnPrefijo < CUIT_PREFIJO_MIN OR lnPrefijo > CUIT_PREFIJO_MAX
    RETURN .F.
  ENDIF
  
  RETURN .T.
ENDFUNC

FUNCTION CalcularComision(pnMonto)
  IF pnMonto > MONTO_DESCUENTO_ALTO
    RETURN pnMonto * COMISION_ALTO
  ELSE
    RETURN pnMonto * COMISION_NORMAL
  ENDIF
ENDFUNC
```

---

### 4. **Introduce Parameter Object**

#### When to Apply
- Función con muchos parámetros (>5)
- Grupo de parámetros siempre usados juntos
- Difícil de recordar orden de parámetros

#### Pattern
```vfp
* ❌ ANTES: Muchos parámetros
FUNCTION GenerarReporte(pcTipo, pdFechaDesde, pdFechaHasta, ;
                        pcCliente, pcSucursal, plIncluirAnulados, ;
                        plIncluirBorradores, pcFormato, pcDestino)
  * ...
ENDFUNC

* Llamada confusa
llOk = GenerarReporte("VENTAS", {^2025-01-01}, {^2025-01-31}, ;
                      "CLI001", "SUC01", .F., .F., "PDF", "C:\Reportes\")

* ✅ DESPUÉS: Objeto de parámetros
DEFINE CLASS ReporteParams AS Custom
  Tipo = ""
  FechaDesde = {}
  FechaHasta = {}
  Cliente = ""
  Sucursal = ""
  IncluirAnulados = .F.
  IncluirBorradores = .F.
  Formato = "PDF"
  Destino = ""
ENDDEFINE

FUNCTION GenerarReporte(poParams)
  LOCAL lcSQL
  
  * Validar
  IF !ValidarParams(poParams)
    RETURN .F.
  ENDIF
  
  * Generar SQL
  lcSQL = "SELECT * FROM ventas WHERE " + ;
          "fecha BETWEEN ?poParams.FechaDesde AND ?poParams.FechaHasta"
  
  IF !EMPTY(poParams.Cliente)
    lcSQL = lcSQL + " AND cliente = ?poParams.Cliente"
  ENDIF
  
  * ... resto de lógica
  RETURN .T.
ENDFUNC

* Llamada clara
LOCAL loParams
loParams = CREATEOBJECT("ReporteParams")
loParams.Tipo = "VENTAS"
loParams.FechaDesde = {^2025-01-01}
loParams.FechaHasta = {^2025-01-31}
loParams.Cliente = "CLI001"
loParams.Sucursal = "SUC01"

llOk = GenerarReporte(loParams)
```

---

### 5. **Replace Nested Conditionals with Guard Clauses**

#### When to Apply
- Múltiples niveles de IF anidados
- Difícil de seguir el flujo
- Muchas validaciones al inicio

#### Pattern
```vfp
* ❌ ANTES: Anidamiento profundo
FUNCTION ProcesarPedido(poPedido)
  IF !ISNULL(poPedido)
    IF poPedido.Estado = "PENDIENTE"
      IF poPedido.Total > 0
        IF !EMPTY(poPedido.Cliente)
          IF ValidarStock(poPedido)
            * Lógica principal aquí (nivel 5 de indentación)
            RETURN .T.
          ELSE
            MostrarError("Stock insuficiente")
          ENDIF
        ELSE
          MostrarError("Cliente requerido")
        ENDIF
      ELSE
        MostrarError("Total debe ser mayor a 0")
      ENDIF
    ELSE
      MostrarError("Pedido debe estar pendiente")
    ENDIF
  ELSE
    MostrarError("Pedido es nulo")
  ENDIF
  
  RETURN .F.
ENDFUNC

* ✅ DESPUÉS: Guard clauses
FUNCTION ProcesarPedido(poPedido)
  * Validaciones con early return
  IF ISNULL(poPedido)
    MostrarError("Pedido es nulo")
    RETURN .F.
  ENDIF
  
  IF poPedido.Estado != "PENDIENTE"
    MostrarError("Pedido debe estar pendiente")
    RETURN .F.
  ENDIF
  
  IF poPedido.Total <= 0
    MostrarError("Total debe ser mayor a 0")
    RETURN .F.
  ENDIF
  
  IF EMPTY(poPedido.Cliente)
    MostrarError("Cliente requerido")
    RETURN .F.
  ENDIF
  
  IF !ValidarStock(poPedido)
    MostrarError("Stock insuficiente")
    RETURN .F.
  ENDIF
  
  * Lógica principal (sin indentación excesiva)
  RealizarPedido(poPedido)
  
  RETURN .T.
ENDFUNC
```

---

### 6. **Extract Class**

#### When to Apply
- Clase con muchas responsabilidades
- Grupo de métodos relacionados
- Clase muy grande (>500 líneas)

#### Pattern
```vfp
* ❌ ANTES: Clase monolítica
DEFINE CLASS GestorVentas AS Custom
  * Propiedades
  IdVenta = 0
  Cliente = ""
  * ...
  
  * Validación
  FUNCTION ValidarVenta()
  ENDFUNC
  
  * Cálculos
  FUNCTION CalcularTotal()
  ENDFUNC
  FUNCTION CalcularDescuento()
  ENDFUNC
  FUNCTION CalcularImpuestos()
  ENDFUNC
  
  * Persistencia
  FUNCTION GuardarVenta()
  ENDFUNC
  FUNCTION CargarVenta()
  ENDFUNC
  
  * Impresión
  FUNCTION ImprimirFactura()
  ENDFUNC
  FUNCTION ImprimirRemito()
  ENDFUNC
  
  * Email
  FUNCTION EnviarEmail()
  ENDFUNC
ENDDEFINE

* ✅ DESPUÉS: Clases separadas con responsabilidades únicas
DEFINE CLASS Venta AS Custom
  * Solo datos y validación básica
  IdVenta = 0
  Cliente = ""
  Total = 0
  
  FUNCTION Validar()
    RETURN !EMPTY(This.Cliente) AND This.Total > 0
  ENDFUNC
ENDDEFINE

DEFINE CLASS CalculadorVenta AS Custom
  * Solo cálculos
  FUNCTION CalcularTotal(poVenta)
  ENDFUNC
  
  FUNCTION CalcularDescuento(poVenta)
  ENDFUNC
  
  FUNCTION CalcularImpuestos(poVenta)
  ENDFUNC
ENDDEFINE

DEFINE CLASS RepositorioVenta AS Custom
  * Solo persistencia
  FUNCTION Guardar(poVenta)
  ENDFUNC
  
  FUNCTION Cargar(pnIdVenta)
  ENDFUNC
ENDDEFINE

DEFINE CLASS ImpresorVenta AS Custom
  * Solo impresión
  FUNCTION ImprimirFactura(poVenta)
  ENDFUNC
  
  FUNCTION ImprimirRemito(poVenta)
  ENDFUNC
ENDDEFINE

DEFINE CLASS NotificadorVenta AS Custom
  * Solo comunicaciones
  FUNCTION EnviarEmail(poVenta, pcDestinatario)
  ENDFUNC
ENDDEFINE
```

---

### 7. **Remove Dead Code**

#### When to Apply
- Código comentado hace tiempo
- Funciones no referenciadas
- Variables no utilizadas
- Features obsoletos

#### Pattern
```vfp
* ❌ ANTES: Código muerto
FUNCTION ProcesarCliente(poCliente)
  LOCAL lcNombre, lcApellido  && lcApellido nunca usado
  LOCAL lnTotal
  
  lcNombre = poCliente.Nombre
  
  * Código obsoleto comentado
  * lcDireccion = poCliente.Direccion
  * IF !EMPTY(lcDireccion)
  *   ValidarDireccion(lcDireccion)
  * ENDIF
  
  lnTotal = CalcularTotal(poCliente)
  
  * Función que nunca se ejecuta
  IF .F.
    MostrarMensajeAntiguo()
  ENDIF
  
  RETURN lnTotal
ENDFUNC

* Función nunca llamada en ningún lado
FUNCTION FuncionObsoleta()
  * código antiguo...
ENDFUNC

* ✅ DESPUÉS: Código limpio
FUNCTION ProcesarCliente(poCliente)
  LOCAL lcNombre, lnTotal
  
  lcNombre = poCliente.Nombre
  lnTotal = CalcularTotal(poCliente)
  
  RETURN lnTotal
ENDFUNC
```

---

### 8. **Consolidate Duplicate Code**

#### When to Apply
- Mismo código en múltiples lugares
- Lógica similar con pequeñas variaciones
- Difícil mantener cambios sincronizados

#### Pattern
```vfp
* ❌ ANTES: Código duplicado
FUNCTION ProcesarFactura(pnIdFactura)
  IF !USED("facturas")
    USE facturas IN 0 SHARED
  ENDIF
  SELECT facturas
  LOCATE FOR id = pnIdFactura
  * procesar...
ENDFUNC

FUNCTION ProcesarRemito(pnIdRemito)
  IF !USED("remitos")
    USE remitos IN 0 SHARED
  ENDIF
  SELECT remitos
  LOCATE FOR id = pnIdRemito
  * procesar...
ENDFUNC

FUNCTION ProcesarPedido(pnIdPedido)
  IF !USED("pedidos")
    USE pedidos IN 0 SHARED
  ENDIF
  SELECT pedidos
  LOCATE FOR id = pnIdPedido
  * procesar...
ENDFUNC

* ✅ DESPUÉS: Lógica común extraída
FUNCTION AbrirYBuscar(pcTabla, pcCampoId, puValorId)
  IF !USED(pcTabla)
    USE (pcTabla) IN 0 SHARED
  ENDIF
  
  SELECT (pcTabla)
  LOCATE FOR EVALUATE(pcCampoId) = puValorId
  
  RETURN FOUND()
ENDFUNC

FUNCTION ProcesarFactura(pnIdFactura)
  IF !AbrirYBuscar("facturas", "id", pnIdFactura)
    RETURN .F.
  ENDIF
  * procesar...
ENDFUNC

FUNCTION ProcesarRemito(pnIdRemito)
  IF !AbrirYBuscar("remitos", "id", pnIdRemito)
    RETURN .F.
  ENDIF
  * procesar...
ENDFUNC

FUNCTION ProcesarPedido(pnIdPedido)
  IF !AbrirYBuscar("pedidos", "id", pnIdPedido)
    RETURN .F.
  ENDIF
  * procesar...
ENDFUNC
```

---

## 🎯 Refactoring Strategy

### 1. **Assessment Phase**
- Identificar code smells
- Priorizar por impacto y riesgo
- Estimar esfuerzo

### 2. **Preparation**
- Crear tests si no existen
- Verificar que tests pasan
- Hacer backup/branch

### 3. **Execution**
- Refactorizar en pequeños pasos
- Ejecutar tests después de cada cambio
- Commit frecuente

### 4. **Validation**
- Todos los tests pasan
- No hay regresiones
- Code review

---

## 💡 Usage

```
@workspace /ask using #file:.github/prompts/refactor/refactor-patterns.prompt.md
Identify refactoring opportunities in Organic.BusinessLogic/CENTRALSS/Generadores
```

```
@workspace using #file:.github/prompts/refactor/refactor-patterns.prompt.md
Apply Extract Method pattern to this function with guard clauses
```

---

**Last Updated:** 2025-10-15  
**Version:** 1.0.0
