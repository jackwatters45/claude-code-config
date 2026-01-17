---
name: debugging
description: Systematic debugging workflow. Use when investigating bugs, errors, or unexpected behavior. Triggers on "debug", "investigate bug", "fix error", "why is this failing", "not working".
---

# Systematic Debugging

Follow this workflow in order. Do NOT skip steps or jump to solutions.

## Phase 1: Reproduce

**Goal:** Confirm the bug exists and understand exact conditions.

1. **Get reproduction steps** from user or error report
2. **Reproduce locally** - run the exact steps
3. **Document the failure:**
   - Expected behavior
   - Actual behavior
   - Error messages (full stack trace)
   - Environment (OS, versions, config)

**If you can't reproduce:** Ask for more details. Don't guess.

```
REPRODUCTION:
Steps: [exact steps]
Expected: [what should happen]
Actual: [what actually happens]
Error: [full error message]
```

## Phase 2: Isolate

**Goal:** Find the smallest code path that triggers the bug.

1. **Trace the execution path** - where does data flow?
2. **Find the boundary** - what's the last working point?
3. **Add logging/breakpoints** at suspected locations
4. **Binary search** - if unsure, split the code path in half

Questions to answer:
- Is it input-dependent? (specific data triggers it)
- Is it state-dependent? (only after certain actions)
- Is it timing-dependent? (race condition)
- Is it environment-dependent? (works locally, fails in CI)

```
ISOLATION:
Entry point: [where execution starts]
Last working: [last point that works correctly]
First failing: [first point that fails]
Suspected area: [file:line or function]
```

## Phase 3: Hypothesize

**Goal:** Form a testable theory about the root cause.

1. **List possible causes** (at least 2-3)
2. **Rank by likelihood** based on evidence
3. **Design a test** for the top hypothesis

Common root causes:
- Off-by-one / boundary conditions
- Null/undefined handling
- Type coercion issues
- Async timing / race conditions
- State mutation side effects
- Missing error handling
- Incorrect assumptions about input

```
HYPOTHESES:
1. [Most likely] - because [evidence]
2. [Second likely] - because [evidence]
3. [Third likely] - because [evidence]

Testing hypothesis #1 by: [how to verify]
```

## Phase 4: Fix

**Goal:** Implement the minimal fix that addresses root cause.

1. **Fix the root cause** - not symptoms
2. **Keep it minimal** - don't refactor while fixing
3. **Add a regression test** - proves fix works, prevents recurrence

```
FIX:
Root cause: [what was actually wrong]
Fix: [what you changed]
Files: [files modified]
```

## Phase 5: Verify

**Goal:** Confirm the fix works and doesn't break anything.

1. **Run original reproduction steps** - bug should be gone
2. **Run test suite** - no regressions
3. **Test edge cases** - related scenarios still work
4. **Check CI** - passes in all environments

```
VERIFICATION:
[ ] Original bug no longer reproduces
[ ] New regression test passes
[ ] Existing tests pass
[ ] CI passes
[ ] Edge cases tested: [list]
```

## Phase 6: Document

**Goal:** Prevent future occurrences and share knowledge.

1. **Commit with clear message** explaining the bug and fix
2. **Update AGENTS.md** if pattern is reusable
3. **Consider:** Should this be caught by linting/types?

```bash
git commit -m "fix: [what was fixed]

Root cause: [brief explanation]
Regression test added: [test name]"
```

---

## Anti-Patterns (avoid these)

| Bad | Why | Do Instead |
|-----|-----|------------|
| Random changes until it works | Hides root cause, may introduce new bugs | Follow the phases |
| Fixing without reproducing | May fix wrong thing | Always reproduce first |
| Large refactor as "fix" | Introduces risk, hard to verify | Minimal fix, refactor separately |
| Skipping regression test | Bug will return | Always add test |
| "It works on my machine" | Ignores environment issues | Test in CI/staging |

## Quick Reference

```
1. REPRODUCE → Can I trigger the bug reliably?
2. ISOLATE   → Where exactly does it fail?
3. HYPOTHESIZE → Why might it fail there?
4. FIX       → Minimal change to address root cause
5. VERIFY    → Does fix work? Any regressions?
6. DOCUMENT  → Commit message, AGENTS.md if needed
```
