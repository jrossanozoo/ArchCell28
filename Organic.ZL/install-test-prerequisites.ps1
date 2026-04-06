param(
    [Parameter()]
    [switch]$Validate
)

# ============================================================================
# install-test-prerequisites.ps1
# Instala los prerrequisitos necesarios para ejecutar tests de Organic.ZL.
#
# Uso local:    .\install-test-prerequisites.ps1
# Solo validar: .\install-test-prerequisites.ps1 -Validate
# Pipeline:     mainTest.prg lo ejecuta automaticamente antes de los tests
# ============================================================================

$ErrorActionPreference = "Stop"
$script:HasErrors = $false
$script:TimeoutSeconds = 120

# Helper: ejecuta un proceso con timeout. Mata el proceso si se cuelga.
function Start-ProcessWithTimeout {
    param(
        [string]$FilePath,
        [string]$ArgumentList,
        [int]$Timeout = $script:TimeoutSeconds
    )
    $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -PassThru -WindowStyle Hidden
    $exited = $process.WaitForExit($Timeout * 1000)
    if (-not $exited) {
        Write-Host "  [TIMEOUT] Proceso colgado tras ${Timeout}s, matando PID $($process.Id)..." -ForegroundColor Yellow
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        return -1
    }
    return $process.ExitCode
}

function Test-Msxml4 {
    try {
        $null = Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\Msxml2.DOMDocument.4.0\CLSID" -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Install-Msxml4 {
    $msi = Join-Path $PSScriptRoot "Organic.Assets\componentes\msxml4\msxml.msi"

    if (-not (Test-Path $msi)) {
        Write-Host "  [SKIP] Instalador no encontrado: $msi" -ForegroundColor Yellow
        Write-Host "  Descargue MSXML4 SP3 de Microsoft y coloque msxml.msi en:" -ForegroundColor Yellow
        Write-Host "    $(Split-Path $msi)" -ForegroundColor Yellow
        return
    }

    Write-Host "  Instalando: msxml.msi..." -ForegroundColor White
    $exitCode = Start-ProcessWithTimeout -FilePath "msiexec.exe" -ArgumentList "/i `"$msi`" /quiet /norestart"
    if ($exitCode -eq 0) {
        Write-Host "  [OK] MSXML4 instalado correctamente" -ForegroundColor Green
    } elseif ($exitCode -eq -1) {
        Write-Host "  [ERROR] MSXML4: instalador colgado (timeout)" -ForegroundColor Red
        $script:HasErrors = $true
    } else {
        Write-Host "  [ERROR] MSXML4 fallo con codigo: $exitCode" -ForegroundColor Red
        $script:HasErrors = $true
    }
}

# ============================================================================
# Main
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Prerequisitos de Tests - Organic.Core" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- MSXML4 ---
Write-Host "MSXML4 SP3:" -ForegroundColor White
if (Test-Msxml4) {
    Write-Host "  [OK] Ya instalado" -ForegroundColor Green
} elseif ($Validate) {
    Write-Host "  [FALTA] No instalado. Ejecute: .\install-test-prerequisites.ps1" -ForegroundColor Red
    $script:HasErrors = $true
} else {
    Install-Msxml4
}

Write-Host ""
if ($script:HasErrors) {
    Write-Host "[ERROR] Hay prerequisitos faltantes o con errores de instalacion" -ForegroundColor Red
    exit 1
} else {
    Write-Host "[OK] Todos los prerequisitos verificados correctamente" -ForegroundColor Green
    exit 0
}
