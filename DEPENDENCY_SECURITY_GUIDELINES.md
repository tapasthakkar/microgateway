# Dependency Security and Vulnerability Management Guidelines

This document outlines the procedures and principles for managing vulnerabilities and dependency updates in this repository. Given the complex and legacy nature of some dependencies in this project, these guidelines ensure that security fixes do not introduce breaking changes.

These rules apply to all contributors, including human developers, automated dependency tools, and AI coding assistants.

---

## Core Principles

### 1. Factual Verification (No Assumptions)
*   **Verify Usage:** Never assume a package is vulnerable or safe based solely on security audit reports (like `npm audit`). Reports flag version ranges, not actual usage.
*   **Ground Truth:** Always inspect the source code in `node_modules` or the repository to verify if the vulnerable code path is actually reachable or executed in this application.
*   **Exhaustive Search:** Check all execution paths when tracing usage, not just the first few results.

### 2. Handle Missing Context Explicitly
*   **Missing Dependencies:** If `node_modules` is not installed, do not infer behavior. Install dependencies to inspect the real code.
*   **Dynamic Imports:** Be aware of dynamic path construction or unusual import patterns that might hide dependency usage.
*   **Acknowledge Limits:** If usage cannot be factually verified, document the limitation clearly rather than guessing.

---

## Vulnerability Fix Workflow

When a vulnerability is identified, follow this prioritized, risk-averse approach:

### 1. Standard Audit Fix
Attempt a standard `npm audit fix` first. This applies safe, non-breaking updates that respect the version constraints in `package.json`.

### 2. Minor and Patch Updates
If the audit fix does not resolve the issue, consider a manual minor or patch update (e.g., `1.0.1` -> `1.0.2`). These are generally safe and unlikely to impact functionality.

### 3. Major Version Updates (High Risk)
If a major version update is required:
*   **Research**: Thoroughly research breaking changes introduced in the major version.
*   **Scan**: Scan the codebase to identify all areas affected by the breaking changes.
*   **Proactive Fixes**: Propose fixes for any code impacted by breaking changes.
*   **Verification**: Execute the functional test suite against the local codebase to verify stability.

### 4. Dependency Overrides
*   Use the `overrides` field in `package.json` only as a last resort for sub-dependencies that cannot be resolved via parent package updates.
*   **Warning**: This forces updates on sub-packages which can break nested dependencies. Thorough testing of the entire application is mandatory.

---

## Internal Packages (`volos-*`, `microgateway-*`)

Internal packages are managed by the team and often reside in sibling directories (e.g., `../microgateway-plugins` or inside `../volos/`) relative to the main project folder.

When dealing with these packages:
1.  **Check `node_modules` First:** Always check the codebase via the installed dependencies in `node_modules` first to understand exactly what version and code execution path the project is running.
2.  **Holistic Fixes:** If a vulnerability stems from an internal package, do not take shortcuts like using overrides in the top-level `package.json` if it can be fixed at the source. Suggest applying the fix directly to the source codebase of the internal package.

---

## Special Directives for AI Coding Assistants

When an AI agent or Large Language Model (LLM)—acting as an expert Subject Matter Expert (SME) in Software Engineering and AI-Assisted Development—is processing this repository, it must adhere to the following behavioral mandates to ensure 100% accuracy and prevent common failure modes:

*   **Countering the 'Helpfulness' Trap:** LLMs often hallucinate plausible-sounding paths or names to appear helpful. You **must** resist this. Never use assumed or placeholder names for files, directories, or packages. If you reference a path, you must have factually verified its existence first.
*   **No Guessing:** When faced with a gap in knowledge, an LLM's default behavior is to guess. You **must** override this. Stop, admit the gap, and run the necessary search or ask the user.
*   **Human-in-the-Loop with Citation:** Never take a potentially breaking action based on a guess. When presenting options or asking for user guidance, always provide proper factual citations (file paths, line numbers, code snippets) so the user can verify your reasoning.
*   **Empirical Behavior Verification (Dual-Version Execution)**: To achieve absolute certainty that an override or upgrade does not introduce regressions, you must employ an empirical approach. Create an isolated test harness to execute the specific code path using the exact import and usage patterns identified in the project. Where feasible, execute this harness against both the legacy and target versions of the dependency, comparing execution results to verify behavioral equivalence. This is the gold standard for factual verification.

