param(
    [string]$Version = "01.0001.00000",
    [string]$FilePath = "Generados\Din_Estructuraadn.prg"
)

# Funcion para normalizar la version al formato 01.0001.00000
function Format-Version {
    param([string]$inputVersion)
    
    # Dividir la version en componentes
    $parts = $inputVersion.Split('.')
    if ($parts.Length -ne 3) {
        Write-Warning "Version debe tener formato x.y.z (ejemplo: 1.2.3 o 01.0002.0003)"
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

# Normalizar la version de entrada
$NormalizedVersion = Format-Version -inputVersion $Version

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificando Din_Estructuraadn.prg" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "Archivo: $FilePath"
Write-Host "Version: $NormalizedVersion"

if (Test-Path $FilePath) {
    Write-Host "Archivo encontrado" -ForegroundColor Green
    $content = Get-Content $FilePath -Raw -Encoding Default
    $pattern = "Return\s+['`"][\d\.]+['`"]"
    $replacement = "Return '$NormalizedVersion'"
    $updated = $content -replace $pattern, $replacement
    
    if ($content -ne $updated) {
        Set-Content $FilePath -Value $updated -NoNewline -Encoding Default
        Write-Host "MODIFICADO: Din_Estructuraadn.prg version actualizada a $NormalizedVersion" -ForegroundColor Green
    } else {
        Write-Host "SIN CAMBIOS: Version ya correcta o patron no encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: Archivo no encontrado: $FilePath" -ForegroundColor Red
    Write-Host "Script fallido - archivo PRG no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificando din_estructuraadn.xml" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
$xmlFilePath = "Generados\din_estructuraadn.xml"
Write-Host "Archivo XML: $xmlFilePath"

if (Test-Path $xmlFilePath) {
    Write-Host "Archivo XML encontrado" -ForegroundColor Green
    $xmlContent = Get-Content $xmlFilePath -Raw -Encoding UTF8
    
    # Extraer componentes de la version para diferentes campos
    $versionParts = $NormalizedVersion.Split('.')
    $majorNumber = [int]$versionParts[0]    # 01 -> 1 (sin ceros a la izquierda)
    $minorNumber = [int]$versionParts[1]    # 0002 -> 2 (sin ceros a la izquierda)
    $buildNumber = [int]$versionParts[2]    # 00003 -> 3 (sin ceros a la izquierda)
    
    # Actualizar <Version>
    $xmlPattern1 = '<Version>[\d\.]+</Version>'
    $xmlReplacement1 = "<Version>$NormalizedVersion</Version>"
    $xmlUpdated = $xmlContent -replace $xmlPattern1, $xmlReplacement1
    
    # Actualizar <Build> (contenido entre las etiquetas, puede tener saltos de linea)
    $xmlPattern2 = '(?s)<Build>[\s\d]*</Build>'
    $xmlReplacement2 = "<Build>$buildNumber</Build>"
    $xmlUpdated = $xmlUpdated -replace $xmlPattern2, $xmlReplacement2
    
    # Actualizar <Major>
    $xmlPattern3 = '<Major>\s*[\d]*\s*</Major>'
    $xmlReplacement3 = "<Major>$majorNumber</Major>"
    $xmlUpdated = $xmlUpdated -replace $xmlPattern3, $xmlReplacement3
    
    # Actualizar <Release> (que deberia contener el minor)
    $xmlPattern4 = '<Release>\s*[\d]*\s*</Release>'
    $xmlReplacement4 = "<Release>$minorNumber</Release>"
    $xmlUpdated = $xmlUpdated -replace $xmlPattern4, $xmlReplacement4
    
    if ($xmlContent -ne $xmlUpdated) {
        Set-Content $xmlFilePath -Value $xmlUpdated -NoNewline -Encoding UTF8
        Write-Host "MODIFICADO: din_estructuraadn.xml - Version:$NormalizedVersion, Major:$majorNumber, Release:$minorNumber, Build:$buildNumber" -ForegroundColor Green
    } else {
        Write-Host "SIN CAMBIOS: Version XML y componentes ya correctos" -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: Archivo XML no encontrado: $xmlFilePath" -ForegroundColor Red
    Write-Host "Nota: XML file not found but PRG was processed successfully" -ForegroundColor Yellow
    # Don't exit with error code here as this is optional
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "PRE-BUILD: Modificacion de archivos COMPLETADA" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Explicit success exit
exit 0
