---
description: Comprehensive code audit for Visual FoxPro projects covering architecture, quality, maintainability, and performance metrics
tools:
  - read_file
  - grep_search
  - semantic_search
  - list_code_usages
  - get_errors
applyTo:
  - "**/*.prg"
  - "**/*.vcx"
  - "**/*.scx"
  - "**/*.frx"
argument-hint: "Especifica el archivo o carpeta a auditar"
---

# 📊 Comprehensive VFP Code Audit

**Apply To**: `**/*.prg`, `**/*.vcx`, `**/*.scx`, `**/*.frx`  
**Tags**: audit, quality, architecture, vfp  
**Complexity**: High  
**Estimated Time**: 30-60 minutes

## Objective
Perform a deep, systematic audit of the Visual FoxPro codebase to identify architectural issues, code smells, technical debt, and opportunities for improvement.

## Audit Scope

### 1. **Architecture Analysis**

#### Class Hierarchy Review
- [ ] Verify inheritance chains are logical and not too deep (max 4 levels)
- [ ] Check for proper use of base classes (ZooBase, ZooSession, etc.)
- [ ] Identify circular dependencies
- [ ] Validate interface segregation

#### Dependency Analysis
- [ ] Map inter-class dependencies
- [ ] Identify tight coupling issues
- [ ] Check for proper dependency injection patterns
- [ ] Validate file reference conventions (lowercase)

#### SOLID Principles Compliance
- [ ] **S**ingle Responsibility: Each class has one clear purpose
- [ ] **O**pen/Closed: Classes open for extension, closed for modification
- [ ] **L**iskov Substitution: Subclasses can replace base classes
- [ ] **I**nterface Segregation: No forced implementation of unused methods
- [ ] **D**ependency Inversion: Depend on abstractions, not concretions

### 2. **Code Quality Metrics**

#### Variable Management
```foxpro
* Check for:
- All LOCAL variables declared
- No implicit variable creation
- Proper scoping (LOCAL, PRIVATE, PUBLIC)
- Meaningful variable names (Hungarian notation)
```

#### Error Handling
```foxpro
* Audit:
- All critical operations wrapped in TRY/CATCH
- Proper exception propagation
- Use of ZooException pattern
- Error logging implementation
- Graceful degradation
```

#### Resource Management
```foxpro
* Verify:
- Objects properly released
- Cursors/tables closed
- DataSessions properly managed
- File handles cleaned up
- Memory leaks prevented
```

### 3. **Performance Audit**

#### Database Operations
- [ ] Use of SQL passthrough where appropriate
- [ ] Proper indexing on cursors
- [ ] Buffering mode optimization
- [ ] Cursor reuse patterns
- [ ] Transaction management

#### Memory Usage
- [ ] Large array handling
- [ ] Object pooling opportunities
- [ ] Excessive object creation in loops
- [ ] Memory cleanup in long-running processes

#### Code Optimization
- [ ] Nested loop complexity (O(n²) or worse)
- [ ] Redundant calculations
- [ ] String concatenation in loops
- [ ] Inefficient SCAN/ENDSCAN usage

### 4. **Maintainability Assessment**

#### Code Documentation
- [ ] Classes have header comments
- [ ] Complex methods documented
- [ ] Parameters explained
- [ ] Return values documented
- [ ] Examples provided for public APIs

#### Code Complexity
- [ ] Cyclomatic complexity per method (target: < 10)
- [ ] Method length (target: < 50 lines)
- [ ] Class size (target: < 500 lines)
- [ ] Deep nesting levels (target: < 4)

#### Code Duplication
- [ ] Identify duplicate code blocks (> 5 lines)
- [ ] Repeated logic that should be extracted
- [ ] Opportunities for method extraction
- [ ] Common patterns for utility classes

### 5. **Security Audit**

#### Input Validation
- [ ] SQL injection prevention (parameterized queries)
- [ ] User input sanitization
- [ ] Path traversal protection
- [ ] Buffer overflow prevention

#### Data Protection
- [ ] Sensitive data handling
- [ ] Password storage (hashing)
- [ ] Configuration security
- [ ] Connection string protection

### 6. **wwDotNetBridge Integration**

#### Bridge Usage Patterns
- [ ] Proper initialization sequence
- [ ] Assembly loading strategy
- [ ] Object lifecycle management
- [ ] Error handling for interop calls
- [ ] Type conversion correctness

#### .NET Compatibility
- [ ] Framework version consistency (.NET 4.8)
- [ ] Assembly version conflicts
- [ ] COM visibility issues
- [ ] Memory management across boundaries

### 7. **VFP Best Practices Compliance**

#### Naming Conventions
```foxpro
* Check adherence:
- Classes: PascalCase (ZooSession)
- Methods: PascalCase (Initialize)
- Properties: Camel/Hungarian (cUserName, lIsActive)
- Variables: Hungarian (lcResult, lnCounter)
- Files: lowercase.prg
```

#### Code Structure
- [ ] One class per file
- [ ] Matching filename and class name (case-insensitive)
- [ ] Proper DEFINE CLASS / ENDDEFINE pairing
- [ ] No orphaned code outside classes
- [ ] Consistent indentation (tabs or spaces)

## Audit Report Template

```markdown
# Code Audit Report: [Project Name]
**Date**: [Date]
**Auditor**: [Name/Tool]
**Scope**: [Files/Modules Audited]

## Executive Summary
- **Overall Health**: [Excellent/Good/Fair/Poor]
- **Critical Issues**: [Count]
- **Major Issues**: [Count]
- **Minor Issues**: [Count]
- **Recommendations**: [Count]

## Detailed Findings

### Architecture
- **Score**: [1-10]
- **Issues**: [List]
- **Recommendations**: [List]

### Code Quality
- **Score**: [1-10]
- **Coverage**: [%]
- **Complexity**: [Average Cyclomatic]
- **Issues**: [List]

### Performance
- **Score**: [1-10]
- **Bottlenecks**: [List]
- **Optimization Opportunities**: [List]

### Security
- **Score**: [1-10]
- **Vulnerabilities**: [List]
- **Risk Level**: [Low/Medium/High/Critical]

### Maintainability
- **Score**: [1-10]
- **Documentation**: [%]
- **Test Coverage**: [%]
- **Technical Debt**: [Estimate in hours]

## Priority Action Items
1. [Critical issue 1]
2. [Critical issue 2]
3. [Major issue 1]

## Long-term Recommendations
- [Strategic improvement 1]
- [Strategic improvement 2]
```

## Execution Commands

```bash
# Run full audit
@workspace /audit Perform comprehensive code audit following the audit prompt

# Specific area audits
@workspace /audit Focus on architecture and SOLID principles
@workspace /audit Analyze performance and optimization opportunities
@workspace /audit Review security vulnerabilities
```

## Expected Outputs

1. **Audit Report**: Detailed markdown report with findings
2. **Issue List**: Categorized list of problems with severity
3. **Metrics Dashboard**: Key quality metrics summary
4. **Remediation Plan**: Prioritized action items with estimates

## Follow-up Actions

After audit completion:
1. Review findings with team
2. Prioritize issues by severity and effort
3. Create work items for remediation
4. Schedule follow-up audit (quarterly recommended)

---

**Related Prompts**:
- [Refactor Patterns](../refactor/refactor-patterns.prompt.md)
- [Test Audit](../test/test-audit.prompt.md)
