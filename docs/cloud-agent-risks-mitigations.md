---
layout: default
title: Cloud Agent Risks and Mitigations
description: Practical summary of the main risks and built-in mitigations for GitHub Copilot cloud agent.
---

## Cloud Agent Risks and Mitigations

**Status:** Concept Guide | **Last Updated:** May 2026 | **Applies to:** GitHub Copilot cloud agent

## Overview

GitHub Copilot cloud agent is autonomous and can access code, create pull requests, and push changes to a repository. That capability is useful, but it introduces risks that need clear operational guardrails. GitHub provides built-in mitigations, and you should layer your own enterprise and repository controls on top.

## 1. Unvalidated Code Can Introduce Vulnerabilities

Copilot cloud agent validates generated code before completing a pull request.

### Built-In Mitigations for Vulnerabilities

- CodeQL checks for security issues
- Newly introduced dependencies are checked against the GitHub Advisory Database
- Secret scanning detects API keys, tokens, and other sensitive values
- Copilot code review provides a second opinion and helps resolve issues before PR completion

### Operational Guidance for Vulnerabilities

- Review the session log to understand what the agent changed and why
- Keep security and code-quality checks enabled in your repository rules
- Treat the agent as a helper, not a replacement for human review

## 2. Copilot Cloud Agent Can Push Code Changes to Your Repository

The agent can modify code and open pull requests, so write access must be tightly controlled.

### Built-In Mitigations for Repository Writes

- Only users with write access can trigger the agent
- Comments from users without write access are not presented to the agent
- The agent can push only to a single branch
- When triggered on an existing PR, it uses that PR branch; otherwise it creates a `copilot/` branch
- It cannot directly run `git push` or other Git commands
- It cannot mark PRs ready for review, approve them, or merge them
- A human must review and merge draft PRs
- Workflow runs are blocked by default until a user with write access approves them

### Operational Guidance for Repository Writes

- Keep branch protections and required checks enabled
- Review existing rulesets for commit metadata constraints
- Use CODEOWNERS for sensitive files and configuration

## 3. Copilot Cloud Agent Has Access to Sensitive Information

Because the agent can see repository content and related context, it could accidentally leak sensitive information or be influenced by malicious input.

### Built-In Mitigations for Sensitive Information

- Internet access is restricted through the cloud-agent firewall
- Sensitive data should stay in GitHub Actions variables or secrets when the agent should not access it directly

### Operational Guidance for Sensitive Information

- Store secrets outside the agent’s accessible context unless the agent truly needs them
- Review any MCP server or external tool access carefully
- Restrict the repositories and organizations where the agent can operate

## 4. AI Prompts Can Be Vulnerable to Injection

Issues and comments can contain hidden or misleading instructions meant to steer the agent.

### Built-In Mitigations for Prompt Injection

- Hidden characters are filtered before user input is passed to the agent

### Operational Guidance for Prompt Injection

- Treat untrusted issue and PR text as potentially adversarial
- Keep prompt-sensitive workflows narrow and explicit
- Prefer task-specific agent instructions over generic prompts

## 5. Administrators Can Lose Sight of Agents’ Work

Agent activity needs to be traceable for review, audit, and rollback.

### Built-In Mitigations for Auditability

- Commits are authored by Copilot and co-authored by the initiating developer
- Commits are signed and appear as verified on GitHub
- Session logs and audit log events are available to administrators
- Commit messages include a link to the session logs

### Operational Guidance for Auditability

- Keep audit logs available to the teams that need them
- Use session logs during code review and incident response
- Adopt naming and branching conventions that make agent activity easy to spot

## Quick Mitigation Checklist

- [ ] Code scanning and secret scanning stay enabled
- [ ] Branch protections and required reviews are in place
- [ ] Rulesets are updated for repositories where cloud agent can operate
- [ ] Sensitive files are protected with CODEOWNERS
- [ ] Secrets are kept out of the agent’s accessible context when possible
- [ ] External tools and MCP servers are reviewed before use
- [ ] Session logs are available for review and audit

## References

- [Official GitHub Docs page](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/risks-and-mitigations)
- [Tracking GitHub Copilot's sessions](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/track-copilot-sessions)
- [Configuring settings for GitHub Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/configuring-agent-settings)
- [Customizing or disabling the firewall for GitHub Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-firewall)
