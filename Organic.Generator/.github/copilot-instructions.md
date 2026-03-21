# Organic - Instrucciones para GitHub Copilot

## Contexto del Proyecto

Este es un proyecto **Visual FoxPro 9** de la familia **Organic**, una solución empresarial desarrollada en VS Code con herramientas modernas:
- **DOVFP**: Compilador .NET 6 para Visual FoxPro
- **VS Code + GitHub Copilot**: Entorno de desarrollo
- **PromptOps**: Sistema de 3 capas (Agents, Prompts, Instructions)
- **Azure DevOps**: CI/CD, repositorios, pipelines

---

## Estructura del Proyecto

### Proyectos principales

- **Organic.BusinessLogic/**: Código de negocio principal (CENTRALSS/)
- **Organic.Generated/**: Código generado automáticamente (**NO EDITAR MANUALMENTE**)
- **Organic.Tests/**: Tests unitarios y funcionales
- **Organic.Hooks/** _(opcional)_: Scripts pre/post build
- **Organic.Assets/** _(opcional)_: Recursos y assets

### Archivos de solución

- `*.vfpsln`: Archivo de solución que agrupa proyectos
- `*.vfpproj`: Archivos de proyecto individual
- `azure-pipelines.yml`: Configuración CI/CD
- `Nuget.config`: Gestión de paquetes DOVFP

---

## Estándares de Código VFP

### Nomenclatura Húngara

```foxpro
* Parámetros de funciones/procedimientos
LPARAMETERS tcNombre, tnEdad, tlActivo, toObjeto, taArray
* tc = text character
* tn = text numeric
* tl = text logical
* to = text object
* ta = text array

* Variables locales
LOCAL lcVariable, lnContador, llFlag, loObjeto, laLista
* l = local

* Propiedades de clase
THIS.cPropiedad = ""   && character
THIS.nPropiedad = 0    && numeric
THIS.lPropiedad = .F.  && logical
THIS.oPropiedad = NULL && object
```

---

## Organización de Archivos - TOLERANCIA CERO

### Archivos permitidos

- **Raíz limpia**: Solo archivos esenciales de producción
- **.github/ limpio**: SOLO AGENTS.md, copilot-instructions.md + carpetas prompts/ e instructions/
- **Proyectos**: Cada carpeta Organic.* tiene su estructura definida

### Archivos PROHIBIDOS

- **NO crear archivos de reporte**: FINAL-STATUS-REPORT.*, *-ANALYSIS.*, *-SUMMARY.*
- **NO crear archivos temporales**: .tmp, .bak, .old, debug-*, test-*
- **PROHIBIDO en .github/**: *-LOG.md, *-COMPLETE.md, *-ANALYSIS.md, *-REPORT.md, *-SUMMARY.md
- **NO carpeta docs/**: GitHub Copilot NO la lee automáticamente

---

## PromptOps - Sistema de 3 Capas

### 1. Agents (AGENTS.md)
**Ubicación**: Dentro de cada proyecto  
**Activación**: Automática según ubicación del archivo activo

### 2. Prompts (.prompt.md)
**Ubicación**: `.github/prompts/` organizados por categoría  
**Activación**: Manual via `@workspace #prompt:nombre`

### 3. Instructions (.instructions.md)
**Ubicación**: `.github/instructions/`  
**Activación**: Automática según tipo de archivo o contexto

---

Cuando trabajes con este proyecto, **SIEMPRE mantén estos estándares** y **NUNCA crees archivos temporales** que violen la política de workspace limpio.