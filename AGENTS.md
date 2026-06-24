# AI Agent Guardrails for Vulnerability Management

This document provides foundational mandates for AI agents when tasked with fixing vulnerabilities within this repository. These guardrails apply to all packages, including internal ones like `volos-*` and `microgateway-*`.

## Vulnerability Fix Workflow

When a vulnerability is identified, agents must follow this prioritized approach, scanning for fixes in minor versions first before considering major versions.

### 1. npm audit fix
The first action should always be to attempt a standard `npm audit fix`.

### 2. Minor Version Updates
If `npm audit fix` does not resolve the issue, consider a minor update (e.g., `5.0.1` -> `5.0.2`). These are generally safe and unlikely to impact code changes.

### 3. Major Version Updates
If a major version update is required to fix the vulnerability:
*   **Research**: Perform thorough research for possible breaking changes introduced in the major version.
*   **Scanning**: Manually scan the codebase and run configurations for affected code areas.
*   **Fixing**: Proactively fix any code impacted by breaking changes.
*   **Highlighting**: Explicitly highlight any breaking changes and the corresponding fixes in the implementation summary.
*   **Verification**: Execute the nightly test suite against the local codebase:
    ```bash
    cd test-functional
    ./NightlyTests.sh 1
    ```

### 4. Dependency Overrides (Sub-package Updates)
**Priority**: Always prioritize updating the parent dependency (even if it's a major update) over using overrides.

For vulnerabilities in sub-dependencies that cannot be resolved via direct parent package updates, the `overrides` field in `package.json` may be used.
*   **Warning**: This is a high-risk operation as it forces updates on sub-packages which can break nested dependencies.
*   **Manual Effort**: Requires significant manual effort to check the impact across the dependency tree.
*   **Thorough Testing**: Mandatory thorough testing of the entire application to ensure no breakage.

## Internal Packages (`volos-*`, `microgateway-*`)
Internal packages are managed by the EMG team. AI agents should follow the same pattern mentioned above for vulnerability fixes in these packages. Changes in internal packages can be managed directly and may not require the high-risk `overrides` mechanism if a parent update is feasible.
