---
name: execute-refactoring
description: Executes code refactoring as a distinct stage, safely applying changes from an implementation plan or directly modifying a specified file based on provided instructions.
user-invocable: true
inputs:
  - target_file: (Optional) A specific file to perform the refactoring on.
  - instruction: (Optional) Specific instructions on what has to be changed and how.
argument-hint: "[target_file] [instruction]"
---

# Execute Refactoring

This skill acts as a dedicated module for executing code refactoring.
It can be invoked as part of a larger architectural refactoring workflow (guided by a generated plan) or triggered independently to target a specific file.

## Orchestration & Execution

### 1. Execution Routing
* **Targeted Refactoring:** If `target_file` is provided, focus execution solely on modifying that file according to the provided `instruction`.
* **Plan-Based Refactoring:** If no `target_file` is provided, execute the steps outlined in `implementation/implementation-plan.md` (e.g. as provided by the architecture-refactorer).

### 2. Execution Constraints
* **Safety Net First:** Systematically deploy and verify test updates prior to modifying any production code to ensure absolute behavior preservation.
* **Continuous Logging:** Maintain a detailed, continuous log of actions in `implementation/work-log.md`.

### 3. Verification
* Validate that all structural changes strictly align with the provided instructions or the implementation plan.
* Ensure external behavior remains intact via test runs.
