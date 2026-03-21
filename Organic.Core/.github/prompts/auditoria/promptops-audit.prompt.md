---
description: AuditorÃ­a comprehensiva de PromptOps - verifica integridad, consistencia y calidad de documentaciÃ³n de agentes, prompts e instructions
---

# ðŸ“ AuditorÃ­a Comprehensiva PromptOps

## Objetivo

Ejecutar auditorÃ­a completa del sistema PromptOps (Agents, Prompts, Instructions) verificando integridad de referencias, consistencia de nomenclatura, eliminaciÃ³n de duplicaciones y alineaciÃ³n con mejores prÃ¡cticas.

---

## ðŸ“‹ Checklist de AuditorÃ­a

### 1ï¸âƒ£ INTEGRIDAD DE REFERENCIAS

**QuÃ© verificar:**
- âœ… Todas las rutas de archivos mencionadas existen
- âœ… Links entre documentos funcionan correctamente
- âœ… Referencias a prompts/instructions son vÃ¡lidas
- âœ… No hay referencias a archivos/carpetas eliminados

**Archivos crÃ­ticos a verificar:**
- `.github/AGENTS.md` - Links a agentes especializados y recursos
- `.github/prompts/README.md` - Referencias a archivos .prompt.md
- `.github/instructions/README.md` - Referencias a archivos .instructions.md
- Todos los `.prompt.md` - Ejemplos de uso con rutas

**Errores comunes:**
- âŒ Rutas relativas incorrectas (`../` cuando deberÃ­a ser sin Ã©l)
- âŒ Referencias a `docs/` (carpeta eliminada)
- âŒ Referencias a archivos inexistentes (`general.instructions.md`)
- âŒ Links a directorios en vez de archivos especÃ­ficos

**Comando para verificar:**
```powershell
# Buscar referencias rotas en AGENTS.md
$content = Get-Content ".github/AGENTS.md" -Raw
$links = [regex]::Matches($content, '\[([^\]]+)\]\(([^\)]+)\)')
foreach ($link in $links) {
    $path = $link.Groups[2].Value
    if ($path -notmatch '^http' -and $path -notmatch '^#') {
        $fullPath = Join-Path (Get-Location) $path
        if (-not (Test-Path $fullPath)) {
            Write-Host "âŒ Referencia rota: $path" -ForegroundColor Red
        }
    }
}
```

---

### 2ï¸âƒ£ CONSISTENCIA DE NOMENCLATURA

**QuÃ© verificar:**
- âœ… Archivos siguen convenciÃ³n kebab-case
- âœ… Prompts terminan en `.prompt.md`
- âœ… Instructions terminan en `.instructions.md`
- âœ… CategorÃ­as de prompts son consistentes

**Convenciones establecidas:**
- **Prompts**: `nombre-descriptivo.prompt.md` (kebab-case)
- **Instructions**: `nombre-descriptivo.instructions.md` (kebab-case)
- **Agentes**: `AGENTS.md` (MAYUSCULAS)
- **CategorÃ­as**: auditoria/, dev/, refactor/, test/

**Comando para verificar:**
```powershell
# Verificar nomenclatura de prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    if ($_.Name -notmatch '^[a-z0-9\-]+\.prompt\.md$') {
        Write-Host "âš ï¸ Nomenclatura incorrecta: $($_.Name)" -ForegroundColor Yellow
    }
}
```

---

### 3ï¸âƒ£ DETECCIÃ“N DE DUPLICACIÃ“N

**QuÃ© verificar:**
- âœ… No hay contenido idÃ©ntico entre archivos
- âœ… No hay informaciÃ³n redundante innecesaria
- âœ… No hay descripciones contradictorias
- âœ… Ejemplos de cÃ³digo son Ãºnicos y relevantes

**Ãreas propensas a duplicaciÃ³n:**
- Nomenclatura hÃºngara VFP (puede estar en prompt + instruction)
- Ejemplos de comandos DOVFP
- Estructura de clases VFP

**Regla:** Si el contenido es idÃ©ntico, consolidar en un solo lugar. Si es similar pero con contexto diferente (prompt vs instruction), estÃ¡ OK.

**Comando para verificar:**
```powershell
# Comparar contenido entre archivos similares
$prompt = Get-Content ".github\prompts\dev\vfp-development-expert.prompt.md" -Raw
$inst = Get-Content ".github\instructions\vfp-development.instructions.md" -Raw
$similarity = ($prompt.Length - ($prompt.Replace($inst.Substring(0, [Math]::Min(200, $inst.Length)), '')).Length) / $prompt.Length * 100
if ($similarity -gt 50) {
    Write-Host "âš ï¸ Alta similitud detectada: $([Math]::Round($similarity, 2))%" -ForegroundColor Yellow
}
```

---

### 4ï¸âƒ£ ESTRUCTURA Y FORMATO MARKDOWN

**QuÃ© verificar:**
- âœ… JerarquÃ­a de headings correcta (H1 â†’ H2 â†’ H3)
- âœ… Bloques de cÃ³digo con especificaciÃ³n de lenguaje
- âœ… Listas correctamente formateadas
- âœ… Links con formato correcto

**Convenciones:**
```markdown
# H1 - Solo uno por archivo (tÃ­tulo principal)

## H2 - Secciones principales

### H3 - Subsecciones

#### H4 - Detalles (usar con moderaciÃ³n)

Bloques de cÃ³digo siempre con lenguaje:
```foxpro
* CÃ³digo VFP
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

**QuÃ© verificar:**
- âœ… Todos los prompts tienen frontmatter con `description`
- âœ… Todos los instructions tienen frontmatter con `description`
- âœ… AGENTS.md tienen secciones estÃ¡ndar (Capacidades, Comandos, Recursos)

**Formato frontmatter requerido:**
```markdown
---
description: DescripciÃ³n clara y concisa del propÃ³sito del archivo
---
```

**Comando para verificar:**
```powershell
# Verificar frontmatter en prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        Write-Host "âŒ Falta frontmatter: $($_.Name)" -ForegroundColor Red
    }
}
```

---

### 6ï¸âƒ£ ALINEACIÃ“N CON MEJORES PRÃCTICAS

**QuÃ© verificar:**
- âœ… Comandos DOVFP verificados con `dovfp help`
- âœ… No hay informaciÃ³n inventada (estructuras de archivos)
- âœ… Ejemplos son ejecutables y funcionales
- âœ… DocumentaciÃ³n refleja realidad del proyecto

**Errores crÃ­ticos a evitar:**
- âŒ **NUNCA inventar sintaxis de comandos** - verificar con ayuda real
- âŒ **NUNCA documentar estructuras de archivos inventadas** - usar ejemplos reales
- âŒ **NUNCA crear archivos temporales** - violar polÃ­tica anti-temporal
- âŒ **NUNCA referencias absolutas** - usar rutas relativas consistentes

**ValidaciÃ³n de comandos DOVFP:**
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

**QuÃ© verificar:**
- âœ… `copilot-instructions.md` es consistente (mismo contenido base)
- âœ… Estructura de carpetas `.github/` es idÃ©ntica
- âœ… Prompts e instructions son los mismos (si aplica)
- âœ… No hay workspaces con contenido desactualizado

**Estructura esperada en todos los workspaces:**
```
.github/
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ AGENTS.md
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ copilot-instructions.md
Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ prompts/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ README.md
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ auditoria/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ dev/
Ã¢â€â€š   Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ refactor/
Ã¢â€â€š   Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ test/
Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ instructions/
    Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ README.md
    Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ vfp-development.instructions.md
    Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬ dovfp-build.instructions.md
    Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬ testing.instructions.md
```

**Comando para verificar consistencia:**
```powershell
$workspaces = @("Organic.Core", "Organic.Drawing", "Organic.Generator", "Organic.Feline", "Organic.Dragonfish", "Organic.ZL")
foreach ($ws in $workspaces) {
    $path = "C:\ZooLogicSA.Repos\GIT\Organic\$ws\.github\copilot-instructions.md"
    $content = Get-Content $path -Raw
    if ($content -match 'Visual FoxPro 9') {
        Write-Host "âœ“ $ws - Correcto" -ForegroundColor Green
    } else {
        Write-Host "âœ— $ws - Contenido incorrecto" -ForegroundColor Red
    }
}
```

---

## ðŸš¨ ERRORES CRÃTICOS A BUSCAR

### Contexto incorrecto en copilot-instructions.md

**SÃ­ntoma:** Menciona "Zoo Tool Kit", "Azure Key Vault", "package.json", tecnologÃ­as Node.js

**CorrecciÃ³n:** Debe mencionar "Visual FoxPro 9", "DOVFP", "Organic", convenciones VFP

### Referencias rotas en AGENTS.md

**SÃ­ntomas comunes:**
- `../Organic.*/AGENTS.md` (ruta relativa incorrecta)
- `./docs/` (carpeta eliminada)
- `general.instructions.md` (archivo inexistente)

**CorrecciÃ³n:** Usar rutas correctas o convertir a texto plano sin link

### Comandos DOVFP inventados

**SÃ­ntomas:**
- Opciones con `--` (dovfp usa `-`)
- `--verbose`, `--incremental`, `--args` (no existen)
- Argumentos posicionales sin `-path`

**CorrecciÃ³n:** Verificar con `dovfp help -command <comando>` y usar sintaxis real

### Estructuras de archivos inventadas

**SÃ­ntomas:**
- XML de `.vfpsln` documentado
- XML de `.vfpproj` documentado
- `dovfp.json` documentado

**CorrecciÃ³n:** Eliminar y reemplazar con nota para consultar ejemplos reales

---

## ðŸ“Š PLANTILLA DE REPORTE

### AuditorÃ­a PromptOps - [Fecha]

**Workspace:** [Nombre]

#### 1. Integridad de Referencias
- Referencias totales: X
- Referencias rotas: X
- Estado: âœ… OK / âš ï¸ Warnings / âŒ Errores

#### 2. Nomenclatura
- Archivos verificados: X
- ConvenciÃ³n correcta: X/X
- Estado: âœ… OK / âš ï¸ Warnings

#### 3. DuplicaciÃ³n
- Comparaciones realizadas: X
- Duplicaciones encontradas: X
- Estado: âœ… OK / âš ï¸ Revisar

#### 4. Formato Markdown
- Archivos verificados: X
- Errores de formato: X
- Estado: âœ… OK / âš ï¸ Warnings

#### 5. Metadatos
- Prompts sin frontmatter: X
- Instructions sin frontmatter: X
- Estado: âœ… OK / âŒ Errores

#### 6. Mejores PrÃ¡cticas
- Comandos verificados: X/X
- InformaciÃ³n inventada: SÃ­/No
- Estado: âœ… OK / âŒ Errores crÃ­ticos

#### 7. Coherencia entre Workspaces
- Workspaces verificados: X
- Consistentes: X/X
- Estado: âœ… OK / âŒ Inconsistencias

### Resumen Ejecutivo

**Estado General:** âœ… APROBADO / âš ï¸ CON WARNINGS / âŒ REQUIERE CORRECCIÃ“N

**Errores CrÃ­ticos:** X  
**Warnings:** X  
**Archivos a corregir:** X

**Prioridades:**
1. [AcciÃ³n mÃ¡s urgente]
2. [Segunda prioridad]
3. [Tercera prioridad]

---

## ðŸ”§ CORRECCIONES AUTOMÃTICAS

### Script de correcciÃ³n rÃ¡pida

```powershell
# Verificar y reportar todos los problemas
$errores = @()
$warnings = @()

# 1. Verificar copilot-instructions.md
$content = Get-Content ".github\copilot-instructions.md" -Raw
if ($content -match 'Zoo Tool Kit') {
    $errores += "âŒ copilot-instructions.md tiene contexto incorrecto"
}

# 2. Verificar referencias en AGENTS.md
$content = Get-Content ".github\AGENTS.md" -Raw
if ($content -match '\.\./docs/') {
    $errores += "âŒ AGENTS.md referencia carpeta docs/ eliminada"
}

# 3. Verificar frontmatter en prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        $warnings += "âš ï¸ $($_.Name) sin frontmatter"
    }
}

# Reporte
Write-Host "Errores crÃ­ticos: $($errores.Count)" -ForegroundColor $(if ($errores.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -gt 0) { "Yellow" } else { "Green" })
```

---

## ðŸ“š RECURSOS Y REFERENCIAS

### DocumentaciÃ³n PromptOps

- **GitHub Copilot Workspace**: Convenciones y mejores prÃ¡cticas
- **Markdown**: Formato estÃ¡ndar para documentaciÃ³n tÃ©cnica
- **DOVFP**: Herramienta de compilaciÃ³n VFP (verificar con `dovfp help`)

### PolÃ­ticas del Proyecto

- **Tolerancia CERO a archivos temporales**: No crear *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md
- **No carpeta docs/**: GitHub Copilot no la lee automÃ¡ticamente
- **InformaciÃ³n verificada**: Nunca inventar sintaxis o estructuras

---

## ðŸ’¡ USO DEL PROMPT

### Invocar auditorÃ­a completa

```
@workspace #prompt:promptops-audit Ejecuta auditorÃ­a completa del sistema PromptOps
```

### AuditorÃ­a especÃ­fica

```
@workspace #prompt:promptops-audit Verifica solo integridad de referencias
@workspace #prompt:promptops-audit Audita coherencia entre workspaces
@workspace #prompt:promptops-audit Verifica comandos DOVFP en toda la documentaciÃ³n
```

### Con reporte detallado

```
@workspace #prompt:promptops-audit Ejecuta auditorÃ­a completa y genera reporte con prioridades de correcciÃ³n
```

---

## âœ… CRITERIOS DE APROBACIÃ“N

Una auditorÃ­a se considera **APROBADA** cuando:

1. âœ… 0 referencias rotas
2. âœ… 0 errores de nomenclatura
3. âœ… 0 errores crÃ­ticos de contenido (comandos inventados, estructuras inventadas)
4. âœ… 100% de prompts/instructions con frontmatter
5. âœ… copilot-instructions.md correcto en 6/6 workspaces
6. âœ… Estructura .github/ consistente en todos los workspaces
7. âœ… 0 archivos temporales o de reporte violando polÃ­tica

**Warnings aceptables (no bloquean aprobaciÃ³n):**
- âš ï¸ DuplicaciÃ³n de contenido justificada (prompt vs instruction con diferente contexto)
- âš ï¸ Ejemplos similares en mÃºltiples archivos (si cada uno tiene su propÃ³sito)

---

MantÃ©n este prompt actualizado con cada nueva lecciÃ³n aprendida o patrÃ³n de error descubierto durante auditorÃ­as.
