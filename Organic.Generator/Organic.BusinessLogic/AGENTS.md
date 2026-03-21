# 🧬 Agent Configuration - Organic.BusinessLogic

> **Role:** VFP Business Logic Developer
> 
> **Scope:** Desarrollo de generadores dinámicos, lógica de negocio y componentes VFP

---

## 📋 Overview

Este agente se especializa en el desarrollo de código Visual FoxPro 9 dentro del proyecto **Organic.BusinessLogic**, enfocándose en generadores dinámicos, ABMs, lógica de negocio y componentes visuales.

## 🎯 Responsibilities

### 1. **Generadores Dinámicos**
- Desarrollo de generadores de ABMs (Alta, Baja, Modificación)
- Plantillas avanzadas (Estilo2, SubEntidades)
- Generadores de menús principales
- Generadores de reportes y combos

### 2. **Código VFP**
- Programación en Visual FoxPro 9 (.prg files)
- Desarrollo de clases visuales (.vcx files)
- Formularios y pantallas (.scx files)
- Bibliotecas y funciones comunes

### 3. **Estructura de Datos**
- ADN (DNA) de estructuras de datos
- Serialización de DBC
- Índices y metadatos
- Validaciones y reglas de negocio

### 4. **Patrones y Convenciones**
- Nomenclatura de variables y funciones VFP
- Estructura de procedimientos y funciones
- Manejo de errores y logging
- Comentarios y documentación inline

---

## 📁 Directory Structure

```
Organic.BusinessLogic/
├── CENTRALSS/
│   ├── main2028.prg          # Entry point
│   ├── _Taspein/             # Módulo Taspein
│   └── Generadores/          # Generadores dinámicos
│       └── _Base/            # Base classes para generadores
├── bin/App/                  # Binarios compilados
├── obj/App/                  # Archivos intermedios
└── packages/                 # Dependencias y paquetes
```

---

## 🎨 Conventions & Standards

### Naming Conventions
```vfp
* Funciones públicas: PascalCase
FUNCTION GenerarAbmAvanzado()

* Variables locales: lowerCamelCase
LOCAL lcNombreTabla, lnContador

* Parámetros: con prefijo p
FUNCTION MiFuncion(pcParametro1, pnParametro2)

* Propiedades de objetos: PascalCase
This.NombrePropiedad = "valor"
```

### File Organization
- Un generador por archivo cuando sea posible
- Separar UI de lógica de negocio
- Agrupar funciones relacionadas
- Documentar parámetros y retornos

### Code Quality
```vfp
*-- ============================================
*-- Función: GenerarComboTipoComprobante
*-- Propósito: Genera combo dinámico de tipos
*-- Parámetros:
*--   pcTipoEntidad: Tipo de entidad (C)
*--   plConValores: Incluir valores (L)
*-- Retorna: XML del combo (C)
*-- ============================================
FUNCTION GenerarComboTipoComprobante(pcTipoEntidad, plConValores)
  LOCAL lcResultado
  
  * Validar parámetros
  IF EMPTY(pcTipoEntidad)
    RETURN ""
  ENDIF
  
  * Lógica principal
  lcResultado = GenerarXMLCombo(pcTipoEntidad, plConValores)
  
  RETURN lcResultado
ENDFUNC
```

---

## 🔧 Common Tasks

### Crear un Nuevo Generador ABM

1. **Copiar plantilla base:**
```vfp
* Ubicación: CENTRALSS/Generadores/_Base/
* Template: generadorabmavanzadoestilo2.prg
```

2. **Personalizar generador:**
- Definir tabla destino
- Configurar campos y validaciones
- Implementar lógica específica
- Generar PRG de salida

3. **Registrar en sistema:**
```vfp
* Agregar a tabla de generadores
* Configurar metadatos
* Validar compilación
```

### Depurar Código VFP

Usar la configuración de VS Code:
- Establecer breakpoints (F9)
- Ejecutar con F5
- Inspeccionar variables en runtime

Ver: [docs/VFP-DEBUGGING.md](../../docs/VFP-DEBUGGING.md)

---

## 🧪 Testing

### Unit Tests
```vfp
* Ubicación: Organic.Tests/Tests/
* Convención: Test[NombreGenerador].prg
```

### Integration Tests
```vfp
* Validar generación completa
* Verificar compilación de PRG generados
* Probar en entorno real
```

---

## 📚 Related Documentation

- **VFP Best Practices:** [docs/VFP-BEST-PRACTICES.md](../../docs/VFP-BEST-PRACTICES.md) *(to be created)*
- **Generator Architecture:** [docs/GENERATOR-ARCHITECTURE.md](../../docs/GENERATOR-ARCHITECTURE.md) *(to be created)*
- **Data Structures:** [docs/DATA-STRUCTURES.md](../../docs/DATA-STRUCTURES.md) *(to be created)*

---

## 🎯 Prompts for This Agent

Use estos prompts en GitHub Copilot Chat:

```
@workspace /ask with #file:Organic.BusinessLogic/AGENTS.md 
How do I create a new dynamic ABM generator?
```

```
@workspace using #file:.github/prompts/dev/vfp-development-expert.prompt.md
Review this VFP code for best practices
```

---

## 🔗 Integration with Build System

Este código se compila usando **DOVFP**:

```powershell
# Compilar proyecto
dovfp build Organic.BusinessLogic/Organic.Generator.vfpproj

# Ejecutar archivo específico
dovfp run -template 1 CENTRALSS/Generadores/_Base/generador.prg
```

Ver agente principal: [.github/AGENTS.md](../.github/AGENTS.md)

---

## 📋 Checklist para Nuevos Desarrollos

- [ ] Seguir convenciones de nombres
- [ ] Documentar función con header estándar
- [ ] Validar parámetros de entrada
- [ ] Manejar errores apropiadamente
- [ ] Agregar tests unitarios
- [ ] Verificar compilación sin warnings
- [ ] Actualizar documentación si aplica
- [ ] Code review con equipo

---

**Last Updated:** 2025-10-15  
**Scope:** `Organic.BusinessLogic/**/*.prg`, `Organic.BusinessLogic/**/*.vcx`, `Organic.BusinessLogic/**/*.scx`
