# 🤖 Índice de Agentes - Organic.Drawing

## Descripción

Este documento lista todos los agentes disponibles para GitHub Copilot en el proyecto Organic.Drawing.

## Agentes Centralizados (.github/agents/)

| Agent | Archivo | Especialización | Tools |
|-------|---------|-----------------|-------|
| `@developer` | [developer.agent.md](agents/developer.agent.md) | Desarrollo de features VFP | search, read_file, run_in_terminal |
| `@test-engineer` | [test-engineer.agent.md](agents/test-engineer.agent.md) | Testing y QA | search, read_file, run_in_terminal |
| `@auditor` | [auditor.agent.md](agents/auditor.agent.md) | Code review y calidad | search, read_file, usages |
| `@refactor` | [refactor.agent.md](agents/refactor.agent.md) | Mejoras SOLID y patrones | search, read_file, usages |

## Agentes por Contexto (AGENTS.md Distribuidos)

Estos agentes se activan automáticamente según el directorio de trabajo:

| Ubicación | Contexto | Responsabilidad |
|-----------|----------|-----------------|
| [/AGENTS.md](../AGENTS.md) | Raíz del proyecto | Arquitecto de soluciones, builds, CI/CD |
| [/Organic.BusinessLogic/AGENTS.md](../Organic.BusinessLogic/AGENTS.md) | Código de negocio | Desarrollo VFP, refactoring |
| [/Organic.Tests/AGENTS.md](../Organic.Tests/AGENTS.md) | Tests | Testing, mocking, cobertura |
| [/Organic.Generated/AGENTS.md](../Organic.Generated/AGENTS.md) | Código generado | Scripts de generación, validación |
| [/Organic.Mocks/AGENTS.md](../Organic.Mocks/AGENTS.md) | Mocks | Clases mock para tests |

## Flujo de Handoffs

```
┌─────────────┐     ┌────────────────┐     ┌───────────┐     ┌───────────┐
│  developer  │────▶│  test-engineer │────▶│  auditor  │────▶│  refactor │
└─────────────┘     └────────────────┘     └───────────┘     └───────────┘
       ▲                                                            │
       └────────────────────────────────────────────────────────────┘
```

### Cuándo hacer handoff

| De | A | Condición |
|----|---|-----------|
| `@developer` | `@test-engineer` | Feature implementada, necesita tests |
| `@test-engineer` | `@auditor` | Tests completos, necesita review |
| `@auditor` | `@refactor` | Issues de calidad identificados |
| `@refactor` | `@test-engineer` | Refactoring hecho, validar tests |

## Uso

### Invocar un agent

```
@developer implementa método de validación de cliente VIP

@test-engineer genera tests unitarios para ServicioVentas

@auditor revisa calidad del módulo de facturación

@refactor aplica patrón Strategy a los descuentos
```

### Cambiar de agent (handoff)

El agent actual puede sugerir pasar a otro:

```
✅ Feature implementada. Pasando a @test-engineer para generar tests.
```

## Capacidades por Agent

### @developer
- ✅ Crear clases y métodos VFP
- ✅ Implementar lógica de negocio
- ✅ Integrar con DOVFP
- ✅ Resolver bugs

### @test-engineer
- ✅ Crear tests unitarios
- ✅ Diseñar mocks y fixtures
- ✅ Ejecutar suite de tests
- ✅ Medir cobertura

### @auditor
- ✅ Revisar calidad de código
- ✅ Identificar code smells
- ✅ Validar estándares VFP
- ✅ Reportar deuda técnica

### @refactor
- ✅ Aplicar principios SOLID
- ✅ Extraer métodos/clases
- ✅ Eliminar duplicación
- ✅ Optimizar performance
