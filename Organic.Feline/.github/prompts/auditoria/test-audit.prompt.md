---
description: "Auditoría de cobertura y calidad de tests en proyectos Visual FoxPro 9"
mode: "agent"
tools: ["read_file", "grep_search", "file_search", "semantic_search", "list_code_usages"]
---

# 🧪 Auditoría de Tests VFP

## Objetivo
Evaluar la calidad, cobertura y efectividad de la suite de pruebas unitarias e integración en proyectos Visual FoxPro 9.

## Alcance del análisis

### 1. Cobertura de código
- **Clases sin tests**: Identificar clases de producción sin tests correspondientes
- **Métodos sin cobertura**: Detectar procedimientos/funciones sin test cases
- **Branches sin cubrir**: Identificar condiciones IF/CASE sin tests para ambos caminos
- **Código crítico**: Validar cobertura en cálculos, transacciones, validaciones

### 2. Calidad de tests

#### Estructura de tests
- **Patrón AAA**: Arrange-Act-Assert correctamente implementado
- **Independencia**: Tests no dependientes de orden de ejecución
- **Aislamiento**: Uso apropiado de mocks y fixtures
- **Nombres descriptivos**: Test names claros y autodocumentados

#### Assertions
- **Assertions presentes**: Todo test debe tener al menos una assertion
- **Assertions específicas**: Uso de assertion correcta (AssertEquals vs AssertTrue)
- **Messages en assertions**: Mensajes descriptivos en caso de fallo

### 3. Organización de tests

```
Tests/
├── UnitTests/          # Tests unitarios aislados
├── IntegrationTests/   # Tests de integración con BD/servicios
├── FunctionalTests/    # Tests de flujos end-to-end
└── Fixtures/           # Datos de prueba reutilizables
```

### 4. Mocks y fixtures

#### Mocks apropiados
```foxpro
*-- ✅ CORRECTO: Mock aislado
DEFINE CLASS MockRepository AS Custom
    PROCEDURE ObtenerPorId(tnId)
        *-- Retorna datos mockeados predecibles
        RETURN THIS.CreateMockEntity(tnId)
    ENDPROC
ENDDEFINE

*-- ❌ INCORRECTO: Dependencia real en test
PROCEDURE Test_ObtenerCliente
    *-- No usar base de datos real en unit tests
    loCliente = THIS.oRepository.ObtenerPorId(1)  && Conecta a BD real
ENDPROC
```

#### Fixtures reutilizables
```foxpro
*-- ✅ CORRECTO: Fixture centralizado
DEFINE CLASS FixtureClientes AS Custom
    PROCEDURE CrearClientesPrueba
        CREATE CURSOR curClientes (Id I, Nombre C(50))
        INSERT INTO curClientes VALUES (1, "Test Cliente 1")
        INSERT INTO curClientes VALUES (2, "Test Cliente 2")
    ENDPROC
ENDDEFINE
```

### 5. Test antipatterns

#### ❌ Antipatrones a detectar

**1. Tests sin assertions**
```foxpro
*-- Mal: No valida nada
PROCEDURE Test_GuardarCliente
    THIS.oService.GuardarCliente(loCliente)
    *-- Falta: THIS.AssertTrue(...)
ENDPROC
```

**2. Tests dependientes**
```foxpro
*-- Mal: Depende de Test_Crear ejecutado previamente
PROCEDURE Test_Actualizar
    loCliente = THIS.ObtenerClienteCreado()  && Asume que existe
    loCliente.Nombre = "Nuevo"
    THIS.AssertTrue(THIS.oService.Actualizar(loCliente))
ENDPROC
```

**3. Tests con lógica compleja**
```foxpro
*-- Mal: Demasiada lógica en el test
PROCEDURE Test_CalculoComplejo
    FOR i = 1 TO 10
        IF i % 2 = 0
            lnResultado = THIS.Calcular(i)
        ELSE
            lnResultado = THIS.CalcularImpar(i)
        ENDIF
        THIS.AssertTrue(lnResultado > 0)
    ENDFOR
ENDPROC
```

**4. Hardcoded dependencies**
```foxpro
*-- Mal: Dependencia hardcodeada
PROCEDURE Test_ConexionBD
    gnHandle = SQLCONNECT("ProductionDB")  && ❌ Conecta a producción!
ENDPROC
```

**5. Tests lentos**
```foxpro
*-- Mal: Test que tarda >1 segundo
PROCEDURE Test_ProcesoCompleto
    *-- Procesa 10,000 registros
    FOR i = 1 TO 10000
        THIS.Procesar(i)
    ENDFOR
    *-- Mejor: mover a integration tests o usar dataset pequeño
ENDPROC
```

## Formato de reporte

```markdown
## Resumen de Cobertura

| Métrica | Valor | Objetivo | Estado |
|---------|-------|----------|--------|
| Clases con tests | X/Y (Z%) | 80% | ⚠️ |
| Métodos cubiertos | X/Y (Z%) | 70% | ✅ |
| Branches cubiertos | X/Y (Z%) | 60% | ❌ |
| Tests exitosos | X/Y (Z%) | 100% | ✅ |

## Análisis por Módulo

### Organic.BusinessLogic/CENTRALSS/_Nucleo/

#### ✅ Bien testeado
- `BaseEntity.prg`: 95% cobertura, 12 tests
- `Validador.prg`: 88% cobertura, 8 tests

#### ⚠️ Cobertura parcial
- `FacturaManager.prg`: 55% cobertura
  - ❌ Falta: Tests para método `CalcularDescuentos`
  - ❌ Falta: Tests para manejo de errores en `Guardar`
  
#### ❌ Sin tests
- `ReporteGenerator.prg`: 0% cobertura
  - 🎯 Prioridad: Alta (lógica de negocio crítica)

## Tests con problemas

### Test_FacturaManager.prg

🔴 **Test_GuardarFactura**: Sin assertions
- **Línea**: 45
- **Problema**: Test no valida resultado
- **Fix**: Agregar `THIS.AssertTrue(llResultado)`

🟡 **Test_CalcularTotal**: Datos hardcodeados
- **Línea**: 67
- **Problema**: Valores mágicos sin constantes
- **Fix**: Usar fixture con datos nombrados

### Test_ClienteService.prg

🔴 **Test_ObtenerCliente**: Dependencia de BD real
- **Línea**: 23
- **Problema**: Conecta a base de datos de producción
- **Fix**: Inyectar mock de repository

## Tests faltantes recomendados

### FacturaManager.prg
```foxpro
*-- Test case recomendado
PROCEDURE Test_CalcularDescuentos_ConPromocionActiva
    *-- Arrange
    loFactura = THIS.CrearFacturaMock()
    loFactura.CodigoPromocion = "VERANO2025"
    
    *-- Act
    lnDescuento = THIS.oManager.CalcularDescuentos(loFactura)
    
    *-- Assert
    THIS.AssertEquals(10.0, lnDescuento, "Descuento de promoción incorrecto")
ENDPROC

PROCEDURE Test_Guardar_ConErrorDeConexion
    *-- Arrange
    THIS.oMockRepo.SimularErrorConexion = .T.
    
    *-- Act & Assert
    THIS.AssertFalse(THIS.oManager.Guardar(loFactura))
    THIS.AssertEquals("ERROR_CONEXION", THIS.oManager.UltimoError)
ENDPROC
```

## Plan de acción priorizado

### 🔴 Prioridad Alta (Sprint actual)
1. **Agregar tests a ReporteGenerator.prg** (0% cobertura, lógica crítica)
   - Estimación: 4 horas
   - Crear: Test_GenerarReporteVentas, Test_FiltrarPorFecha
   
2. **Corregir tests sin assertions** (5 tests identificados)
   - Estimación: 2 horas
   - Archivos: Test_FacturaManager.prg, Test_ClienteService.prg

### 🟡 Prioridad Media (Próximo sprint)
3. **Incrementar cobertura de FacturaManager.prg** (55% → 80%)
   - Estimación: 6 horas
   - Agregar 8 test cases para branches sin cubrir

4. **Refactorizar tests con dependencias reales** (3 tests)
   - Estimación: 3 horas
   - Implementar mocks para BD y servicios externos

### 🟢 Prioridad Baja (Backlog)
5. **Mejorar fixtures para reutilización** 
   - Estimación: 4 horas
   - Crear FixtureFactory centralizado

6. **Agregar integration tests para flujos completos**
   - Estimación: 8 horas
   - Flujos: Facturación end-to-end, Cierre mensual

## Métricas de calidad de tests

### Velocidad de ejecución
```
UnitTests: 2.3s ✅ (objetivo: <5s)
IntegrationTests: 12.5s ⚠️ (objetivo: <10s)
FunctionalTests: 45s ❌ (objetivo: <30s)
```

### Confiabilidad
```
Tests flaky: 2/145 (1.4%) ✅ (objetivo: <2%)
Falsos positivos: 0 ✅
Falsos negativos: 1 ⚠️
```

### Mantenibilidad
```
Tests actualizados con código: 89% ⚠️ (objetivo: 100%)
Tests obsoletos: 3 ❌
Tests duplicados: 5 ⚠️
```

## Recomendaciones generales

### ✅ Mejores prácticas a implementar
1. **Setup/Teardown consistente**: Siempre limpiar recursos
2. **Fixtures centralizados**: Una fuente de datos de prueba
3. **Mocks inyectados**: Dependency injection para testabilidad
4. **Nombres descriptivos**: `Test_<Método>_<Escenario>_<ResultadoEsperado>`
5. **One assertion per test**: Facilita identificar fallos

### 📚 Tests a considerar

#### Edge cases
- Valores nulos, vacíos, cero
- Límites de tipos de datos (max int, max char)
- Colecciones vacías
- Errores de conexión/timeout

#### Integración
- Transacciones con rollback
- Concurrencia (locks de registros)
- Performance con volumen real

## Uso con GitHub Copilot Chat

```
Usa el prompt de auditoría de tests para analizar Test_FacturaManager.prg
```

Para análisis completo:

```
Audita la cobertura de tests del proyecto Organic.Tests
```

---

**Siguiente paso**: Implementa los tests faltantes usando `.github/prompts/dev/vfp-development-expert.prompt.md`
