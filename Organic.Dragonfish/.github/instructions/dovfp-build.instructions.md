---
applyTo: "**/*.vfpproj,**/*.vfpsln,**/azure-pipelines.yml,**/Nuget.config,**/*.ps1"
description: "Instrucciones para trabajar con DOVFP - compilador y build system"
---

# Instrucciones de DOVFP Build

## Contexto

DOVFP es el compilador personalizado para Visual FoxPro 9 que permite builds modernos desde VS Code.

---

## Comandos esenciales

### Compilar
```bash
# Solución completa
dovfp build Organic.Drawing.vfpsln

# Proyecto específico
dovfp build Organic.BusinessLogic/Organic.Drawing.vfpproj

# Con configuración Release
dovfp build Organic.Drawing.vfpsln -build_debug 2
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
# Ejecutar todos (funcionalidad en desarrollo)
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

### .vfpsln (Solución)
Define todos los proyectos y su relación.

```xml
<Solution>
    <Projects>
        <Project Path="Organic.BusinessLogic\Organic.Drawing.vfpproj" />
        <Project Path="Organic.Generated\Organic.Drawing.Generated.vfpproj" />
        <Project Path="Organic.Tests\Organic.Tests.vfpproj" />
    </Projects>
</Solution>
```

### .vfpproj (Proyecto)
Define archivos, dependencias y configuración del proyecto.

```xml
<Project>
    <PropertyGroup>
        <OutputPath>bin\App\</OutputPath>
        <MainProgram>CENTRALSS\main2028.prg</MainProgram>
    </PropertyGroup>
    
    <ItemGroup>
        <Compile Include="CENTRALSS\**\*.prg" />
        <PackageReference Include="VFPLibrary" Version="1.0.0" />
    </ItemGroup>
</Project>
```

---

## Integración con VS Code

### Tareas (tasks.json)

**Build** (Ctrl+Shift+B):
```json
{
    "label": "Build Solution",
    "type": "shell",
    "command": "dovfp",
    "args": ["build", "Organic.Drawing.vfpsln"],
    "group": {
        "kind": "build",
        "isDefault": true
    }
}
```

**Run** (F5):
```json
{
    "name": "Run Visual FoxPro",
    "type": "node",
    "request": "launch",
    "program": "dovfp",
    "args": ["run"]
}
```

**Nota**: Para pasar argumentos al programa VFP, usar `-run_args` en la línea de comandos.

---

## NuGet y dependencias

### Fuentes de paquetes
Configuradas en `Nuget.config`:
- `doVFP`: Azure DevOps feed privado
- `nuget.org`: Paquetes públicos

### Autenticación
- **Producción**: Azure Key Vault
- **Desarrollo**: Azure CLI (`az login`)

### NO hacer
- ❌ NO hardcodear credenciales en `Nuget.config`
- âŒ NO commitear tokens en archivos
- âŒ NO usar variables de entorno VSS_NUGET_EXTERNAL_FEED_ENDPOINTS

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
# Verificar instalación
dotnet tool list --global

# Instalar/actualizar
dotnet tool install --global dovfp --add-source ./nupkg
dotnet tool update --global dovfp --add-source ./nupkg
```

### Error de autenticación
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

## Builds incrementales

### Habilitar
```xml
<PropertyGroup>
    <IncrementalBuild>true</IncrementalBuild>
</PropertyGroup>
```

### Cuando limpiar
- Después de cambios en .vfpproj
- Después de agregar/quitar archivos
- Errores extraños de compilación

---

## CI/CD

### Azure Pipelines
Ver `azure-pipelines.yml` para configuración completa.

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

## Mejores prácticas

### ✅ Hacer
- Compilar localmente antes de push
- Usar builds incrementales en desarrollo
- Ejecutar tests antes de merge
- Mantener `.vfpproj` actualizado

### ❌ No hacer
- Compilar solo en CI (build local primero)
- Ignorar warnings de compilación
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

---

## Ayuda rápida

```
@workspace ¿Cómo compilo solo el proyecto BusinessLogic con DOVFP?

@workspace DOVFP me da error de autenticación, ¿cómo lo soluciono?

@workspace Necesito agregar un target post-build al proyecto
```
