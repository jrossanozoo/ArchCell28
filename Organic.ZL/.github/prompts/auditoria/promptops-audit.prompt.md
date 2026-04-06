---
description: Auditoría comprehensiva de PromptOps - verifica integridad, consistencia y calidad de documentación de agentes, prompts e instructions
tools: ["read_file", "grep_search", "list_dir", "file_search"]
version: 1.0.0
category: auditoria
---

# 📋 Auditoría Comprehensiva PromptOps

## Objetivo

Ejecutar auditoría completa del sistema PromptOps (Agents, Prompts, Instructions) verificando integridad de referencias, consistencia de nomenclatura, eliminación de duplicaciones y alineación con mejores prácticas.

---

## 🔍 Checklist de Auditoría

### 1️⃣ INTEGRIDAD DE REFERENCIAS

**Qué verificar:**
- ✅ Todas las rutas de archivos mencionadas existen
- ✅ Links entre documentos funcionan correctamente
- ✅ Referencias a prompts/instructions son válidas
- ✅ No hay referencias a archivos/carpetas eliminados

**Archivos críticos a verificar:**
- `.github/AGENTS.md` - Links a agentes especializados y recursos
- `.github/prompts/README.md` - Referencias a archivos .prompt.md
- `.github/instructions/README.md` - Referencias a archivos .instructions.md
- Todos los `.prompt.md` - Ejemplos de uso con rutas

**Errores comunes:**
- ❌ Rutas relativas incorrectas (`../` cuando debería ser sin él)
- ❌ Referencias a `docs/` (carpeta eliminada)
- ❌ Referencias a archivos inexistentes (`general.instructions.md`)
- ❌ Links a directorios en vez de archivos específicos

**Comando para verificar:**
```powershell
# Buscar referencias rotas en AGENTS.md
$content = Get-Content .github/AGENTS.md -Raw
$links = [regex]::Matches($content, '\[([^\]]+)\]\(([^\)]+)\)')
foreach ($link in $links) {
    $path = $link.Groups[2].Value
    if ($path -notmatch '^http' -and $path -notmatch '^#') {
        $fullPath = Join-Path (Get-Location) $path
        if (-not (Test-Path $fullPath)) {
            Write-Host âŒ Referencia rota: $path -ForegroundColor Red
        }
    }
}
```

---

### 2️⃣ CONSISTENCIA DE NOMENCLATURA

**Qué verificar:**
- ✅ Archivos siguen convención kebab-case
- ✅ Prompts terminan en `.prompt.md`
- ✅ Instructions terminan en `.instructions.md`
- ✅ Categorías de prompts son consistentes

**Convenciones establecidas:**
- **Prompts**: `nombre-descriptivo.prompt.md` (kebab-case)
- **Instructions**: `nombre-descriptivo.instructions.md` (kebab-case)
- **Agentes**: `AGENTS.md` (MAYÚSCULAS)
- **Categorías**: auditoría/, dev/, refactor/, test/

**Comando para verificar:**
```powershell
# Verificar nomenclatura de prompts
Get-ChildItem .github\prompts -Recurse -Filter *.prompt.md | ForEach-Object {
    if ($_.Name -notmatch '^[a-z0-9\-]+\.prompt\.md$') {
        Write-Host ⚠️ Nomenclatura incorrecta: $($_.Name) -ForegroundColor Yellow
    }
}
```

---

### 3️⃣ DETECCIÓN DE DUPLICACIÓN

**Qué verificar:**
- ✅ No hay contenido idéntico entre archivos
- ✅ No hay información redundante innecesaria
- ✅ No hay descripciones contradictorias
- ✅ Ejemplos de código son únicos y relevantes

**Áreas propensas a duplicación:**
- Nomenclatura húngara VFP (puede estar en prompt + instruction)
- Ejemplos de comandos DOVFP
- Estructura de clases VFP

**Regla:** Si el contenido es idéntico, consolidar en un solo lugar. Si es similar pero con contexto diferente (prompt vs instruction), está OK.

**Comando para verificar:**
```powershell
# Comparar contenido entre archivos similares
$prompt = Get-Content .github\prompts\dev\vfp-development-expert.prompt.md -Raw
$inst = Get-Content .github\instructions\vfp-development.instructions.md -Raw
$similarity = ($prompt.Length - ($prompt.Replace($inst.Substring(0, [Math]::Min(200, $inst.Length)), '')).Length) / $prompt.Length * 100
if ($similarity -gt 50) {
    Write-Host  ï¸ Alta similitud detectada: $([Math]::Round($similarity, 2))% -ForegroundColor Yellow
}
```

---

### 4ï¸âƒ£ ESTRUCTURA Y FORMATO MARKDOWN

**Qué verificar:**
- ✅ JerarQué­a de headings correcta (H1 â†’ H2 â†’ H3)
- ✅ Bloques de código con especificacié³n de lenguaje
- ✅ Listas correctamente formateadas
- ✅ Links con formato correcto

**Convenciones:**
```markdown
# H1 - Solo uno por archivo (té­tulo principal)

## H2 - Secciones principales

### H3 - Subsecciones

#### H4 - Detalles (usar con moderacié³n)

Bloques de código siempre con lenguaje:
```foxpro
* Cé³digo VFP
```

```bash
# Comandos shell
```

```json
{} // JSON
```
```

---

### 5ï¸âƒ£ COMPLETITUD DE METADATOS

**Qué verificar:**
- ✅ Todos los prompts tienen frontmatter con `description`
- ✅ Todos los instructions tienen frontmatter con `description`
- ✅ AGENTS.md tienen secciones estándar (Capacidades, Comandos, Recursos)

**Formato frontmatter requerido:**
```markdown
---
description: Descripcié³n clara y concisa del propé³sito del archivo
---
```

**Comando para verificar:**
```powershell
# Verificar frontmatter en prompts
Get-ChildItem .github\prompts -Recurse -Filter *.prompt.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        Write-Host âŒ Falta frontmatter: $($_.Name) -ForegroundColor Red
    }
}
```

---

### 6ï¸âƒ£ ALINEACIé“N CON MEJORES PRéCTICAS

**Qué verificar:**
- ✅ Comandos DOVFP verificados con `dovfp help`
- ✅ No hay información inventada (estructuras de archivos)
- ✅ Ejemplos son ejecutables y funcionales
- ✅ Documentacié³n refleja realidad del proyecto

**Errores críticos a evitar:**
- âŒ **NUNCA inventar sintaxis de comandos** - verificar con ayuda real
- âŒ **NUNCA documentar estructuras de archivos inventadas** - usar ejemplos reales
- âŒ **NUNCA crear archivos temporales** - violar polé­tica anti-temporal
- âŒ **NUNCA referencias absolutas** - usar rutas relativas consistentes

**Validacié³n de comandos DOVFP:**
```bash
# Verificar sintaxis real
dovfp help
dovfp help -command build
dovfp help -command run
dovfp help -command restore
dovfp help -command clean
```

---

### 7ï¸âƒ£ COHERENCIA ENTRE WORKSPACES

**Qué verificar:**
- ✅ `copilot-instructions.md` es consistente (mismo contenido base)
- ✅ Estructura de carpetas `.github/` es idé©ntica
- ✅ Prompts e instructions son los mismos (si aplica)
- ✅ No hay workspaces con contenido desactualizado

**Estructura esperada en todos los workspaces:**
```
.github/
â”œâ”€â”€ AGENTS.md
â”œâ”€â”€ copilot-instructions.md
â”œâ”€â”€ prompts/
â”‚   â”œâ”€â”€ README.md
â”‚   â”œâ”€â”€ auditoría/
â”‚   â”œâ”€â”€ dev/
â”‚   â”œâ”€â”€ refactor/
â”‚   â””â”€â”€ test/
â””â”€â”€ instructions/
    â”œâ”€â”€ README.md
    â”œâ”€â”€ vfp-development.instructions.md
    â”œâ”€â”€ dovfp-build.instructions.md
    â””â”€â”€ testing.instructions.md
```

**Comando para verificar consistencia:**
```powershell
$workspaces = @(Organic.Core, Organic.Drawing, Organic.Generator, Organic.Feline, Organic.Dragonfish, Organic.ZL)
foreach ($ws in $workspaces) {
    $path = C:\ZooLogicSA.Repos\GIT\Organic\$ws\.github\copilot-instructions.md
    $content = Get-Content $path -Raw
    if ($content -match 'Visual FoxPro 9') {
        Write-Host “ $ws - Correcto -ForegroundColor Green
    } else {
        Write-Host — $ws - Contenido incorrecto -ForegroundColor Red
    }
}
```

---

## š¨ ERRORES CRéTICOS A BUSCAR

### Contexto incorrecto en copilot-instructions.md

**Sé­ntoma:** Menciona Zoo Tool Kit, Azure Key Vault, package.json, tecnologé­as Node.js

**Correccié³n:** Debe mencionar Visual FoxPro 9, DOVFP, Organic, convenciónes VFP

### Referencias rotas en AGENTS.md

**Sé­ntomas comunes:**
- `../Organic.*/AGENTS.md` (ruta relativa incorrecta)
- `./docs/` (carpeta eliminada)
- `general.instructions.md` (archivo inexistente)

**Correccié³n:** Usar rutas correctas o convertir a texto plano sin link

### Comandos DOVFP inventados

**Sé­ntomas:**
- Opciones con `--` (dovfp usa `-`)
- `--verbose`, `--incremental`, `--args` (no existen)
- Argumentos posicionales sin `-path`

**Correccié³n:** Verificar con `dovfp help -command <comando>` y usar sintaxis real

### Estructuras de archivos inventadas

**Sé­ntomas:**
- XML de `.vfpsln` documentado
- XML de `.vfpproj` documentado
- `dovfp.json` documentación:** Eliminar y reemplazar con nota para consultar ejemplos reales

---

## “Š PLANTILLA DE REPORTE

### Auditoría PromptOps - [Fecha]

**Workspace:** [Nombre]

#### 1. Integridad de Referencias
- Referencias totales: X
- Referencias rotas: X
- Estado: ✅ OK /  ï¸ Warnings / âŒ Errores

#### 2. Nomenclatura
- Archivos verificados: X
- Convencié³n correcta: X/X
- Estado: ✅ OK /  ï¸ Warnings

#### 3. Duplicacié³n
- Comparaciones realizadas: X
- Duplicaciones encontradas: X
- Estado: ✅ OK /  ï¸ Revisar

#### 4. Formato Markdown
- Archivos verificados: X
- Errores de formato: X
- Estado: ✅ OK /  ï¸ Warnings

#### 5. Metadatos
- Prompts sin frontmatter: X
- Instructions sin frontmatter: X
- Estado: ✅ OK / âŒ Errores

#### 6. Mejores prácticas
- Comandos verificados: X/X
- Informacié³n inventada: Sé­/No
- Estado: ✅ OK / âŒ Errores críticos

#### 7. Coherencia entre Workspaces
- Workspaces verificados: X
- Consistentes: X/X
- Estado: ✅ OK / âŒ Inconsistencias

### Resumen Ejecutivo

**Estado General:** ✅ APROBADO /  ï¸ CON WARNINGS / âŒ REQUIERE CORRECCIé“N

**Errores Cré­ticos:** X  
**Warnings:** X  
**Archivos a corregir:** X

**Prioridades:**
1. [Accié³n más urgente]
2. [Segunda prioridad]
3. [Tercera prioridad]

---

## ”§ CORRECCIONES AUTOMéTICAS

### Script de correccié³n ré¡pida

```powershell
# Verificar y reportar todos los problemas
$errores = @()
$warnings = @()

# 1. Verificar copilot-instructions.md
$content = Get-Content .github\copilot-instructions.md -Raw
if ($content -match 'Zoo Tool Kit') {
    $errores += âŒ copilot-instructions.md tiene contexto incorrecto
}

# 2. Verificar referencias en AGENTS.md
$content = Get-Content .github\AGENTS.md -Raw
if ($content -match '\.\./docs/') {
    $errores += âŒ AGENTS.md referencia carpeta docs/ eliminada
}

# 3. Verificar frontmatter en prompts
Get-ChildItem .github\prompts -Recurse -Filter *.prompt.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        $warnings +=  ï¸ $($_.Name) sin frontmatter
    }
}

# Reporte
Write-Host Errores críticos: $($errores.Count) -ForegroundColor $(if ($errores.Count -gt 0) { Red } else { Green })
Write-Host Warnings: $($warnings.Count) -ForegroundColor $(if ($warnings.Count -gt 0) { Yellow } else { Green })
```

---

## “š RECURSOS Y REFERENCIAS

### Documentacié³n PromptOps

- **GitHub Copilot Workspace**: Convenciones y mejores prácticas
- **Markdown**: Formato estándar para documentación té©cnica
- **DOVFP**: Herramienta de compilacié³n VFP (verificar con `dovfp help`)

### Polé­ticas del Proyecto

- **Tolerancia CERO a archivos temporales**: No crear *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md
- **No carpeta docs/**: GitHub Copilot no la lee automáticamente
- **Informacié³n verificada**: Nunca inventar sintaxis o estructuras

---

## ’¡ USO DEL PROMPT

### Invocar auditoría completa

```
@workspace #prompt:promptops-audit Ejecuta auditoría completa del sistema PromptOps
```

### Auditoría especé­fica

```
@workspace #prompt:promptops-audit Verifica solo integridad de referencias
@workspace #prompt:promptops-audit Audita coherencia entre workspaces
@workspace #prompt:promptops-audit Verifica comandos DOVFP en toda la documentación
```

### Con reporte detallado

```
@workspace #prompt:promptops-audit Ejecuta auditoría completa y genera reporte con prioridades de correccié³n
```

---

## ✅ CRITERIOS DE APROBACIé“N

Una auditoría se considera **APROBADA** cuando:

1. ✅ 0 referencias rotas
2. ✅ 0 errores de nomenclatura
3. ✅ 0 errores críticos de contenido (comandos inventados, estructuras inventadas)
4. ✅ 100% de prompts/instructions con frontmatter
5. ✅ copilot-instructions.md correcto en 6/6 workspaces
6. ✅ Estructura .github/ consistente en todos los workspaces
7. ✅ 0 archivos temporales o de reporte violando polé­tica

**Warnings aceptables (no bloquean aprobacié³n):**
-  ï¸ Duplicacié³n de contenido justificada (prompt vs instruction con diferente contexto)
-  ï¸ Ejemplos similares en múltiples archivos (si cada uno tiene su propé³sito)

---

Manté©n este prompt actualizado con cada nueva leccié³n aprendida o patré³n de error descubierto durante auditorías.
