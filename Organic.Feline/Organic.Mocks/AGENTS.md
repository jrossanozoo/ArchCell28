# Organic.Mocks - Agente de Proyecto

## Descripción
Proyecto que contiene las clases Mock generadas automáticamente para testing.
Este proyecto se compila de forma independiente para reducir los tiempos de compilación COM del proyecto de Tests.

## Estructura
- **generados/**: Carpeta con todos los archivos Mock_*.prg generados

## Dependencias
- Depende de: Organic.Generated (para clases base)
- Es dependencia de: Organic.Tests

## Notas Importantes
- **NO EDITAR MANUALMENTE** los archivos en generados/
- Los mocks se generan automáticamente desde el sistema de generación de código
- El objetivo de este proyecto es aislar la compilación COM de los mocks
