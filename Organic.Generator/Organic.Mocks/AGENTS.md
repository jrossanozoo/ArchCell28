# Agente: Organic.Mocks (Drawing)

**Contexto**: Proyecto de mocks generados para tests  
**Responsabilidad**: Compilación PRG de clases mock para testing

## Descripción

Este proyecto contiene las clases Mock_* generadas automáticamente para los tests unitarios de Organic.Generator.

## Estructura

```
Organic.Mocks/
├── Generados/          # Archivos Mock_*.prg
└── Organic.Drawing.Mocks.vfpproj
```

## Importante

- **NO EDITAR MANUALMENTE** los archivos en Generados/
- Los mocks son generados y copiados desde Organic.Tests/Mocks/
- Este proyecto existe para optimizar tiempos de compilación COM

## Dependencias

- Es dependencia de: Organic.Tests
