# General Project & Infrastructure Standards

## Infrastructure Requirements (12-Factor Compliant)

1. **Infrastructure Isolation:** 
   All infrastructure scripts (Terraform, CloudFormation, Kubernetes manifests, etc.) MUST be contained within a dedicated `infrastructure/` directory.

2. **Environment Configuration:** 
   Environment-specific configurations (e.g., `dev.yaml`, `prod.yaml`) MUST be stored alongside the infrastructure scripts within the `infrastructure/` directory.

3. **Strict Secret Management:**
   * It is STRICTLY PROHIBITED to save passwords, access tokens, API keys, or any other sensitive secrets within configuration files (like `prod.yaml`) or anywhere else in the codebase.
   * All sensitive secrets MUST be injected via the environment and locally stored in `.env` files.
   * All `.env` files MUST be strictly added to the `.gitignore` to prevent committing them to version control.
