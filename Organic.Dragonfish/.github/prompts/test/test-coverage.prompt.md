---
description: "Análisis de cobertura de tests y generación de tests faltantes para código VFP"
tools: ["read_file", "grep_search", "list_code_usages", "semantic_search", "create_file"]
applyTo: ["**/*.prg", "**/Tests/**", "**/Organic.Tests/**"]
argument-hint: "Especifica la clase o módulo a analizar cobertura"
---

# 📊 Análisis de Cobertura de Tests

## Objetivo

Analizar la cobertura de tests de una clase o módulo VFP, identificar métodos sin tests y generar los tests faltantes.

## Proceso

### Fase 1: Inventario de Código

1. Identificar la clase/módulo objetivo
2. Listar todos los métodos públicos
3. Documentar parámetros y tipos de retorno
4. Identificar dependencias

### Fase 2: Análisis de Tests Existentes

1. Buscar tests existentes para la clase
2. Mapear qué métodos están cubiertos
3. Identificar métodos sin tests
4. Evaluar calidad de tests existentes (edge cases)

### Fase 3: Generación de Tests Faltantes

Para cada método sin tests:

1. Diseñar casos happy path
2. Identificar edge cases
3. Crear mocks necesarios
4. Implementar tests con patrón AAA

## Template de Test

```foxpro
DEFINE CLASS Test_[NombreClase] AS TestCase
    
    oSUT = NULL
    
    PROCEDURE Setup()
        THIS.oSUT = CREATEOBJECT("[NombreClase]")
    ENDPROC
    
    PROCEDURE TearDown()
        THIS.oSUT = NULL
    ENDPROC
    
    *-- Happy Path
    PROCEDURE Test_[Metodo]_Debe[Resultado]_CuandoDatosValidos()
        * Arrange
        LOCAL lcInput
        lcInput = "valor válido"
        
        * Act
        LOCAL lResult
        lResult = THIS.oSUT.[Metodo](lcInput)
        
        * Assert
        THIS.AssertTrue(lResult, "Debe procesar datos válidos")
    ENDPROC
    
    *-- Edge Cases
    PROCEDURE Test_[Metodo]_Debe[Resultado]_CuandoInputNull()
        * Arrange
        LOCAL lcInput
        lcInput = NULL
        
        * Act & Assert
        * ...
    ENDPROC
    
ENDDEFINE
```

## Checklist de Edge Cases

- [ ] NULL
- [ ] String vacío
- [ ] Cero
- [ ] Negativo
- [ ] Muy grande
- [ ] Tipo incorrecto
- [ ] Fecha inválida

## Formato de Reporte

```markdown
## Cobertura: [NombreClase]

### Métodos Cubiertos ✅
| Método | Tests | Edge Cases |
|--------|-------|------------|
| Metodo1 | 3 | Sí |

### Métodos Sin Cobertura ❌
| Método | Complejidad | Prioridad |
|--------|-------------|-----------|
| Metodo2 | Alta | 🔴 |

### Tests Generados
- Test_Metodo2_DebeRetornarTrue_CuandoDatosValidos
- Test_Metodo2_DebeGenerarError_CuandoInputNull
```
