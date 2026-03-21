param(
    [Parameter()]
    [switch]$Validate
)

# ============================================================================
# install-test-prerequisites.ps1
# Instala los prerrequisitos necesarios para ejecutar tests de Organic.Core.
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

function Test-CrystalReports {
    try {
        $null = Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\CrystalRuntime.Application.11\CLSID" -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Test-FinePrint {
    $printers = Get-Printer -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*FinePrint*" }
    return ($null -ne $printers -and @($printers).Count -gt 0)
}

function Test-Msxml4 {
    try {
        $null = Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\Msxml2.DOMDocument.4.0\CLSID" -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Install-CrystalReports {
    $reportesPath = Join-Path $PSScriptRoot "Organic.Assets\componentes\Reportes"
    if (-not (Test-Path $reportesPath)) {
        Write-Host "  [SKIP] Carpeta no encontrada: $reportesPath" -ForegroundColor Yellow
        return
    }

    $installer = Get-ChildItem -Path $reportesPath -Filter "*.exe" | Select-Object -First 1
    if (-not $installer) {
        Write-Host "  [SKIP] No se encontro instalador .exe en $reportesPath" -ForegroundColor Yellow
        return
    }

    Write-Host "  Instalando: $($installer.Name)..." -ForegroundColor White
    $exitCode = Start-ProcessWithTimeout -FilePath $installer.FullName -ArgumentList '/s /v"REINSTALLMODE=omus /qn"'
    if ($exitCode -eq 0) {
        Write-Host "  [OK] Crystal Reports instalado correctamente" -ForegroundColor Green
    } elseif ($exitCode -eq -1) {
        Write-Host "  [ERROR] Crystal Reports: instalador colgado (timeout)" -ForegroundColor Red
        $script:HasErrors = $true
    } else {
        Write-Host "  [ERROR] Crystal Reports fallo con codigo: $exitCode" -ForegroundColor Red
        $script:HasErrors = $true
    }
}

function Install-FinePrint {
    $installer = Join-Path $PSScriptRoot "Organic.Assets\componentes\fineprint\setup-x64.exe"

    if (-not (Test-Path $installer)) {
        Write-Host "  [SKIP] Instalador no encontrado: $installer" -ForegroundColor Yellow
        return
    }

    Write-Host "  Instalando: setup-x64.exe..." -ForegroundColor White
    # FinePrint siempre se cuelga en CI/CD (no hay desktop session), usar timeout corto
    $exitCode = Start-ProcessWithTimeout -FilePath $installer -ArgumentList '/quiet=589' -Timeout 15
    if ($exitCode -eq -1) {
        Write-Host "  [WARN] FinePrint: instalador colgado (timeout). Probablemente requiere sesion de escritorio." -ForegroundColor Yellow
    } elseif ($exitCode -eq 0) {
        $installed = $false
        for ($i = 1; $i -le 10; $i++) {
            Start-Sleep -Seconds 3
            if (Test-FinePrint) {
                $installed = $true
                break
            }
        }
        if ($installed) {
            Write-Host "  [OK] FinePrint instalado correctamente" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] FinePrint instalado pero la impresora no aparece aun" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [ERROR] FinePrint fallo con codigo: $exitCode" -ForegroundColor Red
        $script:HasErrors = $true
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

# --- Crystal Reports ---
Write-Host "Crystal Reports Runtime:" -ForegroundColor White
if (Test-CrystalReports) {
    Write-Host "  [OK] Ya instalado" -ForegroundColor Green
} elseif ($Validate) {
    Write-Host "  [FALTA] No instalado. Ejecute: .\install-test-prerequisites.ps1" -ForegroundColor Red
    $script:HasErrors = $true
} else {
    Install-CrystalReports
}

# --- FinePrint ---
Write-Host "FinePrint:" -ForegroundColor White
if (Test-FinePrint) {
    Write-Host "  [OK] Ya instalado" -ForegroundColor Green
} elseif ($Validate) {
    Write-Host "  [FALTA] No instalado. Ejecute: .\install-test-prerequisites.ps1" -ForegroundColor Red
    $script:HasErrors = $true
} else {
    Install-FinePrint
}

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
