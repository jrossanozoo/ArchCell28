###############################################################################
# convert-to-nuget-appreferences.ps1
#
# Convierte AppReferences con rutas relativas a referencias simples (estilo NuGet)
# 
# Ejemplo:
#   De: <AppReference Include="..\..\Organic.Drawing\Organic.BusinessLogic\bin\App\Organic.Drawing.app" />
#   A:  <AppReference Include="Organic.Drawing.app" />
#
# Uso:
#   .\convert-to-nuget-appreferences.ps1
###############################################################################

$ErrorActionPreference = "Stop"

Write-Host "=== Convirtiendo AppReferences a formato NuGet ===" -ForegroundColor Cyan

# Buscar todos los archivos .vfpproj recursivamente
$vfpprojFiles = @(Get-ChildItem -Path . -Filter "*.vfpproj" -Recurse)

if ($vfpprojFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .vfpproj" -ForegroundColor Yellow
    exit 0
}

Write-Host "Encontrados $($vfpprojFiles.Count) archivos .vfpproj" -ForegroundColor Green

# Compilar regex para mejor performance
$appReferencePattern = [regex]::new('<AppReference\s+Include="([^"]+[\\/ ][^"\\]+\.app)"\s*/>', [System.Text.RegularExpressions.RegexOptions]::Compiled)

$totalChanges = 0

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
        # Comentario en una sola línea (ya manejado arriba)
        elseif (-not $inComment -and $line.Contains('<AppReference')) {
            # Buscar AppReferences con rutas relativas en esta línea
            $match = $appReferencePattern.Match($line)
            if ($match.Success) {
                $fullPath = $match.Groups[1].Value
                $lastSlash = [Math]::Max($fullPath.LastIndexOf('\'), $fullPath.LastIndexOf('/'))
                $fileName = if ($lastSlash -ge 0) { $fullPath.Substring($lastSlash + 1) } else { $fullPath }
                $modifiedLine = $line.Replace($fullPath, $fileName)
                
                if ($modifiedLine -ne $line) {
                    Write-Host "  OK $fullPath -> $fileName" -ForegroundColor Green
                    $fileChanges++
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
