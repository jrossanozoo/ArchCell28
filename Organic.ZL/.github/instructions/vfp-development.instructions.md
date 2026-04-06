---
applyTo: "**/Organic.BusinessLogic/**/*.prg"
description: Instrucciones para desarrollo de código Visual FoxPro 9 en este proyecto
---

# Instrucciones de Desarrollo VFP

## Contexto

Estó¡s trabajando en el proyecto **Organic.Drawing**, una solució³n Visual FoxPro 9 que se desarrolla en VS Code con DOVFP como compilador.

---

## Estructura de có³digo

### Proyectos

- **Organic.BusinessLogic**: Có³digo de negocio principal (CENTRALSS/)
- **Organic.Generated**: Có³digo generado automó¡ticamente (NO EDITAR MANUALMENTE)
- **Organic.Tests**: Tests unitarios y funcionales

### Convenciones

#### Nomenclatura
```foxpro
* Paró¡metros: tc=text char, tn=numeric, tl=logical, to=object, ta=array
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
    
    * Mó©todos póºblicos
    PROCEDURE MetodoPublico()
        * Ló³gica
    ENDPROC
    
    * Mó©todos protegidos (por convenció³n)
    PROTECTED PROCEDURE MetodoInterno()
        * Ló³gica interna
    ENDPROC
    
    * Destructor al final
    PROCEDURE Destroy()
        THIS.LiberarRecursos()
        RETURN DODEFAULT()
    ENDPROC
ENDDEFINE
```

---

## Mejores pró¡cticas

### 1. Manejo de errores
```foxpro
PROCEDURE MiProcedimiento()
    LOCAL llExito
    llExito = .F.
    
    TRY
        * Ló³gica principal
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
* ✅ PREFERIR: SQL
SELECT SUM(Total) FROM Ventas WHERE Fecha > DATE() - 30 INTO CURSOR csrTotal

* ❌ EVITAR: SCAN (lento)
SCAN FOR Fecha > DATE() - 30
    lnTotal = lnTotal + Total
ENDSCAN
```

### 3. Liberación de recursos
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
- Funciones/mó©todos <50 ló­neas
- Una responsabilidad por funció³n
- Reutilizació³n sobre duplicació³n

---

## Debugging

### Breakpoints
Los breakpoints de VS Code se exportan automó¡ticamente cuando presionas F5.

### Ejecutar proyecto
```bash
# Compilar y ejecutar
dovfp build
dovfp run

# Con argumentos
dovfp run -run_args "'parametro1', 123, .T."
```

### Logging
```foxpro
* Usar logger centralizado (si existe)
THIS.Logger.Info("Mensaje", "Contexto")
THIS.Logger.Error("Error", loError, "Contexto")
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

- âŒ NO editar archivos en `Organic.Generated/Generados/` (son generados)
- âŒ NO usar variables globales (PUBLIC/PRIVATE)
- âŒ NO hardcodear rutas absolutas
- âŒ NO dejar có³digo comentado (usar Git)
- âŒ NO usar magic numbers (crear constantes)

---

## Recursos

- **Agente VFP**: `/Organic.BusinessLogic/AGENTS.md`
- **Prompts óºtiles**: `.github/prompts/dev/`
- **Ejemplos de có³digo**: Ver tests en `Organic.Tests/`

---

## Ayuda ró¡pida

```
@workspace Muó©strame ejemplos de có³digo segóºn las convenciones del proyecto

@workspace #file:miarchivo.prg Revisa este có³digo segóºn las instrucciones VFP

@workspace Â¿Có³mo debo estructurar una nueva clase siguiendo los estó¡ndares?
```
