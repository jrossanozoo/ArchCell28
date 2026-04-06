# 🤖 Índice de Agentes - Organic.ZL

Este archivo documenta todos los agentes disponibles en el sistema GitHub Copilot Customization.

---

## 📋 Agentes Centrales (.github/agents/)

Agentes especializados con formato `.agent.md` y capacidad de handoff.

| Agent | Archivo | Propósito | Herramientas |
|-------|---------|-----------|--------------|
| **Developer** | [developer.agent.md](agents/developer.agent.md) | Desarrollo de features VFP | search, usages, read_file, run_in_terminal |
| **Test Engineer** | [test-engineer.agent.md](agents/test-engineer.agent.md) | Testing y validación | search, usages, read_file, run_in_terminal |
| **Auditor** | [auditor.agent.md](agents/auditor.agent.md) | Code review y calidad | search, usages, read_file, grep_search |
| **Refactor** | [refactor.agent.md](agents/refactor.agent.md) | Mejora de código | search, usages, read_file, run_in_terminal |

### Flujo de Handoffs

```
┌─────────────┐     Crear Tests     ┌──────────────────┐
│  developer  │ ──────────────────► │  test-engineer   │
│     💻      │                     │       🧪         │
└─────────────┘                     └──────────────────┘
       │                                    │
       │ Revisar Código                     │ Auditar Tests
       ▼                                    ▼
┌─────────────┐     Refactorizar    ┌──────────────────┐
│   auditor   │ ◄─────────────────► │     refactor     │
│     🔍      │                     │        🔄        │
└─────────────┘                     └──────────────────┘
```

---

## 📁 Agentes por Proyecto (AGENTS.md)

Agentes contextuales que se activan automáticamente según ubicación del archivo.

| Proyecto | Archivo | Rol |
|----------|---------|-----|
| **BusinessLogic** | [Organic.BusinessLogic/AGENTS.md](../Organic.BusinessLogic/AGENTS.md) | Desarrollo de código VFP |
| **Tests** | [Organic.Tests/AGENTS.md](../Organic.Tests/AGENTS.md) | Testing y validación |
| **Generated** | [Organic.Generated/AGENTS.md](../Organic.Generated/AGENTS.md) | Código autogenerado (NO EDITAR) |

---

## 🎯 Cómo Usar los Agentes

### Invocar Agente Central
```
@workspace Usando el agente developer, implementa una clase para...
@workspace Usando el agente auditor, revisa el archivo ClienteBusiness.prg
```

### Activación Automática por Ubicación
Los archivos `AGENTS.md` en cada proyecto se activan automáticamente cuando editas archivos en esa carpeta.

---

## 🔧 Capacidades por Agente

### Developer 💻
- Implementación de nuevas clases y procedimientos
- Aplicación de estándares VFP
- Integración con DOVFP build system
- Documentación de código

### Test Engineer 🧪
- Diseño de casos de prueba
- Implementación de tests unitarios
- Creación de mocks y fixtures
- Análisis de cobertura

### Auditor 🔍
- Análisis de calidad de código
- Detección de vulnerabilidades
- Verificación de estándares
- Generación de reportes

### Refactor 🔄
- Aplicación de patrones SOLID
- Eliminación de código duplicado
- Optimización de performance
- Simplificación de complejidad

---

## 📚 Referencias

- [README.md](README.md) - Guía completa del sistema
- [STRUCTURE.md](STRUCTURE.md) - Vista visual de la estructura
- [copilot-instructions.md](copilot-instructions.md) - Configuración principal
