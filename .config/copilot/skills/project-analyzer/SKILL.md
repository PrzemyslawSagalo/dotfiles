---
name: project-analyzer
description: Analyzes project codebase to detect tech stack, architecture, and conventions for documentation generation. Use for existing/legacy projects to auto-generate meaningful documentation.
---

# Skill: Project Analyzer

## Purpose
Analyze codebases to understand their current state, detect technology stack, architecture patterns, and conventions to generate comprehensive project documentation. Supports new, existing, and legacy projects.

## Triggers
* Invoked when standardizing a new project or updating documentation for an existing/legacy codebase.
* Triggered automatically by an orchestrator when analyzing a codebase for the first time.

## Orchestration & Execution

### Phase 1: Context & Detection
* **Detect Project Type:** Examine git history, file system, and dependency versions to classify project maturity as New, Existing, or Legacy. Assign confidence scores.
* **Detect Project Architecture Type:** Identify if the project is standard, monorepo, frontend-only, backend-only, or mixed. Check indicators like workspace configs and directory structure patterns (e.g., `apps/`, `packages/`). Assign confidence scores.

### Phase 2: Tech Stack & Architecture Analysis
* **Tech Stack Analysis:** Identify all technologies used (Languages, Frameworks, Databases, Build Tools, Testing Frameworks, Infrastructure & DevOps, Linters) by analyzing dependency and config files. Ensure confidence scores and evidence are documented.
* **Architecture Discovery:** Scan directories for structural patterns (e.g., Monolithic MVC, Layered, Feature-Based, Microservices). Detect main application entry points, API structure (REST/GraphQL), and database integrations.

### Phase 3: Conventions Discovery
* **Analyze Conventions:** Discover existing naming conventions (files, code, tests), code organization (imports, file co-location), documentation practices (README quality, API documentation, code comments), and code style rules (indentation, linters, quote style).

### Phase 4: Validation & Saving
* **Compile Report:** Aggregate all findings into a structured report containing an Executive Summary, Detailed Findings, Current State Assessment, and Documentation Recommendations (Required, Suggested, Optional). Provide an Evidence Summary.
* **Delegation:** ALL documentation file write operations MUST be executed via the `artifact-generator` skill. The project analyzer does not write documentation files directly. Pass the finalized analysis report (JSON + Markdown) to the `artifact-generator` to persist the documentation in the corresponding `./agents-standards/` or `./docs/` directory structure.

## Constraints & Rules
* **Evidence-Based Analysis:** Every finding must reference actual files or code patterns discovered. Quote configuration values and provide file paths. Never make assumptions without evidence.
* **Honest Confidence Levels:** Use High, Medium, or Low honestly. When information is missing, mark confidence as "Low", document what you looked for, and suggest asking the user rather than guessing.
* **Delegation Only:** Always use the `artifact-generator` for generating and saving to `./agents-standards/` or project documentation directories. Do NOT modify, create, or delete any project files directly.
* **Efficiency for Large Codebases:** Sample representative files (10-20) rather than reading everything. Focus on key directories and config files first. Use Glob for file discovery and Grep for pattern matching.
