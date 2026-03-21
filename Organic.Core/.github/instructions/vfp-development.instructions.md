---
description: Instrucciones para desarrollo de codigo Visual FoxPro 9 en este proyecto
applyTo: "**/*.prg,**/*.vcx,**/*.scx,**/*.frx,**/*.mnx"
---

# Instrucciones de Desarrollo VFP

## Contexto

Estas trabajando en el proyecto **Organic.Core**, una solucion Visual FoxPro 9 que se desarrolla en VS Code con DOVFP como compilador. El proyecto usa wwDotNetBridge para interoperabilidad con .NET.

---

## Estructura de codigo

### Proyectos

- **Organic.BusinessLogic**: Codigo de negocio principal (CENTRALSS/)
- **Organic.Generated**: Codigo generado automaticamente (NO EDITAR MANUALMENTE)
- **Organic.Tests**: Tests unitarios y funcionales

### Convenciones

#### Nomenclatura hungara
```foxpro
* Parametros: tc=text char, tn=numeric, tl=logical, to=object, ta=array
PROCEDURE MiProcedimiento(tcNombre, tnEdad, tlActivo)

* Variables locales: mismo prefijo con 'l'
LOCAL lcVariable, lnContador, llFlag, loObjeto

* Propiedades de clase
THIS.cPropiedad = ""   && character
THIS.nPropiedad = 0    && numeric
THIS.lPropiedad = .F.  && logical
THIS.oPropiedad = NULL && object
```

#### Formato de clases
```foxpro
DEFINE CLASS MiClase AS ParentClass
    * Propiedades primero
    cNombre = ""
    nEdad = 0
    
    * Constructor
    PROCEDURE Init(tcNombre, tnEdad)
        THIS.cNombre = tcNombre
        THIS.nEdad = tnEdad
        RETURN DODEFAULT()
    ENDPROC
    
    * Metodos publicos
    PROCEDURE MetodoPublico()
        * Logica
    ENDPROC
    
    * Metodos protegidos (por convencion)
    PROTECTED PROCEDURE MetodoInterno()
        * Logica interna
    ENDPROC
    
    * Destructor al final
    PROCEDURE Destroy()
        THIS.LiberarRecursos()
        RETURN DODEFAULT()
    ENDPROC
ENDDEFINE
```

---

## Mejores practicas

### 1. Manejo de errores
```foxpro
PROCEDURE MiProcedimiento()
    LOCAL llExito
    llExito = .F.
    
    TRY
        * Logica principal
        llExito = .T.
        
    CATCH TO loError
        * Logging
        THIS.LogError("MiProcedimiento", loError)
        
    FINALLY
        * Siempre liberar recursos
        THIS.LiberarRecursos()
    ENDTRY
    
    RETURN llExito
ENDPROC
```

### 2. Acceso a datos
```foxpro
* PREFERIR: SQL
SELECT SUM(Total) FROM Ventas WHERE Fecha > DATE() - 30 INTO CURSOR csrTotal

* EVITAR: SCAN (lento)
SCAN FOR Fecha > DATE() - 30
    lnTotal = lnTotal + Total
ENDSCAN
```

### 3. Liberacion de recursos
```foxpro
PROCEDURE Destroy()
    * Liberar objetos
    THIS.oObjeto = NULL
    
    * Cerrar cursores/tablas
    IF USED("MiCursor")
        USE IN MiCursor
    ENDIF
    
    RETURN DODEFAULT()
ENDPROC
```

### 4. Modularidad
- Funciones/metodos <50 lineas
- Una responsabilidad por funcion
- Reutilizacion sobre duplicacion

---

## wwDotNetBridge

### Inicializacion correcta
```foxpro
LOCAL loBridge, loNetObject
TRY
    DO wwDotNetBridge WITH "V4"
    loBridge = CREATEOBJECT("wwDotNetBridge")
    loBridge.LoadAssembly("System.dll")
    
    loNetObject = loBridge.CreateInstance("System.DateTime")
    ? loBridge.InvokeMethod(loNetObject, "ToString")
    
CATCH TO loException
    MESSAGEBOX("Bridge error: " + loException.Message)
FINALLY
    IF TYPE("loBridge") = "O"
        loBridge = NULL
    ENDIF
ENDTRY
```

### Mejores practicas Bridge
- Usar resolucion dinamica de rutas DLL
- Manejar errores de interop con TRY/CATCH
- Liberar objetos .NET cuando termines
- Mantener consistencia de version .NET Framework

---

## Debugging

### Breakpoints
Los breakpoints de VS Code se exportan automaticamente cuando presionas F5.

### Ejecutar proyecto
```bash
# Compilar y ejecutar
dovfp build
dovfp run

# Con argumentos
dovfp run -run_args "'parametro1', 123, .T."
```

---

## Testing

### Crear test
```foxpro
DEFINE CLASS Test_MiClase AS TestCase
    
    PROCEDURE Test_MetodoDebeFuncionar()
        * Arrange
        LOCAL loObjeto, lcEsperado
        loObjeto = CREATEOBJECT("MiClase")
        lcEsperado = "ResultadoEsperado"
        
        * Act
        LOCAL lcResultado
        lcResultado = loObjeto.MiMetodo()
        
        * Assert
        THIS.AssertEquals(lcEsperado, lcResultado)
    ENDPROC
    
ENDDEFINE
```

### Ejecutar tests
```bash
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

---

## No hacer

- NO editar archivos en `Organic.Generated/Generados/` (son generados)
- NO usar variables globales (PUBLIC/PRIVATE)
- NO hardcodear rutas absolutas
- NO dejar codigo comentado (usar Git)
- NO usar magic numbers (crear constantes)
- NO usar referencias a archivos en MAYUSCULAS (usar lowercase para herencia)

---

## Recursos

- **Agente VFP**: `Organic.BusinessLogic/AGENTS.md`
- **Prompts utiles**: `.github/prompts/dev/`
- **Ejemplos de codigo**: Ver tests en `Organic.Tests/`
