# 🤖 Agente: Generación Automática

**Contexto**: Código generado (`Organic.Generated/`)  
**Responsabilidad**: Código generado automáticamente, scripts de generación, validación post-build

---

## 🎯 Especialización

Este agente está especializado en:

- Código VFP generado automáticamente
- Scripts PowerShell de generación
- Validación de versiones
- Serialización de estructuras
- Generación de ABMs (Alta/Baja/Modificación)
- Combos y catálogos dinámicos

---

## 📁 Estructura

```
Organic.Generated/
├── ADN/
│   ├── DBCSerializado/        # Estructuras de base de datos serializadas
│   └── IndiceAdn/             # Índices de ADN del sistema
├── Generados/                 # Código VFP generado
│   ├── Din_Abm*.prg          # ABMs generados dinámicamente
│   ├── Combo*.xml            # Definiciones de combos
│   └── dat_*.s??             # Datos serializados
├── bin/PRG/                   # Salida de compilación
├── obj/PRG/                   # Archivos intermedios
├── packages/PRG/              # Dependencias
└── *.ps1                      # Scripts de generación
```

---

## ⚙️ Scripts de generación

### 1. Update-EstructuraAdnPrg.ps1

**Propósito**: Actualizar estructura ADN desde definiciones

```powershell
# Ejecutar generación
.\Organic.Generated\Update-EstructuraAdnPrg.ps1

# Con parámetros
.\Organic.Generated\Update-EstructuraAdnPrg.ps1 -Verbose -Force
```

**Qué hace**:
- Lee definiciones de `ADN/DBCSerializado/`
- Genera archivos `.prg` con estructuras
- Actualiza índice en `ADN/IndiceAdn/`

### 2. Update-TransferenciaVersions.ps1

**Propósito**: Sincronizar versiones entre proyectos

```powershell
.\Organic.Generated\Update-TransferenciaVersions.ps1 -SourceVersion "2.5.0"
```

**Qué hace**:
- Lee versión del proyecto fuente
- Actualiza referencias en proyectos dependientes
- Valida consistencia de versiones

### 3. Validate-VersionsPostBuild.ps1

**Propósito**: Validar versiones después de compilar

```powershell
# Ejecutado automáticamente en post-build
.\Organic.Generated\Validate-VersionsPostBuild.ps1
```

**Qué hace**:
- Verifica que todas las versiones sean consistentes
- Valida que no haya referencias a versiones antiguas
- Genera warnings si encuentra inconsistencias

---

## 🏗️ Patrones de código generado

### ABM generado (Alta/Baja/Modificación)

```foxpro
* Din_AbmCaballoAvanzadoEstilo2.prg
* ESTE ARCHIVO ES GENERADO AUTOMÁTICAMENTE - NO MODIFICAR MANUALMENTE

DEFINE CLASS Din_AbmCaballoAvanzadoEstilo2 AS AbmBaseAvanzado

    * Propiedades generadas
    cEntidad = "Caballo"
    cTabla = "Caballos"
    cClavePrimaria = "idCaballo"
    
    PROCEDURE Init()
        DODEFAULT()
        THIS.ConfigurarCampos()
    ENDPROC
    
    PROCEDURE ConfigurarCampos()
        * Configuración generada desde metadatos
        THIS.AgregarCampo("Nombre", "C", 100, .T.)
        THIS.AgregarCampo("Edad", "N", 3, .F.)
        THIS.AgregarCampo("Raza", "C", 50, .F.)
    ENDPROC
    
    * Métodos generados...
    
ENDDEFINE
```

### Combo XML generado

```xml
<!-- ComboTipoComprobanteVentas.xml -->
<!-- GENERADO AUTOMÁTICAMENTE -->
<Combo>
    <Items>
        <Item id="1" value="Factura A" />
        <Item id="2" value="Factura B" />
        <Item id="3" value="Nota de Crédito" />
        <Item id="4" value="Nota de Débito" />
    </Items>
    <DefaultValue>1</DefaultValue>
    <AllowNull>false</AllowNull>
</Combo>
```

---

## 🚫 Reglas críticas

### NO MODIFICAR MANUALMENTE

⚠️ **IMPORTANTE**: Los archivos en `Generados/` son generados automáticamente.

**Proceso correcto**:
1. Modificar la fuente de generación (templates, metadatos)
2. Ejecutar el script de generación correspondiente
3. Validar el código generado
4. Commitear tanto la fuente como el generado

**NO hacer**:
- ❌ Editar directamente archivos en `Generados/`
- ❌ Agregar lógica custom en código generado
- ❌ Eliminar comentarios de "GENERADO AUTOMÁTICAMENTE"

### Extensión correcta

Si necesitas customizar un ABM generado:

```foxpro
* MiCaballoCustom.prg (archivo separado)
DEFINE CLASS MiCaballoCustom AS Din_AbmCaballoAvanzadoEstilo2

    PROCEDURE Init()
        DODEFAULT()
        * Tu lógica custom aquí
        THIS.AgregarValidacionCustom()
    ENDPROC
    
    PROCEDURE AgregarValidacionCustom()
        * Lógica específica que no debe generarse
    ENDPROC
    
ENDDEFINE
```

---

## 🔄 Workflow de generación

### 1. Regenerar todo

```powershell
# Script maestro de regeneración
.\scripts\regenerate-all.ps1
```

Ejecuta en orden:
1. `Update-EstructuraAdnPrg.ps1`
2. `Update-TransferenciaVersions.ps1`
3. Compilación
4. `Validate-VersionsPostBuild.ps1`

### 2. Regenerar solo ABMs

```powershell
.\scripts\regenerate-abms.ps1 -Entities "Caballo,Burro,Cebra"
```

### 3. Agregar nueva entidad

```powershell
.\scripts\add-entity.ps1 -Name "NuevaEntidad" -GenerateAbm -GenerateCombo
```

---

## 📊 Datos serializados

### Formato .szl (serializado)

```foxpro
* Leer datos serializados
LOCAL loSerializer, loData
loSerializer = CREATEOBJECT("SerializadorDatos")
loData = loSerializer.Deserializar("Generados/dat_emp.szl")

* Usar datos
FOR EACH loItem IN loData.Items
    ? loItem.Nombre
ENDFOR
```

### Formato .sdb (base serializada)

Similar a `.szl` pero optimizado para estructuras de datos más complejas.

---

## 🧪 Testing de código generado

```foxpro
* Test_GeneratedAbm.prg
DEFINE CLASS Test_GeneratedAbm AS TestCase

    PROCEDURE Test_AbmCaballoGeneradoDebeExistir()
        LOCAL loAbm
        loAbm = CREATEOBJECT("Din_AbmCaballoAvanzadoEstilo2")
        
        THIS.AssertNotNull(loAbm, "ABM debe ser creado")
        THIS.AssertEquals("Caballo", loAbm.cEntidad)
    ENDPROC
    
    PROCEDURE Test_AbmDebeIncluirTodosCamposRequeridos()
        LOCAL loAbm
        loAbm = CREATEOBJECT("Din_AbmCaballoAvanzadoEstilo2")
        
        THIS.AssertTrue(loAbm.TieneCampo("Nombre"))
        THIS.AssertTrue(loAbm.TieneCampo("Edad"))
    ENDPROC
    
ENDDEFINE
```

---

## 📋 Tareas que maneja este agente

- Ejecutar scripts de generación
- Validar código generado
- Agregar nuevas entidades al generador
- Modificar templates de generación
- Resolver problemas de generación
- Actualizar metadatos de generación
- Validar versiones post-build
- Sincronizar estructuras ADN

---

## 🔗 Recursos relacionados

- [Instrucciones de generación](../.github/instructions/generation.instructions.md)
- [Guía de templates](../docs/architecture/generation-templates.md)
- [Metadatos de entidades](../docs/architecture/entity-metadata.md)

---

## 🎨 Uso con GitHub Copilot Chat

```
@workspace #file:Update-EstructuraAdnPrg.ps1 Usando el agente de generación, explica cómo agregar una nueva entidad

@workspace ¿Cómo puedo regenerar todos los ABMs después de modificar los metadatos?

@workspace El código generado para Caballo tiene un error, ¿cómo lo arreglo sin editar el generado?
```

---

## 🔍 Patrones de archivos

Este agente se activa automáticamente cuando trabajas con:

```yaml
applyTo:
  - "Organic.Generated/**/*"
  - "**/Generados/**/*"
  - "**/Din_Abm*.prg"
  - "**/*.szl"
  - "**/*.sdb"
  - "**/Update-*.ps1"
  - "**/Validate-*.ps1"
  - "**/ADN/**/*"
```
