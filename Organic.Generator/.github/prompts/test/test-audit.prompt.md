---
description: "Auditoría de testing: análisis de cobertura, calidad de tests y estrategia de testing para código VFP en Organic.Tests"
---

# 🧪 Test Audit - Visual FoxPro Testing Strategy

## Objective
Analyze test coverage, test quality, and testing strategy for Visual FoxPro 9 code to ensure comprehensive validation and maintainability.

---

## 📋 Test Audit Checklist

### 1. **Test Coverage Analysis**

#### Overall Coverage
- [ ] ¿Qué porcentaje del código tiene tests?
- [ ] ¿Qué componentes críticos carecen de tests?
- [ ] ¿Hay código legacy sin testear?

#### Coverage by Component
```
Organic.BusinessLogic/
├── Generadores/          Coverage: ??%
│   ├── ABM               Coverage: ??%
│   ├── Combos            Coverage: ??%
│   └── Menús             Coverage: ??%
├── Utilidades/           Coverage: ??%
└── Validaciones/         Coverage: ??%
```

---

### 2. **Test Types Distribution**

#### Unit Tests
- **Count:** ??
- **Coverage:** ??%
- **Average execution time:** ?? ms

#### Integration Tests
- **Count:** ??
- **Coverage:** ??%
- **Average execution time:** ?? s

#### End-to-End Tests
- **Count:** ??
- **Coverage:** ??%
- **Average execution time:** ?? s

---

### 3. **Test Quality Assessment**

#### Test Structure
```vfp
* ✅ BIEN: Test bien estructurado (AAA Pattern)
FUNCTION TestGenerarABMConValidaciones()
  * Arrange
  LOCAL lcTabla, llConValidaciones
  lcTabla = "ARTICULO"
  llConValidaciones = .T.
  
  * Act
  LOCAL lcResultado
  lcResultado = GenerarAbmAvanzado(lcTabla, llConValidaciones)
  
  * Assert
  LOCAL llExito
  llExito = !EMPTY(lcResultado) AND ;
            "VALIDATE" $ UPPER(lcResultado) AND ;
            FILE("Generados/Din_AbmArticuloAvanzadoEstilo2.prg")
  
  IF !llExito
    ? "FAIL: Validaciones no generadas correctamente"
  ENDIF
  
  RETURN llExito
ENDFUNC

* ❌ MAL: Test sin estructura clara
FUNCTION Test1()
  lcRes = Generar("ART", .T.)
  RETURN !EMPTY(lcRes)
ENDFUNC
```

#### Test Naming
```vfp
* ✅ BIEN: Nombres descriptivos
FUNCTION TestGenerarABMConTablaInexistenteDebeRetornarError()
FUNCTION TestValidarParametroNuloDebeRetornarFalse()
FUNCTION TestCompilarPRGGeneradoDebeExitoso()

* ❌ MAL: Nombres ambiguos
FUNCTION Test1()
FUNCTION TestGen()
FUNCTION Prueba()
```

---

### 4. **Test Independence**

#### Isolation
- [ ] ¿Los tests se ejecutan independientemente?
- [ ] ¿Hay dependencias entre tests?
- [ ] ¿Orden de ejecución afecta resultados?

```vfp
* ❌ MAL: Tests dependientes
FUNCTION Test1_CrearRegistro()
  INSERT INTO clientes VALUES (1, "Juan")
  RETURN .T.
ENDFUNC

FUNCTION Test2_ActualizarRegistro()
  * Depende de Test1
  UPDATE clientes SET nombre="Pedro" WHERE id=1
  RETURN .T.
ENDFUNC

* ✅ BIEN: Tests independientes
FUNCTION TestCrearRegistro()
  LOCAL lnId
  lnId = CrearClientePrueba("Juan")
  
  TRY
    * Test logic
  FINALLY
    LimpiarClientePrueba(lnId)
  ENDTRY
  
  RETURN .T.
ENDFUNC
```

#### Setup & Teardown
```vfp
* ✅ BIEN: Setup y cleanup explícito
FUNCTION TestSuiteGeneradores()
  LOCAL loTestRunner
  loTestRunner = CREATEOBJECT("TestRunner")
  
  * Setup
  PrepararEntornoPruebas()
  
  TRY
    * Run tests
    loTestRunner.AddTest("TestGenerarABM")
    loTestRunner.Run()
    
  FINALLY
    * Teardown
    LimpiarEntornoPruebas()
  ENDTRY
ENDFUNC
```

---

### 5. **Test Data Management**

#### Test Fixtures
```vfp
* ✅ BIEN: Fixtures reutilizables
FUNCTION CrearFixtureCliente()
  LOCAL loCliente
  loCliente = CREATEOBJECT("Empty")
  ADDPROPERTY(loCliente, "Id", 1)
  ADDPROPERTY(loCliente, "Nombre", "Cliente Test")
  ADDPROPERTY(loCliente, "CUIT", "20123456789")
  RETURN loCliente
ENDFUNC

FUNCTION TestValidarCliente()
  LOCAL loCliente
  loCliente = CrearFixtureCliente()
  RETURN ValidarCliente(loCliente)
ENDFUNC
```

#### Mock Objects
```vfp
* ✅ BIEN: Mock de database
DEFINE CLASS MockDatabase AS Custom
  FUNCTION Query(tcSQL)
    LOCAL loResult
    loResult = CREATEOBJECT("Collection")
    
    * Retornar datos fake
    loResult.Add(CREATEOBJECT("Empty"))
    
    RETURN loResult
  ENDFUNC
ENDDEFINE

FUNCTION TestObtenerClientes()
  LOCAL loMockDB, laClientes
  loMockDB = CREATEOBJECT("MockDatabase")
  
  laClientes = ObtenerClientes(loMockDB)
  
  RETURN TYPE("laClientes") = "O" AND laClientes.Count > 0
ENDFUNC
```

---

### 6. **Edge Cases & Boundary Testing**

#### Boundary Values
- [ ] ¿Se prueban valores límite?
- [ ] ¿Se validan strings vacíos?
- [ ] ¿Se manejan valores nulos?

```vfp
FUNCTION TestValidarParametros_EdgeCases()
  LOCAL llTodosPasan
  llTodosPasan = .T.
  
  * Test null/empty
  llTodosPasan = llTodosPasan AND !ValidarParametro("")
  llTodosPasan = llTodosPasan AND !ValidarParametro(NULL)
  
  * Test boundary values
  llTodosPasan = llTodosPasan AND ValidarParametro(REPLICATE("A", 255))
  llTodosPasan = llTodosPasan AND !ValidarParametro(REPLICATE("A", 256))
  
  * Test special characters
  llTodosPasan = llTodosPasan AND ValidarParametro("Test@#$%")
  
  RETURN llTodosPasan
ENDFUNC
```

#### Error Scenarios
```vfp
FUNCTION TestGenerarABM_ScenariosError()
  LOCAL llTodosPasan
  llTodosPasan = .T.
  
  * Tabla inexistente
  TRY
    GenerarAbmAvanzado("TABLA_NO_EXISTE", .F.)
    llTodosPasan = .F.  && Debería haber lanzado error
  CATCH
    * Esperado
  ENDTRY
  
  * Parámetros inválidos
  llTodosPasan = llTodosPasan AND EMPTY(GenerarAbmAvanzado("", .F.))
  
  RETURN llTodosPasan
ENDFUNC
```

---

### 7. **Test Performance**

#### Execution Time
```
Test Suite: Generadores ABM
├── TestGenerarABMSimple           : 120ms ✓
├── TestGenerarABMConValidaciones  : 180ms ✓
├── TestGenerarABMConSubEntidades  : 350ms ⚠️ (slow)
└── TestCompilarTodosABMs          : 15s   ⚠️ (very slow)

Total: 15.65s
```

#### Performance Benchmarks
- **Unit tests:** < 100ms cada uno
- **Integration tests:** < 5s cada uno
- **E2E tests:** < 30s cada uno
- **Full test suite:** < 5 minutos

#### Optimization Opportunities
- [ ] ¿Hay tests lentos que puedan optimizarse?
- [ ] ¿Se reutilizan recursos apropiadamente?
- [ ] ¿Se podrían paralelizar algunos tests?

---

### 8. **Test Maintenance**

#### Test Code Quality
```vfp
* ✅ BIEN: Test legible y mantenible
FUNCTION TestGenerarComboTipoComprobante()
  * Arrange
  LOCAL lcTipoEntidad, lXML
  lcTipoEntidad = "COMPRAS"
  
  * Act
  lXML = GenerarComboTipoComprobante(lcTipoEntidad, .F.)
  
  * Assert
  LOCAL llValido
  llValido = ValidarFormatoXML(lXML) AND ;
             ContieneOpcion(lXML, "FACTURA") AND ;
             ContieneOpcion(lXML, "NOTA_CREDITO")
  
  AssertTrue(llValido, "Combo no tiene las opciones esperadas")
  
  RETURN llValido
ENDFUNC

* ❌ MAL: Test difícil de entender
FUNCTION Test2()
  x = Func("C", 0)
  RETURN !EMPTY(x) AND "F" $ x AND "N" $ x
ENDFUNC
```

#### Test Documentation
- [ ] ¿Los tests están documentados?
- [ ] ¿Es claro qué valida cada test?
- [ ] ¿Hay README de test strategy?

---

### 9. **Continuous Integration**

#### CI/CD Integration
```yaml
# azure-pipelines.yml
- task: DotNetCoreCLI@2
  displayName: 'Run Unit Tests'
  inputs:
    command: custom
    custom: tool
    arguments: 'run dovfp test Organic.Tests/main.prg'
  
- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results.xml'
```

#### Test Automation
- [ ] ¿Tests corren automáticamente en CI?
- [ ] ¿Se reportan resultados?
- [ ] ¿Se bloquean merges con tests fallidos?

---

### 10. **Test Coverage Tools**

#### Coverage Reports
```powershell
# Generar reporte de cobertura
dovfp test --coverage --format html Organic.Tests/main.prg

# Output: Organic.Tests/bin/coverage/index.html
```

#### Coverage Metrics
- **Line Coverage:** ??%
- **Branch Coverage:** ??%
- **Function Coverage:** ??%

#### Coverage Gaps
- [ ] Identificar funciones sin testear
- [ ] Priorizar por criticidad
- [ ] Crear plan para mejorar cobertura

---

## 📊 Test Audit Report Template

```markdown
# Test Audit Report - Organic.Generator
**Date:** 2025-10-15

## Executive Summary
- **Total Tests:** ???
- **Test Coverage:** ??%
- **Pass Rate:** ??%
- **Average Execution Time:** ?? seconds

## Coverage by Module

| Module                | Tests | Coverage | Status |
|-----------------------|-------|----------|--------|
| Generadores/ABM       | 15    | 75%      | ⚠️     |
| Generadores/Combos    | 8     | 60%      | ❌     |
| Generadores/Menús     | 5     | 45%      | ❌     |
| Utilidades            | 20    | 85%      | ✅     |
| Validaciones          | 12    | 70%      | ⚠️     |

## Critical Gaps

### 1. Missing Tests for Critical Components
- `GeneradorMenuPrincipal.prg` - NO TESTS ❌
- `ValidadorADN.prg` - Partial coverage (30%) ⚠️

### 2. Slow Tests
- `TestCompilarTodosABMs` - 15s (need optimization)
- `TestE2EGeneracionCompleta` - 25s (acceptable for E2E)

### 3. Quality Issues
- 10 tests sin estructura AAA
- 5 tests con nombres ambiguos
- 3 test suites con dependencias

## Recommendations

### High Priority
1. ✅ Agregar tests para `GeneradorMenuPrincipal`
2. ✅ Aumentar cobertura de `Generadores/Combos` a 80%+
3. ✅ Refactorizar tests dependientes

### Medium Priority
1. ⚠️ Optimizar `TestCompilarTodosABMs`
2. ⚠️ Agregar más tests de edge cases
3. ⚠️ Documentar test strategy

### Low Priority
1. 📝 Renombrar tests ambiguos
2. 📝 Agregar test fixtures reutilizables
3. 📝 Mejorar reporting de resultados

## Next Steps
1. Implementar tests faltantes (Sprint 1)
2. Optimizar tests lentos (Sprint 2)
3. Alcanzar 85% de cobertura (Sprint 3)
```

---

## 💡 Usage

```
@workspace /ask using #file:.github/prompts/test/test-audit.prompt.md
Perform a comprehensive test audit of Organic.Tests and analyze coverage
```

---

## 🔗 Related Resources

- Test Agent: [Organic.Tests/AGENTS.md](../../Organic.Tests/AGENTS.md)
- Main Agent: [.github/AGENTS.md](../AGENTS.md)
- Code Audit: [code-audit-comprehensive.prompt.md](../auditoria/code-audit-comprehensive.prompt.md)

---

**Last Updated:** 2025-10-15  
**Version:** 1.0.0
