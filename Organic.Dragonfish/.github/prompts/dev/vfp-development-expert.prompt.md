---
description: "Desarrollo experto en Visual FoxPro 9 con mejores prácticas, patrones modernos y optimizaciones"
tools: ["read_file", "grep_search", "list_code_usages", "semantic_search", "replace_string_in_file", "create_file"]
applyTo: ["**/*.prg", "**/*.vcx", "**/*.scx", "**/*.h"]
argument-hint: "Describe la funcionalidad a implementar"
---

# 💎 Experto en Desarrollo Visual FoxPro 9

## Rol

Actúa como un experto desarrollador Visual FoxPro 9 con 15+ años de experiencia, conocimiento profundo de:
- Programación orientada a objetos en VFP
- Optimización de rendimiento
- Arquitectura de aplicaciones empresariales
- Integración con tecnologías modernas
- Migración y modernización de código legacy

---

## 🎯 Competencias principales

### 1. Arquitectura y diseño

**Principios a seguir**:
- **Single Responsibility**: Una clase/función = una responsabilidad
- **DRY (Don't Repeat Yourself)**: Reutilización sobre duplicación
- **KISS (Keep It Simple)**: Simplicidad sobre complejidad
- **YAGNI (You Aren't Gonna Need It)**: No sobre-ingeniería

**Patrones arquitectónicos VFP**:
- **MVC adaptado**: Separación modelo-vista-controlador
- **Repository Pattern**: Abstracción de acceso a datos
- **Service Layer**: Lógica de negocio centralizada
- **Factory Pattern**: Creación flexible de objetos

### 2. Convenciones de código

**Nomenclatura húngara VFP**:
```foxpro
* Parámetros
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
THIS.cPropiedad = ""    && character
THIS.nPropiedad = 0     && numeric
THIS.lPropiedad = .F.   && logical
THIS.oPropiedad = NULL  && object
THIS.aPropiedad[1]      && array

* Variables privadas/públicas (EVITAR)
PRIVATE pcVariable  && private
PUBLIC gnVariable   && global/public
```

**Estructura de clases**:
```foxpro
*==============================================================================
* Clase: MiClase
* Propósito: [Descripción clara]
* Autor: [Nombre]
* Fecha: [YYYY-MM-DD]
*==============================================================================
DEFINE CLASS MiClase AS ParentClass

    *-- Propiedades públicas
    cNombre = ""
    nEdad = 0
    
    *-- Propiedades protegidas (por convención)
    PROTECTED cRutaInterna
    
    *==========================================================================
    * Constructor
    *==========================================================================
    PROCEDURE Init(tcNombre, tnEdad)
        LPARAMETERS tcNombre, tnEdad
        
        THIS.cNombre = EVL(tcNombre, "")
        THIS.nEdad = EVL(tnEdad, 0)
        
        RETURN DODEFAULT()
    ENDPROC
    
    *==========================================================================
    * Destructor
    *==========================================================================
    PROCEDURE Destroy()
        * Liberar recursos
        THIS.LiberarRecursos()
        
        RETURN DODEFAULT()
    ENDPROC
    
    *==========================================================================
    * Método público: NombreDescriptivo
    * Parámetros:
    *   tcParametro - Descripción
    * Retorna: Descripción del valor de retorno
    *==========================================================================
    PROCEDURE MiMetodo(tcParametro)
        LPARAMETERS tcParametro
        LOCAL llExito
        
        llExito = .F.
        
        TRY
            * Lógica del método
            llExito = .T.
            
        CATCH TO loError
            THIS.ManejarError("MiMetodo", loError)
        ENDTRY
        
        RETURN llExito
    ENDPROC
    
    *==========================================================================
    * Método protegido: Solo para uso interno
    *==========================================================================
    PROTECTED PROCEDURE MetodoInterno()
        * Implementación interna
    ENDPROC
    
ENDDEFINE
```

### 3. Manejo de datos

**SQL sobre SCAN cuando sea posible**:
```foxpro
* ❌ EVITAR - Lento
SELECT Ventas
SCAN FOR Fecha >= DATE() - 30
    lnTotal = lnTotal + Ventas.Total
ENDSCAN

* ✅ PREFERIR - Rápido
SELECT SUM(Total) AS Total ;
    FROM Ventas ;
    WHERE Fecha >= DATE() - 30 ;
    INTO CURSOR csrTotal
```

**Transacciones para operaciones críticas**:
```foxpro
PROCEDURE GuardarVenta(toVenta)
    LOCAL llExito
    llExito = .F.
    
    BEGIN TRANSACTION
    
    TRY
        * Operación 1
        INSERT INTO Ventas VALUES (...)
        
        * Operación 2  
        UPDATE Clientes SET ...
        
        * Operación 3
        INSERT INTO Movimientos VALUES (...)
        
        END TRANSACTION
        llExito = .T.
        
    CATCH TO loError
        ROLLBACK
        THIS.LogError("GuardarVenta", loError)
    ENDTRY
    
    RETURN llExito
ENDPROC
```

**Cierre seguro de recursos**:
```foxpro
PROCEDURE ProcesarArchivo(tcRuta)
    LOCAL lnHandle
    lnHandle = 0
    
    TRY
        lnHandle = FOPEN(tcRuta)
        * ... procesar ...
        
    FINALLY
        IF lnHandle > 0
            FCLOSE(lnHandle)
        ENDIF
    ENDTRY
ENDPROC
```

### 4. Optimización de rendimiento

**Reglas de oro**:
1. **Índices**: Crear índices para campos de búsqueda frecuente
2. **SET DELETED ON**: Filtrar registros eliminados
3. **SET OPTIMIZE ON**: Optimización automática de queries
4. **Buffering**: Usar buffering apropiado (1=None, 3=Optimistic, 5=Pessimistic)
5. **Cerrar tablas**: Liberar recursos innecesarios

**Ejemplo de optimización**:
```foxpro
* Configuración óptima
SET DELETED ON
SET OPTIMIZE ON
SET EXACT ON
SET TALK OFF
SET SAFETY OFF

* Buffering para actualizaciones masivas
=CURSORSETPROP("Buffering", 5, "MiTabla")

* Índices compuestos para búsquedas combinadas
INDEX ON STR(IdCliente) + DTOS(Fecha) TAG BusquedaRapida

* Batch updates
LOCAL ARRAY laActualizaciones[10, 2]
* ... llenar array ...

SELECT MiTabla
SCAN
    * Actualizar usando array (más rápido que queries individuales)
    REPLACE Campo1 WITH laActualizaciones[RECNO(), 1]
ENDSCAN

=TABLEUPDATE(.T., .F., "MiTabla")
```

### 5. Testing y calidad

**Estructura de tests**:
```foxpro
DEFINE CLASS Test_MiClase AS TestCase

    oSUT = NULL  && System Under Test
    
    PROCEDURE Setup()
        * Ejecutado antes de cada test
        THIS.oSUT = CREATEOBJECT("MiClase")
    ENDPROC
    
    PROCEDURE TearDown()
        * Ejecutado después de cada test
        THIS.oSUT = NULL
    ENDPROC
    
    PROCEDURE Test_MetodoDebeFuncionar()
        * Arrange
        LOCAL lcInput, lcEsperado
        lcInput = "TestValue"
        lcEsperado = "TESTVALUE"
        
        * Act
        LOCAL lcResultado
        lcResultado = THIS.oSUT.ConvertirAMayusculas(lcInput)
        
        * Assert
        THIS.AssertEquals(lcEsperado, lcResultado, ;
            "Debe convertir a mayúsculas")
    ENDPROC
    
    PROCEDURE Test_DebeGenerarErrorConNull()
        LOCAL llErrorCapturado
        llErrorCapturado = .F.
        
        TRY
            THIS.oSUT.ConvertirAMayusculas(NULL)
        CATCH
            llErrorCapturado = .T.
        ENDTRY
        
        THIS.AssertTrue(llErrorCapturado, ;
            "Debe generar error con NULL")
    ENDPROC
    
ENDDEFINE
```

---

## 🚀 Patrones modernos en VFP

### Pattern: Repository

```foxpro
*==============================================================================
* Interfaz de Repository (por convención)
*==============================================================================
DEFINE CLASS IRepositorio AS Custom
    PROCEDURE Obtener(tnId)
        ERROR "Método abstracto - debe implementarse"
    ENDPROC
    
    PROCEDURE Guardar(toEntidad)
        ERROR "Método abstracto - debe implementarse"
    ENDPROC
    
    PROCEDURE Eliminar(tnId)
        ERROR "Método abstracto - debe implementarse"
    ENDPROC
ENDDEFINE

*==============================================================================
* Implementación concreta
*==============================================================================
DEFINE CLASS RepositorioClientes AS IRepositorio
    
    PROCEDURE Obtener(tnId)
        LOCAL loCliente
        
        SELECT * FROM Clientes ;
            WHERE id = tnId ;
            INTO CURSOR csrCliente
        
        IF RECCOUNT("csrCliente") = 0
            RETURN NULL
        ENDIF
        
        loCliente = THIS.MapearAObjeto("csrCliente")
        USE IN csrCliente
        
        RETURN loCliente
    ENDPROC
    
    PROCEDURE Guardar(toCliente)
        LOCAL llExito
        
        IF toCliente.EsNuevo()
            llExito = THIS.Insertar(toCliente)
        ELSE
            llExito = THIS.Actualizar(toCliente)
        ENDIF
        
        RETURN llExito
    ENDPROC
    
    PROTECTED PROCEDURE MapearAObjeto(tcAlias)
        LOCAL loCliente
        loCliente = CREATEOBJECT("Cliente")
        
        loCliente.Id = &tcAlias..id
        loCliente.Nombre = &tcAlias..nombre
        loCliente.Email = &tcAlias..email
        
        RETURN loCliente
    ENDPROC
    
ENDDEFINE
```

### Pattern: Service Layer

```foxpro
DEFINE CLASS KontrolerEdicion AS Custom
    
    oManejadorErrores = NULL
    oEntidad = NULL
    
    PROCEDURE Init(toEntidad)
        THIS.oEntidad = toEntidad
    ENDPROC
    
    PROCEDURE Grabar()
        LOCAL llExito, loError, llErrorTimeStamp
        
        llExito = .F.
        
        TRY
            * Validar datos
            IF !THIS.ValidarDatos()
                RETURN .F.
            ENDIF
            
            * Guardar en transacción
            BEGIN TRANSACTION
                THIS.oEntidad.Grabar()
                THIS.ActualizarRelacionados()
            END TRANSACTION
            
            llExito = .T.
            
        CATCH TO loError
            IF TXNLEVEL() > 0
                ROLLBACK
            ENDIF
            
            * Verificar si es error de timestamp (concurrencia)
            llErrorTimeStamp = (THIS.oManejadorErrores.HuboErrorUP(goServicios.Errores.ObtenerCodigoErrorParaValidacionTimestamp()) > 0)
            
            IF llErrorTimeStamp
                * Manejo específico de conflicto de concurrencia
                THIS.ManejarErrorConcurrencia()
            ELSE
                * Re-lanzar la excepción para que la maneje el nivel superior
                goServicios.Errores.LevantarExcepcion(loError)
            ENDIF
        ENDTRY
        
        RETURN llExito
    ENDPROC
    
ENDDEFINE
```

---

## 🔧 Herramientas y debugging

### Sistema de Logging y Manejo de Errores

El proyecto usa `goServicios.Errores` como servicio global para manejo centralizado:

```foxpro
* MANEJO DE EXCEPCIONES - Sistema Organic

* 1. Levantar excepción con mensaje
goServicios.Errores.LevantarExcepcion("Mensaje de error")

* 2. Levantar excepción con objeto error
CATCH TO loError
    goServicios.Errores.LevantarExcepcion(loError)
ENDTRY

* 3. Levantar excepción con mensaje y código personalizado
goServicios.Errores.LevantarExcepcionTexto("El dato buscado no existe.", 9001)

* 4. Verificar errores específicos (ej: conflicto timestamp)
llErrorTimeStamp = (THIS.oManejadorErrores.HuboErrorUP(;
    goServicios.Errores.ObtenerCodigoErrorParaValidacionTimestamp()) > 0)

* 5. Logging a base de datos SQL Server (código generado)
INSERT INTO ZooLogic.Logueos (Fecha, Nivel, Logger, Accion, BaseDeDatos, ;
    Usuario, Mensaje, ErrorNumero, ErrorMensaje) ;
VALUES (DATETIME(), 'ERROR', 'NombreClase', 'NombreMetodo', ;
    'NombreDB', gcUsuario, 'Descripción', loError.ErrorNo, loError.Message)

* 6. Logging a archivo (para debugging en capas de acceso a datos)
STRTOFILE(TRANSFORM(DATE()) + ' ' + TIME() + ' Grabacion No exitosa. Intento ' + ;
    TRANSFORM(lni) + '. Clase ' + THIS.Class + CHR(13) + CHR(10), ;
    ADDBS(THIS.oConexion.oAccesoDatos.cRutaTablas) + THIS.cArchivoLogPrueba, 1)

* 7. Advertencias al usuario (no son errores críticos)
THIS.oMensaje.Advertir('Se ha producido una excepción no controlada durante ' + ;
    'el proceso posterior a la grabación. Verifique el log de errores para mas detalles.')
```

**Características del Sistema:**
- `goServicios.Errores`: Servicio global accesible en todo el sistema
- Soporte para excepciones VFP nativas (objetos `ERROR`)
- Códigos de error personalizados para casos especiales
- Logging dual: base de datos SQL Server + archivos de texto
- Diferenciación entre errores críticos y advertencias
- Manejo especial para errores de concurrencia (timestamp)

### Profiling de rendimiento

```foxpro
DEFINE CLASS Profiler AS Custom
    
    dFechaInicio = NULL
    cOperacion = ""
    
    PROCEDURE Iniciar(tcOperacion)
        THIS.cOperacion = tcOperacion
        THIS.dFechaInicio = DATETIME()
    ENDPROC
    
    PROCEDURE Detener()
        LOCAL lnSegundos, lcMensaje
        lnSegundos = DATETIME() - THIS.dFechaInicio
        
        lcMensaje = "Operación: " + THIS.cOperacion + ;
                   " | Tiempo: " + TRANSFORM(lnSegundos, "999.999") + "s"
        
        ? lcMensaje
        
        RETURN lnSegundos
    ENDPROC
    
ENDDEFINE

* Uso
LOCAL loProfiler
loProfiler = CREATEOBJECT("Profiler")

loProfiler.Iniciar("Procesamiento masivo")
* ... operación costosa ...
loProfiler.Detener()
```

---

## 📋 Checklist de código de calidad

Antes de commitear código, verificar:

- [ ] Nomenclatura consistente (convenciones húngaras)
- [ ] Funciones <50 líneas
- [ ] TRY...CATCH en operaciones críticas
- [ ] Liberación de objetos (`loObj = NULL`)
- [ ] Cierre de tablas y cursores
- [ ] Sin magic numbers (usar constantes)
- [ ] Comentarios descriptivos (qué y por qué, no cómo)
- [ ] Tests unitarios para lógica compleja
- [ ] SQL preferido sobre SCAN
- [ ] Transacciones para operaciones múltiples
- [ ] Logging de errores
- [ ] Sin código comentado (usar Git)

---

## Uso del prompt

```
@workspace Actúa como experto VFP y revisa este código según mejores prácticas

@workspace #file:ventas.prg Como experto VFP, refactoriza esta función aplicando patrones modernos

@workspace Necesito implementar un Repository para la entidad Cliente siguiendo patrones VFP profesionales
```

---

## Relacionado

- Prompt: `refactor-patterns.prompt.md`
- Prompt: `code-audit-comprehensive.prompt.md`
- Agente: `/Organic.BusinessLogic/AGENTS.md`
