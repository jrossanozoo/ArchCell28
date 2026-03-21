---
description: "Instrucciones generales de desarrollo para GitHub Copilot en la solución Organic.Generator (VFP 9) - arquitectura, estándares y patrones"
---

# Zoo Tool Kit Extension - Instrucciones para GitHub Copilot

## Contexto del Proyecto
Este es el proyecto **Zoo Tool Kit para Visual FoxPro** - una extensión de VS Code que proporciona:
- Integración con Azure DevOps para actualizaciones automáticas de DOVFP
- Soporte completo para desarrollo Visual FoxPro (.prg, .fpw, .dbf)
- Gestión segura de autenticación con Azure Key Vault
- Herramientas de debugging y configuración de proyectos VFP

## Estándares de Código y Arquitectura

### Seguridad y Autenticación
- **SOLO usar API REST directa** para consultas a Azure DevOps (sin archivos temporales)
- **PROHIBIDO** usar variables de entorno para credenciales (VSS_NUGET_EXTERNAL_FEED_ENDPOINTS)
- **PROHIBIDO** crear archivos temporales nuget.config con credenciales
- **Token management:** Solo via Azure Key Vault (kv-prod-azdo/feeds-azdo-readonly)

### Organización de Archivos - TOLERANCIA CERO
- **Raíz limpia:** Solo archivos esenciales de producción (package.json, README.md, etc.)
- **NO crear archivos de reporte:** FINAL-STATUS-REPORT.*, POWERSHELL-CLEANUP-REPORT.*
- **NO crear archivos temporales:** .tmp, .bak, .old, debug-*, test-*, experimental-*
- **JavaScript:** Solo en /src/ (producción) - NO JavaScript experimental en /test/
- **PowerShell:** Solo en /scripts/ y /test/scripts/ - UN SOLO .ps1 en raíz (install-latest.ps1)

### Logging y UX
- **Logger centralizado:** Usar getLogger() de utils/logger.js
- **Sin intrusividad:** No mostrar Output panel automáticamente
- **Filtrar errores:** Ignorar errores "Canceled" 
- **preserveFocus=true:** Solo para errores críticos

### Estructura de Servicios
- **/src/services/dovfpService.js:** SOLO método API REST directa
- **/src/services/azureCliService.js:** Gestión de Azure CLI
- **/src/utils/logger.js:** Sistema de logging mejorado
- **/src/commands/:** Comandos de la extensión

## Patrones de Desarrollo

### Para DOVFP Updates
- Usar tryAzureDevOpsApiMethod() únicamente
- Endpoint: https://pkgs.dev.azure.com/zoologicnet/_packaging/doVFP/nuget/v3/registrations2/dovfp/index.json
- Ordenamiento semántico de versiones (no cronológico)
- Descarga directa de .nupkg sin persistencia de credenciales

### Para Workspace Cleanup
- Aplicar tolerancia cero para archivos innecesarios
- Usar scripts/diagnostics/auto-cleanup.ps1 para limpieza automática
- Validar que no queden directorios vacíos

### Para Extension Commands
- Prefijo: "ZooLogic: [Acción]"
- Logging detallado pero no intrusivo
- Manejo robusto de errores sin notificaciones automáticas molestas

## Visual FoxPro Development
- **Archivos soportados:** .prg, .PRG, .fpw, .FPW, .dbf, .DBF
- **Debugging:** Configuración automática de launch.json y tasks.json
- **DOVFP:** Herramienta principal para desarrollo VFP moderno

## Testing y Validación
- **Solo PowerShell:** /test/scripts/ para testing automatizado
- **NO JavaScript:** Eliminados todos los tests experimentales JS
- **Integración:** Azure CLI, DOVFP, feed access validation
- **Packaging:** npm run package debe ser exitoso sin errores

## Documentación Requerida
- **README.md:** Documentación principal del usuario
- **CHANGELOG.md:** Historial detallado de cambios
- **.github/copilot.md:** Documentación técnica completa para desarrolladores
- **scripts/README.md:** Organización de scripts PowerShell

Cuando trabajes con este proyecto, SIEMPRE mantén estos estándares y NUNCA creates archivos temporales o de debugging que violen la política de workspace limpio.