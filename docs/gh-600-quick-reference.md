# GH-600 Quick Reference Cheat Sheet

**Last-minute review before the test - 10 minute read**

---

## Core Concepts (MUST KNOW)

### 1. Agentic AI Definition
- **Not:** Chatbot that answers questions
- **Is:** Autonomous system that plans → acts → evaluates within guardrails
- **Key:** Uses GitHub as both system of record AND control plane

### 2. Plan → Act → Evaluate (The Loop)
```
PLAN:     Analyze → Create human-readable plan → Post for review
ACT:      Execute based on approved plan → Record all actions
EVALUATE: Verify success → Iterate if needed → Update GitHub
```

### 3. 5 Critical Boundaries
1. **Repository** - Which repos can agent access?
2. **Branch** - Which branches can agent modify?
3. **Files** - Which files can agent edit?
4. **Permissions** - What GitHub actions allowed?
5. **Time** - When can agent run?

### 4. SDLC Stage Ownership
| Stage | Agent Can | Agent CANNOT |
|-------|-----------|-------------|
| Planning | Analyze, estimate, categorize | Make prioritization decisions |
| Implementation | Write code, fix bugs | Design architecture |
| Validation | Run tests, scan security | Approve code |
| Deployment | Trigger non-prod, monitor | Approve prod deploy |

### 5. Success Criteria Template
```yaml
INPUTS:         What triggers the agent?
OUTPUTS:        What does it produce?
SUCCESS:        How do you measure success? (quantifiable)
FAILURE:        What means it didn't work?
CONSTRAINTS:    What is it NOT allowed to do?
ESCALATION:     When to ask for human help?
```

---

## Governance Toolkit

### Branch Protection + Status Checks
```yaml
# Prevents agent from merging without safety gates
- Require reviews: 1 human
- Status checks: ✅ tests, security-scan, coverage>80%
- CODEOWNERS: Yes (domain experts review)
- Branches up to date: Yes
```

### Environments (Secrets Boundary)
```yaml
# agent-sandbox environment: Limited secrets
# production environment: Requires approval + special secrets
# Effect: Agent can't access payment/DB secrets
```

### MCP Allow List (Tool Access)
```yaml
# ✅ GitHub MCP (all tools)
# ✅ Docker MCP (specific: run_container, list_images)
# ❌ AWS MCP (blocked entirely)
# ❌ Git repos (specific: pull only, not push)
```

### CODEOWNERS (Approval Routing)
```
# .github/CODEOWNERS
* @senior-dev                    # Default owner
/src/core/ @architecture-team    # Specialized owner
/tests/ @qa-team
/infra/ @devops-team

# If agent PR touches /src/core/, architecture-team must approve
```

---

## GitHub Actions Patterns

### Job Outputs (Pass Data Between Jobs)
```yaml
jobs:
  job1:
    outputs:
      result: ${{ steps.step1.outputs.result }}
    steps:
      - id: step1
        run: echo "result=success" >> $GITHUB_OUTPUT

  job2:
    needs: job1
    steps:
      - run: echo "Previous job returned: ${{ needs.job1.outputs.result }}"
```

### Conditional Execution
```yaml
- if: success()      # Only if all previous steps passed
- if: failure()      # Only if any previous step failed  
- if: always()       # Always run (cleanup on failure)
- if: cancelled()    # If workflow was cancelled
```

### Timeout Protection
```yaml
jobs:
  task:
    timeout-minutes: 10  # Job max 10 min
    steps:
      - timeout-minutes: 5   # Step max 5 min
        run: ./long-task.sh
```

### Approval Gate
```yaml
environment: production  # GitHub UI pauses here
# Required approvers review + approve before continuing
```

### Permissions Model
```yaml
permissions:
  contents: read              # Can read, NOT write commits
  pull-requests: write        # Can write PR comments
  # What's not listed = no access
```

---

## MCP Basics

### What is MCP?
- **Model Context Protocol** = standardized tool broker
- Agents discover & call external tools via MCP
- MCP servers expose capabilities
- Organizations maintain allow lists

### MCP Flow
```
Agent → "What tools available?" 
→ MCP Registry → [GitHub MCP, Docker MCP, ...]
Agent → "Call GitHub MCP: get_pr_details()"
→ GitHub MCP Server → API call → Response
```

### MCP Allow List Example
```yaml
allowed_servers:
  - github-mcp
    tools:
      - get_issue
      - create_pr
      - add_label
      # NOT: delete_repository

  - docker-mcp
    tools:
      - run_container
      - list_images
      # NOT: push_to_registry
```

---

## Common Mistakes (Anti-Patterns)

| ❌ WRONG | ✅ RIGHT |
|--------|---------|
| Agent auto-merges PRs without review | All agent PRs require human review |
| Agent has full repository access | Agent has minimal required permissions |
| No logging of agent decisions | Complete audit trail in GitHub |
| Agent can retry indefinitely | Timeout + max-attempts limits |
| Skip tests for speed | All tests must pass before merge |
| No escalation path | Clear escalation when agent stuck |
| Agent modifies .github/workflows | Workflows are forbidden from agent |
| Trust agent not to abuse tools | Use allow lists to restrict tools |
| Deploy to prod without approval | Approval gate on prod environment |
| No rollback capability | Rollback SHAs saved, tested |

---

## Traceability Requirements (The "Six Ws")

**Every agent action must answer:**
1. **WHO:** Which agent? (Service account identity)
2. **WHAT:** What changed? (Commit diff)
3. **WHEN:** Timestamp? (Commit time)
4. **WHERE:** Repository/branch/files? (GitHub path)
5. **WHY:** Reason for change? (Linked issue)
6. **HOW:** How did agent decide? (Decision log)

**Implementation:** GitHub commit → PR → Issue → Comments = audit trail

---

## Risk Mitigation Checklist

| Risk | Mitigation |
|------|-----------|
| **Hallucination** | Human code review required |
| **Infinite Loops** | Timeout + max-iterations |
| **Privilege Escalation** | Minimal permissions, environment scoping |
| **Silent Failures** | Comprehensive logging + alerting |
| **Scope Creep** | Branch/file/permission boundaries |
| **Dependency Poisoning** | Security scanning, allowlist dependencies |
| **Race Conditions** | Sequential execution (needs:), branch protection |
| **Cost Runaway** | Rate limiting, cost per execution tracking |

---

## Test Question Patterns

### Pattern 1: "What's the best way to..."
→ Look for **governance** and **safety** (not speed)

### Pattern 2: "What separates agentic AI from..."
→ **Autonomous + plan→act→evaluate + GitHub integrated**

### Pattern 3: "Which is NOT a requirement..."
→ Trick question - find the one that isn't critical

### Pattern 4: "Scenario: Agent tries to..."
→ Identify the **boundary violation** and **how to prevent**

### Pattern 5: "How do you ensure..."
→ Usually about **governance patterns** or **GitHub features**

---

## GitHub Features for Agents

| Feature | Purpose |
|---------|---------|
| **Branch Protection** | Prevent bypass, require checks |
| **Status Checks** | Enforce testing/security |
| **CODEOWNERS** | Route approvals to right people |
| **Environments** | Scope secrets, require approval |
| **Rulesets** | Advanced enforcement (new) |
| **Webhooks** | Trigger agent on events |
| **GraphQL API** | Efficient complex queries |
| **Workflow Artifacts** | Save logs/state |

---

## Quick Workflow Template

```yaml
name: Agent Workflow Template

on:
  pull_request:
    branches: [main]

jobs:
  agent_task:
    runs-on: ubuntu-latest
    environment: agent-sandbox
    permissions:
      contents: read
      pull-requests: write
    timeout-minutes: 10
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Plan (Inspect)
        run: |
          echo "Planning task..."
          # Analysis, no actions yet
      
      - name: Act (Execute)
        run: |
          echo "Executing approved plan..."
          # Make changes
      
      - name: Evaluate (Verify)
        run: |
          echo "Verifying success..."
          # Run tests, verify
      
      - name: Log (Audit)
        if: always()
        run: |
          echo "timestamp=$(date -Iseconds)" >> $GITHUB_OUTPUT
          # Audit trail
```

---

## Key Distinctions

### MCP vs GitHub API
- **GitHub API:** Direct access to GitHub data (REST, GraphQL)
- **MCP:** Standardized tool protocol for any external service (GitHub, Docker, Cloud, etc.)

### Repository Scope vs File Scope
- **Repository:** Which repos agent can access at all
- **File:** Within repo, which files/paths agent can modify

### Branch Protection vs Environment Approval
- **Branch Protection:** Automated checks before merge (tests pass, reviews done)
- **Environment Approval:** Human must explicitly approve (pause + wait for human)

### Status Check vs Approval Gate
- **Status Check:** Automated verification (pass/fail, no human)
- **Approval Gate:** Human decision required (approve/reject)

### Rate Limiting vs Timeout
- **Rate Limiting:** How many API calls per time window
- **Timeout:** How long before job is killed

---

## Study Tips for Test Day

1. **Understand WHY** - Not just what, but why governance matters
2. **Think Security First** - Most "best practice" questions reward safety over speed
3. **Trace the Audit Trail** - If you can audit it in GitHub, it's probably correct
4. **Look for Governance** - Correct answers usually involve GitHub features (branch protection, CODEOWNERS, environments)
5. **Recognize Anti-Patterns** - Questions often give you what NOT to do
6. **Human in the Loop** - Agents escalate to humans for decisions, never fully autonomous
7. **Test Everything** - Any answer that skips tests is wrong
8. **Boundaries Matter** - Execution boundaries (repository, branch, file) are constantly tested

---

## Last Minute Formula

```
Problem → Governance Solution
E.g.,
"Agent making bad decisions" 
→ "Add PR review requirement" (CODEOWNERS)
→ "Add test requirements" (Status Check)
→ "Add manual approval gate" (Environment)
```

---

## Passing Criteria

- ✅ Can explain Plan → Act → Evaluate in detail
- ✅ Can design an agent task with I/O/success criteria
- ✅ Know GitHub governance features (branch protection, CODEOWNERS, environments, rulesets)
- ✅ Understand MCP and allow lists
- ✅ Can identify execution boundaries
- ✅ Know reliability patterns (retry, timeout, idempotency, rollback)
- ✅ Can spot anti-patterns (things agents shouldn't do)
- ✅ Understand audit/traceability requirements

**If you can do all 8 of these → You'll pass the test.**

