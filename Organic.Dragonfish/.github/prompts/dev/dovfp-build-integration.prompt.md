---
description: "Integración con DOVFP - compilador Visual FoxPro para VS Code - configuración, builds y troubleshooting"
tools: ["read_file", "run_in_terminal", "grep_search", "file_search", "get_errors"]
applyTo: ["**/*.vfpproj", "**/*.vfpsln", "**/azure-pipelines.yml", "**/*.ps1"]
argument-hint: "Describe el problema de build o la configuración deseada"
---

#  Integración con DOVFP Build System

## Objetivo

Guía completa para trabajar con DOVFP, el compilador personalizado de Visual FoxPro 9 que permite builds modernos desde VS Code.

---

##  Qué es DOVFP

**DOVFP** es una herramienta .NET Core que:
- Compila soluciones y proyectos VFP (`.vfpsln`, `.vfpproj`)
- Ejecuta archivos PRG con parámetros
- Gestiona dependencias y paquetes
- Exporta breakpoints de VS Code a VFP
- Facilita CI/CD para aplicaciones VFP

---

##  Comandos principales

### 1. Compilar proyecto o solución

```bash
# Compilar directorio actual (busca .vfpproj o .vfpsln)
dovfp build

# Compilar proyecto específico
dovfp build -path Organic.BusinessLogic/Organic.Drawing.vfpproj

# Compilar solución específica
dovfp build -path Organic.Drawing.vfpsln

# Compilar con versión específica
dovfp build -project_version 1.2.3

# Forzar recompilación completa
dovfp build -build_force 1

# Compilar en modo Release
dovfp build -build_debug 2

# Compilar con encriptación
dovfp build -build_encrypted 1
```

**Opciones disponibles**:
- `-path`: Ruta al proyecto (.vfpproj), solución (.vfpsln) o directorio
- `-output_path`: Ruta de salida (por defecto bin/)
- `-build_force`: 1=forzar recompilación, 0=incremental (default)
- `-build_debug`: 1=Debug (default), 2=Release
- `-build_encrypted`: 1=compilar con encriptación, 0=normal (default)

### 2. Ejecutar proyecto compilado

```bash
# Ejecutar proyecto del directorio actual (usa bin/ por defecto)
dovfp run

# Ejecutar con argumentos para el programa VFP
dovfp run -run_args "'config.xml', 8080, .T."

# Ejecutar sin modo debug
dovfp run -run_debug 0

# Ejecutar desde ruta específica
dovfp run -path Organic.BusinessLogic/Organic.Drawing.vfpproj
```

**Nota**: `dovfp run` ejecuta el proyecto compilado desde `bin/`. Los argumentos se pasan al programa VFP mediante `-run_args`.

### 3. Restaurar dependencias

```bash
# Restaurar paquetes del directorio actual
dovfp restore

# Restaurar de proyecto/solución específica
dovfp restore -path Organic.Drawing.vfpsln

# Forzar re-descarga de paquetes
dovfp restore -force_download 1

# Con token de autenticación para feeds privados
dovfp restore -feed_token "tu_token_aqui"
```

**Opciones disponibles**:
- `-path`: Ruta al proyecto (.vfpproj), solución (.vfpsln) o directorio
- `-force_download`: 1=forzar descarga, 0=usar caché (default)
- `-feed_token`: Token para feeds privados de Azure DevOps

### 4. Tests

```bash
# Ejecutar tests (funcionalidad en desarrollo)
dovfp test
```

**Nota**: La funcionalidad de testing está en desarrollo. Consultar documentación actualizada.

### 5. Limpiar builds

```bash
# Limpiar archivos de compilación (bin/, obj/, packages/) y caché NuGet
dovfp clean

# Limpiar y reconstruir
dovfp clean
dovfp build
```

### 6. Reconstruir desde cero

```bash
# Limpiar y compilar en un solo comando
dovfp rebuild

# Rebuild de proyecto específico
dovfp rebuild -path Organic.BusinessLogic/Organic.Drawing.vfpproj
```

---

##  Configuración avanzada

### NuGet.config

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="doVFP" value="https://pkgs.dev.azure.com/zoologicnet/_packaging/doVFP/nuget/v3/index.json" />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
  
  <packageSourceCredentials>
    <!-- NO hardcodear credenciales aquí -->
    <!-- Usar Azure Key Vault o variables de entorno -->
  </packageSourceCredentials>
</configuration>
```

**Nota sobre archivos de proyecto**: Los archivos `.vfpsln` y `.vfpproj` tienen formatos específicos del proyecto. Consulta ejemplos existentes en el workspace para entender su estructura.

---

##  Integración con VS Code

### tasks.json

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Solution",
      "type": "shell",
      "command": "dovfp",
      "args": ["build"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    },
    {
      "label": "Build Current Project",
      "type": "shell",
      "command": "dovfp",
      "args": ["build", "-path", "${fileDirname}\\${fileBasenameNoExtension}.vfpproj"],
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Run Project",
      "type": "shell",
      "command": "dovfp",
      "args": ["run"],
      "group": "none",
      "problemMatcher": []
    },
    {
      "label": "Clean",
      "type": "shell",
      "command": "dovfp",
      "args": ["clean"],
      "group": "none"
    },
    {
      "label": "Restore Packages",
      "type": "shell",
      "command": "dovfp",
      "args": ["restore"],
      "group": "none"
    }
  ]
}
```

### launch.json (Debugging)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Visual FoxPro",
      "type": "node",
      "request": "launch",
      "program": "dovfp",
      "args": ["run"],
      "console": "integratedTerminal",
      "preLaunchTask": "Export VFP Breakpoints"
    },
    {
      "name": "Run with Arguments",
      "type": "node",
      "request": "launch",
      "program": "dovfp",
      "args": ["run", "-run_args", "'config.xml', 8080, .T."],
      "console": "integratedTerminal",
      "preLaunchTask": "Export VFP Breakpoints"
    }
  ]
}
```

---

##  Troubleshooting

### Problema: DOVFP no encontrado

**Error**:
```
'dovfp' is not recognized as an internal or external command
```

**Solución**:
```powershell
# Verificar instalación
dotnet tool list --global

# Si no está instalado
dotnet tool install --global dovfp --add-source ./nupkg

# Si está desactualizado
dotnet tool update --global dovfp --add-source ./nupkg

# Verificar PATH
$env:PATH -split ';' | Select-String "dotnet\\tools"
```

### Problema: Error de autenticación con Azure DevOps

**Error**:
```
Unable to load the service index for source https://pkgs.dev.azure.com/...
```

**Solución**:
```powershell
# Opción 1: Azure CLI (recomendado)
az login
az account show

# Opción 2: PAT (Personal Access Token) via Azure Key Vault
# NO hardcodear tokens en archivos

# Opción 3: Usar API REST directa (implementado en extensión)
# Ver: src/services/dovfpService.js
```

### Problema: Compilación falla pero no muestra errores

**Solución**:
```bash
# Limpiar y reconstruir
dovfp clean
dovfp rebuild

# Verificar logs en obj/
Get-Content obj/App/*.log
```

### Problema: Tests fallan en CI pero pasan localmente

**Causas comunes**:
1. Rutas absolutas en código
2. Dependencias de archivos locales
3. Diferencias de configuración regional
4. Concurrencia no manejada

**Solución**:
```foxpro
* Usar rutas relativas
LOCAL lcRutaBase
lcRutaBase = JUSTPATH(SYS(16))  && Ruta del programa actual

* Configuración regional explícita
SET DATE TO BRITISH
SET CENTURY ON
SET DECIMALS TO 2

* Evitar estado compartido en tests
PROCEDURE Test_ConAislamiento()
    * Crear datos fresh en cada test
    LOCAL loRepo
    loRepo = CREATEOBJECT("RepositorioMock")
    * ... usar repo aislado
ENDPROC
```

---

##  CI/CD con Azure Pipelines

### azure-pipelines.yml

```yaml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'windows-latest'

steps:
- task: UseDotNet@2
  inputs:
    version: '6.x'

- script: |
    dotnet tool install --global dovfp --add-source ./nupkg
  displayName: 'Install DOVFP'

- script: |
    dovfp restore
  displayName: 'Restore Dependencies'
  env:
    AZURE_DEVOPS_PAT: $(AzureDevOpsPAT)

- script: |
    dovfp build Organic.Drawing.vfpsln -build_debug 2
  displayName: 'Build Solution (Release)'

- script: |
    dovfp test Organic.Tests/Organic.Tests.vfpproj
  displayName: 'Run Tests'

- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'VSTest'
    testResultsFiles: '**/*.trx'
  condition: always()

- task: CopyFiles@2
  inputs:
    SourceFolder: '$(Build.SourcesDirectory)/Organic.BusinessLogic/bin/App'
    Contents: '**/*'
    TargetFolder: '$(Build.ArtifactStagingDirectory)'

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)'
    ArtifactName: 'organic-drawing'
```

---

##  Optimización de builds

### Build forzado

```bash
# Recompilar todo forzosamente
dovfp build -build_force 1

# O limpiar y reconstruir
dovfp clean
dovfp rebuild
```

### Build paralelo

```bash
# Usar múltiples cores
dovfp build --parallel --max-cpu-count:4

# Configurar en dovfp.json
{
  "build": {
    "parallelBuild": true,
    "maxConcurrency": 4
  }
}
```

### Cache de dependencias

```yaml
# En Azure Pipelines
- task: Cache@2
  inputs:
    key: 'nuget | "$(Agent.OS)" | **/packages.lock.json'
    path: '$(UserProfile)/.nuget/packages'
  displayName: 'Cache NuGet packages'
```

---

##  Checklist de configuración

Antes de pushear cambios a build system:

- [ ] `.vfpsln` incluye todos los proyectos activos
- [ ] Cada `.vfpproj` tiene `OutputPath` correcto
- [ ] `MainProgram` apunta al PRG de inicio correcto
- [ ] `PackageReference` con versiones específicas (no wildcards)
- [ ] Scripts pre/post-build existen y son ejecutables
- [ ] `NuGet.config` NO contiene credenciales hardcodeadas
- [ ] `dovfp.json` tiene rutas relativas
- [ ] `tasks.json` apunta a archivos existentes
- [ ] Tests pasan localmente antes de push
- [ ] Pipeline de Azure DevOps valida correctamente

---

## Uso del prompt

```
@workspace Configura DOVFP para compilar este nuevo proyecto VFP

@workspace #file:azure-pipelines.yml Optimiza este pipeline para builds más rápidos con DOVFP

@workspace DOVFP está fallando con error de dependencias, ayúdame a diagnosticar

@workspace Necesito agregar un target personalizado post-build en el .vfpproj
```

---

## Relacionado

- Agente arquitecto: `/.github/AGENTS.md`
- Documentación DOVFP: `/docs/quick-start/dovfp-guide.md`
- Troubleshooting: `/docs/troubleshooting.md`