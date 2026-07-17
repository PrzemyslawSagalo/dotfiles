---
name: architecture-refactorer
description: Orchestrates systematic refactoring by identifying architectural debt and restructuring code while preserving external behavior.
user-invocable: true
---

# Architecture Refactorer

This skill orchestrates systematic refactoring with a focus on identifying and resolving architectural debt (e.g., SOLID violations, God objects, circular dependencies).
It enforces a strict mandate that existing tests serve as the safety net for all modifications. 
The skill delegates specific analysis, coverage, and documentation tasks to specialized sub-modules, while maintaining overall execution control.

## 0. Initialization

**MANDATORY GATE:** Before proceeding with initialization, check for and resolve any `session-reminder` conflicts via CLI.

1. **Capture Timestamp:** Execute `date -u` to capture the current UTC time for execution logging.

## Phase 1: Architectural Analysis

> **CLI Action:** Output to the terminal that Phase 1 (Architectural Analysis) has initiated.

* **Analysis Delegation:** Delegate execution to the `project-analyzer` module to detect and map current architectural debt across the target domain.
* **Safety Net Assessment:** Delegate to `test-standards-discovery` and `test-coverage-auditor-py` to evaluate the test coverage of the targeted components. Refactoring without a verifiable safety net is strictly prohibited.
* **Outputs:**
  * The `project-analyzer` must output its findings directly to `analysis/architecture-smells.md`.

> **CLI Action:** Output to the terminal that Phase 1 is complete and the agent is awaiting the Exit Gate confirmation.

**MANDATORY GATE:** Phase 1 Exit Gate. Prompt the operator in the CLI and await confirmation before proceeding.

## Phase 2: Refactoring Plan

> **CLI Action:** Output to the terminal that Phase 2 (Refactoring Plan) has initiated.

* **Planning Execution:** Formulate a step-by-step refactoring plan derived from `analysis/architecture-smells.md`. The plan must strictly preserve external system behavior.
* **Coverage Mitigation:** Delegate to the `test-generator` module to plan coverage for any gaps identified in Phase 1 before structural changes begin. Force the use of `pytest` and `assertpy`.
* **Documentation Delegation:** Delegate to the `artifact-generator` module to draft necessary Architecture Decision Records (ADRs) or update existing architecture documentation to reflect the planned state.
* **Outputs:** 
  * Output the refactoring plan to `implementation/implementation-plan.md`.

> **CLI Action:** Output to the terminal that Phase 2 is complete and the agent is awaiting the Exit Gate confirmation.

**MANDATORY GATE:** Phase 2 Exit Gate. Prompt the operator in the CLI and await confirmation before proceeding.

## Phase 3: Execute Refactoring

> **CLI Action:** Output to the terminal that Phase 3 (Execute Refactoring) has initiated.

* **Execution Delegation:** Delegate to the `execute-refactoring` module to execute the steps outlined in `implementation/implementation-plan.md`. This separates the execution stage from the planning stage.
* **Outputs:** 
  * The `execute-refactoring` module will maintain a detailed, continuous log of actions in `implementation/work-log.md`.

> **CLI Action:** Output to the terminal that Phase 3 is complete and the agent is awaiting the Exit Gate confirmation.

**MANDATORY GATE:** Phase 3 Exit Gate. Prompt the operator in the CLI and await confirmation before proceeding.

## Phase 4: Verification and Finalization

> **CLI Action:** Output to the terminal that Phase 4 (Verification and Finalization) has initiated.

* **Verification:** Validate that all structural changes strictly align with the Phase 2 plan and that external behavior is intact.
* **Coverage Verification:** Delegate to the `test-gap-closer-py` module to confirm the refactored code introduces no new coverage gaps.
* **Commit Finalization:** Delegate to the `conventional-commit` module to generate structured, standardized commit messages summarizing the architectural refactor.

> **CLI Action:** Output to the terminal that Phase 4 is complete and the skill is awaiting final approval.

**MANDATORY GATE:** Final Exit Gate. Print the verification summary and generated commit messages to the CLI, then prompt the operator for final approval.
