# Agent Context

<!-- 
This file provides consolidated context for AI agents working on this project.
-->

## AI Documentation Protocol

This protocol defines how AI agents must manage and evolve documentation within the ai-docs/ folder.

### 📁 Folder Overview

Every document in ai-docs/ has a clear purpose and update trigger. Agents must update files incrementally — appending or inserting into relevant sections, never replacing entire documents.

### 📜 Core Principles

1. **Scoped Updates Only**: Each document should be updated only with information relevant to its domain.
2. **Incremental Additions**: Documentation must evolve over time in small, relevant updates that reflect real project changes. Each addition should be scoped (e.g., a new module, design decision, or feature), dated if meaningful, and never overwrite unrelated content. Documents must remain continuously useful and current.
3. **Subsections by Document**: Each document in ai-docs/ must be described as a subsection in this file. Do not reference source files directly.
4. **Self-Awareness**: This protocol may be updated by agents as needs evolve, under strict guidelines (see Self-Revision).
5. **Plan** Any new plan or spec to update the codebase must start with updating relevant documentation in ai-docs/.

### 📘 Document Types & Rules

Each document in ai-docs/ must define its own update triggers. This section serves as a living registry of how each document should be maintained. AI agents must create a subsection below for every document added, keeping it in sync with the folder's content.

#### CONTEXT.md

- **Purpose**: Provide consolidated context for AI agents working on the project.
- **Trigger**: Whenever a new document is added to ai-docs/, or a previously undocumented pattern emerges.
- **Format**: This document itself serves as the protocol for managing ai-docs/ updates. It should be updated with new sections as needed, following the incremental update principle.

#### PATTERNS.md

- **Purpose**: Document GitHub Actions workflow patterns and conventions for consistent CI/CD implementation.
- **Trigger**: When new workflow patterns are introduced, existing patterns are modified, or language-specific conventions are established.
- **Format**: Code patterns with real examples from workflow files, including YAML structure, naming conventions, and reusable workflow patterns.

#### ARCHITECTURE.md

- **Purpose**: Explain how GitHub Actions workflows fit together and define component boundaries.
- **Trigger**: When new workflow types are added, job dependencies change, or the overall CI/CD architecture evolves.
- **Format**: System overview showing workflow relationships, data flow between jobs, and integration points.

#### WORKFLOWS.md

- **Purpose**: Provide step-by-step guidance for common GitHub Actions workflow development tasks.
- **Trigger**: When new development workflows are established, existing processes are updated, or troubleshooting procedures are documented.
- **Format**: Task-oriented instructions with specific commands and procedures for workflow development.

### 🔄 Self-Revision of the Protocol

Agents may propose a revision to this section only if:

- A new document is added to ai-docs/
- A previously undocumented pattern emerges

---

✅ AI agents must reference this protocol when updating or creating documents in ai-docs/. Future updates to this section must be scoped, appended, and appropriately dated.

---

## Project Overview

This is a GitHub Actions workflow repository containing reusable workflows for CI/CD pipelines. The project includes workflows for multiple technology stacks including Node.js, Python, .NET, and Docker image building.

## How to Use This Documentation

When starting work on this project:
1. Run `context-prime` to load relevant project context
2. Reference the ai-docs/ for contribution patterns
3. Follow the documented conventions to maintain consistency

The ai-docs/ folder contains guides for contributing to this project. Each document focuses on HOW to add or modify code correctly.

## Project Structure

- `.github/workflows/` - GitHub Actions workflow definitions
- `ai-docs/` - AI agent documentation and contribution guides
- `specs/` - Feature specifications and requirements

## Technology Stack

- **Primary**: GitHub Actions YAML workflows
- **Supported Languages**: Node.js, Python, .NET, Docker
- **CI/CD**: GitHub Actions-based automation
- **Version Control**: Git with GitHub integration