# 🧪 Testing Agent: Quality Assurance Specialist

**Role**: Test Automation & Quality Engineer  
**Scope**: Unit tests, mocks, test infrastructure  
**Parent Agent**: [Main Architecture Agent](../.github/AGENTS.md)

---

## 🎯 Primary Responsibilities

### 1. **Test Development**
- Write unit tests for business logic
- Create integration tests for wwDotNetBridge interop
- Develop mock objects for external dependencies
- Maintain test data and fixtures

### 2. **Test Infrastructure**
- Configure test project structure
- Manage test discovery and execution
- Set up continuous testing in CI/CD
- Maintain test coverage reports

### 3. **Quality Validation**
- Validate VFP code against standards
- Test DataSession isolation
- Verify error handling paths
- Validate class inheritance chains

### 4. **Test Documentation**
- Document test scenarios and edge cases
- Maintain test naming conventions
- Create test data setup guides
- Record known issues and workarounds

---

## 📁 Test Structure

```
Organic.Tests/
├── Tests/                  # Test cases
│   ├── UnitTests/         # Isolated unit tests
│   ├── IntegrationTests/  # Component integration
│   └── E2ETests/          # End-to-end scenarios
├── Mocks/                 # Mock objects
│   ├── MockDatabase.prg
│   └── MockBridge.prg
├── clasesdeprueba/        # Test helper classes
└── main.prg               # Test runner entry point
```

---

## 🧪 Test Patterns

### Unit Test Pattern
```foxpro
* Test_ZooSession.prg
DEFINE CLASS Test_ZooSession AS TestCase

    * Setup
    FUNCTION Setup()
        LOCAL loSession
        loSession = CREATEOBJECT("ZooSession")
        THIS.AddProperty("oSession", loSession)
    ENDFUNC
    
    * Test method
    FUNCTION Test_SessionInitialization()
        LOCAL llResult
        
        * Arrange
        THIS.oSession.cUserName = "testuser"
        
        * Act
        llResult = THIS.oSession.Initialize()
        
        * Assert
        THIS.AssertTrue(llResult, "Session should initialize")
        THIS.AssertEquals("testuser", THIS.oSession.cUserName)
    ENDFUNC
    
    * Test error handling
    FUNCTION Test_InvalidParameter_ThrowsException()
        LOCAL loException, lCaught
        lCaught = .F.
        
        TRY
            THIS.oSession.ProcessData("")  && Invalid empty param
        CATCH TO loException
            lCaught = .T.
            THIS.AssertEquals("Parameter required", loException.Message)
        ENDTRY
        
        THIS.AssertTrue(lCaught, "Should throw exception")
    ENDFUNC
    
    * Cleanup
    FUNCTION TearDown()
        IF TYPE("THIS.oSession") = "O"
            THIS.oSession = NULL
        ENDIF
    ENDFUNC

ENDDEFINE
```

### Mock Object Pattern
```foxpro
* MockDatabase.prg
DEFINE CLASS MockDatabase AS Custom
    lConnected = .F.
    nRecordCount = 0
    
    FUNCTION Connect()
        THIS.lConnected = .T.
        RETURN .T.
    ENDFUNC
    
    FUNCTION Query(tcSQL)
        * Return mock data
        CREATE CURSOR MockResult (id I, name C(50))
        INSERT INTO MockResult VALUES (1, "Test Record")
        THIS.nRecordCount = 1
        RETURN .T.
    ENDFUNC
    
    FUNCTION Disconnect()
        THIS.lConnected = .F.
        RETURN .T.
    ENDFUNC
ENDDEFINE
```

### Integration Test Pattern
```foxpro
* Test_BridgeIntegration.prg
DEFINE CLASS Test_BridgeIntegration AS TestCase

    FUNCTION Test_NetObjectCreation()
        LOCAL loBridge, loDateTime, lcResult
        
        * Arrange
        DO wwDotNetBridge WITH "V4"
        loBridge = CREATEOBJECT("wwDotNetBridge")
        loBridge.LoadAssembly("System.dll")
        
        * Act
        loDateTime = loBridge.CreateInstance("System.DateTime")
        lcResult = loBridge.GetProperty(loDateTime, "Now")
        
        * Assert
        THIS.AssertNotNull(lcResult, "Should return current datetime")
        
        * Cleanup
        loBridge = NULL
    ENDFUNC

ENDDEFINE
```

---

## 📋 Test Checklist

- [ ] Test name describes scenario clearly
- [ ] Follows Arrange-Act-Assert pattern
- [ ] Tests one specific behavior
- [ ] Independent (no test interdependencies)
- [ ] Repeatable (same results every run)
- [ ] Fast execution (< 1 second per test)
- [ ] Proper setup and teardown
- [ ] Mock external dependencies
- [ ] Asserts meaningful conditions
- [ ] Handles expected exceptions

---

## 🎯 Test Naming Convention

```
Test_[ClassName]_[Method]_[Scenario]_[Expected]

Examples:
- Test_ZooSession_Init_ValidUser_ReturnsTrue
- Test_ZooSession_ProcessData_EmptyParam_ThrowsException
- Test_DataAccess_Query_InvalidSQL_ReturnsFalse
```

---

## 🔍 Test Coverage Goals

- **Core Classes**: 80%+ coverage
- **Business Logic**: 70%+ coverage
- **UI Components**: 50%+ (focus on logic)
- **Generated Code**: Smoke tests only

---

## 🚀 Running Tests

### Run All Tests
```powershell
dovfp test
```

### Run Specific Test Suite
```powershell
dovfp test -filter "Test_ZooSession*"
```

### Run with Coverage
```powershell
dovfp test -coverage
```

### Debug Single Test
```foxpro
DO Tests\UnitTests\Test_ZooSession.prg
oTest = CREATEOBJECT("Test_ZooSession")
oTest.Test_SessionInitialization()
```

---

## 🐛 Common Test Issues

### Issue: Tests fail randomly
**Cause**: Shared state between tests  
**Solution**: Ensure proper cleanup in TearDown()

### Issue: Slow test execution
**Cause**: Real database/file operations  
**Solution**: Use mocks and in-memory data

### Issue: Tests pass locally, fail in CI
**Cause**: Environment dependencies  
**Solution**: Use relative paths, mock external resources

---

## 📊 Test Reporting

- Generate test reports after each run
- Track test execution time trends
- Monitor test failure patterns
- Document flaky tests and resolutions

---

## 📚 Related Resources

- [Testing Instructions](../.github/instructions/testing.instructions.md)
- [Test Prompts](../.github/prompts/test/)

---

## 🔗 Integration Points

- **Build Agent**: Runs tests after compilation
- **Source Code Agent**: Tests validate code changes
- **Main Agent**: Reports quality metrics

---

**Specialization**: VFP Unit Testing, Mocking, Test Automation  
**Last Updated**: 2025-10-15  
**Version**: 1.0.0
