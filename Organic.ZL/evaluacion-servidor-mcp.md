# Evaluación del Servidor MCP `mcp_zooorganic` — Análisis de `entzl_cajaestado.prg`

**Fecha:** 31 de marzo de 2026  
**Archivo analizado:** `Organic.BusinessLogic/CENTRALSS/Zl/_Base/entzl_cajaestado.prg`  
**Analista:** GitHub Copilot (Claude Sonnet 4.6)

---

## 1. Análisis del código

### Descripción del archivo

El archivo contiene dos clases:

| Clase | Base | Rol |
|---|---|---|
| `entZl_cajaestado` | `ent_cajaestado` | Entidad de negocio: estado de caja con control de licencias |
| `ComponenteLicenciasCajaEstado` | `Custom` | Componente auxiliar que consulta licencias/vacaciones en SQL Server |

### Hallazgos

**Conformidad con estándares:**

| Aspecto | Estado | Detalle |
|---|---|---|
| Notación húngara en variables locales | ✅ Correcto | `lcMensaje`, `lcUsuario`, `lcFecha`, `lcSQL`, `lcCursor`, `llRetorno` |
| Prefijos en parámetros (`tc`, `tn`) | ✅ Correcto | `tcUsuario as String`, `tnDataSession as Integer` |
| Método `protected` explícito | ✅ Correcto | `ObtenerMensajeDeLicenciaDelUsuarioLogueado` y `ObtenerComponenteLicencias` |
| Patrón lazy init para componente | ✅ Correcto | `ObtenerComponenteLicencias` con guardia `vartype <> "O"` |
| Cierre de cursor tras uso | ✅ Correcto | `use in select( lcCursor )` con guard `if used()` |
| SQL via `TEXT/TEXTMERGE` | ✅ Correcto | Patrón alineado con estándares del proyecto |
| Propiedades de clase sin prefijo de tipo | ⚠️ Observación | `SeguridadEntidadAbrirCaja = ""` — en VFP las propiedades de clase a veces omiten prefijo; la convención interna debería uniformarse (p. ej. `cSeguridadEntidadAbrirCaja`) |
| Trailing whitespace en línea 4 | ⚠️ Menor | `SeguridadMetodoAbrirCaja = ""[TAB]` — tab al final de la línea |

**Observación de seguridad:**

```foxpro
text to lcSQL textmerge noshow
    ...
    where L.CCod = '<<alltrim( tcUsuario )>>' and
    ...
endtext
```

El valor `tcUsuario` proviene de `goServicios.Seguridad.cUsuarioLogueado` y se interpola directamente en el SQL via TEXTMERGE. Si el nombre de usuario contiene caracteres como `'`, podría producirse una inyección SQL. Se recomienda sanitizar o parametrizar el valor antes de la interpolación, aunque la fuente es interna (controlada por el servidor de seguridad).

---

## 2. Uso del servidor MCP `mcp_zooorganic`

### ¿Se usó el servidor MCP?

**Sí.** Se invocaron 9 llamadas a herramientas del servidor MCP durante el análisis.

### Detalle de cada llamada

| Herramienta | Parámetros usados | Resultado | Útil |
|---|---|---|---|
| `detect-business-line` | `projectPath` | ❌ Error: "Project path does not exist" | No |
| `get-best-practices` | `businessLine: "organic"` | ⚠️ Devolvió `bestPractices: []` (vacío) | No |
| `validate-foxpro-standards` | `businessLine: "ZL"` | ❌ Error: valor no permitido en enum | No |
| `validate-code-standards` | `businessLine: "ZL"` | ❌ Error: valor no permitido en enum | No |
| `get-context-prompt` | `businessLine: "lince"` | ❌ Error: "Project path does not exist" | No |
| `get-knowledge-statistics` | `businessLine: "lince"` | ✅ Devolvió stats: 2 ítems (architecture, best-practices) | Parcialmente |
| `search-knowledge` | `businessLine: "lince"`, query sobre estándares | ✅ Devolvió 3 resultados con contenido de estándares VFP compartidos | Sí |
| `get-specific-prompt` | Faltó `promptType` | ❌ Error: campo requerido faltante | No |
| `get-architectural-patterns` | `businessLine: "lince"` | ✅ Devolvió patrones... pero de TypeScript/AWS Lambda (no VFP) | Marginalmente |

### ¿Fue útil el servidor MCP?

**Parcialmente.** La única herramienta que aportó valor real fue `search-knowledge`, que confirmó la existencia de estándares compartidos para FoxPro (notación húngara, refactoring estructural, guías de testing). Sin embargo, el contenido recuperado ya estaba disponible en las `instructions` del proyecto (`.github/instructions/`), por lo que no generó información nueva para este análisis.

### ¿De qué modo fue útil?

- **`search-knowledge`** permitió cruzar el análisis del código con la base de conocimiento almacenada en el servidor, confirmando que los estándares `shared-foxpro-coding-standards` y `shared-foxpro-structural-refactoring` son los aplicables.
- **`get-knowledge-statistics`** indicó que la base de conocimiento para la línea `lince` tiene exactamente 2 ítems, lo que permitió calibrar el alcance de la información disponible en el servidor.

---

## 3. Qué es necesario mejorar en el servidor MCP

### Problemas críticos (impiden el uso)

| Problema | Herramienta afectada | Descripción |
|---|---|---|
| `businessLine` con valores no documentados | `validate-foxpro-standards`, `validate-code-standards` | El enum de valores permitidos no está expuesto. Se intentó con `"organic"`, `"ZL"`, `"lince"` — solo `"lince"` fue parcialmente aceptado en algunas herramientas. Sin documentación de los valores válidos, el uso es por prueba y error. |
| `detect-business-line` no acepta rutas Windows reales | `detect-business-line`, `get-context-prompt` | Devuelve "Project path does not exist" para `c:\LinceV3\Organic.ZL` aunque el directorio existe. Probablemente hay un problema con separadores de ruta Windows o con el montaje del filesystem en el servidor. |
| `get-specific-prompt` requiere `promptType` no documentado | `get-specific-prompt` | El schema no indica los valores válidos para `promptType`, haciendo imposible invocar la herramienta sin documentación adicional. |

### Problemas de alineación de contenido

| Problema | Descripción |
|---|---|
| Patrones arquitectónicos de `lince` no corresponden al proyecto | `get-architectural-patterns` devuelve patrones serverless en TypeScript/Node.js, cuando el proyecto Organic.ZL es Visual FoxPro 9. La línea de negocio `lince` parece estar mal mapeada al contexto del workspace. |
| `get-best-practices` vacío para `organic` | La línea de negocio `organic` no tiene best practices registradas, perdiendo la oportunidad de enriquecer el análisis de código VFP. |
| Base de conocimiento escasa | Solo 2 ítems para `lince` (1 architecture, 1 best-practices). Para ser útil en análisis de código, la knowledge base debería incluir al menos: patrones de entidad, acceso a datos, seguridad VFP, y convenciones del proyecto. |

### Mejoras sugeridas

1. **Documentar el schema de `businessLine`**: Exponer los valores permitidos en la descripción de cada herramienta o en un endpoint de discovery.
2. **Soporte de rutas Windows absolutas**: Normalizar separadores de ruta (`\` → `/`) antes de resolver el path.
3. **Poblar la knowledge base con contenido VFP real**: Migrar o referenciar el contenido de `.github/instructions/` al servidor MCP para que las validaciones de código sean efectivas.
4. **`validate-foxpro-standards` debería ser la herramienta principal**: Actualmente falla por enum no documentado. Si funcionara correctamente, sería la herramienta de mayor valor para este proyecto.
5. **Mapeo correcto de `businessLine` por workspace**: El workspace `Organic.ZL` debería auto-detectarse o mapearse a la línea correcta (no `lince`, que parece ser otra plataforma).

---

## 4. Conclusión

El análisis del archivo `entzl_cajaestado.prg` se completó **sin dependencia del servidor MCP**, usando lectura directa del código e instrucciones del proyecto. El código cumple bien con los estándares húngaros del proyecto, con observaciones menores sobre las propiedades de clase y una alerta de seguridad en la interpolación SQL.

El servidor MCP `mcp_zooorganic` **está disponible pero no operativo para este workspace** en su estado actual. Los fallos son principalmente por:
- Enum de `businessLine` no documentado
- Rutas Windows no resueltas correctamente
- Knowledge base no poblada con contenido VFP específico del proyecto

El potencial del servidor es alto —centralizar reglas, validar automáticamente contra estándares, recuperar patrones— pero requiere configuración y contenido adicional para ser útil en el contexto de Organic.ZL.
