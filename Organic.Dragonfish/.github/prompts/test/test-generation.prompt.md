---
description: "Generación automática de tests unitarios para clases y métodos VFP"
tools: ["read_file", "grep_search", "list_code_usages", "create_file", "semantic_search"]
applyTo: ["**/*.prg", "**/*.vcx"]
argument-hint: "Especifica la clase o método para generar tests"
---

# 🧪 Generación de Tests Unitarios VFP

## Objetivo

Generar tests unitarios completos para una clase o método Visual FoxPro, siguiendo el patrón AAA y cubriendo casos happy path y edge cases.

## Proceso

### Fase 1: Análisis de la Clase

1. Leer el código de la clase objetivo
2. Identificar métodos públicos a testear
3. Analizar parámetros y tipos de retorno
4. Identificar dependencias externas

### Fase 2: Diseño de Tests

Para cada método:

1. **Happy Path**: Caso normal esperado
2. **Edge Cases**:
   - Valores límite
   - Valores nulos/vacíos
   - Tipos incorrectos
   - Errores esperados
3. **Mocks**: Identificar qué mockear

### Fase 3: Implementación

1. Crear archivo de test en `Organic.Tests/`
2. Implementar Setup y TearDown
3. Implementar cada caso de prueba
4. Validar con `dovfp build`

## Estructura del Test

```foxpro
*==============================================================================
* Tests para: [NombreClase]
* Archivo: Test_[NombreClase].prg
* Generado: [Fecha]
*==============================================================================
DEFINE CLASS Test_[NombreClase] AS TestCase
    
    *-- System Under Test
    oSUT = NULL
    
    *-- Mocks (si aplica)
    oMockDependencia = NULL
    
    *==========================================================================
    * Setup - Ejecutado antes de cada test
    *==========================================================================
    PROCEDURE Setup()
        * Crear instancia del SUT
        THIS.oSUT = CREATEOBJECT("[NombreClase]")
        
        * Preparar mocks si es necesario
        THIS.PrepararMocks()
        
        * Preparar datos de prueba
        THIS.PrepararDatos()
    ENDPROC
    
    *==========================================================================
    * TearDown - Ejecutado después de cada test
    *==========================================================================
    PROCEDURE TearDown()
        * Liberar SUT
        THIS.oSUT = NULL
        
        * Liberar mocks
        THIS.oMockDependencia = NULL
        
        * Limpiar datos de prueba
        THIS.LimpiarDatos()
    ENDPROC
    
    *==========================================================================
    * Tests para: [NombreMetodo]
    *==========================================================================
    
    *-- Happy Path
    PROCEDURE Test_[Metodo]_Debe[Resultado]_CuandoDatosValidos()
        * Arrange
        LOCAL lcInput, lcEsperado
        lcInput = "valor válido"
        lcEsperado = "resultado esperado"
        
        * Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.[Metodo](lcInput)
        
        * Assert
        THIS.AssertEquals(lcEsperado, lcResultado, ;
            "Debe retornar el valor esperado con datos válidos")
    ENDPROC
    
    *-- Edge Case: NULL
    PROCEDURE Test_[Metodo]_DebeRetornarVacio_CuandoInputNull()
        * Arrange
        LOCAL lcInput
        lcInput = NULL
        
        * Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.[Metodo](lcInput)
        
        * Assert
        THIS.AssertTrue(EMPTY(lcResultado), ;
            "Debe retornar vacío cuando input es NULL")
    ENDPROC
    
    *-- Edge Case: String vacío
    PROCEDURE Test_[Metodo]_DebeRetornarVacio_CuandoInputVacio()
        * Arrange
        LOCAL lcInput
        lcInput = ""
        
        * Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.[Metodo](lcInput)
        
        * Assert
        THIS.AssertTrue(EMPTY(lcResultado), ;
            "Debe retornar vacío cuando input es string vacío")
    ENDPROC
    
    *==========================================================================
    * Helpers
    *==========================================================================
    
    PROTECTED PROCEDURE PrepararMocks()
        * Crear mocks necesarios
    ENDPROC
    
    PROTECTED PROCEDURE PrepararDatos()
        * Insertar datos de prueba en tablas
    ENDPROC
    
    PROTECTED PROCEDURE LimpiarDatos()
        * Eliminar datos de prueba
    ENDPROC
    
ENDDEFINE
```

## Assertions Disponibles

```foxpro
THIS.AssertEquals(esperado, actual, "mensaje")
THIS.AssertTrue(expresion, "mensaje")
THIS.AssertFalse(expresion, "mensaje")
THIS.AssertNull(variable, "mensaje")
THIS.AssertNotNull(variable, "mensaje")
THIS.AssertContains("subcadena", texto, "mensaje")
THIS.AssertType(variable, "C", "mensaje")
```

## Nomenclatura de Tests

```
Test_[Método]_Debe[Comportamiento]_Cuando[Condición]

Ejemplos:
- Test_Validar_DebeRetornarTrue_CuandoDatosCompletos
- Test_Calcular_DebeRetornarCero_CuandoListaVacia
- Test_Guardar_DebeGenerarError_CuandoSinPermisos
```

## Formato de Output

Al generar tests:
- 📁 Archivo creado: `Organic.Tests/Test_[Clase].prg`
- 🧪 Tests generados: N tests
- ✅ Happy path: Casos normales
- ⚠️ Edge cases: Casos límite
- 🔧 Mocks requeridos: Lista de mocks
