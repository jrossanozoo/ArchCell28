---
applyTo: "**/*.prg,**/*.vcx,**/*.scx,**/*.frx,**/*.h"
description: "Instrucciones para desarrollo de código Visual FoxPro 9 en este proyecto"
---

# Instrucciones de Desarrollo VFP

## Contexto

Estás trabajando en el proyecto **Organic.Drawing**, una solución Visual FoxPro 9 que se desarrolla en VS Code con DOVFP como compilador.

---

## Estructura de código

### Proyectos

- **Organic.BusinessLogic**: Código de negocio principal (CENTRALSS/)
- **Organic.Generated**: Código generado automáticamente (NO EDITAR MANUALMENTE)
- **Organic.Tests**: Tests unitarios y funcionales

### Convenciones

#### Nomenclatura
```foxpro
* Parámetros: tc=text char, tn=numeric, tl=logical, to=object, ta=array
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
    
    * Métodos públicos
    PROCEDURE MetodoPublico()
        * Lógica
    ENDPROC
    
    * Métodos protegidos (por convención)
    PROTECTED PROCEDURE MetodoInterno()
        * Lógica interna
    ENDPROC
    
    * Destructor al final
    PROCEDURE Destroy()
        THIS.LiberarRecursos()
        RETURN DODEFAULT()
    ENDPROC
ENDDEFINE
```

---

## Mejores prácticas

### 1. Manejo de errores
```foxpro
PROCEDURE MiProcedimiento()
    LOCAL llExito
    llExito = .F.
    
    TRY
        * Lógica principal
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
- Funciones/métodos <50 líneas
- Una responsabilidad por función
- Reutilización sobre duplicación

---

## Debugging

### Breakpoints
Los breakpoints de VS Code se exportan automáticamente cuando presionas F5.

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

- ❌ NO editar archivos en `Organic.Generated/Generados/` (son generados)
- ❌ NO usar variables globales (PUBLIC/PRIVATE)
- ❌ NO hardcodear rutas absolutas
- ❌ NO dejar código comentado (usar Git)
- ❌ NO usar magic numbers (crear constantes)

---

## Recursos

- **Agente VFP**: `/Organic.BusinessLogic/AGENTS.md`
- **Prompts útiles**: `.github/prompts/dev/`
- **Ejemplos de código**: Ver tests en `Organic.Tests/`

---

## Ayuda rápida

```
@workspace Muéstrame ejemplos de código según las convenciones del proyecto

@workspace #file:miarchivo.prg Revisa este código según las instrucciones VFP

@workspace ¿Cómo debo estructurar una nueva clase siguiendo los estándares?
```
