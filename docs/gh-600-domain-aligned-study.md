# GH-600 Domain-Aligned Study Guide

**Based on Official Exam Page: 6 Domains, 120 Minutes, $165 USD**

---

## Official Exam Domains (Weight Distribution)

| Domain | Weight | Topics |
|--------|--------|--------|
| 1. Prepare agent architecture and SDLC processes | 15–20% | Architecture design, SDLC integration, responsibilities |
| 2. Implement Tool Use and Environment Interaction | 20–25% | MCP, tools, GitHub APIs, execution environments |
| 3. Manage Memory, State, and Execution | 10–15% | Agent state management, context handling, execution flow |
| 4. Perform Evaluation, Error Analysis, and Tuning | 15–20% | Metrics, failure analysis, performance tuning, feedback loops |
| 5. Orchestrate Multi-Agent Coordination | 15–20% | Multi-agent workflows, synchronization, communication |
| 6. Implement Guardrails and Accountability | 10–15% | Safety controls, compliance, audit trails, governance |

**Total: 100% | Time: 120 minutes | Question Format: Interactive components included**

---

## DOMAIN 1: PREPARE AGENT ARCHITECTURE AND SDLC PROCESSES (15–20%)

**From Your Learning:** Modules 1 & 2 (Foundations + Architecture)

### 1.1 Agent Architecture Fundamentals
- **Agentic AI Definition:** Autonomous system operating in plan → act → evaluate loops
- **Key Distinction:** Agents vs Assistants
  - Assistants: Reactive, event-driven, single interaction
  - Agents: Autonomous, multi-step reasoning, integrated into SDLC

### 1.2 SDLC Process Integration
**Where agents fit in each stage:**

| SDLC Stage | Agent Responsibilities | Human Responsibilities |
|-----------|----------------------|----------------------|
| **Planning** | Analyze requirements, estimate effort, flag dependencies | Prioritize work, make business decisions |
| **Implementation** | Write code, fix bugs, run tests, generate docs | Design architecture, make technical decisions |
| **Validation** | Run automated tests, security scans, quality checks | Approve code changes, review logic |
| **Deployment** | Deploy to non-prod, monitor health, auto-remediate | Approve prod deployment, handle incidents |

### 1.3 Agent Task Definition
**Required Components for Every Agent:**
```yaml
Task:
  Inputs:        What triggers the agent?
  Outputs:       What does agent produce?
  Success:       Quantifiable success metrics
  Failure:       What constitutes failure?
  Scope:         What is IN-BOUNDS?
  Constraints:   What is OUT-OF-BOUNDS?
  Escalation:    When to ask human for help?
  Boundaries:    Execution limits (time, resources, permissions)
```

### 1.4 GitHub as System of Record and Control Plane
**System of Record:**
- All agent decisions logged in GitHub (commits, PRs, issues, comments)
- Traceability: WHO → WHAT → WHEN → WHERE → WHY → HOW
- Audit trail: Complete history of agent actions

**Control Plane:**
- Branch protection rules enforce quality gates
- Status checks verify automated tests pass
- CODEOWNERS route approvals to right people
- Environments scope secrets and require human approval
- Rulesets enforce organizational standards

### 1.5 Agent Responsibilities Framework
**What Agents SHOULD Do:**
- Execute well-defined tasks autonomously
- Gather and analyze information
- Propose solutions and flag issues
- Log decisions and reasoning
- Escalate when stuck or uncertain

**What Agents SHOULD NOT Do:**
- Make architectural decisions
- Override human approvals
- Access production secrets (unless explicitly allowed)
- Skip required tests or validations
- Operate outside defined boundaries

---

## DOMAIN 2: IMPLEMENT TOOL USE AND ENVIRONMENT INTERACTION (20–25%)

**From Your Learning:** Module 3 (Tooling, MCP, Execution Environments)

### 2.1 GitHub APIs for Agent Integration

**REST API**
```bash
# Get PR details
curl -H "Authorization: Bearer $TOKEN" \
  https://api.github.com/repos/OWNER/REPO/pulls/PR_NUM

# Create PR
curl -X POST -H "Authorization: Bearer $TOKEN" \
  https://api.github.com/repos/OWNER/REPO/pulls \
  -d '{"title":"...", "head":"...", "base":"..."}'

# Common agent operations:
- GET /issues/{issue_number}
- POST /issues/{issue_number}/comments
- GET /pulls/{pr_number}/files
- PUT /pulls/{pr_number}/merge
- POST /git/refs (create branches)
```

**GraphQL API** (More efficient)
```graphql
query GetPRAnalysis {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUM) {
      files(first: 20) {
        edges {
          node { path, additions, deletions }
        }
      }
      reviews { 
        edges {
          node { author { login }, state }
        }
      }
      statusCheckRollup {
        state
        contexts {
          context
          state
        }
      }
    }
  }
}
```

**Webhooks** (Event triggers)
```yaml
Events that trigger agent workflows:
- pull_request (opened, synchronize, labeled)
- issues (opened, edited, labeled)
- push (to specific branches/paths)
- workflow_run (from other workflows)
- repository_dispatch (manual/external triggers)
```

### 2.2 Model Context Protocol (MCP)

**What is MCP?**
- Standardized protocol for agents to discover and use tools
- Think of it as a "universal tool adapter"
- Enables extensibility without custom integration per tool

**MCP Architecture**
```
Agent (Client)
    ↓ (MCP Protocol)
MCP Registry (discovery)
    ↓
MCP Servers (GitHub, Docker, Cloud, Custom)
    ↓
External Systems (APIs, CLIs, services)
```

**Agent Using MCP Server:**
```python
async with connect_to_mcp("github-mcp") as github:
    # Discover available tools
    tools = await github.list_tools()
    # ["get_issue", "create_pr", "add_label", "list_branches"]
    
    # Call a tool
    issue = await github.call_tool("get_issue",
        owner="myorg",
        repo="myrepo",
        number=42
    )
    
    # Use the result
    print(f"Issue: {issue['title']}, Assignee: {issue['assignee']}")
```

### 2.3 MCP Allow Lists (Tool Governance)

**Purpose:** Control which tools agents can use

**Configuration:**
```yaml
allowed_mcp_servers:
  - id: github-mcp
    allowed_tools:
      - get_issue
      - create_pr
      - add_label
      # NOT: delete_repository (dangerous!)
  
  - id: docker-mcp
    allowed_tools:
      - run_container
      - list_images
      # NOT: push_to_registry (dangerous!)

blocked_servers:
  - aws-mcp          # Not available to this agent
  - production-mcp   # Blocked for safety
```

**Effect:** Agent can ONLY use pre-approved tools from pre-approved servers

### 2.4 GitHub Actions as Agent Runtime

**Basic Agent Workflow Structure:**
```yaml
name: Agent Workflow

on:
  pull_request:
    types: [opened]

jobs:
  agent_task:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    environment: agent-sandbox
    timeout-minutes: 10
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Plan Phase
        id: plan
        run: |
          # Analyze input, create plan
          echo "plan=..." >> $GITHUB_OUTPUT
      
      - name: Post Plan for Review
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              body: `Plan: ${{ steps.plan.outputs.plan }}`
            })
      
      - name: Execute Phase
        run: |
          # Execute approved plan
          ...
      
      - name: Evaluate Phase
        run: |
          # Verify success
          ...
```

### 2.5 Job Composition and Dependencies

**Using `needs:` for Sequential Execution:**
```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      config: ${{ steps.gen.outputs.config }}
    steps:
      - id: gen
        run: echo "config=ready" >> $GITHUB_OUTPUT

  process:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: echo "Using config: ${{ needs.setup.outputs.config }}"

  finalize:
    needs: [setup, process]
    runs-on: ubuntu-latest
    if: always()  # Run even if process failed
    steps:
      - run: echo "Cleanup..."
```

**Key Patterns:**
- `needs: job-name` - Wait for specific job
- `needs: [job1, job2]` - Wait for multiple jobs
- `outputs:` - Pass data between jobs
- `if: success()` / `if: failure()` / `if: always()` - Conditional execution

---

## DOMAIN 3: MANAGE MEMORY, STATE, AND EXECUTION (10–15%)

**Key Topic:** How agents maintain context across multiple invocations

### 3.1 Agent State Management

**Types of State:**

| State Type | Scope | Lifetime | Example |
|-----------|-------|----------|---------|
| **Execution State** | Single run | Job duration | Variables, computed values |
| **Workflow State** | Single workflow | Workflow duration | Artifacts, outputs between jobs |
| **Repository State** | Repository | Long-term | Files committed, branches |
| **Memory State** | User/Agent | Persistent | Copilot memory, learned patterns |

### 3.2 Passing State Between Jobs

**Via Outputs:**
```yaml
jobs:
  analyze:
    outputs:
      findings: ${{ steps.scan.outputs.findings }}
      risk_level: ${{ steps.scan.outputs.risk_level }}
    steps:
      - id: scan
        run: |
          # Run security scan
          echo "findings=5 vulns found" >> $GITHUB_OUTPUT
          echo "risk_level=HIGH" >> $GITHUB_OUTPUT

  remediate:
    needs: analyze
    if: needs.analyze.outputs.risk_level == 'HIGH'
    steps:
      - run: |
          echo "Risk is HIGH, applying fixes"
          echo "Findings: ${{ needs.analyze.outputs.findings }}"
```

### 3.3 Persisting State with Artifacts

**Save execution artifacts for later inspection:**
```yaml
- name: Run Agent Task
  run: |
    # Generate output files
    ./agent-task.sh > output.log
    mkdir -p results
    python3 analyze.py > results/analysis.json

- name: Upload Artifacts
  uses: actions/upload-artifact@v3
  with:
    name: agent-results
    path: |
      output.log
      results/
    retention-days: 30  # Keep for 30 days

- name: Download Previous Artifacts
  uses: actions/download-artifact@v3
  with:
    name: agent-results
    path: ./previous-run/
```

### 3.4 Copilot Memory for Agents

**Agent Learning Context:**
- Agents can store learned patterns (using Copilot memory)
- Reduces re-analysis of similar problems
- Improves efficiency on repeated tasks
- Privacy/governance considerations apply

**Memory Types:**
- **Repository facts:** What we know about this codebase
- **User preferences:** How this user likes things done
- **Pattern library:** Previously successful solutions
- **Decision history:** Why we made certain choices

### 3.5 Context Preservation

**Idempotency:** Agent operations should be safe to retry

**Non-idempotent (BAD):**
```python
counter = read_file("counter.txt")
counter += 1
write_file("counter.txt", counter)
# Each run increments counter → wrong if retried
```

**Idempotent (GOOD):**
```python
# Each run produces same result
if file_exists("processed.lock"):
    print("Already processed")
else:
    process_data()
    write_file("processed.lock", datetime.now())
```

---

## DOMAIN 4: PERFORM EVALUATION, ERROR ANALYSIS, AND TUNING (15–20%)

**Key Topic:** How to measure agent performance and improve it

### 4.1 Success Metrics

**Operational Metrics:**
```yaml
Success Rate:          % of agent tasks completing successfully
Execution Time:        How long tasks take (detect slowdowns)
Cost Per Task:         $ spent per execution (budget tracking)
API Call Volume:       Number of external API calls (track usage)
Error Rate:            % of tasks that fail (reliability)
```

**Quality Metrics:**
```yaml
Code Coverage:         % of code tested (from agent-generated tests)
Security Issues:       Vulnerabilities detected (from scans)
Performance Impact:    No regression in latency/throughput
Compliance:            % of agent outputs meeting standards
Human Approval Rate:   % of agent PRs approved (quality signal)
```

### 4.2 Error Analysis

**Common Agent Failures:**

| Error Type | Cause | Detection | Fix |
|-----------|-------|-----------|-----|
| **Hallucination** | Agent generates incorrect code | Code review, tests | Review before merging |
| **Infinite Loop** | Agent retrying endlessly | Timeout trigger | Add max-attempts limit |
| **API Error** | External service unavailable | Error logs | Retry with backoff |
| **Permission Denied** | Agent lacks required access | 403 error | Add permissions |
| **Scope Violation** | Agent exceeding boundaries | Audit logs | Enforce boundaries |
| **Rate Limited** | Too many API calls | 429 error | Implement rate limiting |

### 4.3 Performance Tuning

**Optimization Strategies:**

**Strategy 1: Reduce API Calls**
```python
# BAD: Multiple requests
for file in files:
    details = github_api.get_file(file)

# GOOD: Batch request (GraphQL)
query {
  files(names: $file_list) {
    edges { node { name, content } }
  }
}
```

**Strategy 2: Parallel Execution**
```yaml
jobs:
  test-unit:
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:unit

  test-integration:
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:integration
  
  # Both run in parallel, not sequential
  coverage:
    needs: [test-unit, test-integration]
    runs-on: ubuntu-latest
    steps:
      - run: npm run coverage:merge
```

**Strategy 3: Caching**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
  # Avoids re-downloading dependencies on every run
```

### 4.4 Feedback Loops

**Single-Agent Feedback Loop:**
```
1. Execute task
2. Measure results (metrics)
3. Analyze output quality
4. Tune parameters
5. Retry → back to 1
```

**Multi-Round Agent Workflow:**
```yaml
- name: Attempt 1
  id: attempt1
  continue-on-error: true
  run: ./agent-task.sh

- name: Check Success
  if: steps.attempt1.outcome == 'failure'
  run: echo "Attempt 1 failed, analyzing..."

- name: Adjust and Retry
  if: steps.attempt1.outcome == 'failure'
  run: ./agent-task.sh --adjust-params
```

### 4.5 Monitoring Dashboard

**What to Track:**
```
✅ Agent Task Success Rate: 98.5%
⏱️  Average Execution Time: 45s
🔗 API Calls per Task: 12
❌ Error Rate: 1.5%
💰 Cost per Task: $0.05
👤 Human Approval Latency: 2h 15m
📊 Code Coverage Impact: +2.3%
🔒 Security Issues Found: 0
```

---

## DOMAIN 5: ORCHESTRATE MULTI-AGENT COORDINATION (15–20%)

**Key Topic:** Managing multiple agents working together safely

### 5.1 Multi-Agent Workflow Patterns

**Pattern 1: Sequential Handoff**
```yaml
jobs:
  agent_analyze:
    runs-on: ubuntu-latest
    outputs:
      analysis: ${{ steps.analyze.outputs.result }}
    steps:
      - id: analyze
        run: ./analyze.sh

  agent_plan:
    needs: agent_analyze
    if: needs.agent_analyze.outputs.analysis == 'proceed'
    outputs:
      plan: ${{ steps.plan.outputs.result }}
    steps:
      - id: plan
        run: ./plan.sh

  agent_execute:
    needs: agent_plan
    runs-on: ubuntu-latest
    steps:
      - run: ./execute.sh
```

**Pattern 2: Parallel Execution with Synchronization**
```yaml
jobs:
  agent_test_unit:
    runs-on: ubuntu-latest
    steps:
      - run: npm test:unit

  agent_test_integration:
    runs-on: ubuntu-latest
    steps:
      - run: npm test:integration

  agent_report:
    needs: [agent_test_unit, agent_test_integration]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - run: ./generate-report.sh
```

**Pattern 3: Distributed Responsibility**
```yaml
# Agent1: Code Review
jobs:
  agent_review:
    runs-on: ubuntu-latest
    steps:
      - run: |
          # Agent1 reviews code quality
          ./code-quality-check.sh

# Agent2: Security Scan
jobs:
  agent_security:
    runs-on: ubuntu-latest
    steps:
      - run: |
          # Agent2 scans for vulnerabilities
          ./security-scan.sh

# Aggregation
jobs:
  agent_decide:
    needs: [agent_review, agent_security]
    runs-on: ubuntu-latest
    steps:
      - run: |
          # Agent3 aggregates findings
          ./aggregate-results.sh
```

### 5.2 Race Condition Prevention

**Problem:** Two agents modifying same files simultaneously

**Solution 1: Branch Protection**
```yaml
# Only allow one PR to main at a time
Branch: main
Protection Rules:
  - Require branches up to date
  - Require status checks to pass
  - Enforce against administrators
```

**Solution 2: Sequential Triggers**
```yaml
on:
  workflow_run:
    workflows: [previous-agent-workflow]
    types: [completed]
```

**Solution 3: Atomic Operations**
```python
# Use locks for critical sections
import fcntl

with open('lock.file', 'w') as lock:
    fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
    # Critical section - only one agent at a time
    modify_shared_resource()
    fcntl.flock(lock.fileno(), fcntl.LOCK_UN)
```

### 5.3 Agent Communication

**Method 1: GitHub Issues**
```yaml
# Agent1 creates issue
- name: Report Finding
  run: |
    gh issue create --title "Fix needed" --body "Details..."

# Agent2 reads and acts on issue
- name: Check for Tasks
  run: |
    gh issue list --label "agent-task" --json title,body
```

**Method 2: Workflow Outputs**
```yaml
jobs:
  agent_a:
    outputs:
      decision: ${{ steps.decide.outputs.decision }}
    steps:
      - id: decide
        run: echo "decision=proceed" >> $GITHUB_OUTPUT

  agent_b:
    needs: agent_a
    steps:
      - run: echo "Agent A decided: ${{ needs.agent_a.outputs.decision }}"
```

**Method 3: Artifacts**
```yaml
- name: Agent A: Save State
  uses: actions/upload-artifact@v3
  with:
    name: shared-state
    path: state.json

- name: Agent B: Read State
  uses: actions/download-artifact@v3
  with:
    name: shared-state
```

### 5.4 Deadlock Prevention

**Scenario:** Agent A waiting for Agent B, Agent B waiting for Agent A

**Prevention:**
- Use `timeout-minutes` on all jobs
- Implement max-wait limits on dependencies
- Add deadlock detection monitoring
- Prefer fire-and-forget patterns over waiting

### 5.5 Coordination Protocol

**Reliable Multi-Agent Coordination:**
```yaml
jobs:
  coordinator:
    runs-on: ubuntu-latest
    steps:
      - name: Phase 1 - Setup
        run: |
          # Coordinator prepares work
          mkdir -p work
          echo "READY" > work/status
      
      - name: Phase 2 - Trigger Agents
        run: |
          # Coordinator triggers both agents
          gh workflow run agent-a.yml --ref main
          gh workflow run agent-b.yml --ref main
      
      - name: Phase 3 - Wait for Completion
        run: |
          # Coordinator waits for both to finish
          while [ ! -f work/agent-a-done ] || [ ! -f work/agent-b-done ]; do
            sleep 5
          done
      
      - name: Phase 4 - Aggregate Results
        run: |
          # Coordinator aggregates and reports
          cat work/agent-a-results work/agent-b-results > final-results.json
```

---

## DOMAIN 6: IMPLEMENT GUARDRAILS AND ACCOUNTABILITY (10–15%)

**From Your Learning:** Module 2 (Governance) + Module 3 (Boundaries)

### 6.1 Execution Boundaries

**5 Critical Boundaries:**

**Boundary 1: REPOSITORY**
```yaml
agent_scope:
  repository: "myorg/myrepo"  # ONLY this repo
  # Cannot access: myorg/other-repo, external repos, etc.
```

**Boundary 2: BRANCH**
```yaml
agent_branch_policy:
  read_access: "*"  # Can read all branches
  write_access:
    - "develop"
    - "staging"
    # Cannot write to: main, production, release-*
  merge_access:
    - "develop"
    # Cannot merge to: main or production
```

**Boundary 3: FILE/PATH**
```yaml
agent_file_policy:
  read_access: "**/*"
  write_access:
    - "src/**"
    - "tests/**"
  forbidden_write:
    - ".github/workflows/**"  # Agents can't modify workflows
    - "package.json"          # Can't change dependencies
    - ".env"                  # Can't modify secrets
```

**Boundary 4: PERMISSION**
```yaml
permissions:
  contents: read              # Read files only
  pull-requests: write        # Write PR comments
  issues: read                # Read issues
  # Missing: admin, deploy, secrets
```

**Boundary 5: TIME**
```yaml
agent_time_policy:
  allowed_hours: "09:00-17:00"
  allowed_days: ["Mon-Fri"]
  max_operations_per_day: 100
  rate_limit: 10 ops/hour
```

### 6.2 Governance Controls

**Control 1: Branch Protection**
```yaml
main:
  - Require PR reviews: 1
  - Require status checks: [test, security-scan]
  - Require CODEOWNERS review: Yes
  - Dismiss stale reviews: No
  - Require branches up to date: Yes
```

**Control 2: CODEOWNERS**
```
# .github/CODEOWNERS

# Default
* @senior-dev

# Specialized
/src/auth/ @security-team
/src/billing/ @finance-team
/infra/ @devops-team

# Effect: Agent PRs touching these paths MUST be reviewed by specialists
```

**Control 3: Environments & Approval Gates**
```yaml
environments:
  agent-sandbox:
    deployment_branch_policy:
      protected_branches: false
    secrets:
      - AGENT_GITHUB_TOKEN (limited scope)
      - AGENT_API_KEY (read-only)
  
  production:
    deployment_branch_policy:
      protected_branches: true
    required_reviewers:
      - production-gatekeeper-team
    secrets:
      - DEPLOY_KEY
      - MONITORING_KEY
    # Does NOT have: PAYMENT_API_KEY, DB_PASSWORD
```

**Control 4: Status Checks**
```yaml
# Required before merge
- run: npm test
- run: npm run security:scan
- run: npm run lint
- run: |
    coverage=$(npm run coverage:report | grep -o '[0-9]*')
    if [ $coverage -lt 80 ]; then exit 1; fi
```

**Control 5: Rulesets** (Advanced)
```yaml
Name: Agent Safety Rules
Target: main branch
Enforcement: Active

Rules:
  - Commit Signature Required: Yes
  - Pull Request Required: Yes
  - Required Approvals: 1
  - CodeOwners Review: Yes
  - Status Checks:
      - test-unit
      - test-integration
      - security-scan
  - Allowed Actors:
      - agent-service-account
      - senior-developers
```

### 6.3 Audit Logging & Traceability

**Complete Audit Trail (The Six Ws):**

```yaml
Every agent action MUST answer:

1. WHO:    Which agent? Service account identity
2. WHAT:   What changed? Commit diff
3. WHEN:   Timestamp? Commit time
4. WHERE:  Repository/branch/files? GitHub path
5. WHY:    Why the change? Linked issue/plan
6. HOW:    How decided? Decision log
```

**Implementation:**
```yaml
- name: Log Action
  run: |
    cat >> audit.log << EOF
    {
      "timestamp": "$(date -Iseconds)",
      "action": "created_pr",
      "agent": "${{ github.actor }}",
      "repository": "${{ github.repository }}",
      "branch": "${{ github.ref }}",
      "pr_number": "${{ github.event.pull_request.number }}",
      "linked_issue": "#42",
      "status": "success",
      "commit_sha": "$(git rev-parse HEAD)"
    }
    EOF

- name: Upload Audit Log
  uses: actions/upload-artifact@v3
  with:
    name: audit-logs
    path: audit.log
    retention-days: 365  # Keep for 1 year
```

### 6.4 Reliability Patterns

**Pattern 1: Timeout Protection**
```yaml
jobs:
  agent_task:
    timeout-minutes: 10  # Job-level timeout
    steps:
      - timeout-minutes: 5
        run: ./long-task.sh  # Step-level timeout
```

**Pattern 2: Retry with Backoff**
```yaml
- uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_wait_seconds: 30
    command: npm test
```

**Pattern 3: Approval Gate**
```yaml
deploy:
  environment:
    name: production
    url: https://myapp.com
  steps:
    - run: ./deploy.sh
    # GitHub pauses here, requires human approval
```

**Pattern 4: Rollback Capability**
```yaml
- name: Save Rollback Point
  run: |
    git commit --allow-empty -m "Rollback point"
    git rev-parse HEAD > .rollback-sha

- name: Execute Changes
  run: ./make-changes.sh

- name: Auto-Rollback on Failure
  if: failure()
  run: |
    SHA=$(cat .rollback-sha)
    git reset --hard $SHA
    git push origin HEAD:main --force
```

**Pattern 5: Idempotency**
```python
# Safe to retry without side effects
def process_data():
    if os.path.exists('PROCESSED'):
        print("Already processed, skipping")
        return
    
    # Do work
    do_work()
    
    # Mark complete
    with open('PROCESSED', 'w') as f:
        f.write(time.time())
```

### 6.5 Escalation Protocol

**When agent should escalate to human:**

```yaml
Escalation Triggers:
  - Repeated failures (3+ attempts, same error)
  - Unclear requirements (ambiguous issue description)
  - Scope uncertainty (multiple possible solutions)
  - High-impact changes (major refactors, dependency updates)
  - Missing information (can't find needed data)
  - Exception cases (unusual edge cases)
  - Performance risk (might impact production)
  - Security concerns (potential vulnerabilities)
```

**Implementation:**
```python
if failed_attempts >= 3:
    create_github_issue(
        title="Agent escalation needed",
        body=f"""
        Attempted to {task_description} 3 times but failed.
        Last error: {last_error}
        Request human review and decision.
        """,
        labels=["escalation", "urgent"]
    )
    return  # Stop execution
```

---

## TEST QUESTION MAPPING TO DOMAINS

### Domain 1 Questions (15-20%)
- "What are agent responsibilities in the planning stage?"
- "How do you define success criteria for an agent task?"
- "Why must agents escalate architectural decisions to humans?"
- "Design an agent architecture for [scenario]"

### Domain 2 Questions (20-25%)
- "Which GitHub API is most efficient for [query type]?"
- "How do MCP allow lists prevent [risk]?"
- "Configure a workflow that [uses tools]"
- "What are the limitations of [execution environment]?"

### Domain 3 Questions (10-15%)
- "How should agent state persist across [multiple invocations]?"
- "When is idempotency critical in agent design?"
- "How do you preserve context for [multi-step task]?"

### Domain 4 Questions (15-20%)
- "Analyze this agent performance: [metrics]"
- "The agent is failing at [scenario]. Debug."
- "How would you tune [metric] from [value] to [target]?"
- "What metrics indicate [success/failure]?"

### Domain 5 Questions (15-20%)
- "Design a multi-agent workflow for [scenario]"
- "How do you prevent [race condition/deadlock]?"
- "Coordinate [agent1] and [agent2] safely"
- "Scale [single agent] to [multiple agents]"

### Domain 6 Questions (10-15%)
- "What boundaries should this agent have?"
- "Design governance for [agent scenario]"
- "How would you audit [agent action]?"
- "What would cause this agent to violate [boundary]?"

---

## FINAL PREPARATION CHECKLIST

Before taking the real exam, verify you can:

- [ ] **Domain 1:** Explain SDLC stage mapping, define agent tasks with inputs/outputs/success criteria, understand system of record/control plane
- [ ] **Domain 2:** Use GitHub REST/GraphQL APIs, explain MCP and allow lists, design GitHub Actions workflows with proper job composition
- [ ] **Domain 3:** Manage state across job boundaries, implement idempotency, preserve context for multi-step execution
- [ ] **Domain 4:** Interpret agent metrics, analyze failures, explain tuning strategies, design feedback loops
- [ ] **Domain 5:** Design multi-agent workflows, prevent race conditions, coordinate agents safely, handle communication between agents
- [ ] **Domain 6:** Define execution boundaries, implement governance controls, create audit trails, apply reliability patterns

**If you can do all 6 of these → You'll pass GH-600**

---

## Key Resources
- Exam sandbox: https://ghcertdemo.starttest.com/
- Official study guide: aka.ms/GH600-StudyGuide
- Exam page: https://learn.microsoft.com/en-us/credentials/certifications/agentic-ai-developer/
- Cost: $165 USD | Time: 120 minutes | Status: Beta (results in ~8 weeks)

