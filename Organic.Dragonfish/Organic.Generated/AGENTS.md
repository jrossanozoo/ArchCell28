# 🤖 Agente: Organic.Generated

**Rol**: Gestor de código auto-generado y versionamiento de estructuras de datos.

**Contexto**:
```
Proyecto: Organic.Generated
Tipo: Program Library (PRG)
Output: Archivos .prg generados automáticamente
Dependencias: Ninguna (proyecto base)
```

**Responsabilidades**:
- Generación automática de clases de transferencia (Din_Transferencia*)
- Actualización de versiones en estructuras de datos
- Sincronización de esquemas de base de datos
- Generación de metadatos XML (din_estructuraadn.xml)
- Serialización de estructuras ADN

**Estructura**:
```
Organic.Generated/
├── Generados/                              # Todo el código generado
│   ├── Din_Transferencia*Consulta.prg      # Clases de consulta (26 archivos)
│   ├── Din_Transferencia*Objeto.prg        # Clases de entidades (26 archivos)
│   ├── Din_Estructuraadn.prg               # Metadata de versión
│   ├── din_estructuraadn.xml               # Configuración XML
│   ├── dat_*.sdb / dat_*.szl               # Archivos de datos serializados
│   └── Combo*.xml                          # Combos y catálogos
├── ADN/                                    # Estructuras de datos ADN
│   ├── DBCSerializado/
│   ├── IndiceAdn/
│   └── Paquetes/
├── Update-TransferenciaVersions.ps1        # Script PRE-BUILD
├── Update-EstructuraAdnPrg.ps1             # Script PRE-BUILD
├── Validate-VersionsPostBuild.ps1          # Script POST-BUILD
└── Organic.Dragonfish.Generated.vfpproj
```

**⚠️ ADVERTENCIA: NO EDITAR MANUALMENTE**
Los archivos en `Generados/` son generados automáticamente. Cualquier cambio manual será sobrescrito en el próximo build.

**Proceso de Build**:
1. **PRE-BUILD** (solo en Release):
   - `UpdateTransferenciaVersions`: Actualiza versiones en Din_Transferencia*
   - `UpdateEstructuraAdnPrg`: Actualiza versión en Din_Estructuraadn.prg
   - `UpdateEstructuraAdnXml`: Actualiza XML con XmlPoke
2. **POST-BUILD** (siempre):
   - `PostBuildValidation`: Valida que las versiones sean correctas

**Versionamiento**:
```
Formato: Major.Minor.Build (normalizado: 01.0001.00000)
Ejemplo: 15.10.10018
```

**Scripts PowerShell**:
- **`Update-TransferenciaVersions.ps1`**: 
  - Modifica atributo `Version=""` en archivos XML embebidos
  - Usa regex para actualizar versiones
- **`Update-EstructuraAdnPrg.ps1`**: 
  - Modifica `Return 'version'` en .prg
  - Actualiza campos XML (Major, Release, Build)
- **`Validate-VersionsPostBuild.ps1`**: 
  - SOLO LECTURA: valida versiones, no modifica nada
  - Exit code 1 si hay errores

**Targets MSBuild**:
```xml
<Target Name="PostBuildValidation" DependsOnTargets="Build">
  <!-- Solo validación, sin modificaciones -->
</Target>
```

**Directrices**:
- **Nunca editar archivos en `Generados/` manualmente**
- **Siempre compilar en modo Release** para actualizar versiones
- **Validar post-build** para asegurar coherencia
- **Versionar cambios estructurales** en formato Major.Minor.Build

**Comandos**:
```powershell
# Build con actualización de versiones (Release mode)
dovfp build -project Organic.Dragonfish.Generated -build_debug 2

# Validar versiones manualmente
pwsh -ExecutionPolicy Bypass -File "Validate-VersionsPostBuild.ps1" -ExpectedVersion "15.0010.10018"
```

---

**Ver también**: 
- [AGENTS.md principal](../.github/AGENTS.md)
- [Documentación de versionamiento](../docs/versioning-strategy.md)
