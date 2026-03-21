---
description: "Análisis de cobertura de tests y detección de gaps en código Visual FoxPro 9"
mode: "agent"
tools: ["read_file", "grep_search", "semantic_search", "list_code_usages", "file_search"]
---

# 📊 Análisis de Cobertura de Tests

## Objetivo
Analizar la cobertura de tests existente, identificar gaps de cobertura y generar recomendaciones para mejorar la suite de pruebas.

## Instrucciones

### Fase 1: Inventario de Código de Producción
1. Listar todas las clases en `Organic.BusinessLogic/CENTRALSS/`
2. Para cada clase, identificar métodos públicos
3. Crear mapa de código que necesita tests

```
Organic.BusinessLogic/
└── CENTRALSS/
    ├── [Modulo]/
    │   ├── Clase1.prg → [N métodos públicos]
    │   ├── Clase2.prg → [N métodos públicos]
    │   └── ...
```

### Fase 2: Inventario de Tests Existentes
1. Listar todos los archivos de test en `Organic.Tests/`
2. Mapear cada test a su clase de producción
3. Identificar clases sin tests

```
Organic.Tests/
└── Tests/
    ├── UnitTests/
    │   ├── Test_Clase1.prg → Cubre: Clase1
    │   └── ...
    └── IntegrationTests/
        └── ...
```

### Fase 3: Análisis de Cobertura

Para cada clase de producción:

| Clase | Métodos | Con Test | Sin Test | Cobertura |
|-------|---------|----------|----------|-----------|
| [Clase1] | 10 | 7 | 3 | 70% |
| [Clase2] | 5 | 0 | 5 | 0% |

### Fase 4: Identificación de Gaps

#### Clases sin tests (Crítico)
```foxpro
*-- Clases de producción sin ningún test
- Organic.BusinessLogic/CENTRALSS/[Modulo]/[Clase].prg
```

#### Métodos sin cobertura (Alto)
```foxpro
*-- Métodos públicos sin tests
- [Clase].[Metodo1]()
- [Clase].[Metodo2](tcParam)
```

#### Edge cases no cubiertos (Medio)
```foxpro
*-- Tests que faltan casos límite
- Test_[Clase]_[Metodo]: Falta test para NULL
- Test_[Clase]_[Metodo]: Falta test para valor vacío
```

### Fase 5: Priorización

**Criterios de prioridad:**

| Prioridad | Criterio | Acción |
|-----------|----------|--------|
| 🔴 P1 | Código crítico sin tests | Crear tests inmediatamente |
| 🟡 P2 | Código con cobertura <50% | Planificar en sprint actual |
| 🟢 P3 | Edge cases faltantes | Agregar en próximo sprint |

**Código crítico incluye:**
- Cálculos financieros
- Validaciones de negocio
- Transacciones de base de datos
- Integraciones externas

## Formato de Reporte

```markdown
# 📊 Reporte de Cobertura - [Fecha]

## Resumen Ejecutivo

| Métrica | Valor |
|---------|-------|
| Clases de producción | X |
| Clases con tests | Y |
| Cobertura de clases | Z% |
| Métodos totales | A |
| Métodos con tests | B |
| Cobertura de métodos | C% |

## 🔴 Gaps Críticos (P1)

### Clases sin tests
| Clase | Métodos | Criticidad | Razón |
|-------|---------|------------|-------|
| [Clase] | N | Alta | [Razón] |

### Métodos críticos sin cobertura
| Clase | Método | Tipo | Impacto |
|-------|--------|------|---------|
| [Clase] | [Método] | Cálculo | Alto |

## 🟡 Gaps Importantes (P2)

### Clases con cobertura parcial
| Clase | Cobertura | Métodos faltantes |
|-------|-----------|-------------------|
| [Clase] | 50% | [Método1], [Método2] |

## 🟢 Mejoras Sugeridas (P3)

### Edge cases faltantes
| Test existente | Caso faltante |
|----------------|---------------|
| Test_X | NULL input |
| Test_Y | Empty string |

## 📋 Plan de Acción

### Sprint Actual
1. [ ] Crear tests para [Clase crítica 1]
2. [ ] Crear tests para [Clase crítica 2]

### Próximo Sprint
1. [ ] Completar cobertura de [Clase parcial 1]
2. [ ] Agregar edge cases a [Test existente]

## 📈 Tendencia

| Sprint | Cobertura |
|--------|-----------|
| Sprint N-2 | X% |
| Sprint N-1 | Y% |
| Sprint N | Z% |
| Meta | 80% |
```

## Comandos Útiles

```powershell
# Buscar todas las clases de producción
Get-ChildItem "Organic.BusinessLogic\CENTRALSS" -Recurse -Filter "*.prg" | 
    Select-String "DEFINE CLASS" | 
    Select-Object Filename, Line

# Buscar todos los tests
Get-ChildItem "Organic.Tests" -Recurse -Filter "Test_*.prg"

# Contar métodos públicos en una clase
Select-String "PROCEDURE [^_]" -Path "archivo.prg" | Measure-Object
```

## Herramientas Recomendadas
- `file_search`: Para listar archivos de código y tests
- `grep_search`: Para buscar definiciones de clases/métodos
- `read_file`: Para analizar contenido de archivos
- `list_code_usages`: Para ver uso de clases/métodos

## Referencias
- [testing.instructions.md](../../instructions/testing.instructions.md)
- [test-audit.prompt.md](../auditoria/test-audit.prompt.md)
- [code-audit/SKILL.md](../../skills/code-audit/SKILL.md)
