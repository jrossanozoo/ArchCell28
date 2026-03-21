# Organic Dragonfish

**Sistema de gestión empresarial desarrollado en Visual FoxPro 9** con integración moderna en VS Code y Azure DevOps.

## 🎯 Descripción

Organic Dragonfish es una solución empresarial modular para gestión de ventas, compras, inventario, facturación y trazabilidad. Desarrollado en Visual FoxPro 9 y compilado con **DOVFP**, integra tecnología legacy con pipelines modernos de CI/CD.

## 📦 Estructura de la solución

```
Organic.Dragonfish/
├── Organic.BusinessLogic/    # Lógica de negocio central (CENTRALSS, ColorYTalle, etc.)
├── Organic.Generated/         # Código generado automáticamente (ADN, stubs, bindings)
├── Organic.Hooks/             # Extensiones y hooks personalizados
├── Organic.Tests/             # Suite de pruebas automatizadas
└── Organic.Assets/            # Recursos (DLLs, configuración, multimedia)
```

## 🚀 Inicio rápido

### Requisitos previos

- **Visual Studio Code** con extensión Zoo Tool Kit
- **DOVFP** (instalado automáticamente vía Azure DevOps feed)
- **Visual FoxPro 9** runtime
- **Azure CLI** (para autenticación con Azure DevOps)

### Instalación

1. Clonar el repositorio:
   ```powershell
   git clone https://zoologicnet@dev.azure.com/zoologicnet/Organic/_git/Organic.Dragonfish
   cd Organic.Dragonfish
   ```

2. Autenticarse con Azure CLI:
   ```powershell
   az login
   ```

3. Instalar DOVFP (automático al abrir en VS Code con Zoo Tool Kit)

### Build

```powershell
# Build completo de la solución
dovfp build Organic.Dragonfish.vfpsln

# Build de proyecto específico
dovfp build Organic.BusinessLogic\Organic.Dragonfish.vfpproj
```

### Debugging en VS Code

1. Abrir archivo `.prg` que desees debuggear
2. Presionar `F5` o usar **Run > Start Debugging**
3. Los breakpoints se exportan automáticamente a VFP
4. Ver [`.vscode/VFP-DEBUGGING.md`](.vscode/VFP-DEBUGGING.md) para configuración avanzada

## 🧪 Testing

```powershell
# Ejecutar tests
dovfp test Organic.Tests\Organic.Tests.vfpproj

# Con cobertura
dovfp test Organic.Tests\Organic.Tests.vfpproj --coverage
```

## 🤖 GitHub Copilot

Este proyecto está optimizado para trabajo con **GitHub Copilot Chat**:

- **Instrucciones globales**: [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
- **Agentes especializados**: Cada proyecto tiene su propio `AGENTS.md`
- **Prompts reutilizables**: [`.github/prompts/`](.github/prompts/)

### Uso de agentes

```markdown
# En Copilot Chat, usa:
@workspace /agent BusinessLogic  # Para lógica de negocio
@workspace /agent Generated       # Para código generado
@workspace /agent Hooks           # Para extensiones
@workspace /agent Tests           # Para testing
```

## 📋 Pipelines y CI/CD

Build automatizado con **Azure Pipelines**:
- Pre-build: Generación de stubs, actualización de versiones
- Build: Compilación con DOVFP
- Post-build: Validación de versiones, empaquetado
- Ver [`azure-pipelines.yml`](azure-pipelines.yml)

## 🔧 Configuración

- **config.fpw**: Configuración principal de Visual FoxPro
- **Aplicacion.ini**: Parámetros de la aplicación
- **Nuget.config**: Fuentes de paquetes (Azure Artifacts)

## 📚 Documentación adicional

- [Debugging VFP en VS Code](.vscode/VFP-DEBUGGING.md)
- [Instrucciones para Copilot](.github/copilot-instructions.md)
- [Agente principal](.github/AGENTS.md)

## 🤝 Contribuir

1. Crear rama desde `main`
2. Seguir convenciones de código VFP
3. Ejecutar tests antes de commit
4. Crear Pull Request con descripción detallada
5. Asegurar que el pipeline pase exitosamente

## 📄 Licencia

Propietario: ZooLogic S.A. - Uso interno únicamente.