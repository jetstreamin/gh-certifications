# GH-600: Comprehensive Agentic AI Study Guide

**Target Modules:**
- Foundations of Agentic AI in GitHub (900 XP)
- Designing Agent Architecture and SDLC Integration (1000 XP)  
- Tooling, MCP, and Agent Execution Environments (800 XP)

**Total XP: 2700 | Total Time: 120 minutes**

---

## MODULE 1: FOUNDATIONS OF AGENTIC AI IN GITHUB

### 1.1 Agentic AI vs. AI Assistants

**Key Distinction:**

| Aspect | AI Assistant | Agentic AI |
|--------|-------------|-----------|
| **Primary Role** | Reactive responder | Autonomous planner & executor |
| **Trigger** | Human asks questions | Event-driven (code changes, issues, schedules) |
| **Decision Making** | Provides options to human | Makes decisions and takes actions autonomously |
| **Iteration** | Single response cycle | Multi-step cycles (plan → act → evaluate) |
| **SDLC Integration** | Helps with specific tasks | Integrated into workflows as active participant |
| **GitHub Role** | Code suggestions, chat | Can create PRs, merge, deploy, run tests |
| **Governance** | Requires human approval for all outputs | Can act within defined guardrails/policies |

**Critical Insight:** Agents are not just smarter assistants—they are **autonomous workflow participants** with defined responsibilities, decision boundaries, and evaluation criteria.

### 1.2 The Agent Lifecycle: Plan → Act → Evaluate

This is the **core loop** for all agentic AI systems.

#### Phase 1: PLAN
- Agent analyzes the current state (issue, PR, code change, etc.)
- Decomposes work into subtasks
- Determines required tools/APIs
- Creates a reasoning trace (human-readable plan)
- **Key: Plan must be inspectable and reviewable before execution**

#### Phase 2: ACT
- Agent executes planned tasks sequentially
- Calls appropriate APIs, tools, or runs code
- Records all actions in GitHub (commits, comments, PR descriptions)
- Handles partial failures with graceful degradation
- **Key: All actions must be auditable in GitHub**

#### Phase 3: EVALUATE
- Agent or human assesses outcomes against success criteria
- Identifies blockers and adjustments needed
- Decides to iterate, escalate, or finalize
- Updates issue/PR with results
- **Key: Evaluation feeds back into next planning cycle**

**Example Loop in Code Review:**
1. **Plan:** Analyze failing tests → identify root cause → determine fix strategy
2. **Act:** Modify code → run tests → commit changes → create PR
3. **Evaluate:** Review test results → check code quality → request human review if needed

### 1.3 GitHub as System of Record and Control Plane

#### System of Record
GitHub is the **authoritative source** of:
- Agent decisions and reasoning (logged in issues/PRs)
- Actions taken (commits, branches, workflows)
- Timeline and audit trail
- Success criteria and results

#### Control Plane
GitHub is where **governance is enforced**:
- **Branch protection rules** control which agents can merge
- **Required checks** (status checks, reviews) gate agent actions
- **CODEOWNERS** define approval paths
- **Environments** provide execution boundaries
- **Rulesets** enforce organizational standards
- **Secrets management** restricts agent access

**Why This Matters:** All agent activity must be traceable through GitHub. You cannot run agents in separate systems without GitHub observability.

### 1.4 Responsibilities, Risks, Anti-Patterns, and Traceability

#### Agent Responsibilities Framework

**Clear Ownership Requires:**
- ✅ Explicit input requirements (what triggers the agent?)
- ✅ Defined output requirements (what does success look like?)
- ✅ Success criteria (quantifiable metrics)
- ✅ Failure handling strategy (what if the agent gets stuck?)
- ✅ Human escalation path (when to ask for help)

#### Common Risks

| Risk | Mitigation |
|------|-----------|
| **Hallucination** | Agents generating false/misleading code | Require human review of all code changes |
| **Infinite Loops** | Agents stuck in plan/act/evaluate cycle | Set max iteration limits; implement timeout |
| **Privilege Escalation** | Agents obtaining higher permissions than intended | Use environment-specific secrets; rotate regularly |
| **Silent Failures** | Agent fails but doesn't alert humans | Implement comprehensive logging; set up alerts |
| **Scope Creep** | Agent taking actions outside defined boundaries | Use branch restrictions, environment limits |
| **Dependency Poisoning** | Agent installing/using malicious packages | Implement security scanning; allowlist dependencies |

#### Anti-Patterns (Don't Do This)

| Anti-Pattern | Why It's Bad | Better Approach |
|-------------|------------|-----------------|
| Agents auto-merging to main without review | No human oversight of changes | Require PR reviews; use status checks |
| Agents with full repository access | Catastrophic if compromised | Minimize agent permissions; use environments |
| No logging of agent reasoning | Impossible to debug failures | Log all decisions to GitHub issues/PRs |
| Synchronous agent waiting for user input | Agent blocks other workflows | Use async patterns; agent leaves comment + waits |
| One agent doing everything | Single point of failure; hard to test | Compose agents with specific responsibilities |

#### Traceability Requirements

**Every agent action must answer:**
1. **WHO:** Which agent took the action? (GitHub identity)
2. **WHAT:** What specific action was taken? (commit, PR, comment, etc.)
3. **WHEN:** When did it happen? (timestamp in GitHub)
4. **WHERE:** Where did it happen? (repository, branch, workflow)
5. **WHY:** What was the reasoning? (linked to issue/plan)
6. **HOW:** How did it make the decision? (decision log)

**Implementation:** Use GitHub workflow artifacts, job summaries, and commit messages to document this.

### 1.5 The Contributor Model for Agent-Generated Work

#### What is the Contributor Model?

The **contributor model** frames agents as contributors to a project, not as special entities. This means:
- Agents follow the same SDLC workflow as human developers
- Agent PRs undergo the same review/approval process
- Agents can be subject to CODEOWNERS approval
- Agent commits are attributed to the agent (service account)
- Agent contributions are measured and tracked

#### Key Principles

**1. Ownership & Attribution**
- Agent commits are signed with the agent's GitHub identity (service account)
- Agent PRs are authored by the agent, not the human who triggered it
- This enables audit trails and role-based permissions

**2. Review & Approval**
- All agent PRs require human review (preferably domain experts)
- CODEOWNERS rules apply to agent PRs just like human PRs
- Status checks (tests, security scans, linters) gate all PRs

**3. Consistency**
- Agents follow the project's code standards (linting, formatting, naming conventions)
- Agents use the project's patterns and frameworks
- Agents document their changes like humans do

**4. Accountability**
- Humans remain ultimately responsible for what agents do
- The human who triggered the agent is accountable for the trigger decision
- The reviewer is accountable for approving/rejecting agent work

#### Practical Example

**Scenario:** Agent is fixing failing tests

| Activity | Actor | Traceability |
|----------|-------|-------------|
| Human creates issue: "Fix test failures" | Human | GitHub issue #42 |
| Agent analyzes failures | Agent (service account) | Linked to issue #42 |
| Agent creates PR with fixes | Agent | PR #99, authored by `@bot-agent` |
| Human reviews PR for correctness | Human | Comment + approval on PR #99 |
| Status checks (tests) pass | GitHub Actions | Workflow run linked to PR |
| Agent merges PR | Agent | Merge commit with agent identity |
| Monitoring detects issue | Human + Agent | GitHub issue #100 opened by agent |

---

## MODULE 2: DESIGNING AGENT ARCHITECTURE AND SDLC INTEGRATION

### 2.1 Mapping Agent Responsibilities to SDLC Stages

The SDLC has four main stages, and agents can own specific responsibilities at each stage.

#### STAGE 1: PLANNING
**What Happens:** Define what to build, estimate effort, prioritize work

**Agent Responsibilities:**
- ✅ Analyzing issue descriptions for clarity and completeness
- ✅ Labeling and categorizing issues automatically
- ✅ Suggesting story point estimates using historical data
- ✅ Creating acceptance criteria from requirements
- ✅ Identifying dependencies between issues
- ❌ Making final prioritization decisions (humans decide business value)

**Architectural Boundary:** Agent can provide analysis and recommendations but cannot override human prioritization.

#### STAGE 2: IMPLEMENTATION
**What Happens:** Write code, create branches, commit changes

**Agent Responsibilities:**
- ✅ Implementing features based on well-defined requirements
- ✅ Writing unit tests alongside code
- ✅ Handling bug fixes from failing tests
- ✅ Refactoring code for maintainability
- ✅ Generating documentation
- ❌ Making architectural decisions (humans design the system)

**Architectural Boundary:** Agent works within an established architecture; cannot make design decisions.

#### STAGE 3: VALIDATION
**What Happens:** Test, review, verify code quality

**Agent Responsibilities:**
- ✅ Running automated tests (unit, integration, security)
- ✅ Performing static code analysis (linting, type checking)
- ✅ Identifying test coverage gaps and suggesting improvements
- ✅ Generating test reports and summaries
- ✅ Suggesting code improvements based on patterns
- ❌ Approving code changes (humans responsible for validation)

**Architectural Boundary:** Agent can report findings but humans make approval decisions.

#### STAGE 4: DEPLOYMENT
**What Happens:** Release code to production, monitor, handle incidents

**Agent Responsibilities:**
- ✅ Triggering deployment workflows
- ✅ Monitoring health metrics and logs
- ✅ Creating incidents when anomalies detected
- ✅ Attempting automated remediation (if pre-approved)
- ✅ Rolling back if automated remediation fails
- ❌ Deciding when to deploy to production (humans own release decisions)

**Architectural Boundary:** Agent can deploy to non-prod environments; prod deploys require human approval.

### 2.2 Defining Structured Agent Tasks

Every agent task must have clear, explicit boundaries.

#### Required Components

**1. INPUTS**
- What data/signals trigger the agent?
- What information does the agent need to work?
- Where does the agent get this information?

*Example for PR review agent:*
```yaml
Trigger: Pull request opened
Inputs:
  - PR title and description
  - Changed files and diffs
  - Test results from CI
  - Repository's code standards (linting rules, test coverage threshold)
  - Any linked issues
```

**2. OUTPUTS**
- What does the agent produce?
- Where are outputs stored?
- In what format?

*Example for PR review agent:*
```yaml
Outputs:
  - Review comments on PR (suggestions, concerns)
  - Approval or request changes
  - Generated test report
  - Performance impact analysis
  - Security scan results
```

**3. SUCCESS CRITERIA**
- How do we know the agent succeeded?
- What metrics matter?
- What are acceptable vs. unacceptable outcomes?

*Example for PR review agent:*
```yaml
Success Criteria:
  ✅ Review posted within 2 minutes
  ✅ All automated checks (linting, tests) pass
  ✅ Code coverage doesn't decrease
  ✅ No security vulnerabilities introduced
  ✅ Human reviewer feels informed by agent analysis
  
Failure Criteria:
  ❌ Agent unable to parse PR changes
  ❌ Agent suggests changes that break tests
  ❌ Agent takes > 5 minutes to respond
  ❌ Agent misses obvious bugs
```

**4. CONTEXT & CONSTRAINTS**
- What is the agent NOT allowed to do?
- What are resource limits?
- What environments can the agent access?

*Example for PR review agent:*
```yaml
Constraints:
  - Cannot approve PRs directly (requires human review)
  - Cannot merge PRs
  - Only runs on PRs in this repository
  - Maximum 5 minute execution time
  - Cannot modify .github/workflows/ files
  - Cannot access production secrets
```

### 2.3 Separating Planning, Reasoning, and Execution

This is crucial for **inspectability and reliability**.

#### WHY SEPARATION MATTERS

If planning/reasoning/execution are entangled, it's impossible to:
- Debug why an agent made a decision
- Audit the reasoning trail
- Allow humans to intervene before execution
- Replay/verify decisions

#### THE SEPARATION PRINCIPLE

```
┌──────────────────────────────────────────────────────────┐
│ PLANNING PHASE                                           │
├──────────────────────────────────────────────────────────┤
│ Input: Current state (failing test, code review request) │
│ Process: Analyze, decompose into steps                   │
│ Output: Human-readable plan                              │
│                                                          │
│ Plan posted to GitHub issue for human review             │
│ Human can comment, suggest changes, or approve           │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ REASONING PHASE                                          │
├──────────────────────────────────────────────────────────┤
│ Input: Approved plan                                     │
│ Process: Determine specific actions, tool calls          │
│ Output: Step-by-step reasoning log                       │
│                                                          │
│ Reasoning logged but not yet executed                    │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ EXECUTION PHASE                                          │
├──────────────────────────────────────────────────────────┤
│ Input: Reasoning from Phase 2                            │
│ Process: Execute actions, handle failures                │
│ Output: Results and status updates                       │
│                                                          │
│ All actions are atomic, logged, and auditable            │
└──────────────────────────────────────────────────────────┘
```

#### Practical Implementation in GitHub Actions

```yaml
name: Agent Workflow - Fixed Separation

on: [issue_opened]

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - name: Analyze Issue
        id: analyze
        run: |
          # Parse issue description, extract requirements
          # Generate step-by-step plan
          echo "plan=$PLAN" >> $GITHUB_OUTPUT
      
      - name: Post Plan for Review
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: `## Agent Plan\n${steps.analyze.outputs.plan}`
            })
    outputs:
      plan: ${{ steps.analyze.outputs.plan }}

  reason:
    needs: plan
    runs-on: ubuntu-latest
    steps:
      - name: Generate Reasoning
        id: reason
        run: |
          # Based on plan from previous job
          # Generate specific actions/tool calls
          echo "reasoning=$REASONING" >> $GITHUB_OUTPUT
      
      - name: Post Reasoning
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: `## Reasoning Log\n${steps.reason.outputs.reasoning}`
            })
    outputs:
      reasoning: ${{ steps.reason.outputs.reasoning }}

  execute:
    needs: reason
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Execute Plan
        run: |
          # Execute actions from reasoning
          # All actions logged and auditable
          
      - name: Post Results
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: `## Execution Results\n✅ Complete`
            })
```

### 2.4 Pull Request Governance with Templates, Checks, CODEOWNERS, and Rules

This is how you **enforce** agent behavior.

#### COMPONENT 1: PR TEMPLATES

Creates a standard structure that agents must follow.

```markdown
# .github/pull_request_template.md

## Description
[Agent should fill this automatically from the linked issue]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Refactoring

## Related Issue
Fixes #[issue number]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project standards
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings introduced
```

#### COMPONENT 2: BRANCH PROTECTION RULES

```yaml
# Via GitHub UI or terraform

Branch: main
Protection Rules:
  - Require pull request reviews: 1
  - Require status checks to pass:
      * tests (unit, integration)
      * security-scan
      * code-coverage (>80%)
  - Require branches to be up to date
  - Allow force pushes: false
  - Allow deletions: false
  
# This means agent PRs CANNOT bypass these checks
# Agent must fix failing tests before merge
```

#### COMPONENT 3: CODEOWNERS

```yaml
# .github/CODEOWNERS

# Default owner
* @senior-developer

# Specific paths
/src/core/ @architecture-team
/src/tests/ @qa-team
/docs/ @technical-writer
/infra/ @devops-team
```

**Effect on Agents:** If an agent creates a PR modifying `/src/core/`, the architecture team must review and approve before merge. Agent cannot bypass this.

#### COMPONENT 4: RULESETS (New GitHub Feature)

More flexible than branch protection.

```yaml
# Ruleset for agent activity

Name: Agent Safety Guardrails
Target: main branch
Enforcement: Active

Rules:
  - Commit Signature:
      Required: true  # Agent commits must be signed
  
  - Pull Requests:
      DismissStaleReviews: false
      RequiredApprovingReviewCount: 1
      CodeOwnersReview: true
  
  - Status Checks:
      Required:
        - build
        - test
        - security-scan
  
  - Restrictions:
      AllowedActors:
        - agent-service-account
        - senior-developers
```

### 2.5 Reliable Workflows: Outputs, Contexts, Triggers, Cross-Job Handoffs

#### OUTPUTS

Structured data passed between workflow jobs.

```yaml
jobs:
  analyze:
    runs-on: ubuntu-latest
    outputs:
      issues_found: ${{ steps.scan.outputs.count }}
      severity: ${{ steps.scan.outputs.max_severity }}
    steps:
      - name: Scan Code
        id: scan
        run: |
          # Run security scan
          echo "count=5" >> $GITHUB_OUTPUT
          echo "max_severity=HIGH" >> $GITHUB_OUTPUT

  fix:
    needs: analyze
    if: needs.analyze.outputs.severity == 'HIGH'
    runs-on: ubuntu-latest
    steps:
      - name: Apply Fixes
        run: |
          # Use outputs from previous job
          echo "Found ${{ needs.analyze.outputs.issues_found }} issues"
```

#### CONTEXTS

Variables available in workflows.

```yaml
jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Post Result
        run: |
          # GitHub context
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref }}"
          echo "Actor: ${{ github.actor }}"
          
          # Runner context
          echo "OS: ${{ runner.os }}"
          
          # Env context
          echo "Custom Var: ${{ env.MY_VAR }}"
```

#### TRIGGERS (Events)

Define **what starts** the agent workflow.

```yaml
on:
  # Trigger on PR events
  pull_request:
    types: [opened, synchronize]
  
  # Trigger on issue events
  issues:
    types: [opened, labeled]
  
  # Trigger on schedule
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  
  # Trigger on workflow dispatch (manual)
  workflow_dispatch:
    inputs:
      issue_number:
        description: 'Issue to process'
        required: true
  
  # Trigger on repository event
  push:
    branches: [main]
    paths:
      - 'src/**'
```

**Key:** Be specific about triggers. A badly configured trigger = agent doing wrong thing at wrong time.

#### CROSS-JOB HANDOFFS

How agent jobs coordinate and pass information.

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
    if: needs.job1.outputs.result == 'success'
    steps:
      - run: echo "Job1 succeeded, continuing..."

  job3:
    needs: [job1, job2]
    if: always()  # Run even if job2 fails
    steps:
      - run: echo "Cleanup step"
```

**Idempotency:** Each job should be idempotent (safe to retry without side effects).

### 2.6 Observability, Tool Governance, Secrets Boundaries, Hooks, and Reliability

#### OBSERVABILITY

Make agent activity visible and auditable.

**What to Log:**
- Agent decisions and reasoning
- Actions taken (API calls, commits, comments)
- Success/failure status
- Timing and performance metrics
- Any exceptions or errors

**Where to Log:**
```yaml
jobs:
  agent_task:
    runs-on: ubuntu-latest
    steps:
      - name: Execute Task
        run: |
          # Log to GitHub Actions output
          echo "DEBUG: Starting analysis..."
          echo "INFO: Found 10 issues to fix"
          echo "ERROR: Unable to parse config" >&2
      
      - name: Capture Logs
        if: always()
        run: |
          # Upload to artifact for later inspection
          tar czf logs.tar.gz /var/log/agent/
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: agent-logs
          path: logs.tar.gz

      - name: Post Summary
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              body: '## Agent Execution Summary\n- Duration: 120s\n- Status: ✅ Success'
            })
```

#### TOOL GOVERNANCE

Control **what tools** agents can use.

```yaml
jobs:
  restricted_task:
    runs-on: ubuntu-latest
    permissions:
      contents: read          # Can read repo
      pull-requests: write    # Can write PR comments
      # Notably: NOT write to contents (can't commit)
      # Notably: NOT admin
    steps:
      - name: Safe Operation
        run: |
          # This job CAN:
          # - Read files
          # - Post comments on PRs
          
          # This job CANNOT:
          # - Create commits
          # - Delete branches
          # - Access secrets
```

**Tool Allowlists:**
```yaml
jobs:
  controlled_agent:
    runs-on: ubuntu-latest
    env:
      ALLOWED_TOOLS: |
        github_api
        git_operations
        code_formatter
      FORBIDDEN_TOOLS: |
        shell_execution
        file_deletion
        secret_access
```

#### SECRETS BOUNDARIES

Restrict agent access to secrets.

```yaml
jobs:
  restricted_secrets:
    runs-on: ubuntu-latest
    environment: agent-sandbox
    steps:
      - name: Access Limited Secrets
        run: |
          # environment: agent-sandbox exposes only:
          # - AGENT_GITHUB_TOKEN (limited permissions)
          # - AGENT_API_KEY (read-only)
          
          # Does NOT expose:
          # - PRODUCTION_DATABASE_PASSWORD
          # - STRIPE_SECRET_KEY
          # - AWS_ACCESS_KEY_ID
```

**How to Set Up Secrets Boundaries:**
1. Create a GitHub Environment (e.g., "agent-sandbox")
2. Add only necessary secrets to that environment
3. Configure deployment branches/reviewers if needed
4. Reference environment in workflow: `environment: agent-sandbox`

#### HOOKS

Trigger custom logic before/after agent actions.

```yaml
# Pre-execution hook
- name: Pre-Execution Validation
  run: |
    # Verify agent has correct permissions
    # Check rate limits
    # Verify dependencies are available
    # If any check fails, exit with error

# Post-execution hook
- name: Post-Execution Cleanup
  if: always()
  run: |
    # Clean up temporary files
    # Generate reports
    # Send notifications
    # Update metrics
```

#### RELIABILITY PATTERNS

Make workflows resilient to failures.

```yaml
jobs:
  reliable_agent:
    runs-on: ubuntu-latest
    steps:
      # Pattern 1: Retry on Failure
      - name: Task with Retry
        uses: nick-invision/retry@v2
        with:
          timeout_minutes: 5
          max_attempts: 3
          retry_on: any
          command: ./run-agent-task.sh

      # Pattern 2: Continue on Error
      - name: Non-Critical Task
        continue-on-error: true
        run: ./optional-task.sh

      # Pattern 3: Conditional Execution
      - name: Cleanup Only on Success
        if: success()
        run: ./cleanup.sh

      # Pattern 4: Timeout Protection
      - name: Time-Limited Task
        timeout-minutes: 10
        run: ./important-task.sh

      # Pattern 5: Artifact Preservation
      - name: Save State
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: agent-state
          path: .agent/state/
          retention-days: 30
```

---

## MODULE 3: TOOLING, MCP, AND AGENT EXECUTION ENVIRONMENTS

### 3.1 How Agents Interact with GitHub APIs and Workflows

#### GitHub APIs Agents Use

**1. REST API**
```python
# Agent example: Reading PR information
import requests

headers = {
    'Authorization': f'Bearer {GITHUB_TOKEN}',
    'Accept': 'application/vnd.github+json'
}

# Get PR details
response = requests.get(
    'https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER',
    headers=headers
)
pr = response.json()

# Agent logic: analyze pr['diff_url'], pr['files'], pr['status']
```

**Common Agent API Calls:**
- `GET /repos/{owner}/{repo}/issues/{issue_number}` - Read issue details
- `POST /repos/{owner}/{repo}/issues/{issue_number}/comments` - Post comments
- `GET /repos/{owner}/{repo}/pulls/{pr_number}/files` - Get changed files
- `POST /repos/{owner}/{repo}/git/refs` - Create branches
- `POST /repos/{owner}/{repo}/pulls` - Create PRs
- `PUT /repos/{owner}/{repo}/pulls/{pr_number}/merge` - Merge PRs

**2. GraphQL API**
```graphql
# More efficient for complex queries
query GetPullRequestDetails {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      title
      author {
        login
      }
      files(first: 20) {
        edges {
          node {
            path
            additions
            deletions
          }
        }
      }
      reviews(last: 5) {
        edges {
          node {
            author { login }
            state
          }
        }
      }
    }
  }
}
```

**3. Webhooks**
```yaml
# When agent wants to be notified of events
event: pull_request
actions:
  - opened
  - synchronize
  - labeled

# GitHub sends webhook to agent's endpoint
# Agent processes webhook and takes action
```

#### Integration with Workflows

**Agent Pattern 1: Workflow-Triggered Agent**
```yaml
name: Code Review Agent

on:
  pull_request:
    types: [opened]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read
    steps:
      - uses: actions/checkout@v3
      
      - name: Analyze Code
        run: |
          # Agent code here
          # Uses ${{ github.event.pull_request }} context
          
      - name: Post Review
        uses: actions/github-script@v7
        with:
          script: |
            // Agent uses GitHub API via actions/github-script
            github.rest.pulls.createReview({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number,
              body: 'Review from agent...',
              event: 'COMMENT'
            })
```

**Agent Pattern 2: Issue-Triggered Agent**
```yaml
name: Triage Agent

on:
  issues:
    types: [opened, labeled]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: Analyze Issue
        run: |
          # Extract issue content
          ISSUE_TITLE="${{ github.event.issue.title }}"
          ISSUE_BODY="${{ github.event.issue.body }}"
          
          # Agent logic: parse, categorize, suggest labels
          
      - name: Apply Labels and Comment
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.addLabels({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              labels: ['needs-triage', 'severity-high']
            })
```

### 3.2 Model Context Protocol (MCP) Servers, Registries, and Allow Lists

#### What is MCP?

**MCP (Model Context Protocol)** is a protocol that allows agents to:
- Discover available tools
- Call external tools and services
- Manage context and resources
- Extend capabilities beyond native APIs

Think of it as a **standardized toolkit broker** between agents and external systems.

#### MCP Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Agent (Client)                                          │
│ - Sends requests for tool discovery                     │
│ - Calls tools via MCP protocol                          │
└────────────┬────────────────────────────────────────────┘
             │ MCP Protocol
             │ (JSON-RPC over stdio/HTTP)
┌────────────▼────────────────────────────────────────────┐
│ MCP Server Registry                                     │
│ - Maintains list of available MCP servers               │
│ - Handles server discovery                              │
│ - Enforces allow lists                                  │
└────────────┬────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────┐
│ MCP Servers (Tools)                                     │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐     │
│ │ GitHub MCP   │ │ Docker MCP   │ │ Cloud MCP    │     │
│ │ - list repos │ │ - run images │ │ - deploy app │     │
│ │ - read files │ │ - list containers     │ - scale   │     │
│ └──────────────┘ └──────────────┘ └──────────────┘     │
└─────────────────────────────────────────────────────────┘
```

#### MCP Server Example

```python
# mcp_github_server.py - MCP Server that wraps GitHub API

from mcp.server import Server
from mcp.types import Tool, TextContent

server = Server("github-tools")

@server.tool(name="get_issue", description="Get issue details")
def get_issue(owner: str, repo: str, issue_number: int) -> str:
    """Retrieve issue details from GitHub"""
    # Implementation: call GitHub REST API
    response = github_api.get(f"repos/{owner}/{repo}/issues/{issue_number}")
    return json.dumps(response.json())

@server.tool(name="create_pr", description="Create a pull request")
def create_pr(
    owner: str, 
    repo: str, 
    title: str, 
    body: str, 
    head: str, 
    base: str
) -> str:
    """Create a new pull request"""
    # Implementation: call GitHub REST API
    response = github_api.post(
        f"repos/{owner}/{repo}/pulls",
        json={"title": title, "body": body, "head": head, "base": base}
    )
    return json.dumps(response.json())

if __name__ == "__main__":
    server.run()
```

#### Agent Using MCP Server

```python
# agent.py - Agent that uses MCP servers

from mcp.client import connect_to_mcp_server

async def analyze_and_fix():
    # Connect to GitHub MCP Server
    async with connect_to_mcp_server("github-mcp") as github_client:
        # Discover available tools
        tools = await github_client.list_tools()
        # tools = ["get_issue", "create_pr", "list_branches", ...]
        
        # Call a tool
        issue = await github_client.call_tool(
            "get_issue",
            owner="myorg",
            repo="myrepo",
            issue_number=42
        )
        
        # Agent logic
        print(f"Issue: {issue['title']}")
        print(f"Assignee: {issue['assignee']}")
        
        # Call another tool
        pr = await github_client.call_tool(
            "create_pr",
            owner="myorg",
            repo="myrepo",
            title="Fix: " + issue['title'],
            body="Fixes #42",
            head="fix/issue-42",
            base="main"
        )
        
        print(f"Created PR #{pr['number']}")
```

#### MCP Registry

Centralized registry of available MCP servers.

```json
{
  "registry": "mcpservers.ai",
  "servers": [
    {
      "id": "github-mcp",
      "name": "GitHub Tools",
      "description": "Access GitHub API as MCP server",
      "version": "1.0.0",
      "endpoint": "github-mcp.mcpservers.ai",
      "tools": ["get_issue", "create_pr", "list_repos", ...]
    },
    {
      "id": "docker-mcp",
      "name": "Docker Tools",
      "description": "Control Docker containers",
      "version": "1.0.0",
      "endpoint": "docker-mcp.mcpservers.ai",
      "tools": ["run_container", "list_images", "push_image", ...]
    }
  ]
}
```

#### Allow Lists

Restrict which MCP servers agents can access.

```yaml
# agent-config.yaml

mcp_allow_list:
  enabled: true
  servers:
    - id: github-mcp
      allowed_tools:
        - get_issue
        - create_pr
        - add_label
      # Note: NOT including "delete_repository"
    
    - id: docker-mcp
      allowed_tools:
        - run_container
        - list_images
      # Note: NOT including "push_to_registry" (too dangerous)
  
  # Block these servers entirely
  blocked_servers:
    - aws-mcp  # AWS MCP not allowed for this agent
    - kubernetes-mcp  # K8s operations restricted

# Effect: Agent can only use pre-approved tools from pre-approved servers
```

### 3.3 Execution Context and Boundaries

Agents must operate within defined boundaries to ensure safety.

#### Boundary 1: REPOSITORY SCOPE

```yaml
# Agent can only operate in this repository

agent:
  name: "Code Review Agent"
  permissions:
    repository: "my-org/my-repo"  # Only this repo
    # Cannot access: my-org/other-repo, my-org/private-repo, etc.
```

#### Boundary 2: BRANCH SCOPE

```yaml
# Agent can only operate on certain branches

agent_branch_policy:
  read_access: "*"  # Can read all branches
  write_access:
    - "develop"
    - "staging"
    # Cannot write to: main, production, release-*
  merge_access:
    - "develop"
    # Cannot merge to main or production
```

#### Boundary 3: WORKFLOW SCOPE

```yaml
# Agent only runs within specific workflows

triggers:
  allowed:
    - pull_request
    - issues
  forbidden:
    - workflow_dispatch  # No manual triggers
    - schedule  # No automated scheduling
```

#### Boundary 4: FILE/PATH SCOPE

```yaml
# Agent can only modify certain files/paths

agent_file_policy:
  read_access: "**/*"  # Can read anything
  write_access:
    - "src/**"
    - "tests/**"
  forbidden_write:
    - ".github/workflows/**"  # Cannot modify workflows
    - "package.json"  # Cannot modify dependencies
    - "README.md"  # Cannot modify README
```

#### Boundary 5: TIME SCOPE

```yaml
# Agent operations restricted by time

agent_time_policy:
  allowed_hours: "09:00-17:00"  # Only during business hours
  allowed_days: ["Mon", "Tue", "Wed", "Thu", "Fri"]  # Weekdays only
  max_operations_per_day: 100
  max_operations_per_hour: 20
```

#### Boundary 6: PERMISSION SCOPE

```yaml
# GitHub Actions permissions model

permissions:
  contents: read          # Can read repo contents
  pull-requests: write    # Can write PR comments
  issues: read            # Can read issues
  # Missing: admin, deploy, secrets
```

#### Combining Boundaries

```yaml
# Realistic agent configuration

name: Safe PR Review Agent

on:
  pull_request:
    branches: [main]  # Only on main branch PRs
    paths:
      - 'src/**'      # Only when src changes
      - 'tests/**'    # Or tests change

jobs:
  review:
    runs-on: ubuntu-latest
    environment: agent-sandbox  # Limited secrets
    permissions:
      contents: read
      pull-requests: write
      # No write to contents, no admin
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Bounded Review
        run: |
          # This job is bounded by:
          # - Repository: this repo only
          # - Branch: main only (via trigger)
          # - Paths: src/ and tests/ only
          # - Workflow: pull_request trigger only
          # - Time: anytime (no time restriction here)
          # - Permissions: read contents, write PR comments
          # - Secrets: only those in agent-sandbox environment
```

### 3.4 Agent Execution Limits and Protections

#### LIMIT 1: TIMEOUT

Prevent infinite loops and runaway agents.

```yaml
jobs:
  agent_task:
    runs-on: ubuntu-latest
    timeout-minutes: 10  # Max 10 minutes per job
    
    steps:
      - name: Long-Running Task
        timeout-minutes: 5  # Max 5 minutes per step
        run: |
          # If this takes > 5 minutes, job is killed
          for i in {1..1000000}; do
            # Some long computation
            sleep 1
          done
```

#### LIMIT 2: RESOURCE LIMITS

Prevent resource exhaustion.

```yaml
# In job container
container:
  image: ubuntu:latest
  options: |
    --memory 2GB
    --cpus 1
    --memory-swap 2GB
```

#### LIMIT 3: RATE LIMITING

Prevent API abuse.

```python
# Agent-side rate limiting

from datetime import datetime, timedelta

class RateLimiter:
    def __init__(self, max_calls: int, window_seconds: int):
        self.max_calls = max_calls
        self.window_seconds = window_seconds
        self.calls = []
    
    def is_allowed(self) -> bool:
        now = datetime.now()
        # Remove old calls outside window
        self.calls = [
            call_time for call_time in self.calls
            if now - call_time < timedelta(seconds=self.window_seconds)
        ]
        
        if len(self.calls) < self.max_calls:
            self.calls.append(now)
            return True
        return False

# Usage
limiter = RateLimiter(max_calls=100, window_seconds=3600)  # 100 per hour

for issue in issues:
    if not limiter.is_allowed():
        print("Rate limit exceeded, stopping")
        break
    process_issue(issue)
```

#### PROTECTION 1: APPROVAL GATES

Require human approval before risky actions.

```yaml
jobs:
  deploy_to_prod:
    environment:
      name: production  # Requires approval to proceed
      url: https://myapp.prod.com
    steps:
      - name: Deploy
        run: ./deploy-to-production.sh
```

#### PROTECTION 2: STATUS CHECKS

Verify conditions before proceeding.

```yaml
- name: Pre-Execution Checks
  run: |
    # Check 1: All tests pass
    if ! npm test; then
      echo "Tests failed, aborting"
      exit 1
    fi
    
    # Check 2: No security vulnerabilities
    npm audit --audit-level=moderate
    if [ $? -ne 0 ]; then
      echo "Security issues detected, aborting"
      exit 1
    fi
    
    # Check 3: Code coverage threshold
    if [ $(npm run coverage | grep -oP 'Coverage: \K\d+') -lt 80 ]; then
      echo "Code coverage < 80%, aborting"
      exit 1
    fi
```

#### PROTECTION 3: AUDIT LOGGING

Record all agent actions.

```yaml
- name: Log Action
  run: |
    cat >> agent-audit.log << EOF
    {
      "timestamp": "$(date -Iseconds)",
      "action": "created_pull_request",
      "repository": "${{ github.repository }}",
      "branch": "${{ github.ref }}",
      "actor": "${{ github.actor }}",
      "pr_number": "${{ github.event.pull_request.number }}",
      "status": "success"
    }
    EOF

- name: Upload Audit Log
  uses: actions/upload-artifact@v3
  with:
    name: agent-audit-log
    path: agent-audit.log
```

#### PROTECTION 4: ROLLBACK CAPABILITY

Be able to undo agent actions.

```yaml
- name: Save Rollback Point
  run: |
    # Before making changes, save current state
    git commit -m "Rollback point before agent changes" --allow-empty
    ROLLBACK_SHA=$(git rev-parse HEAD)
    echo $ROLLBACK_SHA > .rollback-sha
    
    # Make changes...

- name: Rollback If Needed
  if: failure()
  run: |
    ROLLBACK_SHA=$(cat .rollback-sha)
    git reset --hard $ROLLBACK_SHA
    git push origin HEAD:${{ github.ref }} --force
```

---

## EXAM STRATEGY

### Focus Areas (Highest Probability on Test)

1. **Plan → Act → Evaluate Lifecycle** (10-15% of questions)
   - Able to identify which phase an agent is in
   - Understand why separation matters
   - Recognize when phase ordering is wrong

2. **GitHub as System of Record** (5-10%)
   - All agent activity traceable through GitHub
   - Using commits/PRs/issues as audit trail

3. **Defined Responsibilities** (15-20%)
   - Agent tasks with clear inputs, outputs, success criteria
   - SDLC stage mapping
   - What agents should/shouldn't do

4. **PR Governance** (10-15%)
   - Branch protection, status checks, CODEOWNERS
   - Enforcing agent behavior through rules

5. **MCP and Tool Governance** (10-15%)
   - What MCP is and why it matters
   - Allow lists and registries
   - Tool access control

6. **Execution Boundaries** (10-15%)
   - Repository, branch, file, permission scopes
   - Why boundaries matter

7. **Reliability Patterns** (10%)
   - Retry logic, idempotency, timeouts
   - Failure handling

### Question Types to Expect

**Type 1: Scenario-Based**
> "An agent keeps retrying the same failed operation indefinitely. Which is the best way to prevent this?"
> A) Add a timeout-minutes limit
> B) Add a max-attempts counter
> C) Delete the agent
> D) Disable the workflow

**Type 2: Definition**
> "What is the primary purpose of the PLAN phase in agent workflows?"
> A) Execute tools and APIs
> B) Create a human-readable step-by-step plan for human review
> C) Evaluate whether the plan worked
> D) Store results in GitHub

**Type 3: Best Practice**
> "You're designing an agent that deploys to production. Which governance pattern is most critical?"
> A) Run the agent on schedule
> B) Require human approval gate in the production environment
> C) Log agent actions to a file
> D) Use docker containers

**Type 4: Architecture**
> "An agent needs to read issue descriptions but NOT create new issues. How would you enforce this?"
> A) GitHub permissions: issues: read
> B) GitHub permissions: issues: write
> C) Create an MCP server with allow list
> D) Use branch protection rules

### Study Plan (Before Taking Real Test)

1. **Read all three modules end-to-end** (2 hours)
2. **Take the built-in knowledge checks** for each module
3. **Work through practice scenarios** in this guide
4. **Create flashcards** for key terms and concepts
5. **Review the anti-patterns section** (common wrong answers)
6. **Take the practice test** in this repository

---

## GLOSSARY

| Term | Definition |
|------|-----------|
| **Agentic AI** | Autonomous AI system that plans, acts, and evaluates within defined boundaries |
| **Assistant** | Reactive AI that responds to user queries but doesn't act autonomously |
| **Plan → Act → Evaluate** | Core agent lifecycle for decision-making |
| **System of Record** | GitHub as authoritative source of all agent activity and decisions |
| **Control Plane** | GitHub features (branch protection, rules, rulesets) that enforce agent behavior |
| **Contributor Model** | Framework treating agents as project contributors subject to same code review processes |
| **MCP Server** | Tool provider that exposes capabilities via Model Context Protocol |
| **Execution Boundary** | Limit on what an agent can access (repo, branch, files, permissions) |
| **Status Check** | GitHub CI check that must pass before PR can merge |
| **CODEOWNERS** | GitHub file that specifies who must review changes to specific paths |
| **Environment** | GitHub context with specific secrets and approval requirements |
| **Idempotency** | Property of operation that produces same result if run once or multiple times |
| **Rate Limiting** | Restriction on how many API calls agent can make in time window |
| **Audit Trail** | Complete log of all agent actions and decisions |
| **Rollback** | Ability to undo or revert agent changes |

