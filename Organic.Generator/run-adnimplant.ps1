param(
    [Parameter(Position=0)]
    [string]$ClientId = " ",
    
    [Parameter()]
    [switch]$Clean,
    
    [Parameter()]
    [switch]$Validate
)

# Function to get OutputType from vfpproj file
function Get-OutputTypeFromProject {
    param(
        [string]$ProjectFolder
    )
    
    try {
        # Search for Organic.*.vfpproj files
        $vfprojFiles = Get-ChildItem -Path $ProjectFolder -Filter "Organic.*.vfpproj" -File
        
        if ($vfprojFiles.Count -eq 0) {
            Write-Host "[ERROR] No se encontró ningún archivo Organic.*.vfpproj en $ProjectFolder" -ForegroundColor Red
            exit 1
        }
        
        if ($vfprojFiles.Count -gt 1) {
			Write-Host "[ERROR] Se encontraron múltiples archivos .vfpproj en ${ProjectFolder}:" -ForegroundColor Red
			foreach ($file in $vfprojFiles) {
                Write-Host "  - $($file.Name)" -ForegroundColor Red
            }
            Write-Host "Solo debe existir un archivo Organic.*.vfpproj en esta carpeta." -ForegroundColor Red
            exit 1
        }
        
        # Read and parse the project file
        $vfprojPath = $vfprojFiles[0].FullName
        [xml]$projectXml = Get-Content $vfprojPath
        
        # Extract OutputType value
        $outputType = $projectXml.Project.PropertyGroup.OutputType | Where-Object { $_ -ne $null } | Select-Object -First 1
        
        if ([string]::IsNullOrWhiteSpace($outputType)) {
            Write-Host "[ERROR] No se encontró el elemento <OutputType> en $($vfprojFiles[0].Name)" -ForegroundColor Red
            exit 1
        }
        
        return $outputType
        
    } catch {
        Write-Host "[ERROR] al leer el archivo vfpproj: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Define the path to the executable directory relative to the current location
$projectFolder = Join-Path -Path $PSScriptRoot -ChildPath "Organic.BusinessLogic"
$outputType = Get-OutputTypeFromProject -ProjectFolder $projectFolder
$exePath = Join-Path -Path $PSScriptRoot -ChildPath "Organic.BusinessLogic\bin\$outputType"
$exeFile = Join-Path -Path $exePath -ChildPath "ZooLogicSA.AdnImplant.exe"
$dataConfigPath = Join-Path -Path $exePath -ChildPath "dataconfig.ini"
$logPath = Join-Path -Path $exePath -ChildPath "Log"
$xmlPath = Join-Path -Path $PSScriptRoot -ChildPath "Organic.Generated\Generados\datosestructuraadnpordefecto.xml"

# Function to read INI file
function Get-IniValue {
    param(
        [string]$FilePath,
        [string]$Key
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath
        foreach ($line in $content) {
            if ($line -match "^\s*$Key\s*=\s*(.+)\s*$") {
                return $matches[1].Trim()
            }
        }
    }
    return $null
}

# Function to set INI value
function Set-IniValue {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath
        $updated = $false
        
        for ($i = 0; $i -lt $content.Count; $i++) {
            if ($content[$i] -match "^\s*$Key\s*=") {
                $content[$i] = "$Key=$Value"
                $updated = $true
                break
            }
        }
        
        if ($updated) {
            $content | Set-Content $FilePath -Encoding UTF8
            return $true
        }
    }
    return $false
}

# Function to get expected databases from XML
function Get-ExpectedDatabases {
    param(
        [string]$XmlPath,
        [string]$Prefijo
    )
    
    $databases = @()
    
    if (Test-Path $XmlPath) {
        try {
            [xml]$xmlContent = Get-Content $XmlPath
            
            foreach ($base in $xmlContent.DatosEstructuraAdnPorDefecto.BasesDeDatosPorDefecto.BaseDeDatosPorDefecto) {
                $nombre = $base.Nombre
                $llevaPrefijo = $base.LlevaPrefijo -eq "true"
                $esEjemplo = $base.BaseDeEjemplo -eq "true"
                
                $nombreCompleto = if ($llevaPrefijo) { "${Prefijo}_${nombre}" } else { $nombre }
                
                $databases += [PSCustomObject]@{
                    NombreOriginal = $nombre
                    NombreCompleto = $nombreCompleto
                    LlevaPrefijo = $llevaPrefijo
                    EsEjemplo = $esEjemplo
                }
            }
        } catch {
            Write-Host "[ERROR] al leer XML: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    return $databases
}

# Function to check if database exists
function Test-DatabaseExists {
    param(
        [string]$ServerInstance,
        [string]$DatabaseName
    )
    
    try {
        $query = "SELECT name FROM sys.databases WHERE name = '$DatabaseName'"
        $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query -ErrorAction Stop
        return ($null -ne $result)
    } catch {
        return $false
    }
}

# Function to drop database
function Remove-Database {
    param(
        [string]$ServerInstance,
        [string]$DatabaseName
    )
    
    try {
        $query = @"
ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [$DatabaseName];
"@
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query -ErrorAction Stop
        return $true
    } catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Process Clean parameter
if ($Clean) {
    Write-Host "=== Modo CLEAN activado ===" -ForegroundColor Yellow
    Write-Host ""
    
    # Read configuration
    $nombreProducto = Get-IniValue -FilePath $dataConfigPath -Key "NombreProducto"
    $servidor = Get-IniValue -FilePath $dataConfigPath -Key "Servidor"
    $seguridadIntegrada = Get-IniValue -FilePath $dataConfigPath -Key "SeguridadIntegrada"
    
    # Update SeguridadIntegrada to SI
    if (Test-Path $dataConfigPath) {
        Write-Host "Configurando SeguridadIntegrada=SI en dataconfig.ini..." -ForegroundColor Cyan
        
        if (Set-IniValue -FilePath $dataConfigPath -Key "SeguridadIntegrada" -Value "SI") {
            Write-Host "[OK] SeguridadIntegrada actualizada a SI" -ForegroundColor Green
            $seguridadIntegrada = "SI"
        } else {
            Write-Host "[ERROR] No se pudo actualizar SeguridadIntegrada" -ForegroundColor Red
        }
    } else {
        Write-Host "[ERROR] No se encontro dataconfig.ini en $dataConfigPath" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # Drop databases if security is integrated
    if ($seguridadIntegrada -eq "SI" -and (Test-Path $xmlPath)) {
        Write-Host "Buscando bases de datos a eliminar..." -ForegroundColor Cyan
        
        $expectedDatabases = Get-ExpectedDatabases -XmlPath $xmlPath -Prefijo $nombreProducto
        
        if ($expectedDatabases.Count -gt 0) {
            Write-Host "Se encontraron $($expectedDatabases.Count) bases de datos definidas" -ForegroundColor Gray
            Write-Host ""
            
            foreach ($db in $expectedDatabases) {
                $exists = Test-DatabaseExists -ServerInstance $servidor -DatabaseName $db.NombreCompleto
                
                if ($exists) {
                    $tipo = if ($db.EsEjemplo) { "(ejemplo)" } else { "(sistema)" }
                    Write-Host "Base de datos encontrada: $($db.NombreCompleto) $tipo" -ForegroundColor Yellow
                    
                    $respuesta = Read-Host "  Desea eliminar esta base? (S/N)"
                    
                    if ($respuesta -eq "S" -or $respuesta -eq "s") {
                        Write-Host "  Eliminando $($db.NombreCompleto)..." -ForegroundColor Cyan
                        
                        if (Remove-Database -ServerInstance $servidor -DatabaseName $db.NombreCompleto) {
                            Write-Host "  [OK] Base eliminada" -ForegroundColor Green
                        } else {
                            Write-Host "  [ERROR] No se pudo eliminar la base" -ForegroundColor Red
                        }
                    } else {
                        Write-Host "  Base omitida" -ForegroundColor Gray
                    }
                    
                    Write-Host ""
                }
            }
        } else {
            Write-Host "[ADVERTENCIA] No se encontraron bases de datos definidas en el XML" -ForegroundColor Yellow
        }
    } elseif ($seguridadIntegrada -ne "SI") {
        Write-Host "[ADVERTENCIA] No se pueden eliminar bases (SeguridadIntegrada=NO)" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Si modo -Validate activado, solo validar sin ejecutar AdnImplant
if ($Validate) {
    Write-Host "=== Modo VALIDACION activado (sin ejecutar AdnImplant) ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Read configuration
    if (-not (Test-Path $dataConfigPath)) {
        Write-Host "[ERROR] No se encontro dataconfig.ini en $dataConfigPath" -ForegroundColor Red
        exit 1
    }
    
    $nombreProducto = Get-IniValue -FilePath $dataConfigPath -Key "NombreProducto"
    $servidor = Get-IniValue -FilePath $dataConfigPath -Key "Servidor"
    $seguridadIntegrada = Get-IniValue -FilePath $dataConfigPath -Key "SeguridadIntegrada"
    
    Write-Host "Producto: $nombreProducto" -ForegroundColor Gray
    Write-Host "Servidor: $servidor" -ForegroundColor Gray
    Write-Host "Seguridad Integrada: $seguridadIntegrada" -ForegroundColor Gray
    Write-Host "Archivo config: $dataConfigPath" -ForegroundColor Gray
    Write-Host ""
    
    # Verify databases
    Write-Host "Verificando bases de datos..." -ForegroundColor Cyan
    
    if ($seguridadIntegrada -ne "SI") {
        Write-Host "[ADVERTENCIA] SeguridadIntegrada=NO, validacion usa credenciales del dominio" -ForegroundColor Yellow
    }
    
    if (Test-Path $xmlPath) {
        $expectedDatabases = Get-ExpectedDatabases -XmlPath $xmlPath -Prefijo $nombreProducto
        
        if ($expectedDatabases.Count -gt 0) {
            $allFound = $true
            
            foreach ($db in $expectedDatabases) {
                $exists = Test-DatabaseExists -ServerInstance $servidor -DatabaseName $db.NombreCompleto
                
                if ($exists) {
                    $tipo = if ($db.EsEjemplo) { "(ejemplo)" } else { "(sistema)" }
                    Write-Host "  [OK] $($db.NombreCompleto) $tipo" -ForegroundColor Green
                } else {
                    Write-Host "  [ERROR] $($db.NombreCompleto) NO encontrada" -ForegroundColor Red
                    $allFound = $false
                }
            }
            
            Write-Host ""
            if ($allFound) {
                Write-Host "=== Validacion exitosa: todas las bases existen ===" -ForegroundColor Green
                exit 0
            } else {
                Write-Host "=== Validacion fallida: faltan bases de datos ===" -ForegroundColor Red
                Write-Host "Ejecute sin -Validate para crear las bases faltantes" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "  [ERROR] No se encontraron bases definidas en XML" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  [ERROR] No se encontro el archivo XML: $xmlPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host "=== Ejecutando AdnImplant ===" -ForegroundColor Cyan

# Verificar que el directorio de trabajo existe
if (-not (Test-Path $exePath)) {
    Write-Host ""
    Write-Host "[ERROR] No se encontro el directorio compilado: $exePath" -ForegroundColor Red
    Write-Host "Ejecute 'dovfp build' para compilar el proyecto primero" -ForegroundColor Yellow
    exit 1
}

# Verificar que el ejecutable existe
if (-not (Test-Path $exeFile)) {
    Write-Host ""
    Write-Host "[ERROR] No se encontro el ejecutable: $exeFile" -ForegroundColor Red
    Write-Host "Ejecute 'dovfp build' para compilar el proyecto primero" -ForegroundColor Yellow
    exit 1
}

# Execute the application with specified working directory
$process = Start-Process -FilePath $exeFile -ArgumentList $ClientId -WorkingDirectory $exePath -NoNewWindow -Wait -PassThru

Write-Host ""
Write-Host "=== Validando resultados ===" -ForegroundColor Cyan

# Read dataconfig.ini
if (Test-Path $dataConfigPath) {
    $nombreProducto = Get-IniValue -FilePath $dataConfigPath -Key "NombreProducto"
    $servidor = Get-IniValue -FilePath $dataConfigPath -Key "Servidor"
    $seguridadIntegrada = Get-IniValue -FilePath $dataConfigPath -Key "SeguridadIntegrada"
    
    Write-Host "Producto: $nombreProducto" -ForegroundColor Gray
    Write-Host "Servidor: $servidor" -ForegroundColor Gray
    Write-Host "Seguridad Integrada: $seguridadIntegrada" -ForegroundColor Gray
	Write-Host "Archivo config: $dataConfigPath" -ForegroundColor Gray


	# Check if we can verify database
    if ($seguridadIntegrada -eq "SI") {
        Write-Host ""
        Write-Host "Verificando bases de datos..." -ForegroundColor Cyan
        
        if (Test-Path $xmlPath) {
            $expectedDatabases = Get-ExpectedDatabases -XmlPath $xmlPath -Prefijo $nombreProducto
            
            if ($expectedDatabases.Count -gt 0) {
                $allFound = $true
                
                foreach ($db in $expectedDatabases) {
                    $exists = Test-DatabaseExists -ServerInstance $servidor -DatabaseName $db.NombreCompleto
                    
                    if ($exists) {
                        $tipo = if ($db.EsEjemplo) { "(ejemplo)" } else { "(sistema)" }
                        Write-Host "  [OK] $($db.NombreCompleto) $tipo" -ForegroundColor Green
                    } else {
                        Write-Host "  [ERROR] $($db.NombreCompleto) NO encontrada" -ForegroundColor Red
                        $allFound = $false
                    }
                }
                
                if (-not $allFound) {
                    $process.ExitCode = 1
                }
            } else {
                Write-Host "  [ADVERTENCIA] No se encontraron bases definidas en XML" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [ERROR] No se encontro el archivo XML: $xmlPath" -ForegroundColor Red
        }
    } else {
        Write-Host ""
        Write-Host "[ADVERTENCIA] No se puede verificar las bases de datos (SeguridadIntegrada=NO)" -ForegroundColor Yellow
        Write-Host "  Verifique manualmente las bases definidas en el XML" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ADVERTENCIA] No se encontro dataconfig.ini en $dataConfigPath" -ForegroundColor Yellow
}

# Show recent logs
if (Test-Path $logPath) {
    Write-Host ""
    Write-Host "=== Logs recientes ===" -ForegroundColor Cyan
    
    $logFiles = Get-ChildItem -Path $logPath -Filter "*.log" -File | 
                Sort-Object LastWriteTime -Descending | 
                Select-Object -First 3
    
    if ($logFiles) {
        foreach ($logFile in $logFiles) {
            Write-Host ""
            Write-Host "--- $($logFile.Name) (Modificado: $($logFile.LastWriteTime)) ---" -ForegroundColor Gray
            
            # Show last 20 lines of each log
            $logContent = Get-Content $logFile.FullName -Tail 20 -ErrorAction SilentlyContinue
            
            if ($logContent) {
                foreach ($line in $logContent) {
                    # Color-code errors and warnings
                    if ($line -match "error|exception|failed") {
                        Write-Host $line -ForegroundColor Red
                    } elseif ($line -match "warning|advertencia") {
                        Write-Host $line -ForegroundColor Yellow
                    } else {
                        Write-Host $line
                    }
                }
            }
        }
    } else {
        Write-Host "No se encontraron archivos de log" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "[ADVERTENCIA] No se encontro la carpeta de logs: $logPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Proceso finalizado con codigo: $($process.ExitCode) ===" -ForegroundColor Cyan

exit $process.ExitCode
