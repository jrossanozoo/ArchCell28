---
description: "Generación de tests unitarios para código Visual FoxPro 9 existente"
mode: "agent"
tools: ["read_file", "grep_search", "semantic_search", "list_code_usages", "create_file"]
---

# 🧪 Generación de Tests Unitarios VFP

## Objetivo
Generar tests unitarios completos para código Visual FoxPro 9 existente, siguiendo el patrón AAA (Arrange-Act-Assert) y las convenciones del proyecto.

## Instrucciones

### Fase 1: Análisis del Código
1. Leer el archivo/clase a testear completamente
2. Identificar todos los métodos públicos
3. Identificar dependencias externas (BD, archivos, otros objetos)
4. Determinar qué dependencias necesitan mocking

### Fase 2: Diseño de Tests
Para cada método público, crear tests para:
- **Happy path**: Caso normal de uso
- **Edge cases**: Valores límite, vacíos, nulos
- **Error cases**: Excepciones esperadas
- **Boundary conditions**: Límites de rangos

### Fase 3: Generación de Código

#### Estructura del Test
```foxpro
*-----------------------------------------------------------------------
*-- Test: [NombreClase]
*-- Descripción: Tests unitarios para [descripción]
*-- Generado: [fecha]
*-----------------------------------------------------------------------
DEFINE CLASS Test_[NombreClase] AS TestCase
    
    *-- System Under Test
    oSUT = .NULL.
    
    *-- Mocks (si aplica)
    oMockRepository = .NULL.
    
    *-- Setup: Ejecutado antes de cada test
    PROCEDURE Setup
        *-- Crear instancia del SUT
        THIS.oSUT = CREATEOBJECT("[NombreClase]")
        
        *-- Configurar mocks si es necesario
        THIS.ConfigurarMocks()
    ENDPROC
    
    *-- TearDown: Ejecutado después de cada test
    PROCEDURE TearDown
        THIS.oSUT = .NULL.
        THIS.LimpiarMocks()
    ENDPROC
    
    *=======================================================================
    *-- TESTS: [NombreMetodo]
    *=======================================================================
    
    *-- Test: Happy path
    PROCEDURE Test_[Metodo]_Debe[Resultado]_Cuando[Condicion]
        *-- Arrange
        LOCAL lcInput, lcEsperado
        lcInput = "valor"
        lcEsperado = "VALOR"
        
        *-- Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.[Metodo](lcInput)
        
        *-- Assert
        THIS.AssertEquals(lcEsperado, lcResultado, ;
            "[Metodo] debe [comportamiento esperado]")
    ENDPROC
    
    *-- Test: Edge case - valor vacío
    PROCEDURE Test_[Metodo]_Debe[Resultado]_CuandoInputVacio
        *-- Arrange
        LOCAL lcInput
        lcInput = ""
        
        *-- Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.[Metodo](lcInput)
        
        *-- Assert
        THIS.AssertEquals("", lcResultado, ;
            "[Metodo] debe manejar string vacío")
    ENDPROC
    
    *-- Test: Edge case - valor NULL
    PROCEDURE Test_[Metodo]_Debe[Resultado]_CuandoInputNull
        *-- Arrange
        LOCAL lcInput
        lcInput = .NULL.
        
        *-- Act & Assert
        THIS.AssertNoException(THIS.oSUT, "[Metodo]", lcInput, ;
            "[Metodo] no debe fallar con NULL")
    ENDPROC
    
    *=======================================================================
    *-- HELPERS
    *=======================================================================
    
    PROTECTED PROCEDURE ConfigurarMocks
        *-- Crear mocks de dependencias
    ENDPROC
    
    PROTECTED PROCEDURE LimpiarMocks
        *-- Liberar mocks
    ENDPROC
    
ENDDEFINE
```

### Fase 4: Nomenclatura de Tests

**Formato obligatorio**:
```
Test_[Metodo]_Debe[ComportamientoEsperado]_Cuando[Condicion]
```

**Ejemplos**:
- `Test_CalcularTotal_DebeRetornar100_CuandoPrecio50Cantidad2`
- `Test_ValidarEmail_DebeRetornarFalse_CuandoEmailSinArroba`
- `Test_GuardarCliente_DebeLanzarError_CuandoNombreVacio`

### Fase 5: Mocking de Dependencias

```foxpro
*-- Mock de repositorio de datos
DEFINE CLASS MockClienteRepository AS Custom
    DIMENSION aClientes[1]
    nCount = 0
    
    PROCEDURE AgregarClienteMock(tnId, tcNombre)
        THIS.nCount = THIS.nCount + 1
        DIMENSION THIS.aClientes[THIS.nCount, 2]
        THIS.aClientes[THIS.nCount, 1] = tnId
        THIS.aClientes[THIS.nCount, 2] = tcNombre
    ENDPROC
    
    PROCEDURE ObtenerPorId(tnId)
        LOCAL i
        FOR i = 1 TO THIS.nCount
            IF THIS.aClientes[i, 1] = tnId
                LOCAL loCliente
                loCliente = CREATEOBJECT("Empty")
                ADDPROPERTY(loCliente, "Id", THIS.aClientes[i, 1])
                ADDPROPERTY(loCliente, "Nombre", THIS.aClientes[i, 2])
                RETURN loCliente
            ENDIF
        ENDFOR
        RETURN .NULL.
    ENDPROC
ENDDEFINE
```

## Formato de Output

Generar archivo de test en:
```
Organic.Tests/Tests/UnitTests/Test_[NombreClase].prg
```

## Checklist de Cobertura

Para cada método, verificar tests para:
- [ ] Caso normal (happy path)
- [ ] String vacío ("")
- [ ] Valor NULL
- [ ] Valor cero (0) si es numérico
- [ ] Valor negativo si es numérico
- [ ] Valor muy grande si es numérico
- [ ] Fecha inválida si aplica
- [ ] Tipo incorrecto de parámetro

## Referencias
- [testing.instructions.md](../../instructions/testing.instructions.md)
- [test-audit.prompt.md](../auditoria/test-audit.prompt.md)
- [Organic.Tests/AGENTS.md](../../../Organic.Tests/AGENTS.md)
