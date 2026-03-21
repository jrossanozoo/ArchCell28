# 🤖 Agentes - Solución Organic.Drawing

Este archivo define los agentes especializados para trabajar con esta solución Visual FoxPro 9 en VS Code.

## 🎯 Propósito

Los agentes son contextos especializados que guían a GitHub Copilot para realizar tareas específicas según el área del proyecto en la que estés trabajando.

---

## 🏗️ Agente Principal: Arquitecto de Soluciones VFP

**Contexto**: Raíz del proyecto  
**Responsabilidad**: Arquitectura general, compilación, integración CI/CD, gestión de dependencias

### Capacidades

- **Gestión de soluciones (.vfpsln)**: Coordinar múltiples proyectos VFP dentro de la solución
- **Compilación con DOVFP**: Integración con el compilador personalizado
- **Azure DevOps**: Gestión de pipelines (azure-pipelines.yml)
- **GestiÃ³n de paquetes**: ConfiguraciÃ³n de NuGet (Nuget.config)
- **Estructura de workspace**: OrganizaciÃ³n de proyectos y dependencias

### Comandos clave

```bash
# Compilar soluciÃ³n completa
dovfp build Organic.Drawing.vfpsln

# Compilar proyecto especÃ­fico
dovfp build Organic.BusinessLogic/Organic.Drawing.vfpproj

# Restaurar paquetes
dovfp restore

# Ejecutar tests
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

### Principios arquitectÃ³nicos

1. **SeparaciÃ³n de responsabilidades**: BusinessLogic, Generated, Tests
2. **CompilaciÃ³n automatizada**: Uso de DOVFP para builds reproducibles
3. **Versionado semÃ¡ntico**: GeneraciÃ³n controlada en Organic.Generated
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

Para tareas mÃ¡s especÃ­ficas, consulta:

- **Agente de CÃ³digo VFP** (`Organic.BusinessLogic/AGENTS.md`): Desarrollo y refactoring de cÃ³digo Visual FoxPro
- **Agente de Testing** (`Organic.Tests/AGENTS.md`): Pruebas unitarias y funcionales
- **Agente de GeneraciÃ³n** (`Organic.Generated/AGENTS.md`): CÃ³digo generado automÃ¡ticamente

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
@workspace Usando el agente arquitecto, Â¿cÃ³mo agrego un nuevo proyecto a esta soluciÃ³n?
```

O simplemente trabaja en archivos de la raÃ­z (.vfpsln, azure-pipelines.yml) y Copilot usarÃ¡ automÃ¡ticamente este contexto.
