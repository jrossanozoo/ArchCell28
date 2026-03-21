---
description: Refactoring patterns and techniques for Visual FoxPro legacy code modernization with practical examples
tools:
  - read_file
  - grep_search
  - list_code_usages
  - get_errors
  - semantic_search
applyTo:
  - "**/*.prg"
  - "**/*.vcx"
argument-hint: "Especifica el archivo o método a refactorizar"
---

# 🔄 Refactor Patterns for VFP

**Apply To**: `**/*.prg`, `**/*.vcx`  
**Tags**: refactor, patterns, modernization  
**Estimated Time**: Variable

## Common Refactoring Patterns

### 1. Extract Method

**Before**:
```foxpro
FUNCTION ProcessOrder(tnOrderId)
    LOCAL loOrder, llValid
    USE Orders
    LOCATE FOR id = tnOrderId
    llValid = !EOF() AND status <> "cancelled"
    IF llValid
        REPLACE status WITH "processing"
        REPLACE updated WITH DATETIME()
        * ... 50 more lines ...
    ENDIF
    RETURN llValid
ENDFUNC
```

**After**:
```foxpro
FUNCTION ProcessOrder(tnOrderId)
    LOCAL loOrder
    loOrder = THIS.FindOrder(tnOrderId)
    IF THIS.IsValidOrder(loOrder)
        THIS.UpdateOrderStatus(loOrder, "processing")
        THIS.NotifyCustomer(loOrder)
    ENDIF
    RETURN !ISNULL(loOrder)
ENDFUNC

PROTECTED FUNCTION FindOrder(tnOrderId)
    * Isolated database logic
ENDFUNC
```

### 2. Replace Conditional with Polymorphism

**Before**:
```foxpro
FUNCTION CalculatePrice(tcType, tnAmount)
    DO CASE
    CASE tcType = "RETAIL"
        RETURN tnAmount * 1.0
    CASE tcType = "WHOLESALE"
        RETURN tnAmount * 0.8
    CASE tcType = "VIP"
        RETURN tnAmount * 0.6
    ENDCASE
ENDFUNC
```

**After**:
```foxpro
DEFINE CLASS PriceStrategy AS Custom
ENDDEFINE

DEFINE CLASS RetailStrategy AS PriceStrategy
    FUNCTION Calculate(tnAmount)
        RETURN tnAmount * 1.0
    ENDFUNC
ENDDEFINE

FUNCTION CalculatePrice(toPriceStrategy, tnAmount)
    RETURN toPriceStrategy.Calculate(tnAmount)
ENDFUNC
```

### 3. Introduce Parameter Object

**Before**:
```foxpro
FUNCTION CreateInvoice(tcCustomer, tdDate, tnAmount, tcCurrency, tn Tax, tcNotes)
    * Too many parameters
ENDFUNC
```

**After**:
```foxpro
DEFINE CLASS InvoiceData AS Custom
    cCustomer = ""
    dDate = {}
    nAmount = 0
    cCurrency = "USD"
    nTax = 0
    cNotes = ""
ENDDEFINE

FUNCTION CreateInvoice(toInvoiceData)
    * Single parameter object
ENDFUNC
```

### 4. Replace Magic Numbers with Constants

**Before**:
```foxpro
IF nStatus = 1
    * Processing
ENDIF
IF nType = 3
    * Special handling
ENDIF
```

**After**:
```foxpro
#DEFINE STATUS_PROCESSING 1
#DEFINE STATUS_COMPLETED  2
#DEFINE TYPE_STANDARD     1
#DEFINE TYPE_SPECIAL      3

IF nStatus = STATUS_PROCESSING
    * Processing
ENDIF
```

### 5. Decompose Conditional

**Before**:
```foxpro
IF (dDate >= DATE() - 30 AND dDate <= DATE()) AND ;
   (cStatus = "active" OR cStatus = "pending") AND ;
   nAmount > 1000
    * Complex condition
ENDIF
```

**After**:
```foxpro
IF THIS.IsRecentDate(dDate) AND ;
   THIS.IsValidStatus(cStatus) AND ;
   THIS.IsLargeAmount(nAmount)
    * Readable condition
ENDIF
```

### 6. Replace Nested Conditionals with Guard Clauses

**Before**:
```foxpro
FUNCTION ProcessData(tcData)
    IF !EMPTY(tcData)
        IF LEN(tcData) > 10
            IF THIS.Validate(tcData)
                RETURN THIS.Process(tcData)
            ENDIF
        ENDIF
    ENDIF
    RETURN ""
ENDFUNC
```

**After**:
```foxpro
FUNCTION ProcessData(tcData)
    IF EMPTY(tcData)
        RETURN ""
    ENDIF
    IF LEN(tcData) <= 10
        RETURN ""
    ENDIF
    IF !THIS.Validate(tcData)
        RETURN ""
    ENDIF
    RETURN THIS.Process(tcData)
ENDFUNC
```

### 7. Extract Class

**Before** (God Object):
```foxpro
DEFINE CLASS OrderManager AS Custom
    FUNCTION ProcessOrder()
    ENDFUNC
    FUNCTION CalculateShipping()
    ENDFUNC
    FUNCTION SendEmail()
    ENDFUNC
    FUNCTION ValidatePayment()
    ENDFUNC
    FUNCTION GenerateInvoice()
    ENDFUNC
    * ... 20 more methods
ENDDEFINE
```

**After**:
```foxpro
DEFINE CLASS OrderManager AS Custom
    oShippingService = NULL
    oEmailService = NULL
    oPaymentService = NULL
    oInvoiceService = NULL
ENDDEFINE

DEFINE CLASS ShippingService AS Custom
    FUNCTION CalculateShipping()
    ENDFUNC
ENDDEFINE
```

## Refactoring Checklist

- [ ] Code compiles after refactoring
- [ ] All tests still pass
- [ ] No behavior changes (unless intended)
- [ ] Improved readability
- [ ] Reduced complexity
- [ ] Better separation of concerns
- [ ] More testable code

## Related

- [Code Audit](../auditoria/code-audit-comprehensive.prompt.md)
- [VFP Development](../dev/vfp-development-expert.prompt.md)
