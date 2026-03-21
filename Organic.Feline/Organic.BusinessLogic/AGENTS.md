# 🧑‍💻 Agente de Código VFP - Business Logic

## Descripción
Agente especializado en desarrollo Visual FoxPro 9 para la capa de lógica de negocio de Organic.Feline. Conoce patrones VFP modernos, integración con SQL Server, manejo de transacciones y arquitectura de clases.

## Ámbito de responsabilidad
- **Código fuente VFP**: Desarrollo y mantenimiento de clases, procedimientos y funciones
- **Formularios y reportes**: Diseño de UI con formularios (.scx) y reportes (.frx)
- **Integración de datos**: Conexión con SQL Server, manejo de cursores y vistas remotas
- **Lógica de negocio**: Reglas empresariales, validaciones, cálculos y procesamiento

## Archivos clave
```yaml
applyTo:
  - "Organic.BusinessLogic/**/*.prg"     # Programas y clases VFP
  - "Organic.BusinessLogic/**/*.vcx"     # Bibliotecas de clases visuales
  - "Organic.BusinessLogic/**/*.scx"     # Formularios
  - "Organic.BusinessLogic/**/*.frx"     # Reportes
  - "Organic.BusinessLogic/**/*.dbc"     # Contenedores de bases de datos
  - "Organic.BusinessLogic/**/*.dbf"     # Tablas de datos
  - "Organic.BusinessLogic/**/*.mnx"     # Menús
  - "Organic.BusinessLogic/**/*.pjx"     # Proyectos legacy (si existen)
```

## Estructura del proyecto

### Carpetas principales
```
Organic.BusinessLogic/
├── CENTRALSS/                 # Módulo principal de la aplicación
│   ├── main2028.prg          # Punto de entrada principal
│   ├── _Dibujante/           # Módulo de dibujo/diseño
│   ├── _Nucleo/              # Core: clases base, utilidades
│   ├── _Taspein/             # Módulo específico de dominio
│   ├── Felino/               # Módulo felino (dominio específico)
│   └── Imagenes/             # Recursos gráficos
├── bin/App/                  # Binarios compilados
├── obj/App/                  # Objetos intermedios de compilación
└── packages/App/             # Paquetes y dependencias
```

## Contexto técnico VFP

### Versión y características
- **Visual FoxPro 9.0** (última versión, EOL 2015 pero ampliamente usada)
- **Características modernas**: Clases, herencia, polimorfismo, eventos
- **Integración**: SQL Server via ODBC/OLE DB, XML, COM/ActiveX

### Patrones de código VFP

#### 1. Definición de clases
```foxpro
*-- Clase base de entidad de negocio
DEFINE CLASS BaseEntity AS Custom
    PROTECTED cTableName
    PROTECTED cPrimaryKey
    
    PROCEDURE Init(tcTableName, tcPrimaryKey)
        THIS.cTableName = tcTableName
        THIS.cPrimaryKey = tcPrimaryKey
    ENDPROC
    
    PROCEDURE Load(tnId)
        LOCAL lcSQL, lnResult
        lcSQL = "SELECT * FROM " + THIS.cTableName + ;
                " WHERE " + THIS.cPrimaryKey + " = ?tnId"
        lnResult = SQLEXEC(gnHandle, lcSQL, "curResult")
        RETURN lnResult > 0
    ENDPROC
ENDDEFINE
```

#### 2. Manejo de transacciones SQL Server
```foxpro
*-- Patrón de transacción segura
LOCAL lnHandle, llSuccess
lnHandle = SQLCONNECT("MiDSN")
IF lnHandle < 0
    RETURN .F.
ENDIF

llSuccess = .F.
=SQLSETPROP(lnHandle, "Transactions", 2) && Manual
IF SQLEXEC(lnHandle, "BEGIN TRANSACTION") > 0
    TRY
        *-- Operaciones de base de datos aquí
        IF THIS.GuardarFactura() AND THIS.GuardarDetalles()
            =SQLEXEC(lnHandle, "COMMIT TRANSACTION")
            llSuccess = .T.
        ELSE
            =SQLEXEC(lnHandle, "ROLLBACK TRANSACTION")
        ENDIF
    CATCH TO loEx
        =SQLEXEC(lnHandle, "ROLLBACK TRANSACTION")
        MESSAGEBOX("Error: " + loEx.Message)
    ENDTRY
ENDIF
=SQLDISCONNECT(lnHandle)
RETURN llSuccess
```

#### 3. Cursores y vistas remotas
```foxpro
*-- Crear vista remota programáticamente
CREATE SQL VIEW vwClientes REMOTE CONNECTION MiDSN AS ;
    SELECT ClienteId, Nombre, Email FROM dbo.Clientes ;
    WHERE Activo = 1

*-- Uso de cursores
SELECT * FROM vwClientes INTO CURSOR curClientes NOFILTER
SCAN
    ? curClientes.Nombre
ENDSCAN
USE IN curClientes
```

## Convenciones de código

### Nomenclatura
- **Clases**: PascalCase (`FacturaManager`, `ClienteEntity`)
- **Variables locales**: lcTipo, lnContador, llBandera (prefijo húngaro)
  - `lc` = local character
  - `ln` = local numeric
  - `ll` = local logical
  - `lo` = local object
  - `la` = local array
- **Parámetros**: tcTexto, tnNumero, tlBandera (prefijo `t` = parameter)
- **Propiedades**: cNombre, nEdad (sin prefijo o con tipo)
- **Tablas/DBF**: snake_case (`dat_clientes.dbf`, `factura_detalle.dbf`)

### Formato de código
```foxpro
*-----------------------------------------------------------------------
*-- Descripción: Procesa una factura de venta
*-- Parámetros:
*--   tnFacturaId : ID de la factura
*--   tcTipo      : Tipo de factura ("A", "B", "C")
*-- Retorna: .T. si fue exitoso, .F. si hubo error
*-----------------------------------------------------------------------
PROCEDURE ProcesarFactura(tnFacturaId, tcTipo)
    LOCAL llSuccess, lcMensaje
    
    *-- Validaciones
    IF EMPTY(tnFacturaId) OR NOT INLIST(tcTipo, "A", "B", "C")
        RETURN .F.
    ENDIF
    
    *-- Procesamiento
    TRY
        llSuccess = THIS.ValidarFactura(tnFacturaId) AND ;
                    THIS.CalcularTotales(tnFacturaId) AND ;
                    THIS.GuardarCambios()
    CATCH TO loEx
        llSuccess = .F.
        lcMensaje = "Error en ProcesarFactura: " + loEx.Message
        THIS.LogError(lcMensaje)
    ENDTRY
    
    RETURN llSuccess
ENDPROC
```

## Mejores prácticas VFP

### ✅ DO's
- **Usar TRY/CATCH** para manejo de errores robusto
- **Cerrar cursores** con `USE IN` después de usarlos
- **Liberar objetos** con `RELEASE` o asignar `.NULL.`
- **Validar conexiones SQL** antes de ejecutar comandos
- **Usar NOFILTER** en cursores para mejor rendimiento
- **Documentar parámetros** de procedimientos y funciones
- **Separar UI de lógica** (formularios delgados, clases gruesas)

### ❌ DON'Ts
- ❌ **Evitar SET TALK ON** en producción
- ❌ **No usar GOTO/SKIP** sin validar EOF()/BOF()
- ❌ **No dejar conexiones SQL abiertas** innecesariamente
- ❌ **Evitar variables públicas** (usar propiedades de objetos)
- ❌ **No hardcodear paths** (usar configuración o variables de entorno)
- ❌ **Evitar SELECT 0** sin control (usar aliases específicos)

## Integración con DOVFP

### Configuración de proyecto (.vfpproj)
El proyecto incluye configuración para DOVFP que compila los archivos .prg, .vcx, .scx en ejecutables o DLLs.

### Debugging con VS Code
- **Breakpoints**: Exportados automáticamente a VFP
- **Launch config**: Ejecuta archivos con `dovfp run -template 1`
- **Output**: Resultados visibles en terminal de VS Code

## Patrones de arquitectura

### Patrón Repository
```foxpro
*-- ClienteRepository.prg
DEFINE CLASS ClienteRepository AS Custom
    PROTECTED cConnection
    
    PROCEDURE ObtenerPorId(tnId)
        LOCAL loCliente
        loCliente = CREATEOBJECT("ClienteEntity")
        IF loCliente.Load(tnId)
            RETURN loCliente
        ENDIF
        RETURN .NULL.
    ENDPROC
    
    PROCEDURE Guardar(toCliente)
        *-- Lógica de persistencia
        RETURN THIS.Save(toCliente)
    ENDPROC
ENDDEFINE
```

### Patrón Service Layer
```foxpro
*-- FacturacionService.prg
DEFINE CLASS FacturacionService AS Custom
    oRepository = .NULL.
    oValidator = .NULL.
    
    PROCEDURE EmitirFactura(toCliente, taItems)
        *-- Validar
        IF NOT THIS.oValidator.ValidarCliente(toCliente)
            RETURN .F.
        ENDIF
        
        *-- Crear factura
        loFactura = THIS.CrearFactura(toCliente, taItems)
        
        *-- Guardar
        RETURN THIS.oRepository.GuardarFactura(loFactura)
    ENDPROC
ENDDEFINE
```

## Prompts especializados para VFP

- `.github/prompts/dev/vfp-development-expert.prompt.md` - Desarrollo VFP avanzado
- `.github/prompts/refactor/refactor-patterns.prompt.md` - Refactorización de código legacy
- `.github/prompts/auditoria/code-audit-comprehensive.prompt.md` - Auditoría de calidad

## Referencias
- 📖 [Documentación VFP 9](https://learn.microsoft.com/en-us/previous-versions/visualstudio/foxpro/mt490117(v=msdn.10))
- 🏗️ [Arquitectura del proyecto](../../docs/architecture/business-logic-layer.md)
- 🔧 [Guía de estilo VFP](../../docs/guides/vfp-style-guide.md)

---

**Versión**: 1.0.0  
**Última actualización**: 2025-10-15  
**Agente padre**: [.github/AGENTS.md](../../.github/AGENTS.md)
