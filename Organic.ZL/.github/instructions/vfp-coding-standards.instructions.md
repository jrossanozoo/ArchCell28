---
description: Estándares de codificación Visual FoxPro 9 para proyecto Organic.ZL
applyTo: "**/*.{prg,vcx,scx,frx}"
---

# Estándares de Codificación VFP - Organic.ZL

## 🎯 Propósito

Este documento establece los estándares de codificación obligatorios para todo el código Visual FoxPro 9 en el proyecto Organic.ZL.

---

## 📝 Convenciones de Nombres

### Variables

**Siempre usar prefijos Hungarian Notation:**

```foxpro
* Variables LOCALES (dentro de procedimientos/métodos)
lcNombre      && Character (string)
lnContador    && Numeric (número)
llActivo      && Logical (boolean)
ldFecha       && Date (fecha)
ltFechaHora   && DateTime (fecha/hora)
loObjeto      && Object (objeto)
laCursor      && Array (arreglo)

* Variables PRIVADAS (parámetros de procedimientos)
pcParametro   && Character
pnValor       && Numeric
plFlag        && Logical
poObjeto      && Object

* Variables PÚBLICAS (evitar en lo posible)
gcGlobal      && Character
gnConfig      && Numeric
glSistema     && Logical

* Propiedades de CLASE
This.cPropiedad    && Character
This.nValor        && Numeric
This.lFlag         && Logical
This.oReferencia   && Object
```

### Procedimientos y Métodos

```foxpro
* PascalCase para procedimientos y métodos públicos
PROCEDURE ObtenerCliente()
PROCEDURE CalcularTotal()
PROCEDURE GuardarFactura()

* _PascalCase para procedimientos protegidos/privados
PROTECTED PROCEDURE _ValidarDatos()
PROTECTED PROCEDURE _InicializarConexion()
```

### Clases

```foxpro
* PascalCase para nombres de clases
DEFINE CLASS ClienteBusiness AS Custom
DEFINE CLASS FacturaRepository AS Custom
DEFINE CLASS FormularioCliente AS Form
```

### Archivos

```foxpro
* PascalCase.prg para clases
ClienteBusiness.prg
FacturaRepository.prg

* lowercase para procedimientos utilitarios
utils.prg
helpers.prg

* Din_* para archivos generados automáticamente
Din_AbmClienteAvanzadoEstilo2.prg
```

---

## 🏗️ Estructura de Archivos

### Header Obligatorio

```foxpro
*******************************************************************************
* Archivo: NombreArchivo.prg
* Propósito: Descripción clara y concisa del propósito del archivo
* Autor: [Nombre o Sistema]
* Fecha creación: YYYY-MM-DD
* Última modificación: YYYY-MM-DD
* Dependencias:
*   - OtraClase.prg
*   - HelperModule.prg
*******************************************************************************
```

### Estructura de Procedimiento

```foxpro
*******************************************************************************
* PROCEDURE: NombreProcedimiento
* PROPÓSITO: Descripción detallada de qué hace el procedimiento
* PARÁMETROS:
*   pcParametro1 - Descripción del parámetro 1
*   pnParametro2 - Descripción del parámetro 2
* RETORNA:
*   Logical - .T. si exitoso, .F. si falla
* EJEMPLO:
*   llExito = NombreProcedimiento("valor1", 123)
*******************************************************************************
PROCEDURE NombreProcedimiento(pcParametro1, pnParametro2)
    LOCAL llExito, lcResultado, loException
    llExito = .F.
    
    TRY
        * Validaciones iniciales
        IF EMPTY(pcParametro1)
            ERROR "Parámetro 1 es requerido"
        ENDIF
        
        * Lógica principal
        * ...
        
        llExito = .T.
        
    CATCH TO loException
        * Manejo de errores
        THIS.LogError(loException.Message, PROGRAM(), loException.LineNo)
        
    ENDTRY
    
    RETURN llExito
ENDPROC
```

### Estructura de Clase

```foxpro
*******************************************************************************
* CLASE: NombreClase
* PROPÓSITO: Descripción de la responsabilidad de la clase
* HEREDA DE: Custom (o clase base)
*******************************************************************************
DEFINE CLASS NombreClase AS Custom
    
    *-- Propiedades públicas
    cPropiedad1 = ""
    nPropiedad2 = 0
    lPropiedad3 = .F.
    
    *-- Propiedades protegidas
    PROTECTED oInternal
    
    *--------------------------------------------------------------------------
    * MÉTODO: Init
    * PROPÓSITO: Constructor de la clase
    *--------------------------------------------------------------------------
    PROCEDURE Init(pcParam)
        * Inicialización
        THIS.cPropiedad1 = pcParam
        RETURN .T.
    ENDPROC
    
    *--------------------------------------------------------------------------
    * MÉTODO: Destroy
    * PROPÓSITO: Destructor de la clase - liberar recursos
    *--------------------------------------------------------------------------
    PROCEDURE Destroy()
        * Cleanup
        THIS.oInternal = NULL
    ENDPROC
    
    *--------------------------------------------------------------------------
    * MÉTODO: MetodoPublico
    * PROPÓSITO: Descripción del método
    *--------------------------------------------------------------------------
    PROCEDURE MetodoPublico()
        * Implementación
        RETURN THIS._MetodoProtegido()
    ENDPROC
    
    *--------------------------------------------------------------------------
    * MÉTODO: _MetodoProtegido
    * PROPÓSITO: Descripción del método protegido
    *--------------------------------------------------------------------------
    PROTECTED PROCEDURE _MetodoProtegido()
        * Implementación interna
        RETURN .T.
    ENDPROC
    
ENDDEFINE
```

---

## ⚡ Buenas Prácticas Obligatorias

### 1. Siempre Usar TRY...CATCH

```foxpro
* ✅ CORRECTO
PROCEDURE ProcesarDatos()
    LOCAL llExito, loEx
    llExito = .F.
    
    TRY
        * Lógica que puede fallar
        USE tabla
        * ...
        USE
        llExito = .T.
        
    CATCH TO loEx
        THIS.LogError(loEx.Message)
        IF USED("tabla")
            USE IN tabla
        ENDIF
    ENDTRY
    
    RETURN llExito
ENDPROC

* ❌ INCORRECTO (sin manejo de errores)
PROCEDURE ProcesarDatos()
    USE tabla
    * ... (puede crashear)
    USE
ENDPROC
```

### 2. Preferir SQL sobre SCAN

```foxpro
* ✅ CORRECTO (rápido)
SELECT COUNT(*) as Total ;
    FROM clientes ;
    WHERE activo = .T. ;
    INTO CURSOR curTotal

* ❌ INCORRECTO (lento)
USE clientes
lnTotal = 0
SCAN FOR activo = .T.
    lnTotal = lnTotal + 1
ENDSCAN
```

### 3. Usar TEXT...ENDTEXT para SQL

```foxpro
* ✅ CORRECTO
TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
    SELECT c.id, c.nombre, f.total
    FROM clientes c
    INNER JOIN facturas f ON c.id = f.id_cliente
    WHERE c.activo = .T.
      AND f.fecha >= '<<DTOC(ldFecha)>>'
ENDTEXT

* ❌ INCORRECTO
lcSQL = "SELECT c.id, c.nombre, f.total " + ;
        "FROM clientes c " + ;
        "INNER JOIN facturas f ON c.id = f.id_cliente " + ;
        "WHERE c.activo = .T. AND f.fecha >= " + DTOC(ldFecha)
```

### 4. Siempre Liberar Recursos

```foxpro
* ✅ CORRECTO
PROCEDURE ProcesarArchivo()
    TRY
        USE tabla IN 0
        * ... procesamiento ...
        USE IN tabla  && Siempre cerrar
        
    CATCH
        IF USED("tabla")
            USE IN tabla  && Cerrar en catch también
        ENDIF
    ENDTRY
ENDPROC

* Objetos
loObjeto = CREATEOBJECT("MiClase")
* ... usar objeto ...
loObjeto = NULL  && Liberar referencia
```

### 5. Validar Parámetros Tempranamente

```foxpro
* ✅ CORRECTO (Guard Clauses)
PROCEDURE GuardarCliente(poCliente)
    * Validaciones al inicio
    IF ISNULL(poCliente)
        RETURN .F.
    ENDIF
    
    IF EMPTY(poCliente.cNombre)
        RETURN .F.
    ENDIF
    
    IF EMPTY(poCliente.cEmail)
        RETURN .F.
    ENDIF
    
    * Lógica principal sin indentación excesiva
    * ...
    RETURN .T.
ENDPROC

* ❌ INCORRECTO (nested IFs)
PROCEDURE GuardarCliente(poCliente)
    IF NOT ISNULL(poCliente)
        IF NOT EMPTY(poCliente.cNombre)
            IF NOT EMPTY(poCliente.cEmail)
                * ... lógica profundamente anidada
            ENDIF
        ENDIF
    ENDIF
ENDPROC
```

### 6. Usar Constantes en Lugar de Magic Numbers

```foxpro
* ✅ CORRECTO
* Definir constantes al inicio del archivo
DEFINE TIPO_FACTURA_A 1
DEFINE TIPO_FACTURA_B 2
DEFINE LIMITE_CREDITO_ESPECIAL 50000

IF lnTipo = TIPO_FACTURA_A
    * ...
ENDIF

IF lnCredito > LIMITE_CREDITO_ESPECIAL
    * ...
ENDIF

* ❌ INCORRECTO
IF lnTipo = 1  && ¿Qué significa 1?
    * ...
ENDIF

IF lnCredito > 50000  && ¿Por qué 50000?
    * ...
ENDIF
```

### 7. Métodos Pequeños y Cohesivos

```foxpro
* ✅ CORRECTO (métodos pequeños)
PROCEDURE ProcesarVenta()
    IF NOT THIS.ValidarDatos()
        RETURN .F.
    ENDIF
    
    lnTotal = THIS.CalcularTotal()
    lnId = THIS.GuardarFactura(lnTotal)
    THIS.ImprimirFactura(lnId)
    
    RETURN .T.
ENDPROC

* Cada método hace UNA cosa
PROTECTED PROCEDURE ValidarDatos()
    * Solo validar
    RETURN llValido
ENDPROC

PROTECTED PROCEDURE CalcularTotal()
    * Solo calcular
    RETURN lnTotal
ENDPROC

* ❌ INCORRECTO (método gigante de 200+ líneas)
PROCEDURE ProcesarVenta()
    * 50 líneas de validación
    * 50 líneas de cálculo
    * 50 líneas de guardado
    * 50 líneas de impresión
ENDPROC
```

---

## 🚫 Prácticas Prohibidas

### ❌ NO usar variables públicas sin justificación

```foxpro
* ❌ PROHIBIDO
PUBLIC gcConnectionString
gcConnectionString = "Server=..."

* ✅ PERMITIDO (inyección de dependencias)
loConfig = CREATEOBJECT("ConfigManager")
loDataAccess = CREATEOBJECT("DataAccess", loConfig.GetConnectionString())
```

### ❌ NO hardcodear paths

```foxpro
* ❌ PROHIBIDO
USE C:\MiApp\Datos\clientes.dbf

* ✅ PERMITIDO
lcBasePath = THIS.oConfig.GetDataPath()
USE (lcBasePath + "clientes.dbf")
```

### ❌ NO ignorar valores de retorno

```foxpro
* ❌ PROHIBIDO
GuardarCliente(loCliente)  && ¿Tuvo éxito?

* ✅ PERMITIDO
llExito = GuardarCliente(loCliente)
IF NOT llExito
    MESSAGEBOX("Error al guardar cliente", 16)
    RETURN .F.
ENDIF
```

### ❌ NO modificar código generado

```foxpro
* ❌ PROHIBIDO - Modificar archivos en Organic.Generated/
* Todos los archivos Din_*.prg son AUTOGENERADOS
* Cualquier cambio será SOBRESCRITO

* ✅ PERMITIDO - Modificar definiciones origen
* Cambiar XMLs, templates, schemas
* Luego regenerar con Update-EstructuraAdnPrg.ps1
```

---

## 📏 Métricas de Calidad

**Cada archivo debe cumplir:**

- ✅ **Complejidad ciclomática**: < 10 por método
- ✅ **Líneas por método**: < 100 líneas
- ✅ **Profundidad de anidación**: < 4 niveles
- ✅ **Parámetros por método**: < 5 parámetros
- ✅ **Longitud de línea**: < 120 caracteres

---

## 🔗 Referencias

- **Agente de código**: `Organic.BusinessLogic/AGENTS.md`
- **Patrones de refactoring**: `.github/prompts/refactor/refactor-patterns.prompt.md`
- **Auditoría de código**: `.github/prompts/auditoria/code-audit-comprehensive.prompt.md`

---

**Última revisión**: 2025-10-15  
**Aplicable a**: Todo código VFP en Organic.ZL  
**Excepciones**: Solo código generado automáticamente
