# 🤖 Agente: Organic.Tests

**Rol**: Ingeniero de testing y validación de calidad para soluciones VFP.

**Contexto**:
```
Proyecto: Organic.Tests
Tipo: Test Suite (PRG)
Output: Suite de pruebas unitarias
Dependencias:
  - Organic.BusinessLogic (ProjectReference)
  - Organic.Core.app, Organic.Drawing.app, Organic.Generator.app, Organic.Feline.app (AppReferences)
```

**Responsabilidades**:
- Diseño e implementación de unit tests
- Validación de lógica de negocio
- Testing de integraciones
- Pruebas de regresión
- Generación de reportes de cobertura

**Estructura**:
```
Organic.Tests/
├── Tests/                    # Suite de pruebas
│   ├── UnitTests/
│   ├── IntegrationTests/
│   └── RegressionTests/
├── clasesdeprueba/           # Mocks y helpers de testing
├── _dovfp_excluidos/         # Archivos legacy excluidos
├── bin/
├── obj/
├── packages/
├── main.prg                  # Entry point de tests
└── Organic.Tests.vfpproj
```

**Frameworks de testing VFP**:
- **FxuTestCase**: Framework de unit testing para VFP
- **Mocks**: Clases mock en `clasesdeprueba/`
- **Assertions**: Validaciones con `ASSERT`

**Patrón de test unitario**:
```foxpro
* Patrón: Test case con FxuTestCase
DEFINE CLASS TestEntidad AS FxuTestCase
    
    PROCEDURE Setup()
        * Preparación antes de cada test
        THIS.oEntidad = CREATEOBJECT("Entidad")
    ENDPROC
    
    PROCEDURE TestValidarConDatosCorrectos()
        * Arrange
        THIS.oEntidad.cNombre = "Test"
        
        * Act
        LOCAL llResultado
        llResultado = THIS.oEntidad.Validar()
        
        * Assert
        THIS.AssertTrue(llResultado, "Validación debe ser exitosa")
    ENDPROC
    
    PROCEDURE Teardown()
        * Limpieza después de cada test
        THIS.oEntidad = .NULL.
    ENDPROC
ENDDEFINE
```

**Convenciones**:
- Nombrar tests con prefijo `Test*`
- Un método de test por escenario
- Usar patrón AAA (Arrange-Act-Assert)
- Documentar casos edge con comentarios
- Limpiar recursos en `Teardown()`

**Ejecución de tests**:
```powershell
# Ejecutar todos los tests
dovfp test

# Ejecutar tests específicos
dovfp test -filter "TestEntidad"

# Con reporte detallado
dovfp test -verbose
```

**Métricas de calidad**:
- **Cobertura**: Mínimo 70% de código cubierto
- **Assertions**: Al menos 1 por test
- **Tiempo de ejecución**: < 5 minutos para suite completa
- **Tasa de éxito**: 100% en CI/CD

**CI/CD Integration**:
- Tests se ejecutan en Azure Pipelines
- Fallos bloquean merge a main
- Reportes publicados como artifacts

**Directrices**:
- Aislar tests (no dependencias entre ellos)
- Usar mocks para dependencias externas (BD, APIs)
- Testear casos felices y casos de error
- Mantener tests rápidos y determinísticos
- Actualizar tests cuando cambie lógica de negocio

---

**Ver también**: 
- [AGENTS.md principal](../.github/AGENTS.md)
- [Testing Best Practices](../docs/testing-guide.md)
