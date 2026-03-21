---
applyTo: "**/*.vfpproj,**/*.vfpsln,**/azure-pipelines.yml,**/Nuget.config"
description: "Instrucciones para trabajar con DOVFP - compilador y build system"
---

# Instrucciones de DOVFP Build

## Contexto

DOVFP es el compilador personalizado para Visual FoxPro 9 que permite builds modernos desde VS Code.

---

## Comandos esenciales

### Compilar
```bash
# SoluciÃ³n completa
dovfp build Organic.Drawing.vfpsln

# Proyecto especÃ­fico
dovfp build Organic.BusinessLogic/Organic.Drawing.vfpproj

# Con configuraciÃ³n Release
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

### .vfpsln (SoluciÃ³n)
Define todos los proyectos y su relaciÃ³n.

```xml
<Solution>
    <Projects>
        <Project Path="Organic.BusinessLogic\Organic.Drawing.vfpproj" />
        <Project Path="Organic.Generated\Organic.Feline.Generated.vfpproj" />
        <Project Path="Organic.Tests\Organic.Tests.vfpproj" />
    </Projects>
</Solution>
```

### .vfpproj (Proyecto)
Define archivos, dependencias y configuraciÃ³n del proyecto.

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

## IntegraciÃ³n con VS Code

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

**Nota**: Para pasar argumentos al programa VFP, usar `-run_args` en la lÃ­nea de comandos.

---

## NuGet y dependencias

### Fuentes de paquetes
Configuradas en `Nuget.config`:
- `doVFP`: Azure DevOps feed privado
- `nuget.org`: Paquetes pÃºblicos

### AutenticaciÃ³n
- **ProducciÃ³n**: Azure Key Vault
- **Desarrollo**: Azure CLI (`az login`)

### NO hacer
- âŒ NO hardcodear credenciales en `Nuget.config`
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
# Verificar instalaciÃ³n
dotnet tool list --global

# Instalar/actualizar
dotnet tool install --global dovfp --add-source ./nupkg
dotnet tool update --global dovfp --add-source ./nupkg
```

### Error de autenticaciÃ³n
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
- DespuÃ©s de cambios en .vfpproj
- DespuÃ©s de agregar/quitar archivos
- Errores extraÃ±os de compilaciÃ³n

---

## CI/CD

### Azure Pipelines
Ver `azure-pipelines.yml` para configuraciÃ³n completa.

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

## Mejores prÃ¡cticas

### âœ… Hacer
- Compilar localmente antes de push
- Usar builds incrementales en desarrollo
- Ejecutar tests antes de merge
- Mantener `.vfpproj` actualizado

### âŒ No hacer
- Compilar solo en CI (build local primero)
- Ignorar warnings de compilaciÃ³n
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

## Ayuda rÃ¡pida

```
@workspace Â¿CÃ³mo compilo solo el proyecto BusinessLogic con DOVFP?

@workspace DOVFP me da error de autenticaciÃ³n, Â¿cÃ³mo lo soluciono?

@workspace Necesito agregar un target post-build al proyecto
```
