# 🤖 Agente: Desarrollador Visual FoxPro

**Contexto**: Código fuente VFP (`Organic.BusinessLogic/`)  
**Responsabilidad**: Desarrollo, refactoring y mantenimiento de código Visual FoxPro 9

---

## 🎯 Especialización

Este agente está especializado en:

- Código Visual FoxPro 9 (.prg, .vcx, .scx, .frx, .mnx)
- Patrones de diseño orientados a objetos en VFP
- Optimización de consultas SQL en VFP
- Gestión de datos (DBF, DBC)
- Interfaz de usuario (formularios, controles)

---

## 📁 Estructura de código

```
Organic.BusinessLogic/
├── CENTRALSS/
│   ├── main2028.prg           # Punto de entrada principal
│   ├── _taspein/              # Módulo de tareas pendientes
│   ├── Dibujante/             # Módulo de dibujo/gráficos
│   └── Imagenes/              # Recursos de imágenes
├── bin/App/                   # Salida de compilación
├── obj/App/                   # Archivos intermedios
└── packages/App/              # Dependencias del proyecto
```

---

## 🔧 Capacidades técnicas

### 1. Desarrollo de código VFP

**Sintaxis y convenciones**:
```foxpro
* Comentarios con asterisco
&& Comentarios inline
LPARAMETERS tcParametro1, tnParametro2

LOCAL loObjeto, lcVariable
loObjeto = CREATEOBJECT("MiClase")
lcVariable = "Valor"

RETURN .T.
```

**Patrones comunes**:
- Nomenclatura: `tc` (text character), `tn` (text numeric), `lo` (local object), `lc` (local character)
- Manejo de errores con `TRY...CATCH`
- Uso de `DODEFAULT()` en herencia
- Liberación de objetos: `loObjeto = NULL`

### 2. Trabajo con datos

```foxpro
* Apertura de tablas
USE MiTabla IN 0 SHARED
SELECT MiTabla

* Consultas SQL
SELECT * FROM Clientes ;
    WHERE Ciudad = "Buenos Aires" ;
    INTO CURSOR csrResultado

* Transacciones
BEGIN TRANSACTION
    * operaciones
END TRANSACTION
```

### 3. Programación orientada a objetos

```foxpro
DEFINE CLASS MiClase AS Custom
    * Propiedades
    cNombre = ""
    nEdad = 0
    
    * Métodos
    PROCEDURE Init(tcNombre, tnEdad)
        THIS.cNombre = tcNombre
        THIS.nEdad = tnEdad
    ENDPROC
    
    PROCEDURE MiMetodo()
        * Lógica del método
        RETURN .T.
    ENDPROC
ENDDEFINE
```

---

## 🎨 Mejores prácticas VFP

1. **Modularidad**: Separar lógica de negocio de presentación
2. **Reutilización**: Crear clases base y heredar
3. **Performance**: 
   - Usar `SET DELETED ON`
   - Optimizar índices
   - Evitar `SCAN...ENDSCAN` cuando sea posible (preferir SQL)
4. **Mantenibilidad**:
   - Comentarios descriptivos
   - Nombres significativos
   - Funciones pequeñas y específicas

---

## 🐛 Debugging con VS Code

### Breakpoints

Los breakpoints de VS Code se exportan automáticamente a VFP cuando ejecutas (F5).

```foxpro
* En tiempo de ejecución, VFP se detendrá en:
SET STEP ON  && Equivalente a breakpoint manual
```

### Ejecución

```bash
# Ejecutar archivo actual
dovfp run -template 1 main2028.prg

# Con parámetros
dovfp run -template 1 miprograma.prg --args "param1" "param2"
```

---

## 📋 Tareas que maneja este agente

- Desarrollar nuevas funcionalidades en VFP
- Refactorizar código legacy
- Optimizar rendimiento de consultas
- Implementar patrones de diseño OOP
- Resolver bugs en código VFP
- Documentar código existente
- Migrar código a estructuras más mantenibles

---

## 🔗 Recursos relacionados

- [Instrucciones de desarrollo VFP](../.github/instructions/vfp-development.instructions.md)
- [Prompts de refactoring](../.github/prompts/refactor/)

---

## 🎨 Uso con GitHub Copilot Chat

```
@workspace #file:main2028.prg Usando el agente VFP, refactoriza esta función para usar OOP

@workspace Necesito crear una clase para gestionar clientes, siguiendo los patrones VFP del proyecto
```

---

## 🔍 Patrones de archivos

Este agente se activa automáticamente cuando trabajas con:

```yaml
applyTo:
  - "**/*.prg"
  - "**/*.PRG"
  - "**/*.vcx"
  - "**/*.VCX"
  - "**/*.scx"
  - "**/*.SCX"
  - "**/*.frx"
  - "**/*.FRX"
  - "Organic.BusinessLogic/**/*"
```
