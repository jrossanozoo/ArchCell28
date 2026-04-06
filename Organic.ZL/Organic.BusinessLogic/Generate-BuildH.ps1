<#
.SYNOPSIS
    Genera archivo build.h con constantes de compilacion para Organic
.DESCRIPTION
    Script de prebuild que genera build.h con constantes de version.
    - Modo Debug: Usa valores mock para posiciones PBD
    - Modo Release: Conecta a SQL Server y ejecuta SP CalcularValores
.PARAMETER BuildDebug
    Modo de compilacion (1=Debug, 2=Release)
.PARAMETER Major
    Numero de version Major (viene de dovfp build)
.PARAMETER Minor
    Numero de version Minor/Release (viene de dovfp build)
.PARAMETER Build
    Numero de build (viene de dovfp build)
.PARAMETER ExeName
    Nombre del ejecutable sin extension
.PARAMETER OutputPath
    Ruta de salida para el archivo build.h
.PARAMETER SimularRefoxeo
    Si es true, agrega "_NOREFOXEADO" al nombre del ejecutable
.PARAMETER KeyVaultName
    Nombre del Azure Key Vault donde estan el endpoint y apikey.
.EXAMPLE
    .\Generate-BuildH.ps1 -BuildDebug 1 -Major 1 -Minor 0 -Build 12345 -ExeName "Organic.ZL"
.EXAMPLE
    .\Generate-BuildH.ps1 -BuildDebug 2 -Major 1 -Minor 0 -Build 12345 -ExeName "Organic.ZL" -KeyVaultName "mykeyvault"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateRange(1,2)]
    [int]$BuildDebug,

    [Parameter(Mandatory=$true)]
    [int]$Major,

    [Parameter(Mandatory=$true)]
    [int]$Minor,

    [Parameter(Mandatory=$true)]
    [int]$Build,

    [Parameter(Mandatory=$true)]
    [string]$ExeName,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory=$false)]
    [bool]$SimularRefoxeo = $false,

    [Parameter(Mandatory=$false)]
    [string]$KeyVaultName = ""
)

Set-StrictMode -Version Latest

# Configuración
$ErrorActionPreference = "Stop"
$ProjectPath = $PSScriptRoot
$AjusteFechaRC = 10
$isDebug = $BuildDebug -eq 1

# Determinar ruta de salida
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    # Si no se especifica, usar raíz del proyecto (compatibilidad)
    $BuildHPath = Join-Path $ProjectPath "build.h"
} else {
    # Resolver ruta completa desde el proyecto
    if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        # Ruta absoluta
        $OutputFullPath = $OutputPath.TrimEnd('\', '/')
    } else {
        # Ruta relativa al proyecto
        $OutputFullPath = Join-Path $ProjectPath $OutputPath.TrimEnd('\', '/')
    }
    if (-not (Test-Path $OutputFullPath)) {
        New-Item -ItemType Directory -Path $OutputFullPath -Force | Out-Null
    }
    $BuildHPath = Join-Path $OutputFullPath "build.h"
}

# Funciones auxiliares
function Get-PosicionesBuildMock {
    return @{
        PBD1 = "10"
        PBD2 = "5"
        PBD3 = "13"
        PBD4 = "18"
        S1 = "0"
        S2 = "0"
        S31 = "0"
        S41 = "0"
    }
}

function Get-CommonContent {
    param($Major, $Minor, $Build, $NombreExe, $Mes, $Anio)
    return @"
#DEFINE NUMEROMAJOR '$Major'
#DEFINE NUMERORELEASE '$Minor'
#DEFINE NUMEROBUILD '$Build'
#DEFINE NOMBREEXE '$NombreExe'
#DEFINE MESDELBUILD '$Mes'
#DEFINE ANIODELBUILD '$Anio'
"@
}

function Get-DebugContent {
    param($CommonContent)
    $posiciones = Get-PosicionesBuildMock
    $mockContent = @"
#DEFINE PBD1 $($posiciones.PBD1)
#DEFINE PBD2 $($posiciones.PBD2)
#DEFINE PBD3 $($posiciones.PBD3)
#DEFINE PBD4 $($posiciones.PBD4)
#DEFINE S1 $($posiciones.S1)
#DEFINE S2 $($posiciones.S2)
#DEFINE S31 $($posiciones.S31)
#DEFINE S41 $($posiciones.S41)
"@
    return $CommonContent + [Environment]::NewLine + $mockContent + [Environment]::NewLine
}

function Get-ReleaseContent {
    param($CommonContent)
    $releaseContent = @"
#DEFINE PBD1 $($env:PBD1)
#DEFINE PBD2 $($env:PBD2)
#DEFINE PBD3 $($env:PBD3)
#DEFINE PBD4 $($env:PBD4)
#DEFINE S1 $($env:S1)
#DEFINE S2 $($env:S2)
#DEFINE S31 $($env:S31)
#DEFINE S41 $($env:S41)
"@
    return $CommonContent + [Environment]::NewLine + $releaseContent + [Environment]::NewLine
}

# MAIN SCRIPT
Write-Host ""
Write-Host "======================================================="
Write-Host "  DOVFP - Generador build.h (Organic.ZL)"
Write-Host "======================================================="
Write-Host ""

try
{
    # Calcular fecha con ajuste
    $fecha = (Get-Date).AddDays($AjusteFechaRC)
    $culture = [System.Globalization.CultureInfo]::GetCultureInfo("es-ES")
    $mes = $culture.TextInfo.ToTitleCase($fecha.ToString("MMMM", $culture))
    $anio = $fecha.Year

    # Determinar nombre del EXE
    $nombreExe = $ExeName
    if ($SimularRefoxeo)
    {
        $nombreExe += "_NOREFOXEADO"
    }

    $nombreExe += ".EXE"

    # Eliminar archivo existente si existe y si estamos en modo debug solamente
    if (Test-Path $BuildHPath)
    {
        Remove-Item $BuildHPath -Force
        Write-Host "  Archivo anterior eliminado."
    }
    
    $commonContent = Get-CommonContent -Major $Major -Minor $Minor -Build $Build -NombreExe $nombreExe -Mes $mes -Anio $anio

    if ($isDebug)
    {
        $content = Get-DebugContent -CommonContent $commonContent
    }
    else
    {
        $content = Get-ReleaseContent -CommonContent $commonContent
    }

    # Escribir nuevo archivo con encoding UTF-8 sin BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($BuildHPath, $content, $utf8NoBom)
    
    # Verificar resultado
    if (Test-Path $BuildHPath)
    {
        $fileSize = (Get-Item $BuildHPath).Length
        Write-Host ""
        Write-Host "build.h generado exitosamente"
        Write-Host "  Ruta: $BuildHPath"
        Write-Host "  Tamanio: $fileSize bytes"
        Write-Host ""
        
        if ($fileSize -eq 0)
        {
            Write-Host "ERROR: El archivo esta vacio"
            exit 1
        }
    }
    else
    {
        Write-Host ""
        Write-Host "ERROR: El archivo NO se creo"
        Write-Host ""
        exit 1
    }

    exit 0
}
catch
{
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Stack Trace:"
    Write-Host $_.ScriptStackTrace
    Write-Host ""
    exit 1
}