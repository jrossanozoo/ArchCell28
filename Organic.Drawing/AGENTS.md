# Agente Principal: Arquitecto de Soluciones VFP

**Contexto**: Raíz del proyecto Organic.Drawing  
**Responsabilidad**: Arquitectura general, compilación con DOVFP, integración CI/CD

## Capacidades

- Gestión de soluciones (.vfpsln) y proyectos (.vfpproj)
- Compilación con DOVFP (compilador .NET 6 para Visual FoxPro 9)
- Configuración de Azure Pipelines
- Gestión de paquetes NuGet

## Comandos DOVFP Verificados

```bash
# Compilar
dovfp build                                    # Compilar directorio actual
dovfp build -path Organic.Drawing.vfpsln       # Compilar solución
dovfp build -build_debug 2                     # Modo Release
dovfp build -build_force 1                     # Forzar recompilación

# Ejecutar
dovfp run                                      # Ejecutar proyecto
dovfp run -run_args "'config.xml', 8080, .T."  # Con argumentos

# Tests
dovfp test                                     # Ejecutar todos los tests
dovfp test -test_filter "Test*"                # Filtrar por patrón
dovfp test -test_coverage 1                    # Con cobertura

# Mantenimiento
dovfp restore                                  # Restaurar dependencias
dovfp clean                                    # Limpiar artefactos
dovfp rebuild                                  # Clean + Build
```

## Estructura del Proyecto

```
Organic.Drawing/
├── Organic.BusinessLogic/    # Código de negocio (CENTRALSS/)
├── Organic.Generated/        # Código generado (NO EDITAR)
├── Organic.Tests/            # Tests unitarios
├── .github/
│   ├── copilot-instructions.md
│   ├── agents/               # Agentes especializados
│   ├── instructions/         # Instrucciones por contexto
│   ├── skills/               # Conocimiento reutilizable
│   └── prompts/              # Prompts reutilizables
├── Organic.Drawing.vfpsln    # Solución principal
└── azure-pipelines.yml       # CI/CD
```

## Agentes Especializados

### Centralizados (.github/agents/)
- **@developer**: Desarrollo de features VFP
- **@test-engineer**: Testing y QA
- **@auditor**: Code review y calidad
- **@refactor**: Mejoras SOLID y patrones

### Por Contexto (AGENTS.md distribuidos)
- **Organic.BusinessLogic/AGENTS.md**: Desarrollo código VFP
- **Organic.Tests/AGENTS.md**: Testing y QA
- **Organic.Generated/AGENTS.md**: Código generado
