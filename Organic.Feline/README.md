# 🐆 Organic.Feline - Aplicación Empresarial Visual FoxPro 9

[![Build Status](https://dev.azure.com/zoologicnet/Organic/_apis/build/status/Organic.Feline-CI?branchName=main)](https://dev.azure.com/zoologicnet/Organic/_build/latest?definitionId=123&branchName=main)
[![DOVFP Version](https://img.shields.io/badge/DOVFP-2.5.0-blue)](https://dev.azure.com/zoologicnet/_packaging?_a=package&feed=doVFP&package=dovfp&protocolType=NuGet)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

> Solución empresarial moderna desarrollada en Visual FoxPro 9, compilada con DOVFP y gestionada con VS Code + GitHub Copilot.

---

## 📋 Tabla de contenidos

- [Características principales](#-características-principales)
- [Arquitectura del proyecto](#-arquitectura-del-proyecto)
- [Requisitos previos](#-requisitos-previos)
- [Instalación y configuración](#-instalación-y-configuración)
- [Compilación y ejecución](#-compilación-y-ejecución)
- [Debugging en VS Code](#-debugging-en-vs-code)
- [Testing](#-testing)
- [Trabajo con GitHub Copilot](#-trabajo-con-github-copilot)
- [CI/CD con Azure Pipelines](#-cicd-con-azure-pipelines)
- [Estructura de carpetas](#-estructura-de-carpetas)
- [Contribuir al proyecto](#-contribuir-al-proyecto)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Características principales

- **🏢 ERP Empresarial completo**: Gestión de clientes, facturación, inventario, contabilidad
- **💻 Desarrollo moderno**: VS Code como IDE principal con extensión Zoo Tool Kit
- **🔨 Compilación moderna**: DOVFP (compilador .NET para VFP) integrado con CI/CD
- **🤖 AI-Powered**: GitHub Copilot con prompts especializados para VFP
- **🧪 Testing robusto**: Suite de tests unitarios y de integración
- **📊 SQL Server**: Integración completa con backend SQL Server
- **🔄 CI/CD**: Azure Pipelines para builds automatizados y despliegues

---

## 🏗️ Arquitectura del proyecto

```
Organic.Feline/
├── Organic.BusinessLogic/    # Lógica de negocio principal
│   └── CENTRALSS/
│       ├── main2028.prg      # Punto de entrada de la aplicación
│       ├── _Nucleo/          # Clases core (repositories, services)
│       ├── _Dibujante/       # Componentes UI
│       ├── _Taspein/         # Módulos de dominio específico
│       └── Felino/           # Lógica del módulo Felino
│
├── Organic.Generated/         # Código generado automáticamente
│   ├── generados/            # ⚠️ NO EDITAR - Auto-generado
│   └── ADN/                  # Estructuras de datos normalizadas
│
├── Organic.Tests/            # Suite de pruebas
│   ├── Tests/UnitTests/      # Tests unitarios
│   ├── Tests/IntegrationTests/  # Tests de integración
│   └── Tests/FunctionalTests/   # Tests funcionales
│
├── .github/                  # GitHub config y prompts Copilot
│   ├── AGENTS.md             # Agente principal de arquitectura
│   ├── copilot-instructions.md  # Instrucciones para Copilot
│   └── prompts/              # Prompts especializados AI
│
└── README.md                 # Este archivo (incluye Quick Start)
```

### Proyectos de la solución

| Proyecto | Propósito | Output |
|----------|-----------|--------|
| **Organic.BusinessLogic** | Lógica de negocio y UI | `Organic.Feline.exe` |
| **Organic.Generated** | Código generado de estructuras ADN | `Organic.Generated.dll` |
| **Organic.Tests** | Suite de pruebas | Ejecutables de test |

---

## 📦 Requisitos previos

### Software requerido

| Componente | Versión | Descarga/Instalación |
|------------|---------|----------------------|
| **Windows** | 10/11 | Sistema operativo base |
| **Visual FoxPro 9** | SP2 | Runtime necesario para ejecución |
| **.NET SDK** | 6.0+ | [Descargar](https://dotnet.microsoft.com/download) |
| **DOVFP** | 2.5.0+ | `dotnet tool install --global dovfp` |
| **VS Code** | Latest | [Descargar](https://code.visualstudio.com/) |
| **Azure CLI** | Latest | [Descargar](https://learn.microsoft.com/cli/azure/install-azure-cli) |
| **SQL Server** | 2016+ | Base de datos backend |

### Extensiones de VS Code recomendadas

- **Zoo Tool Kit** (ZooLogicSA.zoo-tool-kit) - Esencial para VFP
- **GitHub Copilot** (GitHub.copilot) - Asistente AI
- **PowerShell** (ms-vscode.PowerShell) - Para scripts de automatización
- **Azure Pipelines** (ms-azure-devops.azure-pipelines) - CI/CD integration

```bash
# Instalar todas las extensiones recomendadas
code --install-extension ZooLogicSA.zoo-tool-kit
code --install-extension GitHub.copilot
code --install-extension ms-vscode.PowerShell
code --install-extension ms-azure-devops.azure-pipelines
```

---

## 🚀 Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://dev.azure.com/zoologicnet/Organic/_git/Organic.Feline
cd Organic.Feline
```

### 2. Instalar DOVFP

```powershell
# Configurar autenticación Azure DevOps
az login

# Instalar DOVFP desde feed privado
dotnet tool install --global dovfp --add-source https://pkgs.dev.azure.com/zoologicnet/_packaging/doVFP/nuget/v3/index.json

# Verificar instalación
dovfp --version
# Output esperado: dovfp version 2.5.0+
```

### 3. Configurar VS Code

1. Abrir la carpeta del proyecto en VS Code:
   ```bash
   code .
   ```

2. Confiar en el workspace cuando VS Code lo solicite

3. Configurar rutas en `.vscode/settings.json` (si es necesario):
   ```json
   {
       "zoo-tool-kit.dovfpPath": "C:\\Users\\[TU_USUARIO]\\.dotnet\\tools\\dovfp.exe",
       "zoo-tool-kit.vfpPath": "C:\\Program Files\\Microsoft Visual FoxPro 9\\VFP9.EXE"
   }
   ```

### 4. Configurar base de datos

```sql
-- Crear base de datos
CREATE DATABASE OrganicFeline;

-- Ejecutar scripts de inicialización
-- (ubicados en scripts/database/init/)
```

Actualizar connection string en configuración:
```
Server=localhost;Database=OrganicFeline;Integrated Security=true;
```

---

## 🔨 Compilación y ejecución

### Compilar la solución completa

```powershell
# Build de desarrollo (Debug)
dovfp build Organic.Feline.vfpsln

# Build de producción (Release)
dovfp build Organic.Feline.vfpsln --configuration Release

# Rebuild (clean + build)
dovfp rebuild Organic.Feline.vfpsln
```

### Compilar proyecto individual

```powershell
# Solo lógica de negocio
dovfp build Organic.BusinessLogic/Organic.Feline.vfpproj

# Solo código generado
dovfp build Organic.Generated/Organic.Feline.Generated.vfpproj
```

### Ejecutar la aplicación

```powershell
# Desde línea de comandos
dovfp run -template 1 Organic.BusinessLogic/CENTRALSS/main2028.prg

# O ejecutar el EXE compilado
.\Organic.BusinessLogic\bin\App\Organic.Feline.exe
```

### Desde VS Code

1. Presionar **F5** para debugging
2. O usar Command Palette: **Tasks: Run Build Task**

---

## 🐛 Debugging en VS Code

### Configuración de breakpoints

1. **Establecer breakpoints** en archivos `.prg` (click en margen izquierdo)
2. Los breakpoints se exportan automáticamente a formato VFP
3. **F5** para iniciar debugging con breakpoints activos

### Debugging con DOVFP

```json
// .vscode/launch.json
{
    "name": "Run Visual FoxPro",
    "type": "node",
    "request": "launch",
    "program": "dovfp",
    "args": [
        "run",
        "-template", "1",
        "${file}"
    ],
    "preLaunchTask": "Export VFP Breakpoints"
}
```

### Inspeccionar variables

Durante debugging:
- **Hover** sobre variables para ver valores
- **Debug Console** para evaluar expresiones VFP
- **Call Stack** para ver jerarquía de llamadas

### Archivos de log

```
C:\Users\[USUARIO]\AppData\Roaming\Microsoft\Visual FoxPro 9\
├── vsc_breakpoints.json   # Breakpoints exportados
├── error_log.txt          # Log de errores
└── debug_output.txt       # Output de debugging
```

---

## 🧪 Testing

### Ejecutar suite completa de tests

```powershell
# Todos los tests
dovfp test Organic.Tests/Organic.Tests.vfpproj

# Solo tests unitarios
dovfp test Organic.Tests/Organic.Tests.vfpproj --filter "UnitTests*"

# Con cobertura de código
dovfp test Organic.Tests/Organic.Tests.vfpproj --collect:"Code Coverage"
```

### Escribir nuevos tests

```foxpro
*-- Test_MiClase.prg
DEFINE CLASS Test_MiClase AS TestCase
    
    oClaseATestear = .NULL.
    
    *-- Setup: Antes de cada test
    PROCEDURE Setup
        THIS.oClaseATestear = CREATEOBJECT("MiClase")
    ENDPROC
    
    *-- Test individual
    PROCEDURE Test_MetodoCalcular_ConValorPositivo_RetornaCorrecto
        *-- Arrange
        LOCAL lnEntrada, lnEsperado, lnResultado
        lnEntrada = 100
        lnEsperado = 200
        
        *-- Act
        lnResultado = THIS.oClaseATestear.Calcular(lnEntrada)
        
        *-- Assert
        THIS.AssertEquals(lnEsperado, lnResultado, "Cálculo incorrecto")
    ENDPROC
    
    *-- Teardown: Después de cada test
    PROCEDURE Teardown
        RELEASE THIS.oClaseATestear
    ENDPROC
    
ENDDEFINE
```

### Ver resultados de tests

```powershell
# Tests con output detallado
dovfp test Organic.Tests/Organic.Tests.vfpproj --verbosity detailed

# Generar reporte HTML
dovfp test --logger "html;LogFileName=test-results.html"
```

---

## 🤖 Trabajo con GitHub Copilot

### Agentes especializados disponibles

El proyecto incluye **agentes AGENTS.md** con contexto especializado:

| Agente | Ubicación | Uso |
|--------|-----------|-----|
| 🏗️ Arquitectura | `.github/AGENTS.md` | Compilación, CI/CD, estructura |
| 💼 VFP Development | `Organic.BusinessLogic/AGENTS.md` | Código VFP, patrones, SQL |
| ⚙️ Code Generation | `Organic.Generated/AGENTS.md` | Scripts de generación |
| 🧪 Testing | `Organic.Tests/AGENTS.md` | Tests, mocks, fixtures |

### Prompts especializados

```
📁 .github/prompts/
├── auditoria/
│   ├── code-audit-comprehensive.prompt.md    # Auditoría de calidad
│   └── test-audit.prompt.md                  # Auditoría de tests
├── dev/
│   ├── vfp-development-expert.prompt.md      # Desarrollo VFP avanzado
│   └── dovfp-build-integration.prompt.md     # Build y CI/CD
└── refactor/
    └── refactor-patterns.prompt.md           # Refactorización segura
```

### Ejemplos de uso

```
# En Copilot Chat:

"Usa el prompt de auditoría para analizar FacturaManager.prg"

"Con el prompt de experto VFP, implementa un repository para Cliente"

"Refactoriza este método usando el prompt de refactoring"

"@workspace analiza todos los archivos en CENTRALSS/_Nucleo/"
```

---

## 🔄 CI/CD con Azure Pipelines

### Pipeline de build

```yaml
# azure-pipelines.yml
trigger:
  - main
  - develop

pool:
  vmImage: 'windows-latest'

steps:
  - task: DotNetCoreCLI@2
    displayName: 'Install DOVFP'
    inputs:
      command: 'custom'
      custom: 'tool'
      arguments: 'install --global dovfp'

  - task: PowerShell@2
    displayName: 'Build Solution'
    inputs:
      script: 'dovfp build Organic.Feline.vfpsln --configuration Release'

  - task: PowerShell@2
    displayName: 'Run Tests'
    inputs:
      script: 'dovfp test Organic.Tests/Organic.Tests.vfpproj'

  - task: PublishBuildArtifacts@1
    inputs:
      PathtoPublish: 'Organic.BusinessLogic/bin/App'
      ArtifactName: 'organic-feline-release'
```

### Ver estado del pipeline

```bash
# Azure CLI
az pipelines show --name "Organic.Feline-CI" --organization https://dev.azure.com/zoologicnet

# O visitar
https://dev.azure.com/zoologicnet/Organic/_build
```

---

## 📂 Estructura de carpetas detallada

```
Organic.Feline/
│
├── .github/                              # GitHub configuration
│   ├── AGENTS.md                        # Main architecture agent
│   ├── copilot-instructions.md          # Copilot configuration
│   ├── prompts/                         # Specialized AI prompts
│   │   ├── auditoria/                   # Code audit prompts
│   │   ├── dev/                         # Development prompts
│   │   ├── refactor/                    # Refactoring prompts
│   │   └── test/                        # Testing prompts
│   └── instructions/                    # Additional instructions
│
├── .vscode/                             # VS Code workspace config
│   ├── launch.json                      # Debug configurations
│   ├── tasks.json                       # Build tasks
│   ├── settings.json                    # Workspace settings
│   └── VFP-DEBUGGING.md                 # Debugging guide
│
├── Organic.BusinessLogic/               # Main business logic
│   ├── AGENTS.md                        # VFP development agent
│   ├── CENTRALSS/                       # Core application module
│   │   ├── main2028.prg                # Main entry point
│   │   ├── _Dibujante/                 # UI components and forms
│   │   ├── _Nucleo/                    # Core classes (base, utils)
│   │   ├── _Taspein/                   # Domain-specific module
│   │   ├── Felino/                     # Felino business module
│   │   └── Imagenes/                   # Image resources
│   ├── bin/App/                        # Compiled binaries
│   ├── obj/App/                        # Intermediate build objects
│   ├── packages/App/                   # Package dependencies
│   └── Organic.Feline.vfpproj          # DOVFP project file
│
├── Organic.Generated/                   # Auto-generated code
│   ├── AGENTS.md                        # Code generation agent
│   ├── generados/                       # ⚠️ AUTO-GENERATED - DO NOT EDIT
│   │   ├── *.szl                       # Serialized tables
│   │   ├── *.sdb                       # Serialized databases
│   │   └── *.xml                       # Combo definitions
│   ├── ADN/                            # ADN data structures
│   │   ├── DBCSerializado/             # Serialized DBC files
│   │   └── IndiceAdn/                  # ADN indexes
│   ├── Update-EstructuraAdnPrg.ps1     # ADN to PRG generator
│   ├── Update-TransferenciaVersions.ps1 # Version sync script
│   ├── Validate-VersionsPostBuild.ps1  # Post-build validation
│   ├── bin/PRG/                        # Compiled generated code
│   └── Organic.Feline.Generated.vfpproj
│
├── Organic.Tests/                       # Test suite
│   ├── AGENTS.md                        # Testing agent
│   ├── main.prg                         # Test runner entry point
│   ├── Tests/                           # Organized test suites
│   │   ├── UnitTests/                  # Unit tests
│   │   ├── IntegrationTests/           # Integration tests
│   │   └── FunctionalTests/            # Functional/E2E tests
│   ├── clasesdeprueba/                 # Test helper classes
│   ├── ClasesMock.dbf                  # Mock classes table
│   ├── clasesproxy.DBF                 # Proxy classes for testing
│   ├── _dovfp_excluidos/               # Excluded from compilation
│   └── Organic.Tests.vfpproj           # Test project file
│
├── .github/                             # GitHub configuration
│   ├── AGENTS.md                        # Main architecture agent
│   ├── copilot-instructions.md          # GitHub Copilot instructions
│   └── prompts/                         # Specialized AI prompts
│       ├── auditoria/                   # Audit prompts
│       ├── dev/                         # Development prompts
│       └── refactor/                    # Refactoring prompts
│
├── scripts/                             # Automation scripts
│   ├── database/                        # Database scripts
│   └── deployment/                      # Deployment scripts
│
├── Organic.Feline.vfpsln               # Main solution file
├── azure-pipelines.yml                 # CI/CD pipeline definition
├── Nuget.config                        # NuGet feed configuration
├── README.md                           # This file (includes Quick Start)
├── CHANGELOG.md                        # Version history
├── LICENSE                             # License information
└── .gitignore                          # Git ignore rules
```

---

## 🤝 Contribuir al proyecto

### Workflow de desarrollo

1. **Crear branch de feature**
   ```bash
   git checkout -b feature/mi-nueva-funcionalidad
   ```

2. **Desarrollar con calidad**
   - Seguir convenciones VFP (ver `.github/copilot-instructions.md`)
   - Escribir tests para nuevo código
   - Documentar funciones complejas

3. **Validar localmente**
   ```powershell
   # Build
   dovfp build Organic.Feline.vfpsln
   
   # Tests
   dovfp test Organic.Tests/Organic.Tests.vfpproj
   ```

4. **Commit y push**
   ```bash
   git add .
   git commit -m "feat: descripción del cambio"
   git push origin feature/mi-nueva-funcionalidad
   ```

5. **Crear Pull Request**
   - Asignar reviewers
   - Esperar validación de CI/CD
   - Mergear después de aprobación

### Convenciones de commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: nueva funcionalidad
fix: corrección de bug
docs: cambios en documentación
refactor: refactorización sin cambio de funcionalidad
test: agregar o modificar tests
chore: tareas de mantenimiento
```

---

## 🔧 Troubleshooting

### Error: "dovfp: command not found"

**Solución**:
```powershell
# Verificar instalación
dotnet tool list --global

# Reinstalar si es necesario
dotnet tool uninstall --global dovfp
dotnet tool install --global dovfp --add-source https://pkgs.dev.azure.com/zoologicnet/_packaging/doVFP/nuget/v3/index.json
```

### Error de autenticación con Azure DevOps

**Solución**:
```powershell
# Re-autenticar
az login

# O usar Personal Access Token
$env:AZURE_DEVOPS_EXT_PAT = "tu-pat-aqui"
```

### Build falla con "Project file corrupted"

**Solución**:
```powershell
# Validar XML del proyecto
Get-Content Organic.BusinessLogic/Organic.Feline.vfpproj

# Regenerar si es necesario
dovfp init Organic.BusinessLogic --name Organic.Feline
```

### Tests fallan en CI pero pasan localmente

**Posibles causas**:
- Diferencias de paths (usar rutas relativas)
- Base de datos no inicializada en CI
- Dependencias de archivos locales

**Solución**: Revisar logs de Azure Pipelines para detalles específicos.

---

## 📞 Soporte y contacto

- **Issues**: [Azure DevOps Boards](https://dev.azure.com/zoologicnet/Organic/_boards)
- **Wiki**: [Documentación interna](https://dev.azure.com/zoologicnet/Organic/_wiki)
- **Email**: desarrollo@zoologicsa.com.ar

---

## 📄 Licencia

Copyright © 2025 ZooLogicSA. Todos los derechos reservados.

Este es un proyecto propietario. Ver [LICENSE](LICENSE) para más información.

---

## 🏆 Créditos

Desarrollado con ❤️ por el equipo de **ZooLogicSA**.

**Stack tecnológico**:
- Visual FoxPro 9 SP2
- DOVFP (Compiler)
- VS Code + Zoo Tool Kit Extension
- GitHub Copilot
- Azure DevOps
- SQL Server

---

**🚀 Happy coding with VFP + AI!**
