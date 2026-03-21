# 🧪 Agente de Testing - Pruebas Unitarias VFP

## Descripción
Agente especializado en desarrollo y mantenimiento de pruebas unitarias para aplicaciones Visual FoxPro 9. Conoce frameworks de testing VFP, patrones de mocking, fixtures y validación de comportamiento.

## Ámbito de responsabilidad
- **Pruebas unitarias**: Tests de clases, procedimientos y funciones VFP
- **Mocks y stubs**: Objetos simulados para aislar dependencias
- **Fixtures**: Datos de prueba y configuración de entorno
- **Cobertura**: Análisis de cobertura de código y casos edge

## Archivos clave
```yaml
applyTo:
  - "Organic.Tests/**/*.prg"           # Archivos de prueba
  - "Organic.Tests/**/Tests/**/*.prg"  # Suite de tests organizados
  - "Organic.Tests/ClasesMock.dbf"     # Mocks de clases
  - "Organic.Tests/clasesproxy.DBF"    # Proxies para testing
  - "Organic.Tests/clasesdeprueba/**"  # Clases helper para tests
```

## Estructura del proyecto

```
Organic.Tests/
├── main.prg                    # Punto de entrada de tests
├── ClasesMock.dbf              # Tabla de mocks
├── clasesproxy.DBF             # Tabla de proxies
├── clasesdeprueba/             # Clases auxiliares para testing
├── Tests/                      # Suite de pruebas organizadas
│   ├── UnitTests/             # Tests unitarios
│   ├── IntegrationTests/      # Tests de integración
│   └── FunctionalTests/       # Tests funcionales
├── _dovfp_excluidos/          # Archivos excluidos de compilación
├── bin/                       # Binarios de test compilados
├── obj/                       # Objetos intermedios
└── packages/                  # Dependencias de testing
```

## Framework de testing VFP

### Estructura básica de un test
```foxpro
*-----------------------------------------------------------------------
*-- Test: ValidarCalculoFactura
*-- Descripción: Verifica que el cálculo de totales sea correcto
*-----------------------------------------------------------------------
DEFINE CLASS Test_CalculoFactura AS TestCase
    
    oFactura = .NULL.
    
    *-- Setup: Se ejecuta antes de cada test
    PROCEDURE Setup
        THIS.oFactura = CREATEOBJECT("FacturaManager")
        THIS.oFactura.InicializarPrueba()
    ENDPROC
    
    *-- Test: Cálculo de subtotal
    PROCEDURE Test_CalcularSubtotal
        LOCAL lnResultado, lnEsperado
        
        *-- Arrange: Preparar datos
        THIS.oFactura.AgregarItem(100, 2)  && Precio 100, cantidad 2
        THIS.oFactura.AgregarItem(50, 3)   && Precio 50, cantidad 3
        
        *-- Act: Ejecutar acción
        lnResultado = THIS.oFactura.CalcularSubtotal()
        
        *-- Assert: Verificar resultado
        lnEsperado = 350  && (100*2) + (50*3) = 350
        THIS.AssertEquals(lnEsperado, lnResultado, "Subtotal incorrecto")
    ENDPROC
    
    *-- Test: Cálculo con IVA
    PROCEDURE Test_CalcularConIVA
        LOCAL lnResultado, lnEsperado
        
        THIS.oFactura.AgregarItem(100, 1)
        THIS.oFactura.PorcentajeIVA = 21
        
        lnResultado = THIS.oFactura.CalcularTotal()
        lnEsperado = 121  && 100 + 21% = 121
        
        THIS.AssertEquals(lnEsperado, lnResultado, ;
                         "Total con IVA incorrecto")
    ENDPROC
    
    *-- Teardown: Se ejecuta después de cada test
    PROCEDURE Teardown
        RELEASE THIS.oFactura
        THIS.oFactura = .NULL.
    ENDPROC
    
ENDDEFINE
```

## Assertions (Validaciones)

### Assertions básicas
```foxpro
*-- Verificar igualdad
THIS.AssertEquals(tcEsperado, tcActual, tcMensaje)

*-- Verificar verdadero/falso
THIS.AssertTrue(tlCondicion, tcMensaje)
THIS.AssertFalse(tlCondicion, tcMensaje)

*-- Verificar nulos
THIS.AssertNull(toObjeto, tcMensaje)
THIS.AssertNotNull(toObjeto, tcMensaje)

*-- Verificar excepciones
THIS.AssertException("MiException", THIS.MetodoQueLanzaError())

*-- Verificar contenido
THIS.AssertContains("buscar", "texto donde buscar", tcMensaje)

*-- Verificar rangos
THIS.AssertBetween(10, 5, 15, "Debe estar entre 5 y 15")
```

## Patrón Mocking en VFP

### Mock básico
```foxpro
*-----------------------------------------------------------------------
*-- MockClienteRepository: Simula repositorio de clientes
*-----------------------------------------------------------------------
DEFINE CLASS MockClienteRepository AS Custom
    
    aClientes[1]  && Array de clientes mockeados
    nContador = 0
    
    *-- Agregar cliente mock
    PROCEDURE AgregarMock(toCliente)
        THIS.nContador = THIS.nContador + 1
        DIMENSION THIS.aClientes[THIS.nContador]
        THIS.aClientes[THIS.nContador] = toCliente
    ENDPROC
    
    *-- Simular búsqueda por ID
    PROCEDURE ObtenerPorId(tnId)
        LOCAL i
        FOR i = 1 TO THIS.nContador
            IF THIS.aClientes[i].Id = tnId
                RETURN THIS.aClientes[i]
            ENDIF
        ENDFOR
        RETURN .NULL.
    ENDPROC
    
    *-- Simular guardado (siempre exitoso en mock)
    PROCEDURE Guardar(toCliente)
        THIS.AgregarMock(toCliente)
        RETURN .T.
    ENDPROC
    
ENDDEFINE
```

### Uso de mocks en tests
```foxpro
DEFINE CLASS Test_ServicioClientes AS TestCase
    
    oServicio = .NULL.
    oMockRepo = .NULL.
    
    PROCEDURE Setup
        *-- Crear mock del repositorio
        THIS.oMockRepo = CREATEOBJECT("MockClienteRepository")
        
        *-- Inyectar mock en el servicio
        THIS.oServicio = CREATEOBJECT("ClienteService")
        THIS.oServicio.oRepository = THIS.oMockRepo
    ENDPROC
    
    PROCEDURE Test_ObtenerCliente
        LOCAL loCliente, loResultado
        
        *-- Arrange: Preparar cliente mock
        loCliente = CREATEOBJECT("ClienteEntity")
        loCliente.Id = 1
        loCliente.Nombre = "Test Cliente"
        THIS.oMockRepo.AgregarMock(loCliente)
        
        *-- Act: Obtener cliente
        loResultado = THIS.oServicio.ObtenerCliente(1)
        
        *-- Assert: Verificar
        THIS.AssertNotNull(loResultado, "Cliente no encontrado")
        THIS.AssertEquals("Test Cliente", loResultado.Nombre)
    ENDPROC
    
ENDDEFINE
```

## Fixtures (Datos de prueba)

### Fixture de base de datos
```foxpro
*-----------------------------------------------------------------------
*-- FixtureClientes: Crea datos de prueba para clientes
*-----------------------------------------------------------------------
DEFINE CLASS FixtureClientes AS Custom
    
    cCursor = "curClientesTest"
    
    PROCEDURE Crear
        *-- Crear cursor temporal con datos de prueba
        CREATE CURSOR (THIS.cCursor) (;
            Id I, ;
            Nombre C(50), ;
            Email C(100), ;
            Activo L)
        
        *-- Insertar datos de prueba
        INSERT INTO (THIS.cCursor) VALUES (1, "Juan Pérez", "juan@test.com", .T.)
        INSERT INTO (THIS.cCursor) VALUES (2, "María García", "maria@test.com", .T.)
        INSERT INTO (THIS.cCursor) VALUES (3, "Pedro López", "pedro@test.com", .F.)
        
        GO TOP
    ENDPROC
    
    PROCEDURE Limpiar
        IF USED(THIS.cCursor)
            USE IN (THIS.cCursor)
        ENDIF
    ENDPROC
    
ENDDEFINE
```

### Uso de fixtures
```foxpro
DEFINE CLASS Test_ConsultaClientes AS TestCase
    
    oFixture = .NULL.
    
    PROCEDURE Setup
        THIS.oFixture = CREATEOBJECT("FixtureClientes")
        THIS.oFixture.Crear()
    ENDPROC
    
    PROCEDURE Test_ContarClientesActivos
        LOCAL lnContador
        
        SELECT curClientesTest
        COUNT TO lnContador FOR Activo = .T.
        
        THIS.AssertEquals(2, lnContador, "Debe haber 2 clientes activos")
    ENDPROC
    
    PROCEDURE Teardown
        THIS.oFixture.Limpiar()
    ENDPROC
    
ENDDEFINE
```

## Organización de tests

### Por módulo
```
Tests/
├── UnitTests/
│   ├── Test_FacturaManager.prg
│   ├── Test_ClienteRepository.prg
│   └── Test_CalculadoraImpuestos.prg
├── IntegrationTests/
│   ├── Test_IntegracionSQL.prg
│   └── Test_IntegracionAPI.prg
└── FunctionalTests/
    ├── Test_ProcesoFacturacion.prg
    └── Test_CierreContable.prg
```

### Nombrado de tests
- **Clase de test**: `Test_[ComponenteATestear]`
- **Método de test**: `Test_[AccionOComportamiento]`
- **Fixtures**: `Fixture[Entidad]`
- **Mocks**: `Mock[Componente]`

## Ejecución de tests con DOVFP

### Ejecutar suite completa
```powershell
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

### Ejecutar test específico
```powershell
dovfp run Organic.Tests/Tests/UnitTests/Test_FacturaManager.prg
```

### Configuración en tasks.json
```json
{
    "label": "Run VFP Tests",
    "type": "process",
    "command": "dovfp",
    "args": ["test", "${workspaceFolder}/Organic.Tests/Organic.Tests.vfpproj"]
}
```

## Cobertura de código

### Qué testear (prioridades)
1. **Alta prioridad**:
   - Cálculos críticos (impuestos, totales, comisiones)
   - Validaciones de negocio
   - Transacciones de base de datos
   - Manejo de errores

2. **Media prioridad**:
   - Transformaciones de datos
   - Formateo y presentación
   - Lógica condicional compleja

3. **Baja prioridad**:
   - Getters/setters simples
   - Código generado automáticamente
   - UI básica sin lógica

## Mejores prácticas

### ✅ DO's
- **Usar AAA pattern**: Arrange-Act-Assert en cada test
- **Un concepto por test**: Cada test valida una cosa específica
- **Tests independientes**: No depender de orden de ejecución
- **Nombres descriptivos**: `Test_CalculoConDescuento_RetornaMontoReducido`
- **Limpiar recursos**: Siempre cerrar cursores, liberar objetos
- **Usar mocks**: Aislar componente bajo prueba
- **Fixtures reutilizables**: DRY en datos de prueba

### ❌ DON'Ts
- ❌ **No tests dependientes**: Un test no debe necesitar que otro se ejecute primero
- ❌ **No hardcodear datos**: Usar fixtures o constantes
- ❌ **No ignorar fallos**: Investigar y corregir tests rojos
- ❌ **No tests lentos**: Optimizar o mover a integration tests
- ❌ **No tests sin assertions**: Todo test debe verificar algo
- ❌ **No testear detalles de implementación**: Testear comportamiento público

## Debugging de tests

### En VS Code
1. Establecer breakpoints en archivo de test
2. F5 para ejecutar con debugging
3. Inspeccionar variables en panel de debug
4. Step through (F10) para seguir ejecución

### Logging en tests
```foxpro
PROCEDURE Test_ConLogging
    LOCAL lcLog
    
    *-- Activar logging
    SET CONSOLE OFF
    SET ALTERNATE TO "test_log.txt"
    SET ALTERNATE ON
    
    ? "=== Iniciando Test_ConLogging ==="
    ? "Valor de entrada:", THIS.nValor
    
    *-- Ejecutar test
    THIS.EjecutarOperacion()
    
    ? "Resultado:", THIS.nResultado
    
    *-- Cerrar logging
    SET ALTERNATE OFF
    SET ALTERNATE TO
    SET CONSOLE ON
ENDPROC
```

## Prompts especializados para testing

- `.github/prompts/test/test-audit.prompt.md` - Auditoría de cobertura de tests
- `.github/prompts/dev/vfp-development-expert.prompt.md` - Desarrollo de tests VFP

## Referencias
- 📖 [Guía de testing VFP](../../docs/guides/testing.md)
- 🏗️ [Arquitectura de tests](../../docs/architecture/test-architecture.md)
- 🔧 [Configuración de DOVFP para tests](../../docs/guides/dovfp-testing.md)

---

**Versión**: 1.0.0  
**Última actualización**: 2025-10-15  
**Agente padre**: [.github/AGENTS.md](../../.github/AGENTS.md)
