---
description: "Corrección masiva de referencias LoadReference para clases VCX según archivos de símbolos de DOVFP"
tools: ["read_file", "grep_search", "run_in_terminal", "replace_string_in_file", "file_search"]
applyTo: ["**/*.prg"]
argument-hint: "Especifica la carpeta o archivo con herencia VCX a corregir"
---

# 🔧 Corrección de Referencias VCX LoadReference

## 🎯 Objetivo

Corregir automáticamente las referencias `_screen._instanceFactory.LoadReference()` en archivos que heredan de clases VCX, validando contra los archivos de símbolos de DOVFP para determinar la app correcta (Organic.Core.app, Organic.Drawing.app, Organic.Feline.app, etc.).

**🤖 Automación completa**: Este prompt incluye el script PowerShell inline. Solo es necesario copiar el prompt, no archivos adicionales.

---

## 📋 Contexto del Problema

Cuando una clase VFP hereda de una clase visual (.vcx), necesita una referencia explícita a la APP que contiene ese VCX:

```foxpro
_screen._instanceFactory.LoadReference('MiClase.vcx', "Organic.Core.app")

define class MiFormulario as MiClase of MiClase.vcx
    * código de la clase
enddefine
```

**Problema**: Determinar qué APP contiene cada VCX cuando hay múltiples APPs en el sistema.

**Solución**: Usar los archivos `.symbols` generados por DOVFP que indexan qué VCX está en cada APP.

---

## 🚀 Proceso de Corrección (Totalmente Automatizado)

### ⚙️ Instrucciones para GitHub Copilot

1. **Crear script temporal** con el código PowerShell incluido en la sección "Script de Análisis"
2. **Ejecutar el script** para generar `vcx-mapeo.json`
3. **Leer el mapeo** desde el JSON generado
4. **Corregir los archivos** usando `replace_string_in_file` para cada archivo incorrecto
5. **Eliminar archivos temporales**: script `.ps1` y `vcx-mapeo.json`

---

### 📊 Script de Análisis (Incluido en Prompt)

### Paso 1: Identificar Archivos con Patrón VCX

Buscar todos los archivos que contienen el patrón:

```foxpro
define class <ClassName> as <BaseClass> of <VCXFile>.vcx
```

**Script PowerShell**:
```powershell
cd "ruta/a/archivos"
$archivos = Get-ChildItem "*.prg"
$todasLasClases = @()

foreach($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName -Raw
    if($contenido -match "define\s+class\s+(\S+)\s+as\s+(\S+)\s+of\s+(\S+\.vcx)") {
        $obj = New-Object PSObject -Property @{
            Archivo=$archivo.Name
            ClassName=$matches[1]
            BaseClass=$matches[2]
            VCXFile=$matches[3]
        }
        $todasLasClases += $obj
    }
}

Write-Host "Clases encontradas: $($todasLasClases.Count)"
$todasLasClases | Format-Table -AutoSize
```

### Paso 2: Extraer VCX Únicos

```powershell
$vcxUnicos = $todasLasClases | 
    Select-Object -ExpandProperty VCXFile | 
    Sort-Object -Unique

Write-Host "VCX únicos: $($vcxUnicos.Count)"
$vcxUnicos | ForEach-Object { Write-Host "  $_" }
```

### Paso 3: Buscar VCX en Archivos de Símbolos

**Ubicación de símbolos**: `packages/Exe/*.symbols`

**IMPORTANTE**: Pedir a Copilot que ejecute este script completo que hace todo el análisis:

```powershell
# Script autocontenido - copiar y ejecutar completo
$symbolsPath = "packages\Exe"  # Ajustar según tu proyecto
$sourcePath = "."  # Directorio actual o ajustar
$apps = @("Organic.Core", "Organic.Drawing", "Organic.Feline", "Organic.Generator")

Write-Host "`n=== ANÁLISIS VCX -> APP ===" -ForegroundColor Cyan

# 1. Extraer VCX únicos
$archivos = Get-ChildItem -Path $sourcePath -Filter "*.prg" -Recurse
$vcxUnicos = @()
foreach($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName -Raw
    if($contenido -match "define\s+class\s+\S+\s+as\s+\S+\s+of\s+(\S+\.vcx)") {
        $vcxUnicos += $matches[1]
    }
}
$vcxUnicos = $vcxUnicos | Sort-Object -Unique

Write-Host "VCX encontrados: $($vcxUnicos.Count)" -ForegroundColor Green

# 2. Buscar en símbolos
$mapeo = @{}
foreach($vcx in $vcxUnicos) {
    $encontrado = $false
    foreach($app in $apps) {
        $symbolFile = Join-Path $symbolsPath "$app.symbols"
        if(Test-Path $symbolFile) {
            $found = Get-Content $symbolFile | Select-String -Pattern ([regex]::Escape($vcx)) -Quiet
            if($found) {
                $mapeo[$vcx] = "$app.app"
                $encontrado = $true
                Write-Host "  ✓ $vcx -> $app.app" -ForegroundColor Green
                break
            }
        }
    }
    if(-not $encontrado) {
        $localFile = Get-ChildItem -Path $sourcePath -Filter $vcx -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if($localFile) {
            $mapeo[$vcx] = "LOCAL"
            Write-Host "  ⚠ $vcx -> LOCAL (sin LoadReference)" -ForegroundColor Yellow
        } else {
            $mapeo[$vcx] = "NO_ENCONTRADO"
            Write-Host "  ✗ $vcx -> NO ENCONTRADO" -ForegroundColor Red
        }
    }
}

# 3. Verificar estado actual
Write-Host "`n=== VERIFICACIÓN ===" -ForegroundColor Cyan
$incorrectos = @()
foreach($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName -Raw
    if($contenido -match "define\s+class\s+\S+\s+as\s+\S+\s+of\s+(\S+\.vcx)") {
        $vcx = $matches[1]
        if($contenido -match "LoadReference\('$([regex]::Escape($vcx))',\s*`"([^`"]+)`"") {
            $appActual = $matches[1]
            $appCorrecto = $mapeo[$vcx]
            if($appCorrecto -and $appCorrecto -ne "NO_ENCONTRADO" -and $appActual -ne $appCorrecto) {
                $incorrectos += [PSCustomObject]@{
                    Archivo=$archivo.Name
                    VCX=$vcx
                    Actual=$appActual
                    Correcto=$appCorrecto
                }
            }
        }
    }
}

if($incorrectos.Count -gt 0) {
    Write-Host "`nARCHIVOS A CORREGIR: $($incorrectos.Count)" -ForegroundColor Yellow
    $incorrectos | Format-Table -AutoSize
} else {
    Write-Host "`n✅ TODOS LOS ARCHIVOS CORRECTOS" -ForegroundColor Green
}

# 4. Exportar mapeo para uso de Copilot
$mapeo | ConvertTo-Json | Out-File "vcx-mapeo.json" -Encoding UTF8
Write-Host "`nMapeo exportado: vcx-mapeo.json" -ForegroundColor Cyan
```

### Paso 4: Verificar Estado Actual

```powershell
$correctos = 0
$incorrectos = 0
$sinLoadRef = 0
$noEncontrado = 0
$resultados = @()

Get-ChildItem "*.prg" | ForEach-Object {
    $archivo = $_.Name
    $contenido = Get-Content $_.FullName -Raw
    
    if($contenido -match "define\s+class\s+\S+\s+as\s+\S+\s+of\s+(\S+\.vcx)") {
        $vcx = $matches[1]
        
        if($contenido -match "LoadReference\('$([regex]::Escape($vcx))',\s*`"([^`"]+)`"") {
            $appActual = $matches[1]
            $appCorrecto = $mapeo[$vcx]
            
            if($appCorrecto) {
                if($appActual -eq $appCorrecto) {
                    $correctos++
                } else {
                    $incorrectos++
                    $resultados += "$archivo | $vcx | Actual: $appActual | Correcto: $appCorrecto"
                }
            } else {
                $noEncontrado++
                $resultados += "$archivo | $vcx | Actual: $appActual | NO_ENCONTRADO"
            }
        } else {
            $sinLoadRef++
        }
    }
}

Write-Host "`n=== VERIFICACIÓN ===" -ForegroundColor Cyan
Write-Host "✅ Correctos: $correctos" -ForegroundColor Green
Write-Host "❌ Incorrectos: $incorrectos" -ForegroundColor Red
Write-Host "⚠️  Sin LoadReference: $sinLoadRef" -ForegroundColor Yellow
Write-Host "🔍 VCX no encontrado: $noEncontrado" -ForegroundColor Magenta

if($resultados.Count -gt 0) {
    Write-Host "`nARCHIVOS QUE NECESITAN CORRECCIÓN:" -ForegroundColor Yellow
    $resultados | ForEach-Object { Write-Host "  $_" }
}
```

### Paso 5: Aplicar Correcciones

**Usando herramientas de GitHub Copilot en VS Code**:

Pedir a Copilot que corrija los archivos usando `replace_string_in_file`:

```markdown
Necesito que corrijas las referencias LoadReference en estos archivos según el mapeo:

ARCHIVO | VCX | APP_ACTUAL | APP_CORRECTA
--------|-----|------------|-------------
Frm_Archivo1.prg | Usuarios.vcx | Organic.Drawing.app | Organic.Core.app
Frm_Archivo2.prg | Cheques.vcx | Organic.Drawing.app | Organic.Feline.app

Para cada archivo:
1. Lee el contenido actual
2. Reemplaza la línea LoadReference con la app correcta
3. Mantén el resto del código sin cambios
```

---

## 🎨 Casos Especiales

### Caso 1: VCX Local (en el proyecto actual)

**Acción**: **ELIMINAR** la línea LoadReference completa

```foxpro
// ANTES
_screen._instanceFactory.LoadReference('MiClaseLocal.vcx', "Organic.Drawing.app")

define class MiFormulario as MiClaseLocal of MiClaseLocal.vcx

// DESPUÉS
define class MiFormulario as MiClaseLocal of MiClaseLocal.vcx
```

### Caso 2: VCX No Encontrado

**Acción**: **NO MODIFICAR** - Reportar para revisión manual

**Recomendaciones**:
1. Verificar si es código obsoleto
2. Buscar si el VCX fue renombrado
3. Revisar historial Git: `git log --all --full-history -- "**/MiClase.vcx"`
4. Verificar si falta agregar el VCX al proyecto

### Caso 3: Archivo sin LoadReference pero VCX en APP Externa

**Acción**: **AGREGAR** línea LoadReference al inicio de la clase

```foxpro
// ANTES
define class MiFormulario as ClaseExterna of ClaseExterna.vcx

// DESPUÉS
_screen._instanceFactory.LoadReference('ClaseExterna.vcx', "Organic.Core.app")

define class MiFormulario as ClaseExterna of ClaseExterna.vcx
```

---

## 📊 Validación Post-Corrección

### 1. Compilar el Proyecto

```powershell
cd "C:\ruta\al\proyecto"
dovfp build -path NombreDelProyecto
```

**NO usar** `dovfp clean` porque elimina los archivos de símbolos.

### 2. Verificar Errores

```powershell
$errFile = ".\obj\Exe\Proyecto.err"

if(Test-Path $errFile) {
    $errors = Get-Content $errFile
    $misArchivos = $errors | Select-String "Archivo.*\.prg"
    
    if($misArchivos) {
        Write-Host "❌ HAY ERRORES EN ARCHIVOS MODIFICADOS" -ForegroundColor Red
        $misArchivos
    } else {
        Write-Host "✅ NO HAY ERRORES EN ARCHIVOS MODIFICADOS" -ForegroundColor Green
    }
}
```

### 3. Verificar Cobertura

```powershell
# Contar archivos procesados vs total
$total = (Get-ChildItem "*.prg" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match "of\s+\S+\.vcx" }).Count

$procesados = (Get-ChildItem "*.prg" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match "LoadReference" }).Count

Write-Host "Total archivos con VCX: $total"
Write-Host "Archivos con LoadReference: $procesados"
Write-Host "Cobertura: $(($procesados / $total * 100).ToString('0.0'))%"
```

---

## 📝 Plantilla de Instrucción para Copilot

```markdown
Necesito corregir las referencias LoadReference en archivos VFP que heredan de clases VCX.

CONTEXTO:
- Proyecto: [Nombre del proyecto]
- Ubicación archivos: [Ruta relativa]
- Ubicación símbolos: packages/Exe/*.symbols

APPS DISPONIBLES:
- Organic.Core.app (seguridad, usuarios, sistema)
- Organic.Drawing.app (UI, formularios, visualización)
- Organic.Feline.app (financiero, cheques, bancario)
- Organic.Generator.app (generación, templates)

PROCESO:
1. Busca TODOS los archivos con patrón: define class X as Y of Z.vcx
2. Extrae lista de VCX únicos (Z.vcx)
3. Para cada VCX, búscalo en los 4 archivos .symbols en packages/Exe/
4. Crea mapeo VCX -> APP basado en dónde se encontró
5. Verifica estado actual de cada archivo
6. Corrige SOLO los que tienen la app incorrecta
7. Elimina LoadReference de los VCX locales
8. Genera reporte de:
   - Archivos corregidos
   - Archivos ya correctos
   - VCX no encontrados (requieren atención manual)

VALIDACIÓN:
- Compilar: dovfp build -path [Proyecto]
- Verificar que NO haya errores en archivos modificados
- Generar lista de archivos que NO se pudieron resolver
```

---

## 🎯 Criterios de Éxito

- ✅ 100% de archivos con patrón VCX identificados
- ✅ Mapeo completo VCX → APP basado en símbolos
- ✅ 0 referencias incorrectas (salvo VCX no encontrados)
- ✅ Compilación exitosa sin errores en archivos modificados
- ✅ Documentación clara de casos no resueltos

---

## 🔍 Troubleshooting

### Los símbolos no tienen información de VCX

**Solución**: Actualizar DOVFP y regenerar símbolos:

```powershell
dovfp restore
dovfp build -path Proyecto
```

### Muchos VCX "No Encontrados"

**Posibles causas**:
1. VCX en proyecto que no está en solución
2. Archivos obsoletos que deben eliminarse
3. VCX renombrados (buscar similares)
4. Falta configuración de dependencias en .vfpproj

### Error "LoadReference no encontrado" al compilar

**Causa**: Falta la línea LoadReference para un VCX externo

**Solución**: Verificar con Paso 4 qué archivos faltan y agregar manualmente

---

## 📚 Referencias

- **DOVFP Symbols Format**: `SymbolName|Type|BaseClass|FileType|SourcePath`
- **VCX en Symbols**: Tipo = `VCX`, FileType = `VCX`
- **LoadReference Syntax**: `_screen._instanceFactory.LoadReference('file.vcx', "App.Name.app")`

---

## 🏷️ Tags

`#refactor` `#vcx` `#dovfp` `#symbols` `#loadreference` `#automation` `#vfp`
