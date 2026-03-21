# Caso de Uso 1: Validación de Tope de Cuenta Corriente en Facturación

## Descripción del Requerimiento

Agregar una validación al proceso de grabación de facturas para que no permita grabar una factura si tiene un código de cliente y este no tiene definido un tope de cuenta corriente.

## Análisis Técnico

### Investigación Inicial

1. **Archivo Principal**: `/home/jrossano/repo/Legacy/Felino/Ventas/ent_Factura.prg`
   - Clase: `Ent_Factura` que hereda de `Din_EntidadFactura`
   - Método existente: `AntesDeGrabar()` que ya contenía validaciones previas

2. **Estructura de Validación Existente**:
   - Ya existía una validación `ValidarLetraSegunSituacionFiscal()` 
   - Patrón establecido para agregar nuevas validaciones en `AntesDeGrabar()`

3. **Entidad Cliente**:
   - Archivo: `/home/jrossano/repo/Legacy/Felino/Generados/Din_EntidadCliente.prg`
   - Propiedad relevante: `Credito = 0` (tope de cuenta corriente)
   - Propiedad de identificación: `Codigo = []`

4. **Sistema de Control de Límite de Crédito**:
   - Encontrada referencia en `ent_ComprobanteDeVentas.prg`
   - Propiedad: `nTopeDelCliente = 0`
   - Función: `ObtenerTopeDelCliente()` (implementación vacía, se bindea desde kontroler)

## Implementación

### Cambios Realizados

#### 1. Modificación del Método `AntesDeGrabar()`

**Ubicación**: `/home/jrossano/repo/Legacy/Felino/Ventas/ent_Factura.prg` - Líneas 23-32

**Cambio**:
```prg
Function AntesDeGrabar() As Boolean
    local llRetorno as Boolean
    llRetorno = dodefault()
    if llRetorno
        llRetorno = this.ValidarLetraSegunSituacionFiscal()
    endif
    if llRetorno
        llRetorno = this.ValidarTopeDeCredito()  // NUEVO
    endif
    return llRetorno
endfunc
```

#### 2. Nueva Función de Validación

**Ubicación**: `/home/jrossano/repo/Legacy/Felino/Ventas/ent_Factura.prg` - Líneas 55-67

**Implementación**:
```prg
protected function ValidarTopeDeCredito() as Boolean
    local llRetorno as Boolean
    llRetorno = .T.
    
    if vartype( this.Cliente ) = "O" and !isnull( this.Cliente ) and !empty( this.Cliente.Codigo )
        if this.Cliente.Credito <= 0
            llRetorno = .F.
            goMensajes.Advertir( "El cliente " + alltrim( this.Cliente.Codigo ) + " no tiene definido un tope de cuenta corriente." )
        endif
    endif
    
    return llRetorno
endfunc
```

## Lógica de Validación

### Condiciones Verificadas

1. **Existencia del Cliente**: 
   - `vartype( this.Cliente ) = "O"` - Verifica que Cliente sea un objeto
   - `!isnull( this.Cliente )` - Verifica que no sea nulo

2. **Cliente con Código**: 
   - `!empty( this.Cliente.Codigo )` - Solo valida si el cliente tiene código definido

3. **Tope de Cuenta Corriente**: 
   - `this.Cliente.Credito <= 0` - Verifica que el tope sea mayor a cero

### Comportamiento

- **Si no hay cliente**: La validación pasa (no aplica)
- **Si hay cliente sin código**: La validación pasa (no aplica)
- **Si hay cliente con código pero sin tope**: La validación falla, impide el grabado
- **Si hay cliente con código y con tope > 0**: La validación pasa

## Integración con el Sistema

### Patrón de Diseño Utilizado

- **Template Method**: Uso del método `AntesDeGrabar()` que es llamado automáticamente antes del grabado
- **Chain of Responsibility**: Las validaciones se ejecutan en secuencia, si una falla, se detiene el proceso
- **Factory Pattern**: Uso de `goMensajes.Advertir()` para mostrar mensajes al usuario

### Compatibilidad

- **Herencia**: La función respeta la herencia existente llamando a `dodefault()`
- **Patrón Existente**: Sigue el mismo patrón que `ValidarLetraSegunSituacionFiscal()`
- **Mensajería**: Utiliza el sistema de mensajes global existente (`goMensajes`)

## Pruebas Sugeridas

### Casos de Prueba

1. **Factura sin cliente**: Debería grabar normalmente
2. **Factura con cliente sin código**: Debería grabar normalmente  
3. **Factura con cliente con código pero Credito = 0**: No debería grabar, mostrar mensaje
4. **Factura con cliente con código pero Credito < 0**: No debería grabar, mostrar mensaje
5. **Factura con cliente con código y Credito > 0**: Debería grabar normalmente

### Mensaje de Error

```
"El cliente [CODIGO_CLIENTE] no tiene definido un tope de cuenta corriente."
```

## Consideraciones Técnicas

### Ventajas de la Implementación

- **Mínimo Impacto**: Solo afecta el archivo de factura específico
- **Reutilizable**: El patrón puede aplicarse a otros comprobantes
- **Mantenible**: Función separada y bien documentada
- **Consistente**: Sigue las convenciones del código existente

### Posibles Extensiones Futuras

- Aplicar la misma validación a otros tipos de comprobantes
- Parametrizar el comportamiento (advertir vs. bloquear)
- Agregar validaciones adicionales relacionadas con cuenta corriente
- Integrar con el sistema de límites de crédito existente

## Archivos Modificados

- `/home/jrossano/repo/Legacy/Felino/Ventas/ent_Factura.prg`

## Archivos Analizados (Sin Modificar)

- `/home/jrossano/repo/Legacy/Felino/Generados/Din_EntidadCliente.prg`
- `/home/jrossano/repo/Legacy/Felino/Ventas/ent_ComprobanteDeVentas.prg`
- Varios archivos generados relacionados con clientes y créditos
