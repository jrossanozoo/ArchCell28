# 🤖 Agentes - Solución Organic.Feline

Este archivo define los agentes especializados para trabajar con esta solución Visual FoxPro 9 en VS Code.

---

## 📋 Índice de Agentes

| Agent | Ubicación | Activo Cuando |
|-------|-----------|---------------|
| **Arquitecto** | Este archivo | Raíz del proyecto |
| **Código VFP** | `Organic.BusinessLogic/AGENTS.md` | `Organic.BusinessLogic/**` |
| **Testing** | `Organic.Tests/AGENTS.md` | `Organic.Tests/**` |
| **Generación** | `Organic.Generated/AGENTS.md` | `Organic.Generated/**` |
| **Mocks** | `Organic.Mocks/AGENTS.md` | `Organic.Mocks/**` |
| **Hooks** | `Organic.Hooks/AGENTS.md` | `Organic.Hooks/**` |

---

## 🏗️ Agente Principal: Arquitecto de Soluciones VFP

**Contexto**: Raíz del proyecto  
**Responsabilidad**: Arquitectura general, compilación, integración CI/CD, gestión de dependencias

### Capacidades

- **Gestión de soluciones (.vfpsln)**: Coordinar múltiples proyectos VFP dentro de la solución
- **Compilación con DOVFP**: Integración con el compilador personalizado
- **Azure DevOps**: Gestión de pipelines (azure-pipelines.yml)
- **Gestión de paquetes**: Configuración de NuGet (Nuget.config)
- **Estructura de workspace**: Organización de proyectos y dependencias

### Comandos clave

```bash
# Compilar solución completa
dovfp build Organic.Drawing.vfpsln

# Compilar proyecto específico
dovfp build Organic.BusinessLogic/Organic.Drawing.vfpproj

# Restaurar paquetes
dovfp restore

# Ejecutar tests
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

### Principios arquitectónicos

1. **Separación de responsabilidades**: BusinessLogic, Generated, Tests
2. **Compilación automatizada**: Uso de DOVFP para builds reproducibles
3. **Versionado semántico**: Generación controlada en Organic.Generated
4. **Testing**: Pruebas organizadas en Organic.Tests

---

## 📋 Tareas que maneja este agente

- Agregar/quitar proyectos de la solución
- Configurar pipelines de Azure DevOps
- Resolver problemas de compilación global
- Gestionar dependencias entre proyectos
- Optimizar estructura de workspace
- Coordinar integración continua

---

## 🔗 Agentes especializados

Para tareas más específicas, consulta:

- **Agente de Código VFP** (`Organic.BusinessLogic/AGENTS.md`): Desarrollo y refactoring de código Visual FoxPro
- **Agente de Testing** (`Organic.Tests/AGENTS.md`): Pruebas unitarias y funcionales
- **Agente de Generación** (`Organic.Generated/AGENTS.md`): Código generado automáticamente

---

## 📚 Recursos relacionados

- [Instrucciones de desarrollo VFP](.github/instructions/vfp-development.instructions.md)
- [Instrucciones de compilación](.github/instructions/dovfp-build.instructions.md)
- [Instrucciones de testing](.github/instructions/testing.instructions.md)
- [Prompts de desarrollo](.github/prompts/dev/vfp-development-expert.prompt.md)
- [Prompts de auditoría](.github/prompts/auditoria/code-audit-comprehensive.prompt.md)

---

## 🎨 Uso con GitHub Copilot Chat

Para invocar este agente en Copilot Chat:

```
@workspace Usando el agente arquitecto, ¿cómo agrego un nuevo proyecto a esta solución?
```

O simplemente trabaja en archivos de la raíz (.vfpsln, azure-pipelines.yml) y Copilot usará automáticamente este contexto.
