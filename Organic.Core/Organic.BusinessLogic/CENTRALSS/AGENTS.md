# 🧑‍💻 Source Code Agent: VFP Development Specialist

**Role**: Visual FoxPro Code Developer  
**Scope**: Business logic, class design, code quality  
**Parent Agent**: [Main Architecture Agent](../../.github/AGENTS.md)

---

## 🎯 Primary Responsibilities

### 1. **VFP Code Development**
- Write and maintain .prg, .vcx, .scx files
- Implement business logic following ZooLogicSA patterns
- Create and maintain custom classes (Zoo* prefix)
- Handle form and control development

### 2. **Code Quality & Standards**
- Enforce lowercase file references for inheritance
- Declare ALL LOCAL variables in functions/methods
- Use `THIS.` for object member access
- Follow proper `DEFINE CLASS` / `ENDDEFINE` structure
- Maintain consistent indentation and formatting

### 3. **wwDotNetBridge Integration**
- Initialize bridge instances correctly
- Handle DLL path resolution dynamically
- Manage .NET object lifecycle
- Implement proper error handling for interop calls

### 4. **DataSession Management**
- Handle DataSession isolation properly
- Use appropriate DataSession modes (1=default, 2=private)
- Manage cursor/table access across sessions
- Close sessions properly to avoid leaks

### 5. **Class Design**
- Follow SOLID principles
- Implement inheritance hierarchies correctly
- Use composition over inheritance where appropriate
- Document public interfaces with XML comments

---

## 📁 File Structure

```
CENTRALSS/
├── Nucleo/                 # Core framework classes
│   ├── ZooSession.prg
│   ├── ZooException.prg
│   └── ZooBase.prg
├── ControlesVisuales/      # UI controls
├── Dlls/                   # wwDotNetBridge & dependencies
└── _Dibujante/            # Drawing utilities
```

---

## 🔍 Code Review Checklist

- [ ] All LOCAL variables declared
- [ ] File references in lowercase (inheritance)
- [ ] `THIS.` used for member access
- [ ] Proper error handling with TRY/CATCH
- [ ] DataSession management validated
- [ ] No orphaned ENDDEFINE statements
- [ ] Comments explain WHY, not WHAT
- [ ] No hardcoded paths
- [ ] Proper resource cleanup (RELEASE objects)

---

## 🛠️ Common Patterns

### Class Definition
```foxpro
* Filename: myclass.prg (lowercase!)
DEFINE CLASS MyClass AS ZooBase OF nucleo\zoobase.prg
    * Properties
    cVersion = "01.0001.00000"
    lInitialized = .F.
    
    * Constructor
    FUNCTION Init()
        LOCAL llSuccess
        llSuccess = DODEFAULT()
        THIS.lInitialized = .T.
        RETURN llSuccess
    ENDFUNC
    
    * Business method
    FUNCTION ProcessData(tcParameter)
        LOCAL lcResult, loException
        TRY
            IF EMPTY(tcParameter)
                ERROR "Parameter required"
            ENDIF
            lcResult = THIS.InternalProcess(tcParameter)
        CATCH TO loException
            THROW loException
        ENDTRY
        RETURN lcResult
    ENDFUNC
    
    PROTECTED FUNCTION InternalProcess(tcData)
        * Implementation details
        RETURN UPPER(tcData)
    ENDFUNC
ENDDEFINE
```

### wwDotNetBridge Usage
```foxpro
LOCAL loBridge, loNetObject, loException
TRY
    * Initialize bridge
    DO wwDotNetBridge WITH "V4"
    loBridge = CREATEOBJECT("wwDotNetBridge")
    
    * Load assembly
    loBridge.LoadAssembly("System.dll")
    
    * Create .NET object
    loNetObject = loBridge.CreateInstance("System.DateTime")
    
    * Call methods
    ? loBridge.InvokeMethod(loNetObject, "ToString")
    
CATCH TO loException
    * Handle error
    MESSAGEBOX("Bridge error: " + loException.Message)
FINALLY
    * Cleanup
    IF TYPE("loBridge") = "O"
        loBridge = NULL
    ENDIF
ENDTRY
```

### DataSession Management
```foxpro
FUNCTION QueryWithPrivateSession(tcSQL)
    LOCAL lnOldSession, lcResult
    lnOldSession = SET("DataSession")
    
    SET DATASESSION TO 2  && Private session
    TRY
        * Query operations
        lcResult = THIS.ExecuteQuery(tcSQL)
    FINALLY
        * Restore original session
        SET DATASESSION TO (lnOldSession)
    ENDTRY
    
    RETURN lcResult
ENDFUNC
```

---

## 🐛 Common Issues & Solutions

### Issue: "Statement is only valid within a class definition"
**Cause**: Missing `DEFINE CLASS` or orphaned `ENDDEFINE`  
**Solution**: Verify class structure, ensure matched pairs

### Issue: "Variable not found"
**Cause**: Missing LOCAL declaration  
**Solution**: Declare ALL variables at function start

### Issue: "File not found" (inheritance)
**Cause**: Uppercase filename in AS clause  
**Solution**: Use lowercase: `AS Custom OF myform.vcx`

### Issue: wwDotNetBridge DLL conflicts
**Cause**: Multiple versions or wrong path  
**Solution**: Use dynamic path resolution, ensure single version

---

## 📚 Related Resources

- [VFP Development Instructions](../../.github/instructions/vfp-development.instructions.md)
- [Prompts for Development](../../.github/prompts/dev/)

---

## 🔗 Integration Points

- **Build Agent**: Reports compilation errors
- **Test Agent**: Validates functionality
- **Generated Code Agent**: Consumes metadata structures

---

**Specialization**: Visual FoxPro 9.0, OOP, wwDotNetBridge  
**Last Updated**: 2025-10-15  
**Version**: 1.0.0
