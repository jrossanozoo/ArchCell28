###############################################################################
# convert-to-local-appreferences.ps1
#
# Convierte AppReferences simples a referencias con rutas relativas
# Explora el sistema de archivos para encontrar las .app correspondientes
# 
# Ejemplo:
#   De: <AppReference Include="Organic.Drawing.app" />
#   A:  <AppReference Include="..\..\Organic.Drawing\Organic.BusinessLogic\bin\App\Organic.Drawing.app" />
#
# Uso:
#   .\convert-to-local-appreferences.ps1
###############################################################################

$ErrorActionPreference = "Stop"

Write-Host "=== Convirtiendo AppReferences a rutas locales ===" -ForegroundColor Cyan

# Buscar todos los archivos .vfpproj recursivamente
$vfpprojFiles = @(Get-ChildItem -Path . -Filter "*.vfpproj" -Recurse)

if ($vfpprojFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .vfpproj" -ForegroundColor Yellow
    exit 0
}

Write-Host "Encontrados $($vfpprojFiles.Count) archivos .vfpproj" -ForegroundColor Green

# Cache para archivos .app encontrados (evita búsquedas repetidas)
$appCache = @{}

# Compilar regex para mejor performance
$appReferencePattern = [regex]::new('<AppReference\s+Include="([^"\\/ ]+\.app)"\s*/>', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# Funcion para buscar un archivo .app en el repositorio
# Prioriza .app que tengan su .pjx correspondiente en la carpeta obj
function Find-AppFile {
    param(
        [string]$AppFileName,
        [string]$SearchRoot,
        [hashtable]$Cache
    )
    
    # Verificar caché primero
    if ($Cache.ContainsKey($AppFileName)) {
        return $Cache[$AppFileName]
    }
    
    # Obtener nombre base sin extension (.app)
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($AppFileName)
    $binPattern = [regex]::new('\\bin\\(App|Test|Release|Debug)', [System.Text.RegularExpressions.RegexOptions]::Compiled)
    
    # Buscar todos los .app que coincidan con el nombre
    $candidates = @()
    
    # Buscar en el workspace actual
    $candidates += @(Get-ChildItem -Path $SearchRoot -Filter $AppFileName -Recurse -ErrorAction SilentlyContinue | Where-Object { $binPattern.IsMatch($_.DirectoryName) })
    
    # Buscar en carpetas vecinas (proyectos hermanos)
    $parentFolder = Split-Path -Parent $SearchRoot
    if ($parentFolder -and (Test-Path -LiteralPath $parentFolder)) {
        $candidates += @(Get-ChildItem -Path $parentFolder -Filter $AppFileName -Recurse -ErrorAction SilentlyContinue | Where-Object { $binPattern.IsMatch($_.DirectoryName) })
    }
    
    if ($candidates.Count -eq 0) {
        $Cache[$AppFileName] = $null
        return $null
    }
    
    # Prioridad 1: Candidatos con .pjx en obj (compilados localmente)
    foreach ($candidate in $candidates) {
        $appDir = $candidate.DirectoryName
        $match = $binPattern.Match($appDir)
        
        if ($match.Success) {
            $subFolder = $match.Groups[1].Value
            $objPath = $appDir.Replace("\bin\$subFolder", "\obj\$subFolder")
            $pjxPath = Join-Path $objPath "$baseName.pjx"
            
            if (Test-Path -LiteralPath $pjxPath) {
                $result = $candidate.FullName
                $Cache[$AppFileName] = $result
                return $result
            }
        }
    }
    
    # Prioridad 2: Si no hay .pjx, retornar el primer candidato (dependencia externa)
    $result = $candidates[0].FullName
    $Cache[$AppFileName] = $result
    return $result
}

# Funcion para obtener ruta relativa
function Get-RelativePath {
    param(
        [string]$From,
        [string]$To
    )
    
    $fromUri = New-Object System.Uri($From)
    $toUri = New-Object System.Uri($To)
    
    $relativeUri = $fromUri.MakeRelativeUri($toUri)
    $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString())
    
    # Convertir / a \
    return $relativePath -replace '/', '\'
}

$totalChanges = 0
$repositoryRoot = (Get-Location).Path

foreach ($file in $vfpprojFiles) {
    Write-Host "`nProcesando: $($file.FullName)" -ForegroundColor White
    
    # Leer contenido
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileChanges = 0
    
    # Procesar línea por línea para detectar comentarios correctamente
    $lines = $content -split '\r?\n'
    $inComment = $false
    $sb = [System.Text.StringBuilder]::new($content.Length)
    $vfpprojDir = $file.DirectoryName
    $lineIndex = 0
    
    foreach ($line in $lines) {
        if ($lineIndex -gt 0) { [void]$sb.Append("`r`n") }
        $modifiedLine = $line
        
        # Detectar inicio de comentario multilínea
        if ($line.Contains('<!--') -and -not $line.Contains('-->')) {
            $inComment = $true
        }
        # Detectar fin de comentario multilínea
        elseif ($line.Contains('-->') -and $inComment) {
            $inComment = $false
        }
        # Línea válida (no en comentario)
        elseif (-not $inComment -and $line.Contains('<AppReference')) {
            # Buscar AppReferences simples (sin rutas) en esta línea
            $match = $appReferencePattern.Match($line)
            if ($match.Success) {
                $appFileName = $match.Groups[1].Value
                
                Write-Host "  Buscando: $appFileName..." -ForegroundColor Yellow
                
                # Buscar el archivo .app en el repositorio (con caché)
                $appFullPath = Find-AppFile -AppFileName $appFileName -SearchRoot $repositoryRoot -Cache $appCache
                
                if ($appFullPath) {
                    # Calcular ruta relativa desde el .vfpproj hasta el .app
                    $relativePath = Get-RelativePath -From "$vfpprojDir\" -To $appFullPath
                    
                    $modifiedLine = $line.Replace($appFileName, $relativePath)
                    
                    if ($modifiedLine -ne $line) {
                        Write-Host "  OK $appFileName -> $relativePath" -ForegroundColor Green
                        $fileChanges++
                    }
                } else {
                    Write-Host "  Error: No se encontro $appFileName en el repositorio" -ForegroundColor Red
                }
            }
        }
        
        [void]$sb.Append($modifiedLine)
        $lineIndex++
    }
    
    $content = $sb.ToString()
    
    # Solo escribir si hubo cambios
    if ($fileChanges -gt 0) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  Cambios aplicados: $fileChanges" -ForegroundColor Cyan
        $totalChanges += $fileChanges
    } else {
        Write-Host "  Sin cambios necesarios" -ForegroundColor Gray
    }
}

Write-Host "`n=== Completado ===" -ForegroundColor Cyan
Write-Host "Total de referencias convertidas: $totalChanges" -ForegroundColor Green

if ($totalChanges -eq 0) {
    Write-Host "`nNota: Si esperabas conversiones verifica que:" -ForegroundColor Yellow
    Write-Host "  1. Los archivos .app existan en carpetas bin\App bin\Test etc." -ForegroundColor Yellow
    Write-Host "  2. Las referencias en .vfpproj no tengan ya rutas relativas" -ForegroundColor Yellow
}
