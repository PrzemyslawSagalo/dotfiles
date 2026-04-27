---
name: test-coverage-auditor
description: Runs instrumented test coverage across all tiers, detects import-time inflation via AST analysis, corrects misleading percentages, and writes a structured coverage report to the project docs.
argument-hint: "[doc output path (optional, default: doc/test_coverage.rst)]"
---

# Coverage Auditor

Produces accurate, honest per-module code coverage for Python projects.

The standard `coverage` tool inflates numbers for modules that are imported but never exercised — every `import`, `class`, and `def` statement executed at module load time is counted as "covered". This skill detects and corrects that pattern so the final report reflects **real functional coverage** (function bodies actually executed by tests).

## Usage

```bash
/coverage-auditor
/coverage-auditor doc/test_coverage.rst
/coverage-auditor doc/coverage.md
```

## When to Use

- After a test suite is written or significantly changed
- When reporting coverage to stakeholders
- When the tool reports suspiciously high percentages for untested modules

---

## Workflow

### Step 1: Discover Project Structure

1. Detect test tiers by inspecting `tests/` directory:
   - Common names: `test_unit`, `test_integration`, `test_system`, `test_e2e`
   - Presence of `conftest.py` options (e.g. `--tdb-mode`) indicates system tests need extra flags
2. Detect virtual environment: look for `venv/`, `.venv/`, `env/`, or `pyenv` shims. Prefer a venv that successfully imports the main package.
3. Check for a `.env` file with credentials needed by remote/system tests.
4. Detect the source root (`src/`, `lib/`, or package directory at repo root).
5. Read `pyproject.toml` or `setup.cfg` for any existing `[tool.coverage]` configuration.

**Ask the user only if ambiguous** (multiple venvs, unknown system-test flags, no `.env` but remote tests detected).

---

### Step 2: Run Instrumented Coverage

Run coverage tier by tier, appending results:

**Tier 1 — Unit & Integration** (no remote flags):
```bash
coverage run -m pytest tests/test_unit tests/test_integration
```

**Tier 2 — System** (only if detected; append with `-a`; load `.env` if present):
```bash
set -a && source .env && set +a
coverage run -a -m pytest tests/test_system [--project-specific-flags]
```

Adjust tier names and flags based on what was discovered in Step 1.

After all tiers:
```bash
coverage report --include="src/*" -m
```

Capture the full line-by-line report including missing line numbers for every module.

**If tests fail:** report which tests failed and their errors. Ask the user whether to continue with partial results or abort.

---

### Step 3: Detect Import-Time Inflation

For every module where coverage is > 0 % but the module has no test exercising it directly, perform an AST analysis:

1. Parse the source file with Python's `ast` module.
2. Classify every executable statement:
   - **Import-side-effect only**: `import`, `from … import`, `class` definition header, `def` signature, module-level assignments, docstrings
   - **Real function body**: any statement inside a function or method body (assignments, calls, returns, conditionals, loops, `raise`, `yield`, `with`, etc.)
3. Cross-reference with the `coverage report -m` missing-lines output:
   - If **all covered lines** are import-side-effect statements and **all function body lines** are in the missing set → mark module as **0 % functional (import-time only)**
   - If **at least one covered line** is inside a function body → the reported percentage stands

**Script template** (run inline via `python3 -c` or a temp file):

```python
import ast, sys

def classify(path):
    src = open(path).read()
    tree = ast.parse(src)
    body_lines = set()
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            for child in ast.walk(node):
                if hasattr(child, 'lineno') and not isinstance(
                    child, (ast.FunctionDef, ast.AsyncFunctionDef,
                            ast.ClassDef, ast.arguments, ast.arg)):
                    body_lines.add(child.lineno)
    return body_lines

path = sys.argv[1]
body = classify(path)
# cross-reference with covered lines from coverage json export
```

Alternatively, export coverage data with `coverage json` and cross-reference programmatically.

---

### Step 4: Build Corrected Coverage Table

For every module in `coverage report`:

| Field | Source |
|---|---|
| Module path | `coverage report` output |
| Tool % | `coverage report` percentage |
| Corrected % | Same as tool %, or **0 %** if import-time only (Step 3) |
| Notes | "0 % functional (import-time only)", "No tests yet", etc. |

Classify modules into bands using the **corrected %**:

| Band | Range | Label |
|---|---|---|
| Well-covered | ≥ 80 % | ✅ |
| Partially covered | 40–79 % | ⚠️ |
| Poorly/not covered | < 40 % | ❌ |

---

### Step 5: Write the Coverage Report

Detect the output format from the file extension of the argument (`.rst` → reStructuredText, `.md` → Markdown). Default is `.rst`.

**RST template:**

```rst
Test Coverage Report
####################

Coverage is measured with `coverage.py` across all three test tiers.
Overall line coverage: **XX %** (N statements, M missed).

.. note::

   Modules showing **0 %** have no function body executed by any test.
   ``coverage`` may report a non-zero value for these modules due to
   import-side-effects (imports, class and function definitions executed
   at module load time). Those values are corrected to 0 % here.

To regenerate::

   coverage run    -m pytest tests/test_unit tests/test_integration
   coverage run -a -m pytest tests/test_system [--flags]
   coverage report --include="src/*"

Coverage by module
==================

.. list-table::
   :header-rows: 1
   :widths: 45 15 40

   * - Module
     - Cover %
     - Notes
   * - ``path/to/module.py``
     - XX %
     - [note or blank]
```

**Markdown template:**

```markdown
# Test Coverage Report

Coverage measured with `coverage.py` across all test tiers.
Overall: **XX %** (N statements, M missed).

> **Note**: Modules at 0 % have no function body executed. The tool may
> report higher due to import-side-effects; those values are corrected here.

## Coverage by module

| Module | Cover % | Notes |
|---|---|---|
| `path/to/module.py` | XX % | |
```

If the output file already exists, **update it in-place** (preserve surrounding documentation, only replace the coverage table and statistics).

---

### Step 6: Integrate with Project Docs (Optional)

If a `doc/contributing.rst` (or `docs/contributing.md`) exists and does not already reference the coverage report:

- RST: add `.. include:: test_coverage.rst` under a "Test Coverage Report" heading
- Markdown: add a `[Test Coverage Report](test_coverage.md)` link

If the coverage report is already in a top-level TOC (`doc/index.rst` or `docs/index.md`), suggest moving it under `contributing` instead — coverage reports are a developer-facing concern.

---

### Step 7: Summary

Report:

```
Coverage Audit Complete
=======================
Overall (tool):      61 %
Corrected overall:   57 %  (4 modules reclassified as 0 % functional)

Modules reclassified (import-time only):

Report written to: doc/test_coverage.rst
Tests: 258 passed, 0 failed (3 tiers)
```

---

## What This Does

1. **Discovers** project structure (venvs, tiers, flags, credentials)
2. **Runs** instrumented coverage across all test tiers
3. **Detects** import-time inflation via AST classification
4. **Corrects** misleading percentages to 0 % where appropriate
5. **Writes** a structured, honest coverage report (RST or Markdown)
6. **Integrates** the report into project documentation

## Graceful Fallback

- If the main package fails to import in all detected venvs → report the import error and ask the user to fix the environment before proceeding.
- If no test directories are found → ask the user for the test paths.
- If `coverage` is not installed → suggest `pip install coverage` and retry.
- If partial tiers fail (e.g. system tests need credentials) → proceed with available tiers and note which tiers are missing from the report.
