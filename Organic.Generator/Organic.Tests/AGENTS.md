# 🧪 Agent Configuration - Organic.Tests

> **Role:** VFP Testing & Quality Assurance Specialist
> 
> **Scope:** Testing, validación y aseguramiento de calidad de la solución Organic.Generator

---

## 📋 Overview

Este agente se especializa en el testing y validación de código Visual FoxPro 9, generadores dinámicos, y aseguramiento de calidad del proyecto **Organic.Generator**.

## 🎯 Responsibilities

### 1. **Unit Testing**
- Pruebas unitarias de generadores
- Validación de funciones y procedimientos
- Mocking de dependencias VFP
- Assertions y validaciones

### 2. **Integration Testing**
- Pruebas de generación completa (end-to-end)
- Validación de PRG generados
- Testing de compilación con DOVFP
- Verificación de artefactos

### 3. **Test Automation**
- Scripts de testing automatizado
- CI/CD integration con Azure Pipelines
- Test reporting y métricas
- Coverage analysis

### 4. **Quality Assurance**
- Code review de tests
- Mantenimiento de test suites
- Identificación de gaps en cobertura
- Validación de regresiones

---

## 📁 Directory Structure

```
Organic.Tests/
├── main.prg                  # Test runner principal
├── Tests/                    # Test suites
│   ├── TestGeneradores/      # Tests de generadores
│   ├── TestABM/              # Tests de ABMs
│   └── TestUtilidades/       # Tests de utilities
├── clasesdeprueba/           # Test helpers y mocks
├── _dovfp_excluidos/         # Archivos excluidos de build
├── bin/                      # Test binaries
└── packages/                 # Test dependencies
```

---

## 🎨 Testing Conventions

### Test File Naming
```
Test[ComponentName].prg       # Unit test
Integration[Feature].prg      # Integration test
E2E[Scenario].prg            # End-to-end test
```

### Test Structure
```vfp
*-- ============================================
*-- Test Suite: Generador ABM Avanzado
*-- Purpose: Validar generación de ABMs
*-- ============================================

FUNCTION TestSuite_GeneradorABM()
  LOCAL loTestRunner
  loTestRunner = CREATEOBJECT("TestRunner")
  
  * Registrar tests
  loTestRunner.AddTest("TestGenerarABMSimple")
  loTestRunner.AddTest("TestGenerarABMConValidaciones")
  loTestRunner.AddTest("TestGenerarABMConSubEntidades")
  
  * Ejecutar
  RETURN loTestRunner.Run()
ENDFUNC

*-- Test individual
FUNCTION TestGenerarABMSimple()
  LOCAL lcResultado, llExito
  
  * Arrange
  LOCAL lcTabla
  lcTabla = "ARTICULO"
  
  * Act
  lcResultado = GenerarAbmAvanzado(lcTabla, .F.)
  
  * Assert
  llExito = !EMPTY(lcResultado) AND ;
            "FUNCTION" $ UPPER(lcResultado) AND ;
            FILE("Generados/Din_AbmArticuloAvanzadoEstilo2.prg")
  
  IF !llExito
    ? "ERROR: No se generó correctamente el ABM para " + lcTabla
  ENDIF
  
  RETURN llExito
ENDFUNC
```

---

## 🧪 Test Types

### 1. **Unit Tests**
Prueban funciones individuales en aislamiento:

```vfp
*-- TestValidarParametros.prg
FUNCTION TestValidarEntradaNula()
  LOCAL lcResultado
  lcResultado = ValidarParametro("")
  RETURN EMPTY(lcResultado)  && Debe retornar vacío
ENDFUNC

FUNCTION TestValidarEntradaValida()
  LOCAL lcResultado
  lcResultado = ValidarParametro("CLIENTE")
  RETURN !EMPTY(lcResultado)  && Debe retornar algo
ENDFUNC
```

### 2. **Integration Tests**
Validan componentes trabajando juntos:

```vfp
*-- IntegrationGeneradorCompleto.prg
FUNCTION TestGeneracionCompletaABM()
  * 1. Generar PRG
  LOCAL lcPrg
  lcPrg = GenerarAbmAvanzado("CLIENTE", .T.)
  
  * 2. Validar sintaxis
  IF !ValidarSintaxisVFP(lcPrg)
    RETURN .F.
  ENDIF
  
  * 3. Compilar con DOVFP
  IF !CompilarConDOVFP("Generados/Din_AbmClienteAvanzadoEstilo2.prg")
    RETURN .F.
  ENDIF
  
  RETURN .T.
ENDFUNC
```

### 3. **End-to-End Tests**
Simulan el flujo completo del usuario:

```vfp
*-- E2EGenerarYEjecutarABM.prg
FUNCTION TestE2E_CrearArticuloConABM()
  * 1. Generar ABM
  GenerarAbmAvanzado("ARTICULO", .T.)
  
  * 2. Ejecutar formulario generado
  DO Din_AbmArticuloAvanzadoEstilo2.prg
  
  * 3. Crear registro de prueba
  * (simular entrada de usuario)
  
  * 4. Validar registro creado
  * (verificar en base de datos)
  
  RETURN .T.
ENDFUNC
```

---

## 🔧 Running Tests

### From VS Code

```powershell
# Ejecutar todos los tests
dovfp test Organic.Tests/main.prg

# Ejecutar suite específica
dovfp run -template 1 Organic.Tests/Tests/TestGeneradores/TestAbmAvanzado.prg

# Con coverage
dovfp test --coverage Organic.Tests/main.prg
```

### From Terminal

```powershell
cd Organic.Tests
dovfp test main.prg
```

### In CI/CD Pipeline

Ver `azure-pipelines.yml`:
```yaml
- task: DotNetCoreCLI@2
  displayName: 'Run VFP Tests'
  inputs:
    command: custom
    custom: tool
    arguments: 'run dovfp test Organic.Tests/main.prg'
```

---

## 📊 Test Reporting

### Coverage Reports
```powershell
# Generar reporte de cobertura
dovfp test --coverage --output-format html Organic.Tests/main.prg
```

### Test Results
Ubicación: `Organic.Tests/bin/TestResults/`

Formatos disponibles:
- `test-results.xml` (JUnit format)
- `coverage.html` (Coverage report)
- `test-summary.txt` (Human-readable)

---

## 🎯 Test Scenarios to Cover

### Generadores Dinámicos
- [ ] Generación de ABM simple
- [ ] Generación de ABM con validaciones
- [ ] Generación de ABM con SubEntidades
- [ ] Generación de combos
- [ ] Generación de menús

### Validaciones
- [ ] Parámetros nulos
- [ ] Parámetros inválidos
- [ ] Tablas inexistentes
- [ ] Campos requeridos faltantes

### Compilación
- [ ] PRG generado compila sin errores
- [ ] PRG generado no tiene warnings
- [ ] APP/EXE se genera correctamente

### Regresión
- [ ] Tests de versiones anteriores pasan
- [ ] No romper funcionalidad existente
- [ ] Backwards compatibility

---

## 📚 Testing Best Practices

### 1. **AAA Pattern (Arrange-Act-Assert)**
```vfp
FUNCTION TestEjemplo()
  * Arrange (preparar)
  LOCAL lcInput
  lcInput = "CLIENTE"
  
  * Act (ejecutar)
  LOCAL lcResultado
  lcResultado = MiFuncion(lcInput)
  
  * Assert (verificar)
  RETURN !EMPTY(lcResultado) AND "FUNCTION" $ lcResultado
ENDFUNC
```

### 2. **Test Independence**
- Cada test debe poder ejecutarse solo
- No depender de orden de ejecución
- Limpiar estado después del test

### 3. **Meaningful Names**
```vfp
* ❌ Mal
FUNCTION Test1()

* ✅ Bien
FUNCTION TestGenerarABMConTablaInexistenteDebeRetornarError()
```

### 4. **Fast Tests**
- Tests unitarios < 100ms
- Integration tests < 5s
- E2E tests < 30s

---

## 🧰 Test Utilities

### Mock Objects
```vfp
* clasesdeprueba/MockDatabase.prg
DEFINE CLASS MockDatabase AS Custom
  FUNCTION Query(tcSQL)
    * Retornar datos fake
    RETURN CREATEOBJECT("Collection")
  ENDFUNC
ENDDEFINE
```

### Test Helpers
```vfp
* clasesdeprueba/TestHelpers.prg
FUNCTION AssertEquals(puExpected, puActual)
  IF puExpected != puActual
    ? "FAIL: Expected " + TRANSFORM(puExpected) + ;
      " but got " + TRANSFORM(puActual)
    RETURN .F.
  ENDIF
  RETURN .T.
ENDFUNC

FUNCTION AssertTrue(plCondition, pcMessage)
  IF !plCondition
    ? "FAIL: " + pcMessage
  ENDIF
  RETURN plCondition
ENDFUNC
```

---

## 🎨 Prompts for Testing

Use estos prompts en GitHub Copilot Chat:

```
@workspace /ask with #file:Organic.Tests/AGENTS.md 
How do I write a unit test for a VFP generator?
```

```
@workspace using #file:.github/prompts/test/test-audit.prompt.md
Analyze test coverage for Organic.BusinessLogic
```

---

## 🔗 Integration with Main Agent

Ver agente principal: [.github/AGENTS.md](../.github/AGENTS.md)

Ver agente de Business Logic: [Organic.BusinessLogic/AGENTS.md](../Organic.BusinessLogic/AGENTS.md)

---

## 📋 Testing Checklist

- [ ] Test unitario escrito para nueva función
- [ ] Test de integración si toca múltiples componentes
- [ ] Test E2E si afecta flujo de usuario
- [ ] Tests pasan localmente
- [ ] Tests pasan en CI/CD
- [ ] Coverage no disminuye
- [ ] Tests documentados con comentarios
- [ ] Edge cases cubiertos

---

**Last Updated:** 2025-10-15  
**Scope:** `Organic.Tests/**/*.prg`, `Organic.Tests/clasesdeprueba/**/*`  
**Test Runner:** DOVFP + Custom VFP Test Framework
