# 🌿 Organic.Core - Visual FoxPro Enterprise Solution

> Modern DevOps practices for Visual FoxPro 9 development using Visual Studio Code, GitHub Copilot, and DOVFP compiler

[![Build Status](https://dev.azure.com/zoologicsa/Organic/_apis/build/status/organic-core)](https://dev.azure.com/zoologicsa/Organic/_build)
[![VFP Version](https://img.shields.io/badge/Visual%20FoxPro-9.0%20SP2-blue)](https://www.microsoft.com/vfp)
[![.NET](https://img.shields.io/badge/.NET-6.0-purple)](https://dotnet.microsoft.com/)

## 📖 Overview

Organic.Core is a modernized Visual FoxPro enterprise solution featuring:

- ✅ **Modular Architecture**: Three specialized projects (BusinessLogic, Generated, Tests)
- 🔨 **Modern Build System**: DOVFP compiler with MSBuild integration
- 🤖 **AI-Enhanced Development**: GitHub Copilot agents and prompts
- 🧪 **Test-Driven**: Unit testing framework for VFP
- 🔗 **.NET Interop**: wwDotNetBridge for modern capabilities
- 🚀 **CI/CD Ready**: Azure DevOps pipelines

## 🏗️ Project Structure

```
Organic.Core/
├── .github/                        # Copilot agents, prompts, instructions
│   ├── AGENTS.md                  # Main architecture agent
│   ├── prompts/
│   │   ├── auditoria/             # Code audit prompts
│   │   ├── dev/                   # Development prompts
│   │   ├── refactor/              # Refactoring patterns
│   │   └── test/                  # Testing prompts
│   └── instructions/              # Copilot instructions
├── .github/                          # Technical documentation
│   ├── INDEX.md                   # Documentation hub
│   ├── BUILD.md                   # Build system guide (DOVFP, PowerShell, versions)
│   ├── quick-start.md             # Getting started guide
│   ├── vfp-standards.md           # Coding standards
│   ├── troubleshooting.md         # Common issues
│   └── wwdotnetbridge-guide.md    # .NET interop
├── Organic.BusinessLogic/         # Core business logic
│   └── CENTRALSS/
│       ├── Nucleo/                # Framework classes
│       ├── AGENTS.md              # Source code agent
│       └── ...
├── Organic.Generated/             # Auto-generated classes
│   ├── Generados/                 # Generated .prg files
│   ├── ADN/                       # Metadata sources
│   ├── AGENTS.md                  # Code generation agent
│   └── *.ps1                      # Build scripts
└── Organic.Tests/                 # Unit tests
    ├── Tests/                     # Test cases
    ├── Mocks/                     # Mock objects
    └── AGENTS.md                  # Testing agent
```

## 🚀 Quick Start

### Prerequisites

- [Visual Studio Code](https://code.visualstudio.com/)
- Custom VFP Extension for VS Code
- [DOVFP Compiler](https://github.com/your-repo/dovfp)
- Visual FoxPro 9.0 SP2 runtime
- .NET Framework 4.8
- Git

### Setup

```bash
# 1. Clone repository
git clone https://dev.azure.com/zoologicsa/Organic/_git/Organic.Core
cd Organic.Core

# 2. Open in VS Code
code Organic.Core.code-workspace

# 3. Restore dependencies (if using NuGet)
dotnet restore

# 4. Build solution
dovfp build -build_debug 2

# 5. Run tests
dovfp test
```

### Your First Build

```powershell
# Debug build with verbose output
dovfp build -build_debug 2

# Expected output:
# (\) Dependencias resueltas. Orden: Organic.Core.Generated → Organic.Core → Organic.Tests
# Organic.Core.Generated Build
# (-)
# build Command completed successfully in 32,27 sec.
```

## 🤖 Using GitHub Copilot Agents

This solution includes specialized AI agents for different development tasks:

### Main Agent (`.github/AGENTS.md`)
For architecture, build, and solution-wide concerns:
```
@workspace /explain the build pipeline
@workspace /audit Check for architectural issues
```

### Source Code Agent (`Organic.BusinessLogic/CENTRALSS/AGENTS.md`)
For VFP development questions:
```
@workspace How do I create a new business class?
@workspace Explain DataSession management
```

### Testing Agent (`Organic.Tests/AGENTS.md`)
For test development:
```
@workspace How do I write a unit test?
@workspace Create mock for database access
```

### Using Prompts

Located in `.github/prompts/`:

```bash
# Code audit
@workspace #file:.github/prompts/auditoria/code-audit-comprehensive.prompt.md

# VFP development help
@workspace #file:.github/prompts/dev/vfp-development-expert.prompt.md

# Build troubleshooting
@workspace #file:.github/prompts/dev/dovfp-build-integration.prompt.md

# Refactoring guidance
@workspace #file:.github/prompts/refactor/refactor-patterns.prompt.md
```

## 📚 Documentation

Documentation is integrated into the PromptOps system:

- **Instructions**: `.github/instructions/` - Automatic guidance for VFP development, testing, and builds
- **Prompts**: `.github/prompts/` - Reusable prompts for audits, refactoring, and development
- **Agents**: `AGENTS.md` files in each project folder

## 🔨 Build System

### DOVFP Compiler

Custom command-line compiler for VFP with modern features:

```powershell
# Standard commands
dovfp build              # Build solution
dovfp clean              # Clean artifacts
dovfp test               # Run tests
dovfp restore            # Restore packages

# Advanced options
dovfp build -build_debug 2 -project_version 01.0002.000003
dovfp build -build_force 1 -build_encrypted 1
```

### Pre-Build Automation

PowerShell scripts automatically:
- Normalize version numbers (01.0001.00000)
- Update Din_Estructuraadn.prg
- Sync din_estructuraadn.xml components
- Update 60+ Transferencia*Consulta.prg files
- Update 64+ Transferencia*Objeto.prg files

### Version Format

`Major.Minor.Build` → `01.0001.00000` (always 2.4.5 digits)

## 🧪 Testing

### Running Tests

```powershell
# All tests
dovfp test

# Specific project
dovfp test -path "Organic.Tests\Organic.Tests.vfpproj"

# With coverage
dovfp test -coverage
```

### Test Structure

```foxpro
DEFINE CLASS Test_ZooSession AS TestCase
    FUNCTION Setup()
        * Arrange
    ENDFUNC
    
    FUNCTION Test_Initialize_ValidUser_ReturnsTrue()
        * Act & Assert
    ENDFUNC
    
    FUNCTION TearDown()
        * Cleanup
    ENDFUNC
ENDDEFINE
```

## 🔗 Key Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| Visual FoxPro | 9.0 SP2 | Core language |
| wwDotNetBridge | 7.x | .NET interop |
| .NET Framework | 4.8 | Runtime |
| DOVFP | Latest | Compiler |
| VS Code | Latest | IDE |
| Azure DevOps | - | CI/CD |

## 📋 Common Tasks

### Clean Build

```powershell
dovfp clean
dovfp build -build_debug 2
```

### Update Version

Edit `Organic.Generated/Organic.Core.Generated.vfpproj`:
```xml
<ProductVersion>1.2.0</ProductVersion>
```

Pre-build scripts auto-sync to all files.

### Add New Class

1. Create `myclass.prg` (lowercase filename!)
2. Define class:
```foxpro
DEFINE CLASS MyClass AS ZooBase OF nucleo\zoobase.prg
    cVersion = "01.0001.00000"
ENDDEFINE
```
3. Add to project
4. Build and test

### Debug Build Issues

1. Check MSBuild output for errors
2. Validate PowerShell scripts (`.ps1` files)
3. Verify file paths (case-sensitive!)
4. Ensure all LOCAL variables declared
5. Check DEFINE CLASS / ENDDEFINE matching

## 🤝 Contributing

1. Follow VFP standards in `.github/instructions/vfp-development.instructions.md`
2. Use GitHub Copilot agents for guidance
3. Write tests for new features
4. Run code audit before committing
5. Update documentation

## 🐛 Troubleshooting

### Build Errors

| Error | Solution |
|-------|----------|
| "Statement only valid in class" | Check DEFINE CLASS / ENDDEFINE pairing |
| "Variable not found" | Declare all LOCAL variables |
| "File not found" | Use lowercase for file references |
| PowerShell script fails | Check for encoding issues, use single quotes for XML regex |

See `.github/instructions/dovfp-build.instructions.md` for build system details.

## 📞 Support

- **Documentation**: `.github/` folder
- **Agents**: `.github/AGENTS.md` and sub-agents
- **Prompts**: `.github/prompts/` for specific scenarios
- **Instructions**: `.github/instructions/` for Copilot

## 📜 License

Copyright © 2025 ZooLogicSA. All rights reserved.

---

**Version**: 1.1.0  
**Last Updated**: 2025-10-15  
**Build Status**: ✅ Passing (525+ errors resolved to clean build)
