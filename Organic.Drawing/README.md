# 🎨 Organic.Drawing - Solución Visual FoxPro 9

**Sistema de gestión de dibujo y diseño** desarrollado en Visual FoxPro 9, compilable desde VS Code usando DOVFP.

---

## 📋 Tabla de contenidos

- [Inicio rápido](#-inicio-rápido)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Desarrollo](#-desarrollo)
- [Compilación con DOVFP](#-compilación-con-dovfp)
- [Testing](#-testing)
- [PromptOps y Copilot](#-promptops-y-copilot)
- [CI/CD](#-cicd)
- [Contribuir](#-contribuir)

---

## 🚀 Inicio rápido

### Prerrequisitos

- **Visual Studio Code**
- **Visual FoxPro 9** (para ejecución)
- **.NET 6 SDK** (para DOVFP)
- **DOVFP** (compilador VFP)
- **Extensión Zoo Tool Kit** (opcional pero recomendado)

### Instalación

```powershell
# 1. Clonar repositorio
git clone <url-del-repo>
cd Organic.Drawing

# 2. Instalar DOVFP
dotnet tool install --global dovfp --add-source ./nupkg

# 3. Restaurar dependencias
dovfp restore

# 4. Compilar
dovfp build Organic.Drawing.vfpsln

# 5. Ejecutar
dovfp run -template 1 Organic.BusinessLogic/CENTRALSS/main2028.prg
```

### Abrir en VS Code

```powershell
code Organic.Drawing.code-workspace
```

O simplemente:

```powershell
code .
```

---

## 📁 Estructura del proyecto

```
Organic.Drawing/
├── .github/                    # Configuración GitHub y PromptOps
│   ├── AGENTS.md              # Agente arquitecto principal
│   ├── copilot-instructions.md # Instrucciones para Copilot
│   ├── prompts/               # Prompts especializados
│   │   ├── auditoria/         # Code audit
│   │   ├── dev/               # Desarrollo (VFP expert, DOVFP)
│   │   ├── refactor/          # Refactoring patterns
│   │   └── test/              # Test audit
│   └── instructions/          # Instrucciones contextualizadas
│       ├── vfp-development.instructions.md
│       ├── testing.instructions.md
│       └── dovfp-build.instructions.md
│
├── Organic.BusinessLogic/     # 💼 Lógica de negocio
│   ├── AGENTS.md             # Agente VFP
│   ├── CENTRALSS/            # Código principal
│   │   ├── main2028.prg     # Punto de entrada
│   │   ├── _taspein/        # Módulo tareas
│   │   ├── Dibujante/       # Módulo dibujo
│   │   └── Imagenes/        # Recursos
│   ├── bin/App/             # Salida compilada
│   ├── obj/App/             # Archivos intermedios
│   └── Organic.Drawing.vfpproj
│
├── Organic.Generated/         # 🤖 Código generado
│   ├── AGENTS.md             # Agente de generación
│   ├── Generados/            # ABMs y código auto-generado
│   │   ├── Din_Abm*.prg     # ABMs dinámicos
│   │   └── Combo*.xml       # Definiciones de combos
│   ├── ADN/                  # Estructuras serializadas
│   ├── Update-EstructuraAdnPrg.ps1
│   ├── Update-TransferenciaVersions.ps1
│   └── Validate-VersionsPostBuild.ps1
│
├── Organic.Tests/             # 🧪 Tests
│   ├── AGENTS.md             # Agente de testing
│   ├── main.prg              # Runner de tests
│   ├── ClasesMock.dbf        # Datos mock
│   ├── clasesdeprueba/       # Helpers de testing
│   └── Tests/                # Tests unitarios/funcionales
│
├── build/                     # Artefactos de build
├── azure-pipelines.yml        # CI/CD
├── Nuget.config              # Configuración NuGet
├── Organic.Drawing.vfpsln    # Solución VFP
└── README.md                 # Este archivo
```

---

## 💻 Desarrollo

### Abrir y editar código VFP

1. **Abrir workspace en VS Code**
2. **Navegar a** `Organic.BusinessLogic/CENTRALSS/`
3. **Editar archivos** `.prg`, `.vcx`, `.scx`
4. **Seguir convenciones**: Ver [instrucciones VFP](.github/instructions/vfp-development.instructions.md)

### Convenciones de código

```foxpro
* Nomenclatura húngara
LPARAMETERS tcNombre, tnEdad, tlActivo
LOCAL lcVariable, lnContador, llFlag, loObjeto

* Estructura de clases
DEFINE CLASS MiClase AS ParentClass
    cPropiedad = ""
    nPropiedad = 0
    
    PROCEDURE Init()
        * Inicialización
    ENDPROC
ENDDEFINE
```

**Ver más**: [Agente VFP](Organic.BusinessLogic/AGENTS.md) | [Prompt VFP Expert](.github/prompts/dev/vfp-development-expert.prompt.md)

### Debugging

1. **Abrir archivo** `.prg`
2. **Establecer breakpoints** (clic en margen izquierdo)
3. **Presionar F5** (Run Visual FoxPro)
4. Los breakpoints se exportan automáticamente a VFP

**Ver más**: [Guía de debugging](docs/VFP-DEBUGGING.md)

---

## 🛠️ Compilación con DOVFP

### Comandos básicos

```bash
# Compilar solución completa
dovfp build Organic.Drawing.vfpsln

# Compilar proyecto específico
dovfp build Organic.BusinessLogic/Organic.Drawing.vfpproj

# Build en modo Release
dovfp build Organic.Drawing.vfpsln --configuration Release

# Limpiar
dovfp clean

# Limpiar y reconstruir
dovfp clean ; dovfp build
```

### Desde VS Code

- **Ctrl+Shift+B**: Build Solution (tarea por defecto)
- **F5**: Ejecutar archivo actual con debugging

### Configuración

Ver [`.vfpproj`](Organic.BusinessLogic/Organic.Drawing.vfpproj) y [instrucciones DOVFP](.github/instructions/dovfp-build.instructions.md)

**Ver más**: [Agente Arquitecto](.github/AGENTS.md) | [Prompt DOVFP](.github/prompts/dev/dovfp-build-integration.prompt.md)

---

## 🧪 Testing

### Ejecutar tests

```bash
# Todos los tests
dovfp test Organic.Tests/Organic.Tests.vfpproj

# Con verbosidad
dovfp test Organic.Tests/Organic.Tests.vfpproj --verbose

# Test específico (F5 en el archivo)
dovfp run -template 1 Organic.Tests/Tests/Test_MiModulo.prg
```

### Crear un test

```foxpro
DEFINE CLASS Test_MiModulo AS TestCase
    
    PROCEDURE Test_MetodoDebeFuncionar()
        * Arrange
        LOCAL loObjeto
        loObjeto = CREATEOBJECT("MiClase")
        
        * Act
        LOCAL lcResultado
        lcResultado = loObjeto.MiMetodo()
        
        * Assert
        THIS.AssertEquals("Esperado", lcResultado)
    ENDPROC
    
ENDDEFINE
```

**Ver más**: [Agente Testing](Organic.Tests/AGENTS.md) | [Instrucciones Testing](.github/instructions/testing.instructions.md)

---

## 🤖 PromptOps y Copilot

Esta solución está optimizada para trabajar con **GitHub Copilot Chat** usando:

### Agentes especializados

Los agentes proporcionan contexto especializado según dónde trabajes:

- **[Agente Arquitecto](.github/AGENTS.md)**: Arquitectura, compilación, CI/CD
- **[Agente VFP](Organic.BusinessLogic/AGENTS.md)**: Desarrollo en Visual FoxPro
- **[Agente Testing](Organic.Tests/AGENTS.md)**: Testing y QA
- **[Agente Generación](Organic.Generated/AGENTS.md)**: Código generado

### Prompts especializados

Usar con `@workspace`:

```
@workspace #prompt:code-audit-comprehensive Audita este módulo

@workspace #prompt:refactor-patterns Refactoriza esta función aplicando patrones

@workspace #prompt:vfp-development-expert Revisa este código VFP

@workspace #prompt:test-audit Analiza cobertura de tests
```

**Ubicación**: `.github/prompts/`

### Instrucciones contextualizadas

Copilot las usa automáticamente según el contexto:

- **VFP Development**: Cuando editas `.prg`, `.vcx`, `.scx`
- **Testing**: Cuando trabajas en `Organic.Tests/`
- **DOVFP Build**: Cuando editas `.vfpproj`, `.vfpsln`

**Ubicación**: `.github/instructions/`

### Ejemplos de uso

```
@workspace Actúa como experto VFP y refactoriza esta función

@workspace #file:main2028.prg Audita este archivo buscando problemas

@workspace Crea un test para la clase ClienteRepository

@workspace DOVFP me da error de compilación, ayúdame a diagnosticar
```

**Ver más**: [Guía de PromptOps](.github/README.md) | [Debugging](.github/debugging.md)

---

## 🔄 CI/CD

### Azure Pipelines

La solución incluye pipeline completo en [`azure-pipelines.yml`](azure-pipelines.yml):

1. **Restaurar** dependencias
2. **Compilar** en modo Release
3. **Ejecutar** tests
4. **Publicar** artefactos

### Ejecutar localmente

```powershell
# Simular pipeline localmente
.\scripts\ci-local.ps1
```

---

## 🤝 Contribuir

### Workflow

1. **Crear branch**: `git checkout -b feature/mi-feature`
2. **Desarrollar** siguiendo convenciones
3. **Compilar y testear**: `dovfp build && dovfp test`
4. **Commit**: `git commit -m "feat: descripción"`
5. **Push**: `git push origin feature/mi-feature`
6. **Pull Request** en Azure DevOps/GitHub

### Antes de commitear

- [ ] Código compila sin warnings
- [ ] Tests pasan (`dovfp test`)
- [ ] Seguiste convenciones VFP
- [ ] Agregaste tests si es necesario
- [ ] Actualizaste documentación si aplica

### Mensajes de commit

Seguir [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: nueva funcionalidad
fix: corrección de bug
refactor: refactoring sin cambio de funcionalidad
test: agregar/modificar tests
docs: documentación
chore: tareas de mantenimiento
```

---

## 📚 Recursos adicionales

### Links útiles

- **Visual FoxPro 9**: [Documentación oficial](https://docs.microsoft.com/en-us/previous-versions/visualstudio/foxpro/)
- **DOVFP**: Documentación interna
- **Azure DevOps**: [Portal del proyecto](https://dev.azure.com/zoologicnet/)
- **Debugging**: [Guía de debugging VFP](.github/debugging.md)

---

## 📞 Soporte

- **Issues**: Crear issue en el repositorio
- **Discusiones**: Usar GitHub Discussions o Teams
- **Emergencias**: Contactar al equipo de desarrollo

---

## 📄 Licencia

Propietario - ZooLogic SA © 2025

---

**Hecho con ❤️ usando Visual FoxPro 9, VS Code y GitHub Copilot**