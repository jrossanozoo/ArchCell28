---
description: Instrucciones para trabajar con DOVFP - compilador y build system
applyTo: "**/*.vfpproj,**/*.vfpsln,**/azure-pipelines.yml,**/*.ps1"
---

# Instrucciones de DOVFP Build

## Contexto

DOVFP es el compilador personalizado para Visual FoxPro 9 que permite builds modernos desde VS Code.

---

## Comandos esenciales

### Compilar
```bash
# Solucion completa
dovfp build Organic.Core.vfpsln

# Proyecto especifico
dovfp build Organic.BusinessLogic/Organic.Core.vfpproj

# Con configuracion Release
dovfp build Organic.Core.vfpsln -build_debug 2
```

### Ejecutar
```bash
# Ejecutar proyecto (usa bin/ por defecto)
dovfp run

# Pasar argumentos al programa VFP
dovfp run -run_args "'config.xml', 8080, .T."
```

### Tests
```bash
# Ejecutar todos
dovfp test Organic.Tests/Organic.Tests.vfpproj
```

### Mantenimiento
```bash
# Restaurar dependencias
dovfp restore

# Limpiar
dovfp clean

# Limpiar y reconstruir
dovfp clean ; dovfp build
```

---

## Estructura de proyectos

### .vfpsln (Solucion)
Define todos los proyectos y su relacion.

### .vfpproj (Proyecto)
Define archivos, dependencias y configuracion del proyecto.

---

## Integracion con VS Code

### Tareas (tasks.json)

**Build** (Ctrl+Shift+B):
```json
{
    "label": "Build Solution",
    "type": "shell",
    "command": "dovfp",
    "args": ["build", "Organic.Core.vfpsln"],
    "group": {
        "kind": "build",
        "isDefault": true
    }
}
```

---

## NuGet y dependencias

### Fuentes de paquetes
Configuradas en `Nuget.config`:
- `Zoo Logic`: Nexus privado
- `Zoo Logic SA Organic`: Azure DevOps feed
- `nuget.org`: Paquetes publicos

### Autenticacion
- **Produccion**: Azure Key Vault
- **Desarrollo**: Azure CLI (`az login`)

### NO hacer
- NO hardcodear credenciales en `Nuget.config`
- NO commitear tokens en archivos

---

## Targets personalizados

### Pre-build
```xml
<Target Name="PreBuild">
    <Exec Command="powershell -File scripts\pre-build.ps1" />
</Target>
```

### Post-build
```xml
<Target Name="PostBuild">
    <Exec Command="powershell -File scripts\post-build.ps1" />
    <Exec Command="powershell -File Organic.Generated\Validate-VersionsPostBuild.ps1" />
</Target>
```

---

## Troubleshooting

### DOVFP no encontrado
```powershell
# Verificar instalacion
dotnet tool list --global

# Instalar/actualizar
dotnet tool install --global dovfp --add-source ./nupkg
dotnet tool update --global dovfp --add-source ./nupkg
```

### Error de autenticacion
```powershell
# Azure CLI
az login
az account show
```

### Build falla sin errores
```bash
# Limpiar cache y reconstruir
dovfp clean
rm -r obj/
dovfp build
```

---

## CI/CD

### Azure Pipelines
Ver `azure-pipelines.yml` para configuracion completa.

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

---

## Mejores practicas

### Hacer
- Compilar localmente antes de push
- Usar builds incrementales en desarrollo
- Ejecutar tests antes de merge
- Mantener `.vfpproj` actualizado

### No hacer
- Compilar solo en CI (build local primero)
- Ignorar warnings de compilacion
- Commitear archivos `obj/` o `bin/`
- Modificar manualmente archivos generados

---

## Archivos a ignorar (.gitignore)

```gitignore
# DOVFP outputs
**/bin/
**/obj/
**/packages/

# Intermedios
**/*.bak
**/*.tmp
```

---

## Recursos

- **Prompt DOVFP**: `.github/prompts/dev/dovfp-build-integration.prompt.md`
- **Agente arquitecto**: `.github/AGENTS.md`
- **Pipeline**: `azure-pipelines.yml`
