#Requires -Version 5.1
<#
.SYNOPSIS
    Transforma tests legacy para usar FxuTestCaseLegacy en lugar de FxuTestCase

.DESCRIPTION
    Este script:
    1. Copia archivos de Tests.Legacy/ a Tests.Legacy.Temp/
    2. Analiza cada archivo y solo transforma si hereda de FxuTestCase
    3. Reemplaza la herencia por FxuTestCaseLegacy

    Los archivos originales NUNCA se modifican.

.PARAMETER Clean
    Si se especifica, solo limpia la carpeta temporal sin regenerar

.PARAMETER Verbose
    Muestra información detallada del proceso

.EXAMPLE
    .\transform-legacy-tests.ps1

.EXAMPLE
    .\transform-legacy-tests.ps1 -Clean
#>

[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$DryRun
)

# Configuración
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
if (-not $ProjectRoot) {
    $ProjectRoot = "C:\ZooLogicSA.Repos\GIT\Organic\Organic.Core\Organic.Tests"
}

$SourceFolder = Join-Path $ProjectRoot "Tests.Legacy"
$TempFolder = Join-Path $ProjectRoot ".legacy-tests-build"

# Patrones de búsqueda y reemplazo (case insensitive)
$SearchPatterns = @(
    @{
        # Patrón: as FxuTestCase OF FxuTestCase.prg (con variaciones de espacios y case)
        Search = '(?i)(as\s+)FxuTestCase(\s+OF\s+)FxuTestCase(\.prg)'
        Replace = '${1}FxuTestCaseLegacy${2}FxuTestCaseLegacy${3}'
        Description = "Herencia de clase FxuTestCase OF FxuTestCase.prg"
    },
    @{
        # Patrón: LOCAL this as FxuTestCase OF FxuTestCase.prg
        Search = '(?i)(LOCAL\s+\w+\s+as\s+)FxuTestCase(\s+OF\s+)FxuTestCase(\.prg)'
        Replace = '${1}FxuTestCaseLegacy${2}FxuTestCaseLegacy${3}'
        Description = "Declaración LOCAL de FxuTestCase"
    }
)

# Función para mostrar mensajes
function Write-Info {
    param([string]$Message, [string]$Type = "Info")

    $color = switch ($Type) {
        "Info" { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Transform" { "Magenta" }
        default { "White" }
    }

    Write-Host $Message -ForegroundColor $color
}

# Función para limpiar carpeta temporal
function Clear-TempFolder {
    if (Test-Path $TempFolder) {
        Write-Info "Limpiando carpeta temporal: $TempFolder" "Warning"
        Remove-Item -Path $TempFolder -Recurse -Force
        Write-Info "Carpeta temporal eliminada" "Success"
    } else {
        Write-Info "Carpeta temporal no existe, nada que limpiar" "Info"
    }
}

# Función para verificar si un archivo necesita transformación
function Test-NeedsTransformation {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }

    foreach ($pattern in $SearchPatterns) {
        if ($content -match $pattern.Search) {
            return $true
        }
    }
    return $false
}

# Función para transformar un archivo
function Convert-LegacyTestFile {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$RelativePathToRoot  # Path relativo desde el archivo hasta la raíz de .legacy-tests-build
    )

    $content = Get-Content $SourcePath -Raw
    $originalContent = $content
    $transformations = @()

    # FxuTestCaseLegacy.prg está en bin/ al lado de la APP, no necesita path relativo
    $legacyPath = "FxuTestCaseLegacy.prg"

    # Patrones específicos con el path relativo calculado
    $dynamicPatterns = @(
        @{
            Search = '(?i)(as\s+)FxuTestCase(\s+OF\s+)FxuTestCase(\.prg)'
            Replace = "`${1}FxuTestCaseLegacy`${2}$legacyPath"
            Description = "Herencia de clase con path relativo: $legacyPath"
        },
        @{
            Search = '(?i)(LOCAL\s+\w+\s+as\s+)FxuTestCase(\s+OF\s+)FxuTestCase(\.prg)'
            Replace = "`${1}FxuTestCaseLegacy`${2}$legacyPath"
            Description = "Declaración LOCAL con path relativo"
        }
    )

    foreach ($pattern in $dynamicPatterns) {
        if ($content -match $pattern.Search) {
            $content = $content -replace $pattern.Search, $pattern.Replace
            $transformations += $pattern.Description
        }
    }

    # Solo escribir si hubo cambios
    if ($content -ne $originalContent) {
        if (-not $DryRun) {
            # Asegurar que el directorio destino existe
            $destDir = Split-Path -Parent $DestPath
            if (-not (Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            Set-Content -Path $DestPath -Value $content -NoNewline
        }
        return @{
            Transformed = $true
            Transformations = $transformations
        }
    }

    return @{
        Transformed = $false
        Transformations = @()
    }
}

# Función principal
function Start-LegacyTestTransformation {
    Write-Info "============================================" "Info"
    Write-Info "  TRANSFORM LEGACY TESTS FOR DOVFP" "Info"
    Write-Info "============================================" "Info"
    Write-Info ""
    Write-Info "Proyecto: $ProjectRoot" "Info"
    Write-Info "Fuente:   $SourceFolder" "Info"
    Write-Info "Destino:  $TempFolder" "Info"
    Write-Info ""

    # Verificar que existe la carpeta fuente
    if (-not (Test-Path $SourceFolder)) {
        Write-Info "ERROR: No se encuentra la carpeta Tests.Legacy" "Error"
        exit 1
    }

    # Limpiar carpeta temporal existente
    Clear-TempFolder

    if ($Clean) {
        Write-Info "Modo limpieza completado" "Success"
        return
    }

    # Crear carpeta temporal
    Write-Info "Creando carpeta temporal..." "Info"
    New-Item -Path $TempFolder -ItemType Directory -Force | Out-Null

    # Obtener todos los archivos .prg de Tests.Legacy
    $prgFiles = Get-ChildItem -Path $SourceFolder -Filter "*.prg" -Recurse

    Write-Info ""
    Write-Info "Archivos PRG encontrados: $($prgFiles.Count)" "Info"
    Write-Info ""

    $stats = @{
        Total = $prgFiles.Count
        Transformed = 0
        Skipped = 0
        Copied = 0
    }

    foreach ($file in $prgFiles) {
        # Calcular ruta relativa y destino
        $relativePath = $file.FullName.Substring($SourceFolder.Length).TrimStart('\', '/')
        $destPath = Join-Path $TempFolder $relativePath

        # Calcular path relativo desde el archivo hasta la raíz de .legacy-tests-build
        # Ejemplo: _AdnImplant\test\ztestfuncion_alltrim.prg -> ..\..
        $fileDir = Split-Path -Parent $relativePath
        if ($fileDir) {
            $depth = ($fileDir -split '[\\/]').Count
            $relativeToRoot = (@("..") * $depth) -join "\"
        } else {
            $relativeToRoot = ""
        }

        # Verificar si necesita transformación
        if (Test-NeedsTransformation -FilePath $file.FullName) {
            $result = Convert-LegacyTestFile -SourcePath $file.FullName -DestPath $destPath -RelativePathToRoot $relativeToRoot

            if ($result.Transformed) {
                $stats.Transformed++
                if ($VerbosePreference -eq 'Continue' -or $DryRun) {
                    Write-Info "  [TRANSFORM] $relativePath" "Transform"
                    foreach ($t in $result.Transformations) {
                        Write-Info "              -> $t" "Transform"
                    }
                }
            }
        } else {
            # Copiar sin transformar (archivos que no heredan de FxuTestCase)
            if (-not $DryRun) {
                $destDir = Split-Path -Parent $destPath
                if (-not (Test-Path $destDir)) {
                    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                }
                Copy-Item -Path $file.FullName -Destination $destPath -Force
            }
            $stats.Copied++
            if ($VerbosePreference -eq 'Continue') {
                Write-Info "  [COPY]      $relativePath" "Info"
            }
        }
    }

    # Copiar archivos no-PRG (DBF, etc.)
    $otherFiles = Get-ChildItem -Path $SourceFolder -Exclude "*.prg" -File -Recurse
    foreach ($file in $otherFiles) {
        $relativePath = $file.FullName.Substring($SourceFolder.Length).TrimStart('\', '/')
        $destPath = Join-Path $TempFolder $relativePath

        if (-not $DryRun) {
            $destDir = Split-Path -Parent $destPath
            if (-not (Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $destPath -Force
        }
    }

    # NOTA: Los archivos de infraestructura (FxuTestCaseLegacy.prg, MockSetupRegistry.prg, etc.)
    # NO se copian aquí. Se copian a bin/ durante el build y se cargan via SET PROCEDURE en maintest.prg

    # Resumen
    Write-Info ""
    Write-Info "============================================" "Info"
    Write-Info "  RESUMEN" "Info"
    Write-Info "============================================" "Info"
    Write-Info "Total archivos PRG:    $($stats.Total)" "Info"
    Write-Info "Transformados:         $($stats.Transformed)" "Transform"
    Write-Info "Copiados sin cambios:  $($stats.Copied)" "Info"
    Write-Info ""

    if ($DryRun) {
        Write-Info "MODO DRY-RUN: No se realizaron cambios reales" "Warning"
    } else {
        Write-Info "Transformación completada exitosamente!" "Success"
        Write-Info ""
        Write-Info "SIGUIENTE PASO:" "Warning"
        Write-Info "  El .vfpproj debe apuntar a Tests.Legacy.Temp/ en lugar de Tests.Legacy/" "Info"
    }
}

# Ejecutar
Start-LegacyTestTransformation
