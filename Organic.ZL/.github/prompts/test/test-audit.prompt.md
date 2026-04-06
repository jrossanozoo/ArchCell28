---
description: Auditoría especializada de testing - Analiza cobertura, calidad de tests y estrategia de validación
tools: ["read_file", "grep_search", "list_code_usages", "semantic_search"]
applyTo:
  - "Organic.Tests/**/*.prg"
  - "Organic.Tests/**/*.vcx"
argument-hint: Especifica el módulo o suite de tests a auditar
version: 1.0.0
category: test
---

# 🧪 Auditoría de Testing y Cobertura

## 🎯 Objetivo

Evaluar la calidad, cobertura y efectividad de la suite de pruebas en el proyecto Organic.Tests.

## 📋 Áreas de Auditoría

### 1. **Cobertura de Código**

Analizar qué código está siendo testeado:

- ✅ **Cobertura por módulo**: % de código cubierto en cada componente
- ✅ **Código crítico sin tests**: Lógica de negocio sin validación
- ✅ **Test-to-code ratio**: Proporción de tests vs código productivo
- ✅ **Branches sin cubrir**: Condiciones no testeadas

### 2. **Calidad de Tests**

Evaluar características de los tests:

```foxpro
* Tests bien escritos deben:
✓ Ser independientes (no depender de orden de ejecución)
✓ Ser rápidos (< 1 segundo cada uno)
✓ Ser determinísticos (mismo input = mismo resultado)
✓ Tener nombres descriptivos (TestGuardarClienteConDatosValidos)
✓ Validar UNA sola cosa por test
✓ Usar assertions apropiadas
✓ Tener Setup/TearDown correctos
```

### 3. **Casos de Prueba**

Validar cobertura de escenarios:

- ✅ **Happy path**: Casos de uso normales cubiertos
- ✅ **Edge cases**: Valores límite, nulos, vacíos
- ✅ **Error handling**: Validación de manejo de errores
- ✅ **Integration tests**: Interacción entre componentes
- ✅ **Regression tests**: Tests para bugs conocidos

### 4. **Test Smells**

Detectar anti-patrones en tests:

- 🔴 **Tests vacíos**: Sin assertions o lógica
- 🔴 **Tests comentados**: Tests deshabilitados sin razón
- 🔴 **Tests que siempre pasan**: Assertions incorrectas
- 🔴 **Tests lentos**: > 5 segundos de ejecución
- 🔴 **Tests frágiles**: Fallan aleatoriamente
- 🔴 **Tests con side effects**: Modifican datos persistentes
- 🔴 **Duplicación de código**: Setup repetido sin helpers

### 5. **Mocking y Datos de Prueba**

Validar uso de mocks:

```foxpro
* Uso apropiado de mocks:
✓ Aislar unidad bajo prueba
✓ Simular dependencias externas (BD, APIs, archivos)
✓ Datos consistentes y reproducibles
✓ Cleanup correcto de datos mock

* Anti-patrones a evitar:
✗ Mocks muy complejos (reimplementan lógica real)
✗ Mocks compartidos entre tests (interdependencia)
✗ Datos hardcodeados dispersos (sin centralización)
```

### 6. **Estructura y Organización**

Evaluar organización del proyecto de tests:

```
Organic.Tests/
├── Tests/
│   ├── Unit/           # Tests unitarios (aislados)
│   ├── Integration/    # Tests de integración
│   └── Functional/     # Tests funcionales end-to-end
├── ClasesMock.dbf      # Datos mock centralizados
├── ClasesDePrueba/     # Clases auxiliares de testing
└── main.prg            # Test runner
```

### 7. **Estrategia de Testing**

Verificar que exista estrategia clara:

- 📊 **Pirámide de testing**: Más unit tests que integration/functional
- 📊 **Testing prioritario**: Código crítico tiene > 80% cobertura
- 📊 **Regression suite**: Bugs históricos tienen tests
- 📊 **CI/CD integration**: Tests se ejecutan automáticamente

## 📊 Formato de Reporte

```markdown
# REPORTE DE AUDITORÍA DE TESTING
Fecha: [YYYY-MM-DD HH:MM:SS]
Proyecto: Organic.Tests
Test suites: [N]

## 📈 MÉTRICAS DE COBERTURA

### Cobertura General
- **Total líneas**: 15,234
- **Líneas cubiertas**: 11,845
- **Cobertura global**: 77.7%

### Cobertura por Módulo
| Módulo | Líneas | Cubierto | % |
|--------|--------|----------|---|
| ClienteBusiness | 1,234 | 1,100 | 89% ✅ |
| ProductoBusiness | 890 | 712 | 80% ✅ |
| FacturaBusiness | 2,456 | 1,720 | 70% ⚠️ |
| ReporteBusiness | 567 | 227 | 40% 🔴 |

## 🔴 PROBLEMAS CRÍTICOS

### 1. Módulos sin Tests
- **ReporteBusiness.prg**: 0% cobertura
- **ImportarDatos.prg**: 0% cobertura
- **ProcesarLotes.prg**: 15% cobertura

### 2. Tests Deshabilitados
- TestFacturaBusiness.prg: 5 tests comentados (líneas 234-289)
- TestInventarioBusiness.prg: Test completo comentado

### 3. Tests Lentos
- TestGenerarReporte: 12.3s (debería ser < 1s)
- TestProcesarLoteCompleto: 45.7s (considerar mock de BD)

## 🟡 ADVERTENCIAS

### 1. Test Smells Detectados
```foxpro
* TestClienteBusiness.prg:145
PROCEDURE TestGuardar()
    * Sin assertions - test siempre pasa
    loCliente.Guardar()
    * FALTA: THIS.AssertTrue(llResultado)
ENDPROC

* TestProductoBusiness.prg:234
PROCEDURE TestCalcular()
    * Mock compartido entre tests
    USE ClasesMock SHARED  && ⚠️ Crear mock local
ENDPROC
```

### 2. Edge Cases No Cubiertos
- ClienteBusiness: No hay tests para valores NULL
- ProductoBusiness: No hay tests para precios negativos
- FacturaBusiness: No hay tests para totales = 0

### 3. Setup/TearDown Faltantes
- 8 test cases sin TearDown (posibles resource leaks)
- 3 test cases sin Setup (dependen de estado previo)

## 🔵 SUGERENCIAS DE MEJORA

### 1. Aumentar Cobertura
Prioridad: **ReporteBusiness** (40% → 75%)
```foxpro
* Tests faltantes:
- TestGenerarReporteVacio()
- TestGenerarReporteConFiltros()
- TestExportarReportePDF()
- TestErrorEnGeneracion()
```

### 2. Refactorizar Tests Lentos
```foxpro
* Antes (12.3s):
PROCEDURE TestGenerarReporte()
    * Genera archivo PDF real
    loReporte.Generar("reporte.pdf")
ENDPROC

* Después (0.05s):
PROCEDURE TestGenerarReporte()
    * Mock del generador PDF
    loMockPDF = CREATEOBJECT("MockPDFGenerator")
    loReporte.SetGenerator(loMockPDF)
    loReporte.Generar("reporte.pdf")
    THIS.AssertTrue(loMockPDF.WasCalled("Generate"))
ENDPROC
```

### 3. Organizar por Tipo
Crear subdirectorios:
- `Tests/Unit/` para tests unitarios
- `Tests/Integration/` para tests de integración
- `Tests/Functional/` para tests end-to-end

## 📊 ANÁLISIS DE CALIDAD

### Fortalezas
✅ Buenos nombres de tests (descriptivos)
✅ Uso consistente de TRY...CATCH
✅ Mocks bien organizados en ClasesMock.dbf

### Debilidades
❌ Falta documentación de qué testea cada suite
❌ Setup/TearDown inconsistentes
❌ No hay tests de regresión para bugs conocidos

## 🎯 PLAN DE ACCIÓN RECOMENDADO

### Corto Plazo (1-2 semanas)
1. ✅ Descomentar y arreglar tests deshabilitados
2. ✅ Agregar assertions faltantes en tests vacíos
3. ✅ Implementar TearDown en 8 test cases

### Mediano Plazo (1 mes)
4. ✅ Aumentar cobertura de ReporteBusiness a 75%
5. ✅ Optimizar tests lentos con mocks
6. ✅ Agregar tests para edge cases críticos

### Largo Plazo (3 meses)
7. ✅ Reorganizar en Unit/Integration/Functional
8. ✅ Alcanzar 80% cobertura global
9. ✅ Integrar en pipeline CI/CD

## 📈 TENDENCIA HISTÓRICA
```
Cobertura últimos 6 meses:
Abril:  68% ░░░░░░░▒▒▒
Mayo:   71% ░░░░░░░▒▒▒
Junio:  73% ░░░░░░░▒▒▒
Julio:  75% ░░░░░░░▒▒▒
Agosto: 76% ░░░░░░░▒▒▒
Sept:   77.7% ░░░░░░░▒▒▒  ← Actual

Tendencia: 📈 Mejorando (meta: 80%)
```

## ✅ CONCLUSIÓN

**Estado general**: ACEPTABLE ⚠️

El proyecto tiene una base sólida de testing, pero requiere:
1. Aumentar cobertura en módulos críticos
2. Corregir test smells identificados
3. Optimizar performance de tests lentos

**Próxima auditoría recomendada**: 30 días
```

## 🛠️ Ejemplo de Uso

```
@workspace /audit Auditar la suite de pruebas en Organic.Tests enfocándome 
en cobertura de módulos de negocio y performance de tests. Generar plan 
de acción priorizado.
```

## 🔗 Referencias

- **Agente especializado**: `Organic.Tests/AGENTS.md`
- **Framework de testing**: `Organic.Tests/_dovfp_excluidos/FxuTestCase.prg`
- **Best practices**: `docs/testing-best-practices.md`

---

**Última revisión**: 2025-10-15  
**Mantenido por**: Equipo de QA Organic.ZL
