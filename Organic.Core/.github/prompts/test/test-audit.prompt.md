---
description: Test audit procedures for Visual FoxPro unit tests including coverage analysis and quality assessment
tools:
  - read_file
  - grep_search
  - runTests
  - list_code_usages
  - get_errors
applyTo:
  - "**/Tests/**/*.prg"
  - "**/Organic.Tests/**"
argument-hint: "Especifica los tests o clase a auditar"
---

# 🧪 Test Audit

**Apply To**: `**/Tests/**/*.prg`  
**Tags**: testing, audit, quality  
**Estimated Time**: 20-30 minutes

## Test Audit Checklist

### Test Coverage
- [ ] Core classes have > 80% coverage
- [ ] Business logic has > 70% coverage
- [ ] Edge cases covered
- [ ] Error paths tested

### Test Quality
- [ ] Tests follow AAA pattern (Arrange-Act-Assert)
- [ ] One assertion per test
- [ ] Independent tests (no interdependencies)
- [ ] Meaningful test names
- [ ] Mock external dependencies

### Test Structure
- [ ] Proper Setup/TearDown
- [ ] No hardcoded values
- [ ] Tests run in < 1 second
- [ ] Repeatable results

### Test Naming
```
Test_[ClassName]_[Method]_[Scenario]_[Expected]
```

## Audit Report

```markdown
# Test Audit Report
**Date**: [Date]
**Coverage**: [%]
**Pass Rate**: [%]

## Issues Found
- Missing tests for [Class]
- Flaky test: [TestName]
- Slow test: [TestName]

## Recommendations
1. Add tests for edge cases
2. Mock database access
3. Improve test isolation
```

## Related

- [Testing Agent](../../Organic.Tests/AGENTS.md)
- [Code Audit](../auditoria/code-audit-comprehensive.prompt.md)
