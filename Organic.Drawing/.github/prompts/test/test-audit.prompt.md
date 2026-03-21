---
description: Auditoría de testing - cobertura, calidad de tests y oportunidades de mejora en suite de pruebas VFP
argument-hint: "Especifica la clase o módulo a evaluar cobertura de tests"
---

# 🧪 Auditoría de Testing y Cobertura

## Objetivo

Evaluar la calidad y cobertura de tests en proyectos Visual FoxPro, identificando gaps, mejoras y oportunidades.

---

## 🎯 Áreas de evaluación

### 1. 📊 Cobertura de código

**Métricas a calcular**:
- **Cobertura de líneas**: % de líneas ejecutadas por tests
- **Cobertura de funciones**: % de funciones/métodos testeados
- **Cobertura de branches**: % de ramas condicionales cubiertas
- **Cobertura de clases**: % de clases con tests

**Análisis manual** (VFP no tiene herramientas automáticas robustas):
```foxpro
* Instrumentar código con logging
PROCEDURE MiFuncion(tnParametro)
    * Log para tracking de cobertura
    THIS.LogCovertura("MiFuncion", PROGRAM(), LINENO())
    
    * Lógica normal
    IF tnParametro > 10
        * Branch 1
        THIS.LogCovertura("MiFuncion_Branch1", PROGRAM(), LINENO())
        RETURN .T.
    ELSE
        * Branch 2  
        THIS.LogCovertura("MiFuncion_Branch2", PROGRAM(), LINENO())
        RETURN .F.
    ENDIF
ENDPROC
```

**Reportar**:
```markdown
### Cobertura de código

| Proyecto | Clases | Funciones | Líneas | Estado |
|----------|--------|-----------|--------|--------|
| BusinessLogic | 45/120 (38%) | 234/680 (34%) | ~35% | ⚠️ Bajo |
| Generated | 0/89 (0%) | 0/445 (0%) | 0% | ❌ Crítico |
| Tests | N/A | N/A | N/A | ✅ N/A |

**Gaps críticos**:
1. **Módulo Ventas**: 0% cobertura - sin tests
2. **Módulo Clientes**: 15% cobertura - tests incompletos
3. **Validaciones**: 60% cobertura - falta edge cases
```

---

### 2. 🏗️ Calidad de tests

**Evaluar**:
- [ ] Tests siguen patrón AAA (Arrange, Act, Assert)
- [ ] Nombres descriptivos (`Test_DebeFallarCon_ParametroNulo`)
- [ ] Un concepto por test (no tests "gordos")
- [ ] Tests independientes (sin dependencias entre sí)
- [ ] Setup/TearDown correcto
- [ ] Uso apropiado de mocks/stubs
- [ ] Assertions significativas (no solo "no crashea")

**Ejemplo de test de baja calidad**:
```foxpro
* ❌ MAL: Test confuso, múltiples conceptos, sin cleanup
PROCEDURE Test_Ventas()
    LOCAL loServicio, loVenta, loCliente
    loServicio = CREATEOBJECT("ServicioVentas")
    loCliente = CREATEOBJECT("Cliente")
    loCliente.Id = 123
    loVenta = loServicio.ProcesarVenta(loCliente, 1000)
    ? loVenta.Total  && Sin assertion real
    loVenta2 = loServicio.ProcesarVenta(loCliente, -500)
    ? loVenta2.Total
ENDPROC
```

**Ejemplo de test de alta calidad**:
```foxpro
* ✅ BIEN: Claro, enfocado, con assertions
PROCEDURE Test_ProcesarVenta_DebeCalcularTotalConDescuento_CuandoClienteEsVIP()
    * Arrange
    LOCAL loServicio, loCliente, loVenta
    LOCAL lnMontoEsperado
    
    loServicio = CREATEOBJECT("ServicioVentas")
    loCliente = THIS.CrearClienteVIPMock()
    lnMontoEsperado = 800  && 1000 - 20% descuento
    
    * Act
    loVenta = loServicio.ProcesarVenta(loCliente, 1000)
    
    * Assert
    THIS.AssertEquals(lnMontoEsperado, loVenta.Total, ;
        "Cliente VIP debe tener 20% descuento")
    THIS.AssertEquals("VIP", loVenta.TipoDescuento, ;
        "Debe registrar tipo de descuento aplicado")
        
    * Cleanup
    loServicio = NULL
    loCliente = NULL
    loVenta = NULL
ENDPROC
```

**Reportar**:
```markdown
### Calidad de tests

**Tests con problemas**:
1. **Test_Ventas.prg**:
   - ❌ Múltiples conceptos en un test
   - ❌ Sin assertions (solo `?` para debug)
   - ❌ Sin cleanup de recursos
   
2. **Test_Clientes.prg**:
   - ⚠️ Nombres poco descriptivos (`Test1`, `Test2`)
   - ⚠️ Tests interdependientes (comparten estado)
   
**Métricas**:
- Tests bien estructurados: 45/120 (38%)
- Tests con assertions: 89/120 (74%)
- Tests independientes: 67/120 (56%)
```

---

### 3. 🎭 Uso de mocks y test doubles

**Evaluar**:
- [ ] Uso de mocks para dependencias externas
- [ ] Datos de prueba aislados (ClasesMock.dbf)
- [ ] Stubs para servicios externos
- [ ] Fakes para repositorios

**Ejemplo sin mocks (dependencia real)**:
```foxpro
* ❌ MAL: Depende de BD real
PROCEDURE Test_ObtenerCliente()
    LOCAL loRepo, loCliente
    loRepo = CREATEOBJECT("RepositorioClientesSQL")
    loCliente = loRepo.Obtener(123)  && Depende de que exista en BD
    THIS.AssertNotNull(loCliente)
ENDPROC
```

**Ejemplo con mocks**:
```foxpro
* ✅ BIEN: Mock aislado
PROCEDURE Test_ObtenerCliente_DebeRetornarCliente_CuandoExiste()
    * Arrange
    LOCAL loMockRepo, loCliente
    loMockRepo = CREATEOBJECT("RepositorioClientesMock")
    loMockRepo.AgregarClienteMock(123, "Juan Pérez", "juan@email.com")
    
    * Act
    loCliente = loMockRepo.Obtener(123)
    
    * Assert
    THIS.AssertNotNull(loCliente, "Cliente mock debe existir")
    THIS.AssertEquals("Juan Pérez", loCliente.Nombre)
ENDPROC

* Mock Repository
DEFINE CLASS RepositorioClientesMock AS Custom
    DIMENSION aClientes[1, 3]
    nCount = 0
    
    PROCEDURE AgregarClienteMock(tnId, tcNombre, tcEmail)
        THIS.nCount = THIS.nCount + 1
        DIMENSION THIS.aClientes[THIS.nCount, 3]
        THIS.aClientes[THIS.nCount, 1] = tnId
        THIS.aClientes[THIS.nCount, 2] = tcNombre
        THIS.aClientes[THIS.nCount, 3] = tcEmail
    ENDPROC
    
    PROCEDURE Obtener(tnId)
        LOCAL i, loCliente
        FOR i = 1 TO THIS.nCount
            IF THIS.aClientes[i, 1] = tnId
                loCliente = CREATEOBJECT("Cliente")
                loCliente.Id = THIS.aClientes[i, 1]
                loCliente.Nombre = THIS.aClientes[i, 2]
                loCliente.Email = THIS.aClientes[i, 3]
                RETURN loCliente
            ENDIF
        ENDFOR
        RETURN NULL
    ENDPROC
ENDDEFINE
```

**Reportar**:
```markdown
### Uso de mocks

**Estado actual**:
- Tests con mocks: 23/120 (19%)
- Tests con dependencias reales: 67/120 (56%)
- Tests con datos aislados: 30/120 (25%)

**Oportunidades**:
1. **Test_Ventas.prg**: Mockear RepositorioClientes (actualmente usa BD)
2. **Test_Email.prg**: Mockear ServicioEmail (actualmente envía emails reales)
3. **Test_Reportes.prg**: Mockear generador PDF
```

---

### 4. 🚦 Tests ignorados o deshabilitados

**Buscar**:
- Tests comentados
- Flags de "skip"
- Archivos en `_dovfp_excluidos/`

**Reportar**:
```markdown
### Tests deshabilitados

**Encontrados**: 15 tests

1. **Test_IntegracionBD.prg** (líneas 45-67):
   - Razón: "Falla en CI - investigar"
   - Antigüedad: 6 meses
   - Acción: ⚠️ Reactivar o eliminar

2. **Test_EnvioEmail.prg** (todo el archivo):
   - Ubicación: `_dovfp_excluidos/`
   - Razón: Desconocida
   - Acción: ❌ Revisar necesidad

**Impacto**: ~12% de tests deshabilitados reduce confianza en suite
```

---

### 5. ⚡ Performance de tests

**Medir**:
- Tiempo total de suite
- Tests lentos (>2 segundos)
- Posibles optimizaciones

**Instrumentar**:
```foxpro
DEFINE CLASS TestCase AS Custom
    dInicio = NULL
    
    PROCEDURE Setup()
        THIS.dInicio = SECONDS()
    ENDPROC
    
    PROCEDURE TearDown()
        LOCAL lnTiempo
        lnTiempo = SECONDS() - THIS.dInicio
        
        IF lnTiempo > 2
            ? "⚠️ Test lento:", PROGRAM(), lnTiempo, "segundos"
        ENDIF
    ENDPROC
ENDDEFINE
```

**Reportar**:
```markdown
### Performance de tests

**Tiempo total**: 45 segundos
**Tests lentos** (>2s): 8

| Test | Tiempo | Causa probable |
|------|--------|----------------|
| Test_ConsultaMasiva | 8.5s | SCAN sin índice |
| Test_GenerarReporte | 5.2s | Genera PDF real |
| Test_IntegracionAPI | 4.1s | Llama API externa |

**Recomendaciones**:
1. Agregar índices a tablas de test
2. Mockear generación de PDF
3. Mockear llamadas a APIs
```

---

### 6. 🔍 Edge cases y validaciones

**Evaluar cobertura de**:
- Parámetros nulos
- Strings vacíos
- Números negativos/cero
- Fechas inválidas
- Arrays vacíos
- Casos límite (min/max)

**Checklist por función**:
```markdown
#### Función: CalcularDescuento(tnTotal, tcTipoCliente)

Tests existentes:
- [x] Cliente VIP con monto positivo
- [x] Cliente Regular con monto positivo
- [ ] tnTotal = 0
- [ ] tnTotal negativo
- [ ] tcTipoCliente vacío/NULL
- [ ] tcTipoCliente con tipo no válido
- [ ] tnTotal muy grande (overflow)
- [ ] tcTipoCliente con espacios
```

**Reportar**:
```markdown
### Edge cases

**Cobertura de validaciones**: 34%

**Gaps por módulo**:

1. **Módulo Ventas**:
   - ❌ Sin tests para parámetros NULL
   - ❌ Sin tests para montos negativos
   - ⚠️ Validaciones parciales de fechas
   
2. **Módulo Clientes**:
   - ✅ Validaciones completas de email
   - ⚠️ Falta validación de nombres vacíos
   - ❌ Sin tests para caracteres especiales
```

---

### 7. 📚 Documentación de tests

**Evaluar**:
- Comentarios explicativos en tests
- README en carpeta de tests
- Guías de cómo ejecutar tests
- Documentación de fixtures y mocks

**Reportar**:
```markdown
### Documentación

**Estado**:
- README en /Organic.Tests/: ❌ No existe
- Tests documentados: 23/120 (19%)
- Mocks documentados: 3/15 (20%)

**Necesario**:
1. Crear README.md con:
   - Cómo ejecutar tests
   - Estructura de fixtures
   - Guía de mocking
2. Documentar tests complejos
3. Explicar datos en ClasesMock.dbf
```

---

## 📋 Reporte final de auditoría

```markdown
# 🧪 Reporte de Auditoría de Testing

**Proyecto**: Organic.Drawing
**Fecha**: [fecha]
**Tests totales**: 120

## 🎯 Resumen ejecutivo

**Puntuación general**: [X/10]

| Área | Puntuación | Estado |
|------|------------|--------|
| Cobertura de código | 3/10 | ❌ Crítico |
| Calidad de tests | 6/10 | ⚠️ Mejorable |
| Uso de mocks | 4/10 | ⚠️ Insuficiente |
| Edge cases | 3/10 | ❌ Crítico |
| Performance | 7/10 | ✅ Aceptable |
| Documentación | 2/10 | ❌ Crítico |

## 🚨 Acciones críticas (hacer YA)

1. **Agregar tests a módulo Ventas** (0% cobertura)
2. **Mockear dependencias en Test_Email** (envía emails reales)
3. **Documentar ClasesMock.dbf** (nadie sabe cómo usarlo)

## ⚠️ Acciones importantes (próximas 2 semanas)

1. Refactorizar tests con múltiples conceptos
2. Agregar edge cases a validaciones
3. Optimizar tests lentos

## 💡 Mejoras recomendadas (backlog)

1. Aumentar cobertura al 60%
2. Estandarizar nomenclatura de tests
3. Crear helpers de mocking reutilizables

## 📈 Plan de acción

### Fase 1 (Semana 1-2): Crítico
- [ ] Tests para Ventas.prg
- [ ] Mock de ServicioEmail
- [ ] README de testing

### Fase 2 (Semana 3-4): Importante  
- [ ] Refactor de tests "gordos"
- [ ] Edge cases de validaciones
- [ ] Optimizar 3 tests más lentos

### Fase 3 (Mes 2): Mejoras
- [ ] Aumentar cobertura a 60%
- [ ] Helpers de mocking
- [ ] Documentación completa
```

---

## Uso del prompt

```
@workspace Ejecuta una auditoría completa de testing en Organic.Tests/

@workspace #file:Test_Ventas.prg Analiza la calidad de estos tests y sugiere mejoras

@workspace ¿Qué edge cases faltan en nuestros tests de validaciones?

@workspace Necesito un plan para aumentar la cobertura de tests del 35% al 70%
```

---

## Relacionado

- Agente de testing: `/Organic.Tests/AGENTS.md`
- Prompt de desarrollo: `vfp-development-expert.prompt.md`
- Instrucciones de testing: crear en `.github/instructions/`
