---
description: "Auditoría comprehensiva de PromptOps - verifica integridad, consistencia y calidad de documentación de agentes, prompts e instructions"
tools: ["read_file", "grep_search", "list_dir", "file_search", "run_in_terminal"]
applyTo: ["**/*.md", "**/*.prompt.md", "**/*.instructions.md"]
argument-hint: "Ejecuta sin argumentos para auditoría completa"
---

#  Auditoría Comprehensiva PromptOps

## Objetivo

Ejecutar auditoría completa del sistema PromptOps (Agents, Prompts, Instructions) verificando integridad de referencias, consistencia de nomenclatura, eliminación de duplicaciones y alineación con mejores prácticas.

---

##  Checklist de Auditoría

### 1 INTEGRIDAD DE REFERENCIAS

**Qué verificar:**
-  Todas las rutas de archivos mencionadas existen
-  Links entre documentos funcionan correctamente
-  Referencias a prompts/instructions son válidas
-  No hay referencias a archivos/carpetas eliminados

**Archivos críticos a verificar:**
- `.github/AGENTS.md` - Links a agentes especializados y recursos
- `.github/prompts/README.md` - Referencias a archivos .prompt.md
- `.github/instructions/README.md` - Referencias a archivos .instructions.md
- Todos los `.prompt.md` - Ejemplos de uso con rutas

**Errores comunes:**
-  Rutas relativas incorrectas (`../` cuando debería ser sin él)
-  Referencias a `docs/` (carpeta eliminada)
-  Referencias a archivos inexistentes (`general.instructions.md`)
-  Links a directorios en vez de archivos específicos

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
            Write-Host " Referencia rota: $path" -ForegroundColor Red
        }
    }
}
```

---

### 2 CONSISTENCIA DE NOMENCLATURA

**Qué verificar:**
-  Archivos siguen convención kebab-case
-  Prompts terminan en `.prompt.md`
-  Instructions terminan en `.instructions.md`
-  Categorías de prompts son consistentes

**Convenciones establecidas:**
- **Prompts**: `nombre-descriptivo.prompt.md` (kebab-case)
- **Instructions**: `nombre-descriptivo.instructions.md` (kebab-case)
- **Agentes**: `AGENTS.md` (MAYÚSCULAS)
- **Categorías**: auditoria/, dev/, refactor/, test/

**Comando para verificar:**
```powershell
# Verificar nomenclatura de prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    if ($_.Name -notmatch '^[a-z0-9\-]+\.prompt\.md$') {
        Write-Host " Nomenclatura incorrecta: $($_.Name)" -ForegroundColor Yellow
    }
}
```

---

### 3 DETECCIÓN DE DUPLICACIÓN

**Qué verificar:**
-  No hay contenido idéntico entre archivos
-  No hay información redundante innecesaria
-  No hay descripciones contradictorias
-  Ejemplos de código son únicos y relevantes

**Áreas propensas a duplicación:**
- Nomenclatura húngara VFP (puede estar en prompt + instruction)
- Ejemplos de comandos DOVFP
- Estructura de clases VFP

**Regla:** Si el contenido es idéntico, consolidar en un solo lugar. Si es similar pero con contexto diferente (prompt vs instruction), está OK.

**Comando para verificar:**
```powershell
# Comparar contenido entre archivos similares
$prompt = Get-Content ".github\prompts\dev\vfp-development-expert.prompt.md" -Raw
$inst = Get-Content ".github\instructions\vfp-development.instructions.md" -Raw
$similarity = ($prompt.Length - ($prompt.Replace($inst.Substring(0, [Math]::Min(200, $inst.Length)), '')).Length) / $prompt.Length * 100
if ($similarity -gt 50) {
    Write-Host " Alta similitud detectada: $([Math]::Round($similarity, 2))%" -ForegroundColor Yellow
}
```

---

### 4 ESTRUCTURA Y FORMATO MARKDOWN

**Qué verificar:**
-  Jerarquía de headings correcta (H1  H2  H3)
-  Bloques de código con especificación de lenguaje
-  Listas correctamente formateadas
-  Links con formato correcto

**Convenciones:**
```markdown
# H1 - Solo uno por archivo (título principal)

## H2 - Secciones principales

### H3 - Subsecciones

#### H4 - Detalles (usar con moderación)

Bloques de código siempre con lenguaje:
```foxpro
* Código VFP
```

```bash
# Comandos shell
```

```json
{} // JSON
```
```

---

### 5 COMPLETITUD DE METADATOS

**Qué verificar:**
-  Todos los prompts tienen frontmatter con `description`
-  Todos los instructions tienen frontmatter con `description`
-  AGENTS.md tienen secciones estándar (Capacidades, Comandos, Recursos)

**Formato frontmatter requerido:**
```markdown
---
description: Descripción clara y concisa del propósito del archivo
---
```

**Comando para verificar:**
```powershell
# Verificar frontmatter en prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        Write-Host " Falta frontmatter: $($_.Name)" -ForegroundColor Red
    }
}
```

---

### 6 ALINEACIÓN CON MEJORES PRÁCTICAS

**Qué verificar:**
-  Comandos DOVFP verificados con `dovfp help`
-  No hay información inventada (estructuras de archivos)
-  Ejemplos son ejecutables y funcionales
-  Documentación refleja realidad del proyecto

**Errores críticos a evitar:**
-  **NUNCA inventar sintaxis de comandos** - verificar con ayuda real
-  **NUNCA documentar estructuras de archivos inventadas** - usar ejemplos reales
-  **NUNCA crear archivos temporales** - violar política anti-temporal
-  **NUNCA referencias absolutas** - usar rutas relativas consistentes

**Validación de comandos DOVFP:**
```bash
# Verificar sintaxis real
dovfp help
dovfp help -command build
dovfp help -command run
dovfp help -command restore
dovfp help -command clean
```

---

### 7 COHERENCIA ENTRE WORKSPACES

**Qué verificar:**
-  `copilot-instructions.md` es consistente (mismo contenido base)
-  Estructura de carpetas `.github/` es idéntica
-  Prompts e instructions son los mismos (si aplica)
-  No hay workspaces con contenido desactualizado

**Estructura esperada en todos los workspaces:**
```
.github/
 AGENTS.md
 copilot-instructions.md
 prompts/
    README.md
    auditoria/
    dev/
    refactor/
    test/
 instructions/
     README.md
     vfp-development.instructions.md
     dovfp-build.instructions.md
     testing.instructions.md
```

**Comando para verificar consistencia:**
```powershell
$workspaces = @("Organic.Core", "Organic.Drawing", "Organic.Generator", "Organic.Feline", "Organic.Dragonfish", "Organic.ZL")
foreach ($ws in $workspaces) {
    $path = "C:\ZooLogicSA.Repos\GIT\Organic\$ws\.github\copilot-instructions.md"
    $content = Get-Content $path -Raw
    if ($content -match 'Visual FoxPro 9') {
        Write-Host " $ws - Correcto" -ForegroundColor Green
    } else {
        Write-Host " $ws - Contenido incorrecto" -ForegroundColor Red
    }
}
```

---

##  ERRORES CRÍTICOS A BUSCAR

### Contexto incorrecto en copilot-instructions.md

**Síntoma:** Menciona "Zoo Tool Kit", "Azure Key Vault", "package.json", tecnologías Node.js

**Corrección:** Debe mencionar "Visual FoxPro 9", "DOVFP", "Organic", convenciones VFP

### Referencias rotas en AGENTS.md

**Síntomas comunes:**
- `../Organic.*/AGENTS.md` (ruta relativa incorrecta)
- `./docs/` (carpeta eliminada)
- `general.instructions.md` (archivo inexistente)

**Corrección:** Usar rutas correctas o convertir a texto plano sin link

### Comandos DOVFP inventados

**Síntomas:**
- Opciones con `--` (dovfp usa `-`)
- `--verbose`, `--incremental`, `--args` (no existen)
- Argumentos posicionales sin `-path`

**Corrección:** Verificar con `dovfp help -command <comando>` y usar sintaxis real

### Estructuras de archivos inventadas

**Síntomas:**
- XML de `.vfpsln` documentado
- XML de `.vfpproj` documentado
- `dovfp.json` documentado

**Corrección:** Eliminar y reemplazar con nota para consultar ejemplos reales

---

##  PLANTILLA DE REPORTE

### Auditoría PromptOps - [Fecha]

**Workspace:** [Nombre]

#### 1. Integridad de Referencias
- Referencias totales: X
- Referencias rotas: X
- Estado:  OK /  Warnings /  Errores

#### 2. Nomenclatura
- Archivos verificados: X
- Convención correcta: X/X
- Estado:  OK /  Warnings

#### 3. Duplicación
- Comparaciones realizadas: X
- Duplicaciones encontradas: X
- Estado:  OK /  Revisar

#### 4. Formato Markdown
- Archivos verificados: X
- Errores de formato: X
- Estado:  OK /  Warnings

#### 5. Metadatos
- Prompts sin frontmatter: X
- Instructions sin frontmatter: X
- Estado:  OK /  Errores

#### 6. Mejores Prácticas
- Comandos verificados: X/X
- Información inventada: Sí/No
- Estado:  OK /  Errores críticos

#### 7. Coherencia entre Workspaces
- Workspaces verificados: X
- Consistentes: X/X
- Estado:  OK /  Inconsistencias

### Resumen Ejecutivo

**Estado General:**  APROBADO /  CON WARNINGS /  REQUIERE CORRECCIÓN

**Errores Críticos:** X  
**Warnings:** X  
**Archivos a corregir:** X

**Prioridades:**
1. [Acción más urgente]
2. [Segunda prioridad]
3. [Tercera prioridad]

---

##  CORRECCIONES AUTOMÁTICAS

### Script de corrección rápida

```powershell
# Verificar y reportar todos los problemas
$errores = @()
$warnings = @()

# 1. Verificar copilot-instructions.md
$content = Get-Content ".github\copilot-instructions.md" -Raw
if ($content -match 'Zoo Tool Kit') {
    $errores += " copilot-instructions.md tiene contexto incorrecto"
}

# 2. Verificar referencias en AGENTS.md
$content = Get-Content ".github\AGENTS.md" -Raw
if ($content -match '\.\./docs/') {
    $errores += " AGENTS.md referencia carpeta docs/ eliminada"
}

# 3. Verificar frontmatter en prompts
Get-ChildItem ".github\prompts" -Recurse -Filter "*.prompt.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch '---\s*\ndescription:') {
        $warnings += " $($_.Name) sin frontmatter"
    }
}

# Reporte
Write-Host "Errores críticos: $($errores.Count)" -ForegroundColor $(if ($errores.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -gt 0) { "Yellow" } else { "Green" })
```

---

##  RECURSOS Y REFERENCIAS

### Documentación PromptOps

- **GitHub Copilot Workspace**: Convenciones y mejores prácticas
- **Markdown**: Formato estándar para documentación técnica
- **DOVFP**: Herramienta de compilación VFP (verificar con `dovfp help`)

### Políticas del Proyecto

- **Tolerancia CERO a archivos temporales**: No crear *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md
- **No carpeta docs/**: GitHub Copilot no la lee automáticamente
- **Información verificada**: Nunca inventar sintaxis o estructuras

---

##  USO DEL PROMPT

### Invocar auditoría completa

```
@workspace #prompt:promptops-audit Ejecuta auditoría completa del sistema PromptOps
```

### Auditoría específica

```
@workspace #prompt:promptops-audit Verifica solo integridad de referencias
@workspace #prompt:promptops-audit Audita coherencia entre workspaces
@workspace #prompt:promptops-audit Verifica comandos DOVFP en toda la documentación
```

### Con reporte detallado

```
@workspace #prompt:promptops-audit Ejecuta auditoría completa y genera reporte con prioridades de corrección
```

---

##  CRITERIOS DE APROBACIÓN

Una auditoría se considera **APROBADA** cuando:

1.  0 referencias rotas
2.  0 errores de nomenclatura
3.  0 errores críticos de contenido (comandos inventados, estructuras inventadas)
4.  100% de prompts/instructions con frontmatter
5.  copilot-instructions.md correcto en 6/6 workspaces
6.  Estructura .github/ consistente en todos los workspaces
7.  0 archivos temporales o de reporte violando política

**Warnings aceptables (no bloquean aprobación):**
-  Duplicación de contenido justificada (prompt vs instruction con diferente contexto)
-  Ejemplos similares en múltiples archivos (si cada uno tiene su propósito)

---

Mantén este prompt actualizado con cada nueva lección aprendida o patrón de error descubierto durante auditorías.