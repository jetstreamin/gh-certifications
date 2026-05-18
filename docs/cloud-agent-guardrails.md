---
layout: default
title: Cloud Agent Guardrails
description: Practical guide to building guardrails for GitHub Copilot cloud agent, including policy planning, rulesets, Actions environment controls, and secure defaults.
---

# Cloud Agent Guardrails

**Status:** Tutorial | **Last Updated:** May 2026 | **Applies to:** GitHub Copilot cloud agent

## Overview

Before enabling GitHub Copilot cloud agent, set up enterprise guardrails so the agent operates in a secure, predictable, and compliant environment. The official guidance focuses on policy planning, branch and repository rulesets, and the GitHub Actions environment that cloud agent uses for execution.

### What This Guide Covers

- Built-in protections and where they help
- Policy planning at the enterprise and organization levels
- Ruleset and CODEOWNERS protections for important files
- GitHub Actions environment controls for secrets, runners, workflows, and permissions
- A short readiness checklist for administrators

## Learn About Built-In Protections

Copilot cloud agent includes built-in protections that reduce common AI-agent risks. Use those defaults as a baseline, then add organization-specific controls around access, repository policy, and workflow execution.

### Key Principle

Use layered defenses:

1. Rely on built-in protections for the baseline.
2. Restrict where the cloud agent can operate.
3. Protect sensitive repository and workflow files.
4. Limit the Actions environment as tightly as practical.

## Plan Policy Settings

Plan your cloud-agent policies before rollout. Enterprise policy sets the baseline, and organization owners can add narrower restrictions where needed.

### Questions to Resolve Up Front

- Which organizations and repositories will have cloud agent enabled?
- Which MCP servers will be allowed for external tool access?
- Which repositories require stricter review or approval before agent changes land?
- Which teams should own cloud-agent configuration files?

### Policies That Do Not Apply

The following Copilot policies do not apply to Copilot cloud agent:

- Content exclusions
- Custom models that provide your own LLM API keys
- Private MCP registries

## Adapt Rulesets

Copilot cloud agent already cannot perform some sensitive actions, such as pushing to a default branch or merging pull requests. Build on those defaults with repository rulesets.

### Recommended Ruleset Controls

- Require code scanning or code-quality checks for repositories where cloud agent works.
- Add a custom property to repositories or organizations where cloud agent is enabled so rules can target them cleanly.
- Review existing rulesets for conflicts with cloud-agent commit behavior, especially commit metadata constraints.
- Protect important cloud-agent and MCP configuration files with CODEOWNERS and require code-owner review.

### Suggested Files to Protect

- Cloud-agent configuration files
- MCP server definitions
- Workflow files that control agent setup
- Repository policy files that affect agent behavior

## Set Up Your GitHub Actions Environment

Copilot cloud agent runs on GitHub Actions runners, so your runner and workflow settings are part of the guardrail story.

### Store Data and Secrets

Keep data and secrets that cloud agent should not access in GitHub Actions variables or secrets. If cloud agent does need access to specific values, configure Copilot cloud agent secrets and variables at the organization or repository level.

### Configure Runners

Prefer GitHub-hosted runners so each cloud-agent run starts from a fresh environment. If you must use self-hosted runners, prefer ephemeral runners.

Organization owners can also restrict cloud agent to a specific runner label for consistent execution across repositories.

### Configure Workflow Policies

Decide whether GitHub Actions workflows should run automatically in pull requests created by cloud agent. By default, workflows are blocked until someone with write access approves them.

### Review Default Permissions

Review the default permissions for `GITHUB_TOKEN` in your enterprise. This does not change the token cloud agent uses in its own sessions, but it does affect setup steps in `copilot-setup-steps.yml` workflows. Encourage minimum necessary permissions in all workflows.

## Readiness Checklist

- [ ] Built-in protections reviewed
- [ ] Enterprise policy baseline defined
- [ ] Target organizations and repositories identified
- [ ] Relevant rulesets updated
- [ ] CODEOWNERS protections added for configuration files
- [ ] Secrets and variables reviewed for Actions exposure
- [ ] Runner strategy selected
- [ ] Workflow approval behavior documented
- [ ] `GITHUB_TOKEN` permissions reviewed

## References

- [Official GitHub Docs tutorial](https://docs.github.com/en/copilot/tutorials/cloud-agent/build-guardrails)
- [Risks and mitigations for GitHub Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/coding-agent/risks-and-mitigations)
- [Managing access to GitHub Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/coding-agent/access-management)
- [Connect agents to external tools](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/extend-cloud-agent-with-mcp)
- [Configure secrets and variables for Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/configure-secrets-and-variables)
- [Configure runners for GitHub Copilot cloud agent in your organization](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-organization/configure-runner-for-coding-agent)
- [Copilot customization cheat sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet)
