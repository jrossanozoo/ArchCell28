###############################################################################
# Add-VcxLoadReference.ps1
#
# Agrega LoadReference para clases que heredan de .vcx en Organic.Generated
# 
# Busca archivos .prg que heredan de clases .vcx y agrega la linea:
#   _screen._instanceFactory.LoadReference('NombreClase.vcx', "Ensamblado.app")
#
# Determina automaticamente el ensamblado correcto:
# 1. Si la VCX esta fisicamente en un proyecto del workspace, usa el ensamblado
#    de ese proyecto (AssemblyName del .vfpproj o nombre del proyecto si esta vacio)
# 2. Si la VCX no esta fisicamente pero esta en AppReferences, lee los archivos
#    .symbols correspondientes para determinar el ensamblado externo
#
# Solo agrega si no esta ya presente.
#
# Uso:
#   .\Add-VcxLoadReference.ps1
###############################################################################

$ErrorActionPreference = "Stop"

Write-Host "=== Agregando LoadReference a clases VCX ===" -ForegroundColor Cyan

# Obtener la raiz del workspace (un nivel arriba del directorio del script)
$workspaceRoot = Split-Path -Parent $PSScriptRoot

# Directorio de archivos generados
$generadosPath = Join-Path $PSScriptRoot "Generados"

if (-not (Test-Path $generadosPath)) {
    Write-Host "No se encontro la carpeta Generados: $generadosPath" -ForegroundColor Yellow
    exit 0
}

# Cache global para mapeo vcx -> app
$vcxToAppMap = @{}

# Cache para mapeo proyecto (carpeta) -> nombre de ensamblado
$projectToAssemblyMap = @{}

# Funcion para cargar archivos .symbols leyendo AppReferences de .vfpproj
# y construir el mapa de proyectos locales
function Load-SymbolsFromVfpProjects {
    param(
        [string]$WorkspaceRoot
    )
    
    Write-Host "Buscando proyectos .vfpproj con AppReferences..." -ForegroundColor Gray
    
    # Buscar todos los .vfpproj en el workspace
    $vfpprojFiles = @(Get-ChildItem -Path $WorkspaceRoot -Filter "*.vfpproj" -Recurse -ErrorAction SilentlyContinue)
    
    Write-Host "Encontrados $($vfpprojFiles.Count) archivos .vfpproj" -ForegroundColor Gray
    
    $symbolsFiles = @()
    
    # Procesar cada .vfpproj para obtener AppReferences y construir mapa de proyectos locales
    foreach ($vfpprojFile in $vfpprojFiles) {
        Write-Host "`nProcesando vfpproj: $($vfpprojFile.Name)" -ForegroundColor Cyan
        
        # Leer contenido XML
        [xml]$xml = Get-Content -Path $vfpprojFile.FullName -Encoding UTF8
        $projectDir = $vfpprojFile.DirectoryName
        
        # Obtener nombre del ensamblado para este proyecto
        $assemblyName = $xml.Project.PropertyGroup.AssemblyName | Where-Object { $_ } | Select-Object -First 1
        $outputType = $xml.Project.PropertyGroup.OutputType | Where-Object { $_ } | Select-Object -First 1
        
        # Si AssemblyName esta vacio, usar el nombre del archivo .vfpproj sin extension
        if ([string]::IsNullOrWhiteSpace($assemblyName)) {
            $assemblyName = [System.IO.Path]::GetFileNameWithoutExtension($vfpprojFile.Name)
        }
        
        # Determinar extension segun OutputType
        $extension = ".app"
        if ($outputType -eq "Exe") {
            $extension = ".exe"
        }
        
        $fullAssemblyName = $assemblyName + $extension
        
        # Guardar en el mapa de proyectos (carpeta del proyecto -> nombre ensamblado)
        $projectToAssemblyMap[$projectDir] = $fullAssemblyName
        Write-Host "  Proyecto local: $projectDir -> $fullAssemblyName" -ForegroundColor DarkCyan
        
        # Buscar AppReferences
        $appReferences = $xml.Project.ItemGroup.AppReference
        
        if (-not $appReferences) {
            Write-Host "  Sin AppReferences" -ForegroundColor DarkGray
            continue
        }
        
        foreach ($appRef in $appReferences) {
            $appPath = $appRef.Include
            
            if ([string]::IsNullOrWhiteSpace($appPath)) {
                continue
            }
            
            Write-Host "  AppReference: $appPath" -ForegroundColor Gray
            
            # Determinar ruta completa del .symbols
            $symbolsPath = $null
            
            if ($appPath -match '[\\/]') {
                # Es ruta relativa
                $fullAppPath = Join-Path $projectDir $appPath
                $fullAppPath = [System.IO.Path]::GetFullPath($fullAppPath)
                
                # Reemplazar .app por .symbols
                $symbolsPath = $fullAppPath -replace '\.app$', '.symbols'
            } else {
                # Es solo nombre, buscar en bin/ del proyecto
                $appName = $appPath
                $symbolsName = $appName -replace '\.app$', '.symbols'
                
                # Buscar en bin/App, bin/Test, etc
                $found = Get-ChildItem -Path $projectDir -Filter $symbolsName -Recurse -ErrorAction SilentlyContinue |
                         Where-Object { $_.DirectoryName -match '\\bin\\' } |
                         Select-Object -First 1
                
                if ($found) {
                    $symbolsPath = $found.FullName
                }
            }
            
            # Si encontramos el .symbols, procesarlo
            if ($symbolsPath -and (Test-Path -LiteralPath $symbolsPath)) {
                Write-Host "    Symbols encontrado: $symbolsPath" -ForegroundColor Green
                $symbolsFiles += Get-Item $symbolsPath
            } else {
                Write-Host "    Symbols NO encontrado para: $appPath" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "`nCargando $($symbolsFiles.Count) archivos .symbols..." -ForegroundColor Cyan
    
    foreach ($symbolFile in $symbolsFiles) {
        # Extraer nombre del .app del nombre del archivo .symbols
        # Ejemplo: Organic.Core.symbols -> Organic.Core.app
        $appName = $symbolFile.BaseName + ".app"
        
        Write-Host "  Procesando: $($symbolFile.Name) -> $appName" -ForegroundColor DarkGray
        
        # Leer contenido del archivo .symbols
        $lines = Get-Content -Path $symbolFile.FullName -Encoding UTF8
        $vcxCount = 0
        
        foreach ($line in $lines) {
            # Ignorar comentarios y lineas vacias
            if ($line.StartsWith('#') -or [string]::IsNullOrWhiteSpace($line)) {
                continue
            }
            
            # Formato: SymbolName|Type|BaseClass|StubFileType|SourceFile|LastModified
            $parts = $line -split '\|'
            
            if ($parts.Length -ge 5) {
                $stubFileType = $parts[3]
                $sourceFile = $parts[4]
                
                # Solo nos interesan archivos VCX
                if ($stubFileType -eq "VCX" -and $sourceFile -match '\.vcx$') {
                    # Extraer solo el nombre del archivo .vcx (sin ruta)
                    $vcxFileName = Split-Path -Leaf $sourceFile
                    
                    # Mapear vcx -> app (priorizar primera ocurrencia si no existe)
                    if (-not $vcxToAppMap.ContainsKey($vcxFileName)) {
                        $vcxToAppMap[$vcxFileName] = $appName
                        $vcxCount++
                    }
                }
            }
        }
        
        if ($vcxCount -gt 0) {
            Write-Host "    Mapeados: $vcxCount archivos .vcx" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "Total de .vcx mapeados: $($vcxToAppMap.Count)" -ForegroundColor Green
}

# Funcion para buscar el .app de una .vcx
# Retorna: nombre del .app (ya sea de proyecto local o de AppReference externa)
function Find-AppForVcx {
    param(
        [string]$VcxFileName,
        [string]$WorkspaceRoot
    )
    
    # PRIMERO: Buscar fisicamente en el workspace (excluyendo carpetas obj que contienen stubs)
    $vcxFiles = @(Get-ChildItem -Path $WorkspaceRoot -Filter $VcxFileName -Recurse -ErrorAction SilentlyContinue |
                  Where-Object { $_.DirectoryName -notmatch '\\obj\\' })
    
    if ($vcxFiles.Count -gt 0) {
        # Esta en el workspace fisicamente, buscar en que proyecto esta
        $vcxPath = $vcxFiles[0].DirectoryName
        
        # Buscar el proyecto que contiene esta VCX (la carpeta del proyecto es padre de la VCX)
        foreach ($projectDir in $projectToAssemblyMap.Keys) {
            if ($vcxPath.StartsWith($projectDir, [System.StringComparison]::OrdinalIgnoreCase)) {
                # Encontrado el proyecto que contiene la VCX
                return $projectToAssemblyMap[$projectDir]
            }
        }
        
        # VCX fisica pero no encontramos el proyecto, SKIP
        return "SKIP"
    }
    
    # SEGUNDO: No esta fisicamente, buscar en el mapa de simbolos (AppReferences externas)
    if ($vcxToAppMap.ContainsKey($VcxFileName)) {
        $appName = $vcxToAppMap[$VcxFileName]
        
        # Esta en .symbols de una AppReference externa
        return $appName
    }
    
    # No esta fisicamente ni en simbolos, NO hacer nada
    return "SKIP"
}

# Cargar archivos .symbols desde AppReferences de .vfpproj
Load-SymbolsFromVfpProjects -WorkspaceRoot $workspaceRoot

# Buscar todos los archivos .prg en Generados
$prgFiles = @(Get-ChildItem -Path $generadosPath -Filter "*.prg" -Recurse)

if ($prgFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .prg en Generados" -ForegroundColor Yellow
    exit 0
}

Write-Host "`nEncontrados $($prgFiles.Count) archivos .prg" -ForegroundColor Green

$totalChanges = 0
$defineClassPattern = [regex]::new('(?i)define\s+class\s+\w+\s+as\s+(\w+)\s+of\s+([\w\.]+\.vcx)', [System.Text.RegularExpressions.RegexOptions]::Compiled)

foreach ($file in $prgFiles) {
    # Leer contenido del archivo usando Windows-1252 (encoding de Visual FoxPro)
    $content = Get-Content -Path $file.FullName -Raw -Encoding Default
    
    # Buscar: define class XXXXX as YYYYY of ZZZZZ.vcx
    $match = $defineClassPattern.Match($content)
    
    if ($match.Success) {
        $parentClass = $match.Groups[1].Value
        $vcxFile = $match.Groups[2].Value
        
        # Verificar si ya tiene el LoadReference para este vcx
        $loadReferencePattern = [regex]::Escape("_screen._instanceFactory.LoadReference('$vcxFile'")
        
        if ($content -notmatch $loadReferencePattern) {
            # Buscar el .app correcto para esta .vcx (proyecto local o AppReference externa)
            $appName = Find-AppForVcx -VcxFileName $vcxFile -WorkspaceRoot $workspaceRoot
            
            # Si es SKIP, no hacer nada (vcx no encontrada en ningun proyecto)
            if ($appName -eq "SKIP") {
                continue
            }
            
            # Encontrado el ensamblado (puede ser proyecto local o AppReference externa)
            Write-Host "`nProcesando: $($file.Name)" -ForegroundColor White
            Write-Host "  Clase padre: $parentClass de $vcxFile" -ForegroundColor Gray
            Write-Host "  Ensamblado: $appName" -ForegroundColor Cyan
            
            # Crear la linea de LoadReference con el ensamblado encontrado
            $loadReferenceLine = "*!*`t DRAGON 2028`r`n_screen._instanceFactory.LoadReference('$vcxFile', `"$appName`")`r`n`r`n"
            
            # Agregar antes del define class
            $newContent = $content -replace '(?i)(define\s+class)', "$loadReferenceLine`$1"
            
            # Guardar el archivo usando Windows-1252 (encoding de Visual FoxPro)
            Set-Content -Path $file.FullName -Value $newContent -Encoding Default -NoNewline
            
            Write-Host "  Agregado LoadReference" -ForegroundColor Green
            $totalChanges++
        }
    }
}

Write-Host "`n=== Completado ===" -ForegroundColor Cyan
Write-Host "Total de archivos modificados: $totalChanges" -ForegroundColor Green

if ($totalChanges -eq 0) {
    Write-Host "Todos los archivos ya tienen LoadReference o no heredan de vcx" -ForegroundColor Gray
}
