# start-localdb.ps1
# Script para iniciar LocalDB antes de trabajar con Organic.Core

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando LocalDB para Organic.Core  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si sqllocaldb está disponible
if (-not (Get-Command sqllocaldb -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: sqllocaldb no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Instalá SQL Server LocalDB desde Visual Studio Installer" -ForegroundColor Yellow
    exit 1
}

# Obtener estado actual
$info = sqllocaldb info MSSQLLocalDB 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "La instancia MSSQLLocalDB no existe. Creándola..." -ForegroundColor Yellow
    sqllocaldb create MSSQLLocalDB
}

# Iniciar la instancia
Write-Host "Iniciando instancia MSSQLLocalDB..." -ForegroundColor Yellow
sqllocaldb start MSSQLLocalDB 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ LocalDB iniciado correctamente" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar info
    sqllocaldb info MSSQLLocalDB
    
    Write-Host ""
    Write-Host "Conexión: (localdb)\MSSQLLocalDB" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "ERROR: No se pudo iniciar LocalDB" -ForegroundColor Red
    exit 1
}
