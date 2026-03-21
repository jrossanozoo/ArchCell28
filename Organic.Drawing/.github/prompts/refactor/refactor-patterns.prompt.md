---
description: Guía de patrones de refactoring para código Visual FoxPro 9 legacy hacia arquitecturas modernas y mantenibles
argument-hint: "Especifica el archivo o patrón de refactoring a aplicar (ej: extraer función, SCAN a SQL)"
---

# 🔧 Patrones de Refactoring para Visual FoxPro

## Objetivo

Transformar código Visual FoxPro legacy en código modular, mantenible y testeable aplicando patrones de refactoring probados.

---

## 🎯 Principios guía

1. **Refactoring incremental**: Pequeños cambios con validación continua
2. **Tests primero**: Crear tests antes de refactorizar (cuando sea posible)
3. **Mantener funcionalidad**: No cambiar comportamiento, solo estructura
4. **Reversibilidad**: Cada cambio debe ser reversible vía Git

---

## Patrón 1: 📦 Extraer Función

### Cuándo usar
- Funciones largas (>50 líneas)
- Bloques de código repetidos
- Lógica compleja sin nombre descriptivo

### Antes

```foxpro
PROCEDURE ProcesarVenta(tnIdCliente, tnTotal)
    LOCAL loCliente, lcSQL
    
    * Validar cliente
    lcSQL = "SELECT * FROM Clientes WHERE id = " + TRANSFORM(tnIdCliente)
    IF EXECSCRIPT(lcSQL) = 0
        MESSAGEBOX("Cliente no encontrado")
        RETURN .F.
    ENDIF
    
    * Verificar crédito
    IF Clientes.saldo < 0 AND ABS(Clientes.saldo) + tnTotal > Clientes.limite_credito
        MESSAGEBOX("Cliente sin crédito suficiente")
        RETURN .F.
    ENDIF
    
    * Registrar venta
    INSERT INTO Ventas (idCliente, total, fecha) ;
        VALUES (tnIdCliente, tnTotal, DATE())
    
    * Actualizar saldo
    UPDATE Clientes SET saldo = saldo - tnTotal WHERE id = tnIdCliente
    
    RETURN .T.
ENDPROC
```

### Después

```foxpro
PROCEDURE ProcesarVenta(tnIdCliente, tnTotal)
    IF !THIS.ValidarCliente(tnIdCliente)
        RETURN .F.
    ENDIF
    
    IF !THIS.VerificarCredito(tnIdCliente, tnTotal)
        RETURN .F.
    ENDIF
    
    THIS.RegistrarVenta(tnIdCliente, tnTotal)
    THIS.ActualizarSaldoCliente(tnIdCliente, tnTotal)
    
    RETURN .T.
ENDPROC

PROCEDURE ValidarCliente(tnIdCliente)
    LOCAL lcSQL
    lcSQL = "SELECT * FROM Clientes WHERE id = " + TRANSFORM(tnIdCliente)
    
    IF EXECSCRIPT(lcSQL) = 0
        MESSAGEBOX("Cliente no encontrado")
        RETURN .F.
    ENDIF
    
    RETURN .T.
ENDPROC

PROCEDURE VerificarCredito(tnIdCliente, tnTotal)
    IF Clientes.saldo < 0 AND ;
       ABS(Clientes.saldo) + tnTotal > Clientes.limite_credito
        MESSAGEBOX("Cliente sin crédito suficiente")
        RETURN .F.
    ENDIF
    
    RETURN .T.
ENDPROC
```

### Beneficios
- ✅ Mejor legibilidad
- ✅ Funciones reutilizables
- ✅ Más fácil de testear
- ✅ Responsabilidades claras

---

## Patrón 2: 🏗️ De Procedural a OOP

### Cuándo usar
- Código procedural con múltiples funciones relacionadas
- Necesidad de estado compartido
- Múltiples variaciones de un mismo comportamiento

### Antes (Procedural)

```foxpro
* Funciones sueltas en un .prg
FUNCTION CalcularDescuento(tnTotal, tcTipoCliente)
    DO CASE
        CASE tcTipoCliente = "VIP"
            RETURN tnTotal * 0.20
        CASE tcTipoCliente = "Regular"
            RETURN tnTotal * 0.10
        OTHERWISE
            RETURN 0
    ENDCASE
ENDFUNC

FUNCTION AplicarDescuento(tnTotal, tnDescuento)
    RETURN tnTotal - tnDescuento
ENDFUNC

FUNCTION GenerarFactura(tnIdCliente, tnTotal, tnDescuento)
    * Lógica de facturación...
ENDFUNC
```

### Después (OOP)

```foxpro
DEFINE CLASS GestorVentas AS Custom
    * Propiedades
    nTotal = 0
    nDescuento = 0
    oCliente = NULL
    
    PROCEDURE Init(toCliente)
        THIS.oCliente = toCliente
    ENDPROC
    
    PROCEDURE CalcularVenta(tnTotal)
        THIS.nTotal = tnTotal
        THIS.nDescuento = THIS.CalcularDescuento()
        RETURN THIS.nTotal - THIS.nDescuento
    ENDPROC
    
    PROTECTED PROCEDURE CalcularDescuento()
        LOCAL loEstrategia
        loEstrategia = THIS.ObtenerEstrategiaDescuento()
        RETURN loEstrategia.Calcular(THIS.nTotal)
    ENDPROC
    
    PROCEDURE ObtenerEstrategiaDescuento()
        DO CASE
            CASE THIS.oCliente.Tipo = "VIP"
                RETURN CREATEOBJECT("DescuentoVIP")
            CASE THIS.oCliente.Tipo = "Regular"
                RETURN CREATEOBJECT("DescuentoRegular")
            OTHERWISE
                RETURN CREATEOBJECT("SinDescuento")
        ENDCASE
    ENDPROC
ENDDEFINE

* Estrategias de descuento
DEFINE CLASS DescuentoVIP AS Custom
    PROCEDURE Calcular(tnTotal)
        RETURN tnTotal * 0.20
    ENDPROC
ENDDEFINE

DEFINE CLASS DescuentoRegular AS Custom
    PROCEDURE Calcular(tnTotal)
        RETURN tnTotal * 0.10
    ENDPROC
ENDDEFINE
```

### Beneficios
- ✅ Encapsulación de estado
- ✅ Reutilización vía herencia
- ✅ Más fácil de extender
- ✅ Testing independiente

---

## Patrón 3: 🔄 Reemplazar SCAN con SQL

### Cuándo usar
- Loops con `SCAN...ENDSCAN` sobre tablas
- Operaciones que pueden expresarse en SQL
- Performance crítica

### Antes

```foxpro
LOCAL lnTotal
lnTotal = 0

SELECT Ventas
SCAN FOR Fecha >= DATE() - 30 AND IdCliente = 123
    lnTotal = lnTotal + Ventas.Total
ENDSCAN

? "Total:", lnTotal
```

### Después

```foxpro
LOCAL lnTotal
lnTotal = 0

SELECT SUM(Total) AS Total ;
    FROM Ventas ;
    WHERE Fecha >= DATE() - 30 ;
      AND IdCliente = 123 ;
    INTO CURSOR csrTotal

lnTotal = csrTotal.Total
USE IN csrTotal

? "Total:", lnTotal
```

### Performance

| Método | 1,000 registros | 10,000 registros |
|--------|----------------|------------------|
| SCAN | 2.5 seg | 28 seg |
| SQL | 0.1 seg | 0.8 seg |

### Beneficios
- ✅ 10-25x más rápido
- ✅ Más legible
- ✅ Aprovecha optimizaciones del motor

---

## Patrón 4: 🛡️ Agregar Manejo de Errores

### Cuándo usar
- Funciones sin TRY...CATCH
- Operaciones de I/O
- Acceso a datos externos

### Antes

```foxpro
PROCEDURE AbrirArchivo(tcRuta)
    LOCAL lnHandle
    lnHandle = FOPEN(tcRuta)
    * ... operaciones ...
    FCLOSE(lnHandle)
ENDPROC
```

### Después

```foxpro
PROCEDURE AbrirArchivo(tcRuta)
    LOCAL lnHandle, llExito
    llExito = .F.
    
    TRY
        IF !FILE(tcRuta)
            ERROR "Archivo no encontrado: " + tcRuta
        ENDIF
        
        lnHandle = FOPEN(tcRuta)
        
        IF lnHandle < 0
            ERROR "No se pudo abrir: " + tcRuta
        ENDIF
        
        * ... operaciones seguras ...
        
        llExito = .T.
        
    CATCH TO loError
        THIS.LogError("AbrirArchivo", loError.Message, tcRuta)
        THROW  && Propagar error
        
    FINALLY
        IF lnHandle > 0
            FCLOSE(lnHandle)
        ENDIF
    ENDTRY
    
    RETURN llExito
ENDPROC

PROCEDURE LogError(tcMetodo, tcMensaje, tcContexto)
    LOCAL lcLog
    lcLog = TRANSFORM(DATETIME()) + " | " + ;
            tcMetodo + " | " + ;
            tcMensaje + " | " + ;
            tcContexto + CHR(13) + CHR(10)
    
    STRTOFILE(lcLog, "error.log", .T.)  && Append
ENDPROC
```

### Beneficios
- ✅ Errores controlados
- ✅ Liberación garantizada de recursos
- ✅ Logging para debugging
- ✅ Mayor robustez

---

## Patrón 5: 🧩 Inyección de Dependencias

### Cuándo usar
- Clases fuertemente acopladas
- Dificultad para testing
- Necesidad de múltiples implementaciones

### Antes (Acoplamiento fuerte)

```foxpro
DEFINE CLASS ServicioVentas AS Custom
    PROCEDURE ProcesarVenta(tnIdCliente, tnTotal)
        * Acoplamiento directo a clase concreta
        LOCAL loRepoClientes
        loRepoClientes = CREATEOBJECT("RepositorioClientesSQL")
        
        LOCAL loCliente
        loCliente = loRepoClientes.Obtener(tnIdCliente)
        
        * ... lógica ...
    ENDPROC
ENDDEFINE
```

### Después (Inyección de dependencias)

```foxpro
DEFINE CLASS ServicioVentas AS Custom
    oRepositorioClientes = NULL
    
    * Inyectar dependencia en Init
    PROCEDURE Init(toRepositorioClientes)
        THIS.oRepositorioClientes = toRepositorioClientes
    ENDPROC
    
    PROCEDURE ProcesarVenta(tnIdCliente, tnTotal)
        * Usar dependencia inyectada
        LOCAL loCliente
        loCliente = THIS.oRepositorioClientes.Obtener(tnIdCliente)
        
        * ... lógica ...
    ENDPROC
ENDDEFINE

* Uso en producción
LOCAL loRepo, loServicio
loRepo = CREATEOBJECT("RepositorioClientesSQL")
loServicio = CREATEOBJECT("ServicioVentas", loRepo)

* Uso en tests
LOCAL loMockRepo, loServicio
loMockRepo = CREATEOBJECT("RepositorioClientesMock")
loServicio = CREATEOBJECT("ServicioVentas", loMockRepo)
```

### Beneficios
- ✅ Bajo acoplamiento
- ✅ Testing fácil con mocks
- ✅ Intercambio de implementaciones
- ✅ Más flexible

---

## Patrón 6: 🔢 Eliminar Magic Numbers

### Cuándo usar
- Números o strings hardcodeados
- Valores que podrían cambiar
- Código poco expresivo

### Antes

```foxpro
PROCEDURE ValidarEdad(tnEdad)
    IF tnEdad < 18
        RETURN .F.
    ENDIF
    
    IF tnEdad > 120
        RETURN .F.
    ENDIF
    
    RETURN .T.
ENDPROC

PROCEDURE CalcularPrecio(tcCategoria, tnPrecioBase)
    DO CASE
        CASE tcCategoria = "A"
            RETURN tnPrecioBase * 1.5
        CASE tcCategoria = "B"
            RETURN tnPrecioBase * 1.2
        OTHERWISE
            RETURN tnPrecioBase
    ENDCASE
ENDPROC
```

### Después

```foxpro
* Constantes al inicio del archivo o clase
#DEFINE EDAD_MINIMA 18
#DEFINE EDAD_MAXIMA 120

#DEFINE CATEGORIA_PREMIUM "A"
#DEFINE CATEGORIA_STANDARD "B"
#DEFINE MULTIPLICADOR_PREMIUM 1.5
#DEFINE MULTIPLICADOR_STANDARD 1.2

PROCEDURE ValidarEdad(tnEdad)
    IF tnEdad < EDAD_MINIMA OR tnEdad > EDAD_MAXIMA
        RETURN .F.
    ENDIF
    
    RETURN .T.
ENDPROC

PROCEDURE CalcularPrecio(tcCategoria, tnPrecioBase)
    DO CASE
        CASE tcCategoria = CATEGORIA_PREMIUM
            RETURN tnPrecioBase * MULTIPLICADOR_PREMIUM
        CASE tcCategoria = CATEGORIA_STANDARD
            RETURN tnPrecioBase * MULTIPLICADOR_STANDARD
        OTHERWISE
            RETURN tnPrecioBase
    ENDCASE
ENDPROC
```

### Beneficios
- ✅ Código auto-documentado
- ✅ Fácil de mantener
- ✅ Cambios centralizados
- ✅ Menos errores

---

## 🗺️ Proceso de refactoring paso a paso

### 1. Identificar código a refactorizar
```
@workspace Usando el prompt code-audit-comprehensive, identifica candidatos para refactoring
```

### 2. Crear tests (si no existen)
```foxpro
* Test_MiModulo.prg
DEFINE CLASS Test_MiModulo AS TestCase
    PROCEDURE Test_ComportamientoActual()
        * Documentar comportamiento antes de refactorizar
    ENDPROC
ENDDEFINE
```

### 3. Hacer backup
```powershell
git checkout -b refactor/nombre-descriptivo
git add .
git commit -m "Pre-refactoring: estado actual"
```

### 4. Refactorizar incrementalmente
- Cambios pequeños y atómicos
- Ejecutar tests después de cada cambio
- Commit frecuentes

### 5. Validar
```bash
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

### 6. Documentar cambios
```markdown
## Refactoring realizado

**Archivo**: main2028.prg
**Patrón aplicado**: Extraer Función
**Líneas afectadas**: 45-120
**Tests agregados**: Test_NuevaFuncion.prg
**Mejora**: Reducción de complejidad ciclomática de 15 a 5
```

---

## 🎯 Priorización de refactoring

### Urgente (hacer ahora)
- Código con bugs frecuentes
- Funciones >200 líneas
- Duplicación masiva
- Falta crítica de manejo de errores

### Importante (próximas semanas)
- Código poco testeable
- Acoplamiento alto
- Performance pobre

### Deseable (backlog)
- Mejoras de nomenclatura
- Optimizaciones menores
- Documentación

---

## Uso del prompt

```
@workspace #file:ventas.prg Aplicando refactor-patterns, extrae funciones de este procedimiento largo

@workspace Convierte este código procedural a OOP siguiendo los patrones del prompt

@workspace #file:consultas.prg Reemplaza los SCAN con SQL según el patrón de refactoring
```

---

## Relacionado

- Prompt: `code-audit-comprehensive.prompt.md`
- Agente VFP: `/Organic.BusinessLogic/AGENTS.md`
- Agente de testing: `/Organic.Tests/AGENTS.md`
