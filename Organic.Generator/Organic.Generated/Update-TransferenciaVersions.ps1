param(
    [string]$ProjectDirectory = ".",
    [string]$Version = "01.0001.00000"
)

# Función para normalizar la versión al formato 01.0001.00000
function Format-Version {
    param([string]$inputVersion)
    
    # Dividir la versión en componentes
    $parts = $inputVersion.Split('.')
    if ($parts.Length -ne 3) {
        Write-Warning "Versión debe tener formato x.y.z (ejemplo: 1.2.3 o 01.0002.0003)"
        return $inputVersion
    }
    
    # Formatear cada componente con padding de ceros
    $major = $parts[0].PadLeft(2, '0')      # 01
    $minor = $parts[1].PadLeft(4, '0')      # 0001  
    $build = $parts[2].PadLeft(5, '0')      # 00000
    
    $normalizedVersion = "$major.$minor.$build"
    Write-Host "Version normalizada: $inputVersion -> $normalizedVersion" -ForegroundColor Cyan
    return $normalizedVersion
}

# Normalizar la versión de entrada
$NormalizedVersion = Format-Version -inputVersion $Version

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificando archivos Din_Transferencia*Consulta.prg" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
$consultaFiles = Get-ChildItem -Path $ProjectDirectory -Filter "Din_Transferencia*Consulta.prg" -Recurse
Write-Host "Encontrados: $($consultaFiles.Count) archivos Consulta"

foreach ($file in $consultaFiles) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    if (Test-Path $file.FullName) {
        $content = Get-Content $file.FullName -Raw -Encoding Default
        $pattern = '<EstructuraEntidades Version="[\d\.]+"'
        $replacement = '<EstructuraEntidades Version="' + $NormalizedVersion + '"'
        $updated = $content -replace $pattern, $replacement
        if ($content -ne $updated) {
            Set-Content $file.FullName -Value $updated -NoNewline -Encoding Default
            Write-Host "  UPDATED: $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "  NO CHANGES: $($file.Name)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificando archivos Din_Transferencia*Objeto.prg" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
$objetoFiles = Get-ChildItem -Path $ProjectDirectory -Filter "Din_Transferencia*Objeto.prg" -Recurse
Write-Host "Encontrados: $($objetoFiles.Count) archivos Objeto"

foreach ($file in $objetoFiles) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    if (Test-Path $file.FullName) {
        $content = Get-Content $file.FullName -Raw -Encoding Default
        $pattern = '<EstructuraEntidades Version="[\d\.]+"'
        $replacement = '<EstructuraEntidades Version="' + $NormalizedVersion + '"'
        $updated = $content -replace $pattern, $replacement
        if ($content -ne $updated) {
            Set-Content $file.FullName -Value $updated -NoNewline -Encoding Default
            Write-Host "  UPDATED: $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "  NO CHANGES: $($file.Name)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificación de archivos Din_Transferencia* COMPLETADA" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
