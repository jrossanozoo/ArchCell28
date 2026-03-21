---
applyTo: "**/Tests/**,**/*Test*.prg,**/clasesdeprueba/**,**/Organic.Tests/**"
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
    
    * TearDown: ejecutado DESPUÉS de cada test
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
            "Debe convertir a mayúsculas")
    ENDPROC
    
ENDDEFINE
```

---

## Nomenclatura de tests

**Formato**:
```
Test_[Método]_Debe[Comportamiento]_Cuando[Condición]
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

### Checklist por función
- [ ] Parámetro NULL
- [ ] String vacío ("")
- [ ] Cero (0)
- [ ] Números negativos
- [ ] Números muy grandes
- [ ] Fechas inválidas
- [ ] Arrays vacíos
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
        "Debe generar error con Parámetro NULL")
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

# Test específico: compilar y ejecutar el proyecto de tests
dovfp build Organic.Tests/Organic.Tests.vfpproj
dovfp run -path Organic.Tests/Organic.Tests.vfpproj
```

### Con F5
Abre el archivo de test (.prg) y presiona F5 para ejecutarlo con debugging.

---

## Organización de tests

```
Organic.Tests/
├── main.prg              # Runner principal
├── ClasesMock.dbf        # Datos mock
├── clasesdeprueba/       # Helpers y utilidades
├── Tests/
│   ├── Test_Ventas.prg
│   ├── Test_Clientes.prg
│   └── Test_Validaciones.prg
└── _dovfp_excluidos/     # Tests deshabilitados
```

---

## Mejores prácticas

### "… Hacer
- Un concepto por test
- Tests independientes (sin estado compartido)
- Usar mocks para dependencias externas
- Nombres descriptivos
- Arrange-Act-Assert
- Cleanup en TearDown

### "Œ No hacer
- Tests con múltiples assertions no relacionadas
- Dependencias entre tests
- Usar base de datos real sin aislamiento
- Tests sin assertions (solo `?` o `!!`)
- Dejar tests comentados

---

## Performance

### Tests deben ser rápidos
- **Objetivo**: <1 segundo por test
- **Límite**: <2 segundos por test

### Si un test es lento
```foxpro
* ❌ LENTO: Acceso a BD real
SELECT * FROM Clientes INTO CURSOR csr

* ✅ RÁPIDO: Mock en memoria
THIS.oMockRepo.ObtenerClientes()
```

---

## Cobertura

### Objetivos
- **Mínimo aceptable**: 50%
- **Objetivo**: 70%
- **Ideal**: 85%

### Prioridad de cobertura
1. Lógica de negocio crítica
2. Validaciones y reglas
3. Cálculos financieros
4. Integraciones externas
5. UI y presentación

---

## Recursos

- **Agente de testing**: `/Organic.Tests/AGENTS.md`
- **Prompt de auditoría**: `.github/prompts/test/test-audit.prompt.md`
- **Ejemplos**: Ver tests existentes en `Tests/`

---

## Ayuda rápida

```
@workspace Crea un test para esta función siguiendo las convenciones del proyecto

@workspace #file:Test_MiModulo.prg Revisa la calidad de estos tests

@workspace ¿Cómo mockeo esta dependencia de base de datos?
```
