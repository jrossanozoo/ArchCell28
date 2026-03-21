---
applyTo: "**/*test*.prg,**/*Test*.prg,**/Tests/**/*.prg,**/Organic.Tests/**/*.prg"
description: "Instrucciones para testing y QA en proyectos Visual FoxPro"
---

# Instrucciones de Testing

## Contexto

Tests ubicados en `Organic.Tests/` usando framework de testing personalizado para VFP.

---

## Estructura de un test

```foxpro
DEFINE CLASS Test_MiModulo AS TestCase
    
    * Propiedades
    oSUT = NULL  && System Under Test
    
    * Setup: ejecutado ANTES de cada test
    PROCEDURE Setup()
        THIS.oSUT = CREATEOBJECT("MiClase")
        THIS.PreparenvirDatosMock()
    ENDPROC
    
    * TearDown: ejecutado DESPUÃ‰S de cada test
    PROCEDURE TearDown()
        THIS.oSUT = NULL
        THIS.LimpiarDatosMock()
    ENDPROC
    
    * Test individual
    PROCEDURE Test_MetodoDebeFuncionar_CuandoCondicion_EntoncesResultado()
        * Arrange (Preparar)
        LOCAL lcInput, lcEsperado
        lcInput = "valor"
        lcEsperado = "VALOR"
        
        * Act (Actuar)
        LOCAL lcResultado
        lcResultado = THIS.oSUT.ConvertirAMayusculas(lcInput)
        
        * Assert (Afirmar)
        THIS.AssertEquals(lcEsperado, lcResultado, ;
            "Debe convertir a mayÃºsculas")
    ENDPROC
    
ENDDEFINE
```

---

## Nomenclatura de tests

**Formato**:
```
Test_[MÃ©todo]_Debe[Comportamiento]_Cuando[CondiciÃ³n]
```

**Ejemplos**:
- `Test_ProcesarVenta_DebeRetornarTrue_CuandoClienteTieneCredito`
- `Test_ValidarEmail_DebeGenerarError_CuandoEmailEsInvalido`
- `Test_CalcularDescuento_DebeRetornar20Porciento_CuandoClienteEsVIP`

---

## Assertions disponibles

```foxpro
* Igualdad
THIS.AssertEquals(valorEsperado, valorActual, "mensaje")

* Verdadero/Falso
THIS.AssertTrue(expresion, "mensaje")
THIS.AssertFalse(expresion, "mensaje")

* Null
THIS.AssertNull(variable, "mensaje")
THIS.AssertNotNull(variable, "mensaje")

* Tipo
THIS.AssertType(variable, "C", "mensaje")  && Character
THIS.AssertType(variable, "N", "mensaje")  && Numeric
THIS.AssertType(variable, "L", "mensaje")  && Logical

* Contiene
THIS.AssertContains("subcadena", lcTextoCompleto, "mensaje")
```

---

## Uso de mocks

### Datos mock
```foxpro
* Usar ClasesMock.dbf para datos de prueba
USE ClasesMock IN 0 SHARED
SELECT ClasesMock

INSERT INTO ClasesMock (id, nombre, tipo) ;
    VALUES (999, "Cliente Test", "Mock")

* Limpiar en TearDown
DELETE FROM ClasesMock WHERE tipo = "Mock"
PACK
```

### Mock de clases
```foxpro
DEFINE CLASS RepositorioMock AS Custom
    DIMENSION aDatos[1, 2]
    nCount = 0
    
    PROCEDURE AgregarDato(tnId, tcValor)
        THIS.nCount = THIS.nCount + 1
        DIMENSION THIS.aDatos[THIS.nCount, 2]
        THIS.aDatos[THIS.nCount, 1] = tnId
        THIS.aDatos[THIS.nCount, 2] = tcValor
    ENDPROC
    
    PROCEDURE Obtener(tnId)
        LOCAL i
        FOR i = 1 TO THIS.nCount
            IF THIS.aDatos[i, 1] = tnId
                RETURN THIS.aDatos[i, 2]
            ENDIF
        ENDFOR
        RETURN NULL
    ENDPROC
ENDDEFINE
```

---

## Testear edge cases

### Checklist por funciÃ³n
- [ ] ParÃ¡metro NULL
- [ ] String vacÃ­o ("")
- [ ] Cero (0)
- [ ] NÃºmeros negativos
- [ ] NÃºmeros muy grandes
- [ ] Fechas invÃ¡lidas
- [ ] Arrays vacÃ­os
- [ ] Tipos incorrectos

### Ejemplo
```foxpro
PROCEDURE Test_CalcularDescuento_DebeGenerarError_CuandoTotalEsNull()
    LOCAL llErrorCapturado
    llErrorCapturado = .F.
    
    TRY
        THIS.oSUT.CalcularDescuento(NULL)
    CATCH
        llErrorCapturado = .T.
    ENDTRY
    
    THIS.AssertTrue(llErrorCapturado, ;
        "Debe generar error con parÃ¡metro NULL")
ENDPROC

PROCEDURE Test_CalcularDescuento_DebeRetornarCero_CuandoTotalEsCero()
    LOCAL lnResultado
    lnResultado = THIS.oSUT.CalcularDescuento(0)
    
    THIS.AssertEquals(0, lnResultado, ;
        "Descuento de $0 debe ser $0")
ENDPROC
```

---

## Ejecutar tests

### Desde VS Code
```bash
# Todos los tests (funcionalidad en desarrollo)
dovfp test Organic.Tests/Organic.Tests.vfpproj

# Test especÃ­fico: compilar y ejecutar el proyecto de tests
dovfp build Organic.Tests/Organic.Tests.vfpproj
dovfp run -path Organic.Tests/Organic.Tests.vfpproj
```

### Con F5
Abre el archivo de test (.prg) y presiona F5 para ejecutarlo con debugging.

---

## OrganizaciÃ³n de tests

```
Organic.Tests/
â”œâ”€â”€ main.prg              # Runner principal
â”œâ”€â”€ ClasesMock.dbf        # Datos mock
â”œâ”€â”€ clasesdeprueba/       # Helpers y utilidades
â”œâ”€â”€ Tests/
â”‚   â”œâ”€â”€ Test_Ventas.prg
â”‚   â”œâ”€â”€ Test_Clientes.prg
â”‚   â””â”€â”€ Test_Validaciones.prg
â””â”€â”€ _dovfp_excluidos/     # Tests deshabilitados
```

---

## Mejores prÃ¡cticas

### âœ… Hacer
- Un concepto por test
- Tests independientes (sin estado compartido)
- Usar mocks para dependencias externas
- Nombres descriptivos
- Arrange-Act-Assert
- Cleanup en TearDown

### âŒ No hacer
- Tests con mÃºltiples assertions no relacionadas
- Dependencias entre tests
- Usar base de datos real sin aislamiento
- Tests sin assertions (solo `?` o `!!`)
- Dejar tests comentados

---

## Performance

### Tests deben ser rÃ¡pidos
- **Objetivo**: <1 segundo por test
- **LÃ­mite**: <2 segundos por test

### Si un test es lento
```foxpro
* âŒ LENTO: Acceso a BD real
SELECT * FROM Clientes INTO CURSOR csr

* âœ… RÃPIDO: Mock en memoria
THIS.oMockRepo.ObtenerClientes()
```

---

## Cobertura

### Objetivos
- **MÃ­nimo aceptable**: 50%
- **Objetivo**: 70%
- **Ideal**: 85%

### Prioridad de cobertura
1. LÃ³gica de negocio crÃ­tica
2. Validaciones y reglas
3. CÃ¡lculos financieros
4. Integraciones externas
5. UI y presentaciÃ³n

---

## Recursos

- **Agente de testing**: `/Organic.Tests/AGENTS.md`
- **Prompt de auditorÃ­a**: `.github/prompts/test/test-audit.prompt.md`
- **Ejemplos**: Ver tests existentes en `Tests/`

---

## Ayuda rÃ¡pida

```
@workspace Crea un test para esta funciÃ³n siguiendo las convenciones del proyecto

@workspace #file:Test_MiModulo.prg Revisa la calidad de estos tests

@workspace Â¿CÃ³mo mockeo esta dependencia de base de datos?
```
