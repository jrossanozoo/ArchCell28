param(
    [Parameter(Mandatory=$false)][string]$ProjectRoot = '.',
    [Parameter(Mandatory=$false)][string]$IconRelativePath = ''
)

$ErrorActionPreference = 'Stop'

function Write-Info { param([string]$msg); Write-Host "[ICON] $msg" -ForegroundColor Cyan }

function Get-RelativePath {
    param([string]$From, [string]$To)
    
    $from = $From.TrimEnd('\')
    $to = $To
    
    # Convertir a rutas absolutas
    if (-not [System.IO.Path]::IsPathRooted($from)) { $from = [System.IO.Path]::GetFullPath($from) }
    if (-not [System.IO.Path]::IsPathRooted($to)) { $to = [System.IO.Path]::GetFullPath($to) }
    
    $fromUri = New-Object System.Uri($from + "\")
    $toUri = New-Object System.Uri($to)
    
    $relativeUri = $fromUri.MakeRelativeUri($toUri)
    $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', '\')
    
    return $relativePath
}

try {
    if (-not (Test-Path $ProjectRoot)) { 
        Write-Host "[ERROR] ProjectRoot no existe: $ProjectRoot" -ForegroundColor Red
        exit 1 
    }
    
    $ProjectRoot = (Resolve-Path $ProjectRoot).Path
    
    # Si no se especificó icono, leerlo del archivo .vfpproj
    if ([string]::IsNullOrWhiteSpace($IconRelativePath)) {
        Write-Info "Leyendo icono desde archivo .vfpproj..."
        
        $vfpprojFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.vfpproj" -File
        if ($vfpprojFiles.Count -eq 0) {
            Write-Host "[ERROR] No se encontró archivo .vfpproj en: $ProjectRoot" -ForegroundColor Red
            exit 1
        }
        
        $vfpprojFile = $vfpprojFiles[0].FullName
        Write-Info "Proyecto encontrado: $($vfpprojFiles[0].Name)"
        
        # Leer ApplicationIcon del XML
        [xml]$projectXml = Get-Content $vfpprojFile
        $applicationIcon = $projectXml.Project.PropertyGroup.ApplicationIcon
        
        if ([string]::IsNullOrWhiteSpace($applicationIcon)) {
            Write-Host "[WARN] No se encontró <ApplicationIcon> en el proyecto" -ForegroundColor Yellow
            exit 0
        }
        
        $IconRelativePath = $applicationIcon
        Write-Info "Icono del proyecto: $IconRelativePath"
    }
    
    $iconPath = Join-Path $ProjectRoot $IconRelativePath
    
    if (-not (Test-Path $iconPath)) { 
        Write-Host "[WARN] Icono no encontrado: $iconPath" -ForegroundColor Yellow
        exit 0 
    }
    
    Write-Info "Icono corporativo verificado: $iconPath"
    
    # Aplicar ícono a DRAGONFISH.EXE usando Resource Tuner Console
    $outputDir = Join-Path $ProjectRoot "bin\Exe"
    $dragonfishExe = Join-Path $outputDir "DRAGONFISH.EXE"
    
    if (Test-Path $dragonfishExe) {
        Write-Info "Aplicando ícono a DRAGONFISH.EXE con Resource Tuner Console..."
        
        # Usar RTC desde Dovfp.Build.Tools
        $solutionRoot = Split-Path $ProjectRoot -Parent
        $rtcExe = Join-Path $solutionRoot "Dovfp.Build.Tools\RTC\rtc.exe"
        
        if (-not (Test-Path $rtcExe)) {
            Write-Host "[ERROR] RTC no encontrado en: $rtcExe" -ForegroundColor Red
            exit 1
        }
        
        # Crear script VBScript para RTC (sintaxis correcta)
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $scriptPath = Join-Path $ProjectRoot "bin\Exe\rtc_icon_$timestamp.rts"
        $logPath = Join-Path $ProjectRoot "bin\Exe\rtc_icon_$timestamp.log"
        
        # RTC REQUIERE rutas relativas desde el directorio donde se ejecuta el script
        # Cambiaremos al directorio bin\Exe para usar rutas relativas simples
        $exeRelPath = ".\DRAGONFISH.EXE"
        
        # Calcular ruta relativa del icono desde bin\Exe
        $iconRelPath = Get-RelativePath -From (Join-Path $ProjectRoot "bin\Exe") -To $iconPath
        
        # Escapar backslashes para VBScript
        $exePathVbs = $exeRelPath.Replace('\', '\\')
        $icoPathVbs = $iconRelPath.Replace('\', '\\')
        
        # Crear script VBScript con sintaxis correcta de RTC
        @"
'------------------------------------------------------------------------------
' Auto-generated RTC script: Apply application icon to DRAGONFISH.EXE
' Timestamp: $timestamp
'------------------------------------------------------------------------------
Sub Main
  PEFileProxy.PostDebugString "=== RTC Icon Replacement Script ==="
  PEFileProxy.PostDebugString "Target: $exeRelPath"
  PEFileProxy.PostDebugString "Icon: $iconRelPath"
  PEFileProxy.PostDebugString ""
  
  ' Configurar RTC
  PEFileProxy.UpdateCheckSum = True
  PEFileProxy.CreateBackUp = False
  
  ' Abrir archivo ejecutable
  PEFileProxy.PostDebugString "Opening PE file..."
  PEFileProxy.OpenFile "$exePathVbs"
  
  If (PEFileProxy.Terminated) Then
    PEFileProxy.PostDebugString "[ERROR] Failed to open PE file"
    Exit Sub
  End If
  
  PEFileProxy.PostDebugString "PE file opened successfully"
  
  If (Not PEFileProxy.HasResources) Then
    PEFileProxy.PostDebugString "[WARN] PE file has no resources section"
  Else
    ' Cambiar/agregar el icono principal de la aplicación
    PEFileProxy.PostDebugString "Replacing main application icon..."
    LangID = 0  ' Default language
    ResourcesProxy.ChangeIcon "", LangID, CREATE_IF_NOT_EXIST, REPLACE_IF_ITEM_EXISTS, "$icoPathVbs"
    
    ' Ordenar los íconos en el orden correcto
    PEFileProxy.PostDebugString "Sorting icon group..."
    ResourcesProxy.SortGroupIcon "", True
    
    ' Mostrar árbol de recursos modificado
    PEFileProxy.PostDebugString ""
    PEFileProxy.PostDebugString "Resource Tree after changes:"
    ResourcesProxy.ResourceTreeToLog
    PEFileProxy.PostDebugString ""
    
    ' Guardar archivo (in-place, sin cambiar nombre)
    PEFileProxy.PostDebugString "Saving PE file..."
    PEFileProxy.SaveAsNewImage "$exePathVbs"
    PEFileProxy.PostDebugString "[SUCCESS] Icon applied successfully"
  End If
  
  PEFileProxy.PostDebugString "Closing PE file..."
  PEFileProxy.CloseFile
  PEFileProxy.PostDebugString "=== RTC Script Completed ==="
End Sub
"@ | Out-File $scriptPath -Encoding ASCII
        
        # Ejecutar RTC con el script desde el directorio bin\Exe (para rutas relativas)
        Write-Info "Ejecutando RTC desde bin\Exe con rutas relativas..."
        $scriptName = Split-Path $scriptPath -Leaf
        $logName = Split-Path $logPath -Leaf
        
        Push-Location $outputDir
        try {
            $rtcArgs = @("/L:$logName", "/F:$scriptName")
        
            $process = Start-Process -FilePath $rtcExe -ArgumentList $rtcArgs -NoNewWindow -Wait -PassThru
        
            # Verificar resultado
            if ($process.ExitCode -eq 0) {
                Write-Info "✅ Ícono aplicado exitosamente a DRAGONFISH.EXE"
            
                # Mostrar log si existe y tiene errores/warnings
                if (Test-Path $logName) {
                    $logContent = Get-Content $logName -Raw
                    if ($logContent -match '\[ERROR\]|\[WARN\]|Failed|Error') {
                        Write-Host "[RTC LOG - Warnings/Errors]" -ForegroundColor Yellow
                        Write-Host $logContent -ForegroundColor Gray
                    }
                }
            } else {
                Write-Host "[ERROR] RTC falló con código de salida: $($process.ExitCode)" -ForegroundColor Red
                if (Test-Path $logName) {
                    Write-Host "[RTC LOG]" -ForegroundColor Red
                    Get-Content $logName | Write-Host -ForegroundColor Gray
                }
                exit 1
            }
        
            # Limpiar archivos temporales
            Remove-Item $scriptName -Force -EA SilentlyContinue
            Remove-Item $logName -Force -EA SilentlyContinue
        } finally {
            Pop-Location
        }
    }
    
    Write-Info "✅ DRAGONFISH_CORE.exe tiene el ícono embebido automáticamente (via ApplicationIcon)"
    Write-Info "ℹ️  Los archivos .app (no-PE) no pueden tener íconos embebidos"
    
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
