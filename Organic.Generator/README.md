#  Organic.Generator

> **Sistema de generación dinámica de código Visual FoxPro 9**  
> Desarrollo modernizado con VS Code, DOVFP y GitHub Copilot

---

##  Descripción

**Organic.Generator** es una solución completa para la generación automática de código Visual FoxPro 9, incluyendo:

-  **Generadores dinámicos de ABM** (Alta, Baja, Modificación)
-  **Generación de combos y menús** personalizados
-  **Arquitectura basada en ADN** de estructuras de datos
-  **Compilación moderna** con DOVFP desde VS Code
-  **Testing automatizado** y CI/CD con Azure Pipelines
-  **Integración con GitHub Copilot** para desarrollo asistido por IA

---

##  Estructura del Proyecto

```
Organic.Generator/
 .github/                          # Configuración GitHub y prompts
    AGENTS.md                     # Agente principal de arquitectura
    debugging.md                  # Guía de debugging VFP
    prompts/                      # Prompts especializados
       auditoria/                # Auditoría de código
       dev/                      # Desarrollo VFP
       refactor/                 # Refactorización
       test/                     # Testing
    instructions/                 # Instrucciones para Copilot

 Organic.BusinessLogic/            # Lógica de negocio y generadores
    AGENTS.md                     # Agente especializado en VFP
    CENTRALSS/                    # Código fuente principal
    packages/                     # Dependencias

 Organic.Generated/                # Código generado automáticamente
    Generados/                    # PRG, XML, combos generados
    ADN/                          # ADN de estructuras

 Organic.Tests/                    # Testing y validación
    AGENTS.md                     # Agente de testing
    Tests/                        # Test suites

 .vscode/                          # Configuración VS Code
    launch.json                   # Debug configuration
    tasks.json                    # Build/Run/Test tasks

 azure-pipelines.yml               # CI/CD pipeline
 Organic.Generator.vfpsln          # Solución VFP
```

---

##  Quick Start

### Prerrequisitos

- Visual Studio Code 1.85+
- Visual FoxPro 9 instalado
- .NET SDK 6.0+ (para DOVFP)
- DOVFP compiler

### Instalar DOVFP

```powershell
dotnet tool install --global dovfp --add-source ./nupkg
dovfp --version
```

### Compilar

```powershell
# Build completo
dovfp build Organic.Generator.vfpsln

# Ejecutar tests
dovfp test Organic.Tests/main.prg
```

### Depurar en VS Code

1. Abre un archivo `.prg`
2. Establece breakpoints (F9)
3. Presiona F5

Ver: [.github/debugging.md](.github/debugging.md)

---

##  GitHub Copilot Integration

### Agentes Especializados

| Agente | Ubicación | Propósito |
|--------|-----------|-----------|
| **Arquitecto** | `.github/AGENTS.md` | Build, CI/CD, arquitectura |
| **VFP Developer** | `Organic.BusinessLogic/AGENTS.md` | Generadores y lógica VFP |
| **Testing** | `Organic.Tests/AGENTS.md` | Tests y QA |

### Prompts Disponibles

```
# Auditoría de código
@workspace /ask using #file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md

# Desarrollo VFP
@workspace /ask using #file:.github/prompts/dev/vfp-development-expert.prompt.md

# Refactorización
@workspace /ask using #file:.github/prompts/refactor/refactor-patterns.prompt.md

# Testing
@workspace /ask using #file:.github/prompts/test/test-audit.prompt.md

# DOVFP Build
@workspace /ask using #file:.github/prompts/dev/dovfp-build-integration.prompt.md
```

---

##  Documentación

- [Agente Principal](.github/AGENTS.md)
- [VFP Debugging](.github/debugging.md)
- [Business Logic Agent](Organic.BusinessLogic/AGENTS.md)
- [Testing Agent](Organic.Tests/AGENTS.md)
- [Azure Pipeline](azure-pipelines.yml)

---

##  Contribuir

1. Branch desde `develop`
2. Implementar cambios
3. Agregar tests
4. Ejecutar `dovfp test`
5. Pull Request

Ver convenciones: [Organic.BusinessLogic/AGENTS.md](Organic.BusinessLogic/AGENTS.md#conventions--standards)

---

##  Licencia

Copyright  2025 ZooLogic SA

---

**¿Preguntas?** Consulta los [agentes](.github/AGENTS.md) o usa los [prompts](.github/prompts/) con Copilot.
