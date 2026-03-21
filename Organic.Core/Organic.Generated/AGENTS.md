# ⚙️ Generated Code Agent: Metadata & Code Generation Specialist

**Role**: Code Generation Engineer  
**Scope**: Din_* classes, ADN metadata, automated generation  
**Parent Agent**: [Main Architecture Agent](../.github/AGENTS.md)

---

## 🎯 Primary Responsibilities

### 1. **Code Generation**
- Generate Din_* classes from ADN metadata
- Create Transferencia classes (Consulta, Objeto)
- Generate autocomplete classes (Din_AutocompletarDO)
- Maintain component classes (Muralla, Rio, Comprobante)

### 2. **Metadata Management**
- Validate ADN structure integrity
- Maintain version synchronization
- Process database schema metadata
- Generate entity relationship metadata

### 3. **Version Synchronization**
- Update Din_Estructuraadn.prg with current version
- Sync din_estructuraadn.xml components (Major/Minor/Build)
- Update all Din_Transferencia* files with version info
- Maintain version consistency across generated files

### 4. **Build Integration**
- Execute pre-build PowerShell scripts
- Validate generated file outputs
- Handle encoding issues (UTF-8, Default)
- Ensure MSBuild compatibility

---

## 📁 Generated Files Structure

```
Organic.Generated/
├── Generados/              # Generated source files
│   ├── Din_Estructuraadn.prg
│   ├── din_estructuraadn.xml
│   ├── Din_Transferencia*Consulta.prg (60 files)
│   ├── Din_Transferencia*Objeto.prg (64 files)
│   ├── Din_AutocompletarDO*.prg
│   └── Din_Componente*.prg
├── ADN/                    # Metadata sources
│   ├── adn.pjm
│   ├── serviciometadata.prg
│   └── DBCSerializado/
└── Scripts/                # Generation scripts
    ├── Update-EstructuraAdnPrg.ps1
    └── Update-TransferenciaVersions.ps1
```

---

## 🔄 Generation Workflow

### 1. Pre-Build Phase
```
MSBuild Target: UpdateEstructuraAdnPrg
├── Run: Update-EstructuraAdnPrg.ps1
│   ├── Normalize version (01.0002.000003)
│   ├── Update Din_Estructuraadn.prg
│   └── Update din_estructuraadn.xml
└── Run: Update-TransferenciaVersions.ps1
    ├── Find all Din_Transferencia*Consulta.prg
    ├── Find all Din_Transferencia*Objeto.prg
    └── Update version in each file
```

### 2. Generation Phase
```
Metadata Processing
├── Load ADN structure
├── Parse entity definitions
├── Apply templates
└── Output Din_* classes
```

### 3. Validation Phase
```
Post-Generation Checks
├── Verify file count matches expected
├── Validate VFP syntax
├── Check version consistency
└── Report generation metrics
```

---

## 🛠️ PowerShell Script Patterns

### Update-EstructuraAdnPrg.ps1
```powershell
param(
    [string]$Version = "01.0001.00000",
    [string]$FilePath = "Generados\Din_Estructuraadn.prg"
)

# Normalize version to 01.0001.00000 format
function Format-Version {
    param([string]$inputVersion)
    $parts = $inputVersion.Split('.')
    $major = $parts[0].PadLeft(2, '0')
    $minor = $parts[1].PadLeft(4, '0')
    $build = $parts[2].PadLeft(5, '0')
    return "$major.$minor.$build"
}

# Update .prg file
$content = Get-Content $FilePath -Raw -Encoding Default
$pattern = "Return\s+['`"][\d\.]+['`"]"
$replacement = "Return '$NormalizedVersion'"
$updated = $content -replace $pattern, $replacement
Set-Content $FilePath -Value $updated -NoNewline -Encoding Default

# Update .xml file (Major, Minor, Build components)
# ... XML update logic with proper escaping
```

### Update-TransferenciaVersions.ps1
```powershell
param(
    [string]$ProjectDirectory,
    [string]$Version
)

# Find all Consulta and Objeto files
$consultaFiles = Get-ChildItem -Path "$ProjectDirectory\Generados" `
    -Filter "Din_Transferencia*Consulta.prg"

# Update version in each file
foreach ($file in $consultaFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding Default
    # Apply version update patterns
    Set-Content $file.FullName -Value $updated -NoNewline -Encoding Default
}
```

---

## ⚙️ Code Generation Templates

### Transferencia Class Template
```foxpro
* Din_Transferencia[Entity]Objeto.prg
* Generated: [Date]
* Version: [Version]

DEFINE CLASS Din_Transferencia[Entity]Objeto AS TransferenciaBase
    cVersion = "[Version]"
    cEntity = "[Entity]"
    cTableName = "[TableName]"
    
    FUNCTION GetStructure()
        LOCAL loStructure
        loStructure = CREATEOBJECT("Collection")
        * Add fields from metadata
        loStructure.Add(THIS.CreateField("id", "I"))
        loStructure.Add(THIS.CreateField("name", "C", 50))
        RETURN loStructure
    ENDFUNC
    
ENDDEFINE
```

---

## 🔍 Validation Rules

### File Validation
- [ ] All generated files have proper encoding (UTF-8 or Default as needed)
- [ ] Version numbers are consistent across all files
- [ ] No PowerShell syntax errors in scripts
- [ ] Regex patterns use single quotes for XML tags
- [ ] Exit codes properly set (0=success, 1=error)

### Code Validation
- [ ] Generated classes compile without errors
- [ ] Class names match file names (case-sensitive)
- [ ] All DEFINE CLASS have matching ENDDEFINE
- [ ] Required base classes are available

### Metadata Validation
- [ ] ADN structure is valid XML
- [ ] Entity definitions are complete
- [ ] Field mappings are correct
- [ ] Relationships are bidirectional

---

## 🐛 Common Generation Issues

### Issue: PowerShell script fails with "operator < reserved"
**Cause**: Double quotes around XML regex patterns  
**Solution**: Use single quotes: `'<Version>[\d\.]+</Version>'`

### Issue: Script exits with code -1
**Cause**: Missing explicit `exit 0`  
**Solution**: Add `exit 0` at script end

### Issue: Version not updating
**Cause**: Regex pattern doesn't match file content  
**Solution**: Verify pattern against actual file format

### Issue: Encoding corruption in MSBuild output
**Cause**: Special characters (ñ, ó, ✓, ⚠)  
**Solution**: Use ASCII-only in scripts, no Unicode symbols

---

## 📊 Generation Metrics

Track these metrics for each build:
- Total files generated
- Files modified vs unchanged
- Script execution time
- Validation failures
- Version mismatches

---

## 🚀 Manual Regeneration

### Regenerate All Classes
```powershell
cd Organic.Generated
.\Scripts\Generate-AllClasses.ps1
```

### Update Versions Only
```powershell
.\Update-EstructuraAdnPrg.ps1 -Version "01.0003.00000"
.\Update-TransferenciaVersions.ps1 -Version "01.0003.00000"
```

### Validate Generated Code
```powershell
dovfp build -project Organic.Core.Generated.vfpproj -build_debug 2
```

---

## 📚 Related Resources

- [Build Instructions](../.github/instructions/dovfp-build.instructions.md)
- [Main Architecture Agent](../.github/AGENTS.md)

---

## 🔗 Integration Points

- **Build Agent**: Executes generation in pre-build
- **Source Code Agent**: Consumes generated classes
- **Main Agent**: Monitors generation metrics

---

**Specialization**: Code Generation, Metadata Processing, Build Automation  
**Last Updated**: 2025-10-15  
**Version**: 1.0.0
