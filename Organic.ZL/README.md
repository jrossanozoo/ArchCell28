# Organic.ZL - Solución Empresarial Visual FoxPro 9

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![DOVFP](https://img.shields.io/badge/DOVFP-2.5.0-blue)]()
[![VFP](https://img.shields.io/badge/Visual_FoxPro-9.0-orange)]()
[![VS Code](https://img.shields.io/badge/VS_Code-Latest-blue)]()

Solución empresarial Visual FoxPro 9 modernizada con compilación DOVFP, testing automatizado y desarrollo asistido por IA.

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Inicio Rápido](#-inicio-rápido)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Desarrollo](#-desarrollo)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Documentación](#-documentación)
- [Contribución](#-contribución)

---

## ✨ Características

- ✅ **Compilación Moderna**: DOVFP desde VS Code y pipelines CI/CD
- ✅ **Código Generado**: Sistema ADN para forms y entidades
- ✅ **Testing Automatizado**: Suite de pruebas unitarias y funcionales
- ✅ **IA-Assisted Development**: GitHub Copilot con prompts especializados
- ✅ **Debugging Integrado**: Breakpoints de VS Code en código VFP
- ✅ **Arquitectura Modular**: Separación clara de responsabilidades

---

## 🚀 Inicio Rápido

### Prerrequisitos

```powershell
# .NET SDK 6.0+
dotnet --version

# Visual Studio Code
code --version

# Git
git --version
```

### Instalación

```powershell
# 1. Clonar repositorio
git clone https://tu-org.visualstudio.com/_git/Organic.ZL
cd Organic.ZL

# 2. Instalar DOVFP
dotnet tool install --global dovfp --version 2.5.0 `
    --add-source https://pkgs.dev.azure.com/zoologicnet/_packaging/doVFP/nuget/v3/index.json

# 3. Compilar solución
dovfp build Organic.ZL.vfpsln

# 4. Ejecutar aplicación
dovfp run -template 1 Organic.BusinessLogic\CENTRALSS\main2028.PRG
```

### Desarrollo en VS Code

```powershell
# Abrir proyecto
code .

# Compilar: Ctrl+Shift+B
# Ejecutar: F5
# Tests: Ctrl+Shift+T (custom)
```

---

## 📁 Estructura del Proyecto

```
Organic.ZL/
├── 📘 Organic.BusinessLogic/    # Lógica de negocio principal
│   ├── CENTRALSS/
│   │   ├── main2028.PRG         # Punto de entrada
│   │   ├── _Nucleo/             # Framework core
│   │   ├── _Taspein/            # Módulos de negocio
│   │   └── Zl/                  # Componentes ZooLogic
│   └── AGENTS.md                # Agente de código VFP
│
├── 🤖 Organic.Generated/         # Código autogenerado (NO MODIFICAR)
│   ├── Generados/               # Forms y datos generados
│   ├── ADN/                     # Esquemas serializados
│   ├── *.ps1                    # Scripts de generación
│   └── AGENTS.md                # Agente de código generado
│
├── 🧪 Organic.Tests/            # Suite de pruebas
│   ├── Tests/                   # Casos de prueba
│   ├── main.prg                 # Test runner
│   └── AGENTS.md                # Agente de testing
│
├── 📦 Organic.Assets/           # Configuración y assets
│   ├── Config.ini
│   └── *.fll                    # Bibliotecas externas
│
├── 🤖 .github/                  # Configuración + Prompts
│   ├── AGENTS.md                # Agente principal
│   ├── prompts/                 # Prompts para Copilot
│   │   ├── auditoria/
│   │   ├── dev/
│   │   ├── refactor/
│   │   └── test/
│   └── instructions/            # Instrucciones de desarrollo
│
└── Organic.ZL.vfpsln            # Solución principal
```

---

## 🏛️ Arquitectura

### Visión General

```
┌──────────────────────────────────────────────────────────┐
│                    Organic.ZL Solution                    │
└──────────────────────────────────────────────────────────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
    ┌───────▼───────┐ ┌───▼────────┐ ┌──▼────────┐
    │ Business      │ │ Generated  │ │   Tests   │
    │ Logic         │ │ Code       │ │           │
    └───────┬───────┘ └────────────┘ └───────────┘
            │
    ┌───────▼───────┐
    │    Assets     │
    │ (Config, DLLs)│
    └───────────────┘
```

### Proyectos y Responsabilidades

#### 📘 Organic.BusinessLogic

**Propósito**: Lógica de negocio principal del sistema

**Responsabilidades**:
- Lógica de negocio domain-specific
- Casos de uso y workflows
- Acceso a datos y persistencia
- Validaciones de negocio
- Integración con servicios externos

**Output**: `bin/Exe/Organic.ZL.exe`

#### 🤖 Organic.Generated

**Propósito**: Código autogenerado por sistema ADN

⚠️ **CRÍTICO**: TODO el código es generado automáticamente. **NO MODIFICAR MANUALMENTE**.

**Flujo de generación**:
1. Definiciones XML/DBC
2. Ejecutar `Update-EstructuraAdnPrg.ps1`
3. Código PRG generado en `Generados/`
4. DOVFP compila a `bin/PRG/*.fxp`

**Output**: `bin/PRG/*.fxp`

#### 🧪 Organic.Tests

**Propósito**: Suite de pruebas unitarias y funcionales

**Cobertura objetivo**:
- Business Logic: > 80%
- Código crítico: > 90%
- Global: > 70%

#### 📦 Organic.Assets

**Propósito**: Configuración y runtime assets (Config.ini, *.fll, Videos)

### Orden de Compilación

1. `Organic.Generated` (sin dependencias)
2. `Organic.BusinessLogic` (depende de Generated)
3. `Organic.Tests` (depende de ambos)

### Patrones Arquitectónicos

**Separación de responsabilidades**:
- **Presentation**: Forms y UI
- **Business Logic**: Clases de negocio
- **Data Access**: Repositorios en `_Nucleo/`
- **Configuration**: Assets externos

**Reglas de acoplamiento**:
- ✅ BusinessLogic → Generated (permitido)
- ❌ Generated → BusinessLogic (prohibido)
- ✅ Tests → Ambos (permitido)

---

## 💻 Desarrollo

### Compilar

```powershell
# Solución completa
dovfp build Organic.ZL.vfpsln

# Solo un proyecto
dovfp build Organic.BusinessLogic\Organic.ZL.vfpproj

# Clean + Rebuild
dovfp rebuild Organic.ZL.vfpsln
```

### Debugging

1. Colocar breakpoints en VS Code (F9)
2. `Ctrl+Shift+P` → "Export VFP Breakpoints"
3. Presionar F5 para debug

### Regenerar Código Autogenerado

```powershell
# Regenerar estructura ADN
.\Organic.Generated\Update-EstructuraAdnPrg.ps1

# Validar integridad
.\Organic.Generated\Validate-VersionsPostBuild.ps1
```

### Usando GitHub Copilot

```
@workspace Auditoría de código VFP en módulo CENTRALSS/_Nucleo

@workspace Refactoriza este procedimiento siguiendo mejores prácticas

@workspace Crea tests unitarios para ClienteBusiness.prg
```

**Prompts disponibles**:
- `.github/prompts/auditoria/code-audit-comprehensive.prompt.md`
- `.github/prompts/dev/vfp-development-expert.prompt.md`
- `.github/prompts/refactor/refactor-patterns.prompt.md`
- `.github/prompts/test/test-audit.prompt.md`

---

## 🧪 Testing

### Ejecutar Tests

```powershell
# Suite completa
dovfp run -template 1 Organic.Tests\main.prg

# Desde VS Code
# Ctrl+Shift+P → "Run Tests"
```

### Cobertura Objetivo

- Business Logic: > 80%
- Código crítico: > 90%
- Global: > 70%

---

## 🚀 Deployment

### Pipeline de Azure DevOps

El archivo `azure-pipelines.yml` configura CI/CD automático:

1. **Build**: Compilación con DOVFP
2. **Test**: Ejecución de suite de tests
3. **Publish**: Publicación de artefactos

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'windows-latest'

steps:
  - script: dovfp build Organic.ZL.vfpsln
    displayName: 'Build Solution'
```

---

## 📚 Documentación

### Instrucciones de Desarrollo

- **[vfp-coding-standards.instructions.md](.github/instructions/vfp-coding-standards.instructions.md)** - Estándares de codificación VFP obligatorios
- **[dovfp-build.instructions.md](.github/instructions/dovfp-build.instructions.md)** - Compilación y debugging con DOVFP

### Sistema de Agentes y Prompts

- **[AGENTS.md](.github/AGENTS.md)** - Agente principal (arquitectura y delegación)
- **Agentes especializados**: Ver AGENTS.md en cada carpeta de proyecto
- **[Prompts](.github/prompts/)** - Prompts especializados para GitHub Copilot
  - `auditoria/` - Auditoría de código y calidad
  - `dev/` - Desarrollo VFP y integración DOVFP
  - `refactor/` - Patrones de refactoring
  - `test/` - Testing y cobertura

---

## 🤝 Contribución

### Estándares de Código

- **Naming**: Hungarian notation (lcVar, lnNum, llFlag)
- **Error Handling**: Siempre usar TRY...CATCH
- **SQL vs SCAN**: Preferir SQL SELECT
- **Documentación**: Headers obligatorios en todos los procedimientos

Ver [`.github/instructions/vfp-coding-standards.instructions.md`](.github/instructions/vfp-coding-standards.instructions.md)

### Workflow

```
1. Crear feature branch
2. Desarrollar con asistencia de Copilot
3. Compilar y testear localmente
4. Commit con mensajes descriptivos
5. Push y crear Pull Request
6. CI/CD ejecuta build y tests automáticamente
7. Code review
8. Merge a main
```

### Agentes Especializados

Consultar `AGENTS.md` en cada carpeta para ayuda especializada:

- `.github/AGENTS.md` - Arquitectura y compilación
- `Organic.BusinessLogic/AGENTS.md` - Desarrollo VFP
- `Organic.Generated/AGENTS.md` - Código generado
- `Organic.Tests/AGENTS.md` - Testing

---

## 📞 Soporte

- **Documentación**: Revisar `docs/`
- **Issues**: Azure DevOps Boards
- **GitHub Copilot**: `@workspace` con tu pregunta
- **Agentes**: Consultar AGENTS.md relevante

---

## 📄 Licencia

Copyright © 2025 ZooLogic SA. Todos los derechos reservados.

---

## 🎯 Versión Actual

**Versión**: 1.0.0  
**DOVFP**: 2.5.0  
**Visual FoxPro**: 9.0  
**Última actualización**: 2025-10-15

---

**¿Nuevo en el proyecto?** Revisa la sección [🚀 Inicio Rápido](#-inicio-rápido) arriba.

**¿Quieres entender la arquitectura?** Ve la sección [🏛️ Arquitectura](#️-arquitectura) completa.