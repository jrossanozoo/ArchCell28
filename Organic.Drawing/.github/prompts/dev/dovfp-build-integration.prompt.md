---
description: Integracion con DOVFP - compilador Visual FoxPro para VS Code - configuracion, builds y troubleshooting
argument-hint: "Describe el problema de build o la configuración necesaria"
---

# Integracion con DOVFP Build System

## Objetivo

Guia completa para trabajar con DOVFP, el compilador de Visual FoxPro 9 que permite builds modernos desde VS Code.

## Que es DOVFP

**DOVFP** es una herramienta .NET 6 que:
- Compila soluciones y proyectos VFP (.vfpsln, .vfpproj)
- Ejecuta archivos PRG con parametros
- Gestiona dependencias y paquetes NuGet
- Exporta breakpoints de VS Code a VFP
- Facilita CI/CD para aplicaciones VFP

## Comandos Principales (Verificados)

### Compilar

```bash
# Compilar directorio actual
dovfp build

# Compilar proyecto especifico
dovfp build -path Organic.BusinessLogic/Organic.Drawing.vfpproj

# Compilar solucion
dovfp build -path Organic.Drawing.vfpsln

# Forzar recompilacion completa
dovfp build -build_force 1

# Compilar en modo Release
dovfp build -build_debug 2

# Compilar con encriptacion
dovfp build -build_encrypted 1
```

**Opciones disponibles:**
- `-path`: Ruta al proyecto/solucion/directorio
- `-output_path`: Ruta de salida (default: bin/)
- `-build_force`: 1=forzar recompilacion, 0=incremental
- `-build_debug`: 1=Debug, 2=Release
- `-build_encrypted`: 1=con encriptacion

### Ejecutar

```bash
# Ejecutar proyecto
dovfp run

# Con argumentos para el programa VFP
dovfp run -run_args "'config.xml', 8080, .T."

# Sin modo debug
dovfp run -run_debug 0
```

### Tests

```bash
# Ejecutar todos los tests
dovfp test

# Filtrar por patron (wildcards)
dovfp test -test_filter "Test*"

# Filtrar por regex
dovfp test -test_filter "^Test(Add|Sub)$" -test_filter_regex 1

# Con cobertura
dovfp test -test_coverage 1

# Formato de salida
dovfp test -test_format junit

# Test especifico
dovfp test -test_path Tests/MiTest.prg

# Modo verbose
dovfp test -test_verbose 1
```

### Restaurar Dependencias

```bash
# Restaurar paquetes
dovfp restore

# Forzar descarga
dovfp restore -force_download 1

# Con token para feeds privados
dovfp restore -feed_token "tu_token"
```

### Limpiar

```bash
# Limpiar artefactos (bin, obj, packages, .fxp, .err, .log)
dovfp clean

# Sin recursion
dovfp clean -recursive 0

# Limpiar cache NuGet
dovfp clean -cache_nuget all
```

### Rebuild

```bash
# Clean + Build en un comando
dovfp rebuild
```

## Integracion con VS Code

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
      "group": { "kind": "build", "isDefault": true }
    },
    {
      "label": "Run Project",
      "type": "shell",
      "command": "dovfp",
      "args": ["run"]
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "dovfp",
      "args": ["test"]
    }
  ]
}
```

## Troubleshooting

### DOVFP no encontrado

```powershell
# Verificar instalacion
dotnet tool list --global

# Instalar/actualizar
dotnet tool install --global dovfp --add-source ./nupkg
dotnet tool update --global dovfp --add-source ./nupkg
```

### Error de autenticacion con Azure DevOps

```powershell
# Usar Azure CLI
az login
az account show
```

### Build falla sin errores

```bash
# Limpiar y reconstruir
dovfp clean
dovfp rebuild
```

## CI/CD con Azure Pipelines

```yaml
steps:
- script: dotnet tool install --global dovfp
  displayName: 'Install DOVFP'

- script: dovfp restore
  displayName: 'Restore'

- script: dovfp build -build_debug 2
  displayName: 'Build Release'

- script: dovfp test
  displayName: 'Test'
```

## Mejores Practicas

**Hacer:**
- Compilar localmente antes de push
- Usar builds incrementales en desarrollo
- Ejecutar tests antes de merge

**No hacer:**
- Commitear archivos bin/, obj/, packages/
- Ignorar warnings de compilacion
- Modificar manualmente archivos generados

## Uso del Prompt

```
@workspace #prompt:dovfp-build-integration Configura DOVFP para este proyecto

@workspace #prompt:dovfp-build-integration DOVFP falla con error, ayudame a diagnosticar

@workspace #prompt:dovfp-build-integration Optimiza el pipeline de CI/CD
```
