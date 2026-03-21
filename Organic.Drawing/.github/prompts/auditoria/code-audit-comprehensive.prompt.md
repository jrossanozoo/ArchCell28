---
description: Auditoría comprehensiva de código Visual FoxPro 9 con análisis de calidad, mantenibilidad y mejores prácticas
argument-hint: "Especifica el archivo o clase a auditar (ej: CENTRALSS/ServicioVentas.prg)"
---

# 🔍 Auditoría Comprehensiva de Código VFP

## Objetivo

Realizar una auditoría exhaustiva de código Visual FoxPro 9, identificando:
- Problemas de calidad de código
- Violaciones de mejores prácticas
- Oportunidades de refactoring
- Deuda técnica
- Riesgos de mantenibilidad

---

## Áreas de análisis

### 1. 🏗️ Arquitectura y diseño

**Analizar**:
- [ ] Separación de responsabilidades (SRP)
- [ ] Acoplamiento entre módulos
- [ ] Cohesión de clases y funciones
- [ ] Uso apropiado de OOP vs. procedural
- [ ] Jerarquías de herencia
- [ ] Dependencias circulares

**Reportar**:
```markdown
### Arquitectura
- **Nivel de modularidad**: [Alto/Medio/Bajo]
- **Acoplamiento**: [Bajo/Medio/Alto]
- **Problemas identificados**:
  1. [Descripción del problema]
  2. [Impacto y recomendación]
```

---

### 2. 📝 Calidad de código

**Analizar**:
- [ ] Nomenclatura consistente (convenciones húngaras: tc, tn, lo, lc)
- [ ] Longitud de funciones y procedimientos (máx. 50 líneas)
- [ ] Complejidad ciclomática
- [ ] Duplicación de código
- [ ] Código muerto o comentado
- [ ] Magic numbers y strings hardcodeados

**Reportar**:
```markdown
### Calidad de código
- **Funciones largas** (>50 líneas): [cantidad]
  - `NombreFuncion` (línea X): [líneas] líneas
- **Código duplicado**: [porcentaje estimado]
  - Bloque en líneas X-Y similar a líneas Z-W
- **Magic numbers encontrados**: [cantidad]
  - Línea X: `IF lnValor = 42` (sin constante)
```

---

### 3. 🛡️ Manejo de errores

**Analizar**:
- [ ] Uso de `TRY...CATCH`
- [ ] Manejo de errores específicos vs. genéricos
- [ ] Liberación de recursos en caso de error
- [ ] Logging de errores
- [ ] Propagación apropiada de excepciones

**Reportar**:
```markdown
### Manejo de errores
- **Bloques sin TRY...CATCH**: [cantidad]
  - `NombreFuncion` (línea X): Operación crítica sin manejo
- **CATCH genéricos**: [cantidad]
- **Recomendaciones**:
  1. Agregar manejo en [ubicación]
  2. Especificar errores en [ubicación]
```

---

### 4. 🗄️ Acceso a datos

**Analizar**:
- [ ] Uso de SQL vs. SCAN...ENDSCAN
- [ ] Cierre apropiado de cursores y tablas
- [ ] Transacciones para operaciones críticas
- [ ] Índices utilizados correctamente
- [ ] Riesgo de SQL injection (aunque menos común en VFP)
- [ ] Performance de queries

**Reportar**:
```markdown
### Acceso a datos
- **SCAN sin justificación**: [cantidad]
  - Línea X: Puede optimizarse con SQL
- **Tablas sin cerrar**: [ubicaciones]
- **Falta de transacciones**: [operaciones críticas]
- **Queries N+1**: [identificados]
```

---

### 5. 🧠 Memoria y recursos

**Analizar**:
- [ ] Liberación de objetos (`loObj = NULL`)
- [ ] Cierre de archivos y cursores
- [ ] Uso de `RELEASE` apropiadamente
- [ ] Variables globales vs. locales
- [ ] Fugas de memoria potenciales

**Reportar**:
```markdown
### Gestión de memoria
- **Objetos sin liberar**: [cantidad]
  - `NombreFuncion` (línea X): loObjeto creado pero no liberado
- **Variables globales**: [cantidad y ubicaciones]
- **Cursores sin cerrar**: [cantidad]
```

---

### 6. 🎨 Mantenibilidad

**Analizar**:
- [ ] Comentarios descriptivos
- [ ] Nombres significativos
- [ ] Documentación de funciones/clases
- [ ] Estructura de carpetas lógica
- [ ] Separación de configuración y lógica
- [ ] Uso de constantes vs. valores hardcodeados

**Reportar**:
```markdown
### Mantenibilidad
- **Funciones sin documentar**: [cantidad]
- **Nombres ambiguos**: [ejemplos]
- **Comentarios obsoletos**: [identificados]
- **Índice de mantenibilidad**: [estimación 1-10]
```

---

### 7. ⚡ Performance

**Analizar**:
- [ ] Queries ineficientes
- [ ] Operaciones repetidas en loops
- [ ] Uso excesivo de funciones lentas (SCAN, LOCATE)
- [ ] Creación de objetos en loops
- [ ] Falta de índices en búsquedas

**Reportar**:
```markdown
### Performance
- **Hotspots identificados**: [cantidad]
  - Línea X: Loop con creación de objetos
  - Línea Y: SCAN sobre tabla grande
- **Optimizaciones sugeridas**: [lista priorizada]
```

---

### 8. 🔒 Seguridad

**Analizar**:
- [ ] Validación de inputs
- [ ] Sanitización de datos
- [ ] Credenciales hardcodeadas
- [ ] Permisos de archivos
- [ ] Exposición de información sensible

**Reportar**:
```markdown
### Seguridad
- **Inputs sin validar**: [cantidad y ubicaciones]
- **Credenciales encontradas**: [ubicaciones - ⚠️ CRÍTICO]
- **Recomendaciones de seguridad**: [lista]
```

---

## Formato de reporte final

```markdown
# 📊 Reporte de Auditoría de Código

**Proyecto**: Organic.Drawing
**Fecha**: [fecha]
**Archivos analizados**: [cantidad]
**Líneas de código**: [total]

## 🎯 Resumen ejecutivo

**Puntuación general**: [X/10]

**Hallazgos críticos**: [cantidad]
**Hallazgos importantes**: [cantidad]
**Sugerencias**: [cantidad]

## 🚨 Problemas críticos (resolver inmediatamente)

1. **[Título del problema]**
   - **Ubicación**: archivo.prg, línea X
   - **Impacto**: [descripción]
   - **Solución recomendada**: [descripción]

## ⚠️ Problemas importantes (resolver pronto)

[Lista similar a críticos]

## 💡 Sugerencias de mejora

[Lista de optimizaciones y mejoras]

## 📈 Métricas

| Métrica | Valor | Estado |
|---------|-------|--------|
| Complejidad promedio | X | ✅/⚠️/❌ |
| Funciones largas | X | ✅/⚠️/❌ |
| Cobertura de errores | X% | ✅/⚠️/❌ |
| Duplicación de código | X% | ✅/⚠️/❌ |

## 🎯 Plan de acción recomendado

1. **Fase 1 (Urgente)**:
   - [ ] Resolver problema crítico 1
   - [ ] Resolver problema crítico 2

2. **Fase 2 (1-2 semanas)**:
   - [ ] Refactorizar módulo X
   - [ ] Optimizar queries lentas

3. **Fase 3 (1 mes)**:
   - [ ] Mejorar documentación
   - [ ] Reducir duplicación
```

---

## Uso del prompt

### Con GitHub Copilot Chat

```
@workspace /file:main2028.prg Ejecuta una auditoría comprehensiva usando el prompt code-audit-comprehensive

@workspace Aplica la auditoría de código a todos los .prg en Organic.BusinessLogic/CENTRALSS/
```

### Alcance

- **Archivo individual**: Auditoría profunda de un archivo
- **Módulo**: Auditoría de una carpeta completa
- **Proyecto**: Auditoría de todo el proyecto (puede tomar tiempo)

---

## Notas importantes

- Prioriza problemas por impacto y esfuerzo de resolución
- Usa ejemplos concretos con números de línea
- Proporciona código de ejemplo para soluciones
- Contextualiza cada problema dentro de la arquitectura VFP
- Considera el balance entre refactoring y estabilidad

---

## Relacionado

- Prompt: `refactor-patterns.prompt.md` (crear próximamente)
- Agente VFP: `/Organic.BusinessLogic/AGENTS.md`
- Instrucciones de desarrollo: crear en `.github/instructions/`
