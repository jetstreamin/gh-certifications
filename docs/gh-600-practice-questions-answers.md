# GH-600 Practice Questions & Answers

**Total Questions: 50+ | Multiple Choice & Scenario-Based**

---

## SECTION 1: FOUNDATIONS OF AGENTIC AI

### Question 1.1 - Definition
**What is the fundamental difference between an AI assistant and agentic AI?**

A) Assistants are faster than agents
B) Assistants react to user queries, while agents autonomously plan, act, and evaluate within defined boundaries
C) Agents require more processing power
D) Assistants use GitHub, agents use other platforms

**Answer: B**

**Explanation:**
- **Assistants:** Passive, respond when asked, single interaction cycle
- **Agents:** Active, autonomous, multi-step decision cycles, can trigger workflows, integrated into SDLC

---

### Question 1.2 - Scenario
**An agent is fixing failing tests in a repository. Which sequence best represents the Plan → Act → Evaluate lifecycle?**

A) Execute fixes → Post plan to issue → Verify tests pass
B) Post plan to issue for review → Execute fixes → Verify tests pass and update issue
C) Verify tests pass → Execute fixes → Post results
D) Execute all possible fixes → Choose best one → Plan

**Answer: B**

**Explanation:**
- **Plan phase:** Agent analyzes failing tests, creates human-readable plan, posts to issue for inspection
- **Act phase:** Human approves or comments; agent then executes fixes
- **Evaluate phase:** Agent runs tests again, verifies success, updates issue with results
- This separation ensures human visibility before execution (security requirement)

---

### Question 1.3 - Concept
**Why is GitHub considered both the "system of record" and "control plane" for agents?**

A) Because GitHub has the best UI
B) GitHub stores all agent decisions/actions (record) AND GitHub rules enforce agent behavior (control)
C) Because agents can only work with GitHub
D) GitHub is cheaper than alternatives

**Answer: B**

**Explanation:**
- **System of Record:** All agent activity (commits, PRs, comments, decisions) is logged in GitHub
  - You can audit everything by reviewing GitHub history
  - No separate logging system needed
  - GitHub is the source of truth

- **Control Plane:** GitHub features enforce guardrails:
  - Branch protection rules prevent agent merging
  - Status checks force agent to fix failing tests
  - CODEOWNERS require approval
  - Environments gate production access
  - Rulesets enforce policies

---

### Question 1.4 - Risk Management
**Which is NOT a recognized risk in agent systems?**

A) Hallucination - agent generates false or misleading code
B) Privilege escalation - agent obtains higher permissions than intended
C) Infinite loops - agent stuck in plan/act/evaluate cycle
D) Agent has good marketing

**Answer: D**

**Explanation:**
- A, B, C are all documented risks requiring mitigation strategies
- D is not a technical risk (obvious wrong answer, tests reading comprehension)

---

### Question 1.5 - Traceability
**An agent posts a PR to fix a bug. To satisfy traceability requirements, which information MUST be included?**

A) WHO (agent identity), WHAT (PR description), WHEN (timestamp), WHERE (repo/branch), WHY (linked issue), HOW (decision log)
B) Just the agent name
C) Just the code changes
D) Email notification to human

**Answer: A**

**Explanation:**
Traceability requires answering all six questions:
1. WHO - Which agent made the change? (Service account identity)
2. WHAT - What exactly was changed? (PR diff)
3. WHEN - When did it happen? (Commit timestamp, PR created time)
4. WHERE - Where did it happen? (Repository, branch, file paths)
5. WHY - What was the reasoning? (Linked to issue, plan documented)
6. HOW - How did it decide? (Decision logs in PR description/comments)

---

### Question 1.6 - Contributor Model
**Under the contributor model, what happens when an agent PR is rejected by a reviewer?**

A) The agent is deleted
B) The agent can force merge the PR
C) The agent should analyze feedback and either fix the issues or escalate to human decision-maker
D) The PR is automatically approved

**Answer: C**

**Explanation:**
- Agents are contributors like humans
- Agents must follow the project's code review process
- When PR is rejected, agent should:
  1. Analyze the feedback (e.g., "security issue detected")
  2. Attempt to fix the issue (if possible)
  3. Or acknowledge limitation and escalate to human
- Agent never overrides human reviewer decision

---

## SECTION 2: ARCHITECTURE AND SDLC INTEGRATION

### Question 2.1 - SDLC Stages
**In which SDLC stage should an agent be responsible for "making architectural decisions"?**

A) Planning
B) Implementation
C) Validation
D) None - architectural decisions are human responsibility

**Answer: D**

**Explanation:**
- Agents should implement within established architecture
- But agents should NOT design the architecture
- Architectural decisions require human judgment about business needs, scalability, maintainability
- Agents can suggest refactoring within existing architecture

---

### Question 2.2 - Task Definition
**Which component is NOT required to define a structured agent task?**

A) Inputs (what triggers the agent?)
B) Outputs (what does the agent produce?)
C) Success criteria (how do we know it worked?)
D) Agent name (what color is the agent?)

**Answer: D**

**Explanation:**
- A, B, C are essential for clear task boundaries
- D is not a functional requirement for task definition
- The following ARE required:
  - Inputs: What data/signals trigger it?
  - Outputs: What does it produce and where?
  - Success criteria: Quantifiable metrics for success
  - Failure criteria: What constitutes failure?
  - Context: What can/cannot it access?
  - Constraints: Resource and permission limits

---

### Question 2.3 - Separation of Concerns
**Why is separating PLAN, REASON, and EXECUTE phases critical?**

A) It makes workflows longer
B) It enables humans to inspect/approve before execution and makes debugging possible
C) It's required by GitHub
D) It improves workflow performance

**Answer: B**

**Explanation:**
Separation enables:
- **Inspection:** Humans can review agent's plan before anything happens
- **Intervention:** Humans can request changes to the plan
- **Debugging:** If something goes wrong, you know which phase failed
- **Auditing:** Clear decision trail for compliance

Without separation, it's impossible to know what the agent was thinking.

---

### Question 2.4 - Scenario: PR Governance
**You have an agent that writes code. To ensure only high-quality code reaches main branch, which governance pattern is insufficient?**

A) Require agent PR to have CODEOWNERS approval
B) Block agent from creating commits to main branch directly
C) Run security scanning before PR can merge
D) Allow agent to choose which tests to run

**Answer: D**

**Explanation:**
- A, B, C enforce quality gates
- D is dangerous - agent could skip tests to make PRs merge
- **Correct governance requires:**
  - Branch protection (B) - agent can't commit to main directly
  - Required checks (C) - security scan must pass
  - CODEOWNERS (A) - domain experts must review
  - NOT: Agent discretion on testing (D)

---

### Question 2.5 - Outputs Context
**In a GitHub Actions workflow, what is the purpose of `outputs`?**

A) Display information to the user
B) Pass data between jobs in a workflow
C) Store secrets securely
D) Run tests

**Answer: B**

**Explanation:**
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
      - run: echo "Received: ${{ needs.job1.outputs.result }}"
      # job2 can use outputs from job1
```

Outputs enable complex multi-job workflows where later jobs depend on earlier job results.

---

### Question 2.6 - Hooks
**An agent needs to perform cleanup if a task fails, but NOT if the task succeeds. Which approach is correct?**

A) Add cleanup step with `if: failure()`
B) Delete workflow after execution
C) Add cleanup step with `if: success()`
D) Manual cleanup required

**Answer: A**

**Explanation:**
```yaml
steps:
  - name: Main Task
    run: ./main-task.sh
    # May fail

  - name: Cleanup on Failure
    if: failure()  # Only runs if previous step failed
    run: ./cleanup.sh
```

GitHub Actions conditional keywords:
- `if: success()` - runs if all previous steps succeeded
- `if: failure()` - runs if any previous step failed
- `if: always()` - always runs (even on failure)

---

### Question 2.7 - Scenario: Tool Governance
**An agent needs to read deployment secrets but shouldn't be able to read payment processing secrets. How do you enforce this?**

A) Ask the agent nicely
B) Use separate environments with different secrets in each
C) Store both in the same environment but hope agent doesn't use wrong one
D) Encrypt secrets differently

**Answer: B**

**Explanation:**
```yaml
job1:
  environment: agent-sandbox  # Only has DEPLOY_KEY
  # Can access ${{ secrets.DEPLOY_KEY }}
  # Cannot access ${{ secrets.STRIPE_SECRET_KEY }}

job2:
  environment: prod  # Has STRIPE_SECRET_KEY
  # Only runs on explicit approval
```

Secrets are environment-scoped. By assigning agent to a specific environment, you control which secrets it can access.

---

### Question 2.8 - Observability
**What is the primary purpose of logging agent decisions and actions?**

A) To make humans feel better
B) To enable auditing, debugging, and traceability
C) To comply with GitHub requirements
D) To slow down the agent

**Answer: B**

**Explanation:**
Logging enables:
- **Auditing:** Compliance and security review
- **Debugging:** Understanding why something failed
- **Traceability:** Linking actions to decisions
- **Forensics:** Post-incident analysis

Logging MUST include:
- Timestamp
- Action taken
- Result (success/failure)
- Any error details
- Links to relevant GitHub artifacts

---

## SECTION 3: TOOLING, MCP, AND EXECUTION ENVIRONMENTS

### Question 3.1 - GitHub APIs
**An agent needs to read PR file changes. Which GitHub API is most efficient for complex queries?**

A) REST API
B) GraphQL API
C) Webhooks
D) GitHub CLI

**Answer: B**

**Explanation:**
- **REST API:** Simple queries, requires multiple requests
- **GraphQL API:** Complex queries in single request, more efficient
- **Webhooks:** Notification mechanism, not for querying
- **GitHub CLI:** Command-line tool, not API

For this scenario (reading multiple fields from PR), GraphQL is optimal:
```graphql
query {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      files(first: 20) {
        edges {
          node {
            path
            additions
            deletions
          }
        }
      }
    }
  }
}
```

---

### Question 3.2 - MCP Basics
**What does MCP (Model Context Protocol) enable?**

A) Agents to connect to external tools and services in a standardized way
B) GitHub to run code faster
C) Humans to write code faster
D) Better password security

**Answer: A**

**Explanation:**
- MCP is a protocol that allows agents (clients) to discover and call tools
- MCP servers expose capabilities (tools)
- Agents can use any MCP server without custom integration
- Think of it as a universal tool adapter

---

### Question 3.3 - MCP Allow List
**An organization has MCP servers for GitHub, Docker, and AWS. An agent should only access GitHub tools. What's the best approach?**

A) Delete Docker and AWS MCP servers
B) Hope the agent doesn't call Docker/AWS tools
C) Use an MCP allow list to restrict the agent to GitHub MCP only
D) Tell the agent nicely not to use Docker/AWS

**Answer: C**

**Explanation:**
```yaml
mcp_allow_list:
  servers:
    - id: github-mcp
      allowed_tools: ["*"]  # All GitHub tools allowed
    # docker-mcp and aws-mcp not listed = blocked
```

Allow lists provide:
- Explicit permission model (only allowed things work)
- Security (agent can't accidentally access dangerous tools)
- Auditability (know exactly what tools each agent can use)

---

### Question 3.4 - Repository Scope
**An agent is configured for "my-org/my-repo". Can it read issues from "my-org/other-repo"?**

A) Yes, all repos in the organization are accessible
B) No, repository scope restricts the agent to only my-org/my-repo
C) Only if approved by an admin
D) Only on Tuesdays

**Answer: B**

**Explanation:**
- Repository scope is a hard boundary
- Agent is restricted to the specified repository only
- This prevents lateral movement/privilege escalation
- Agent cannot access any other repositories regardless of permissions

---

### Question 3.5 - Branch Scope
**An agent is configured with write_access to ["develop", "staging"]. What happens if the agent tries to push to "main"?**

A) Agent can push, branch scope is just a suggestion
B) Agent push to main fails (boundary violation)
C) Admin approval is required
D) Agent automatically switches to develop

**Answer: B**

**Explanation:**
Branch scope is enforced:
```yaml
write_access:
  - "develop"
  - "staging"
# This means agent CAN push to: develop, staging
# This means agent CANNOT push to: main, production, feature-*, etc.
```

If agent attempts to push to main, it fails at the Git level (rejection by branch protection rule).

---

### Question 3.6 - File Path Scope
**Which configuration correctly prevents agent from modifying workflow files?**

A) `write_access: "**/*"` (allow all files)
B) `write_access: "src/**"` and `write_access: "tests/**"`
C) `write_access: "**/*"` but `forbidden_write: ".github/workflows/**"`
D) Nothing, agent has full write access

**Answer: C**

**Explanation:**
- A allows everything (not restricted)
- B only allows src/ and tests/ (but doesn't explicitly forbid workflows)
- C **explicitly** allows everything except workflows (correct approach)
- D is insecure

Best practice: **Allowlist + blocklist**
```yaml
write_access: "**/*"  # Generally can write...
forbidden_write: ".github/workflows/**"  # ...except workflows
```

---

### Question 3.7 - Permission Scope
**An agent has GitHub Actions job with `permissions: { contents: read, pull-requests: write }`. What can this agent do?**

A) Read files, create commits, merge PRs
B) Read files and write PR comments (but not modify repo contents)
C) Anything it wants
D) Nothing

**Answer: B**

**Explanation:**
```yaml
permissions:
  contents: read          # ✅ Can READ files, view branches
                          # ❌ Cannot WRITE commits
  pull-requests: write    # ✅ Can write PR comments, request changes
                          # ❌ Cannot create PRs (needs pull-requests: write on creation)
```

Permissions are:
- **read:** View-only access
- **write:** Can modify
- **(not listed):** No access

---

### Question 3.8 - Scenario: Execution Boundaries
**Your agent needs to run only on PRs to "main" branch, only when "src/" changes, and only during business hours. How do you enforce this?**

A) Add all constraints in agent code
B) Use workflow trigger for branch/path + time boundary in agent execution logic
C) Trust the agent to follow rules
D) Run manual approval process

**Answer: B**

**Explanation:**
```yaml
on:
  pull_request:
    branches: [main]          # Boundary 1: Only main branch
    paths: ['src/**']          # Boundary 2: Only when src/ changes

jobs:
  task:
    runs-on: ubuntu-latest
    steps:
      - name: Check Business Hours
        run: |
          hour=$(date +%H)
          if [ $hour -lt 9 ] || [ $hour -gt 17 ]; then
            echo "Outside business hours, exiting"
            exit 0
          fi
          # Boundary 3: Business hours enforced
```

Layered boundary approach:
1. **Workflow trigger:** Automatic (branch, paths)
2. **Code logic:** Manual checks (time boundaries)
3. **Permissions:** GitHub scope (read/write access)
4. **Environments:** Secrets boundary

---

### Question 3.9 - Timeout Protection
**An agent task takes 45 minutes but has `timeout-minutes: 10` set. What happens?**

A) Task runs to completion
B) Task is killed at 10 minutes
C) Task is paused and resumed later
D) Warning is displayed but task continues

**Answer: B**

**Explanation:**
```yaml
jobs:
  agent_task:
    timeout-minutes: 10  # Hard limit
    steps:
      - name: Long Task
        run: |
          for i in {1..100}; do
            sleep 30  # 30 seconds per iteration
            # After 10 minutes (20 iterations), job is killed
          done
```

Timeout is a **hard limit**:
- When timeout expires, job is terminated
- Graceful cleanup code in `finally` blocks still runs
- No warning before kill (it's hard cutoff)

Purpose: Prevent runaway workflows consuming resources.

---

### Question 3.10 - Rate Limiting
**Why should agents implement rate limiting on API calls?**

A) It's not necessary
B) To prevent API abuse and respect rate limits of external services
C) To make workflows run slower
D) GitHub requires it

**Answer: B**

**Explanation:**
Rate limiting prevents:
- **API throttling:** External APIs block if too many requests
- **DOS:** Unintended service disruption
- **Costs:** Excessive API calls might incur charges
- **Resource exhaustion:** Running out of quota

Implementation:
```python
limiter = RateLimiter(max_calls=100, window_seconds=3600)  # 100/hr
for issue in issues:
    if not limiter.is_allowed():
        print("Rate limit, stopping")
        break
    process_issue(issue)
```

---

### Question 3.11 - Approval Gates
**An agent needs to perform a critical deployment. Which protection should be used?**

A) Add a TODO comment in code
B) Use a GitHub Environment with approval requirement
C) Ask in Slack
D) Send an email

**Answer: B**

**Explanation:**
```yaml
jobs:
  deploy:
    environment:
      name: production  # Requires approval
      url: https://myapp.prod.com
    steps:
      - name: Deploy
        run: ./deploy-to-prod.sh
        # GitHub pauses here and asks required reviewers for approval
        # Only proceeds if approved within specified time
```

Approval gates provide:
- **Enforced human oversight:** GitHub won't proceed without approval
- **Auditing:** Records who approved
- **Timing:** Reviewers have time limit to approve
- **Deny capability:** Reviewers can reject

---

### Question 3.12 - Status Checks
**An agent is about to make changes to production. Which status check should be required to pass first?**

A) None - just make the changes
B) Automated tests, security scan, code coverage threshold
C) Vague "looks good to me" check
D) Checks are optional

**Answer: B**

**Explanation:**
Before production changes:
- ✅ **Unit tests** pass (code works)
- ✅ **Security scan** completes (no vulnerabilities)
- ✅ **Code coverage** above threshold (sufficient testing)
- ✅ **Integration tests** pass (works with other systems)
- ✅ **Performance tests** pass (no regression)

Anti-pattern: Allowing agent to skip checks or merge with failed checks.

---

## SECTION 4: INTEGRATION & COMPLEX SCENARIOS

### Question 4.1 - Full Workflow Scenario
**You need to design an agent that fixes failing tests. Describe the ideal workflow structure.**

A) Agent runs tests → fixes code → merges to main
B) Agent analyzes test failures → posts plan to issue → awaits approval → implements fixes → verifies → creates PR → human reviews → merge
C) Agent makes random changes
D) Humans manually fix everything

**Answer: B**

**Explanation:**
Correct workflow requires all these stages:

1. **Plan:** Analyze test failures → create step-by-step plan
2. **Post Plan:** Create issue comment or GitHub discussion
3. **Human Approval:** Developer reviews and approves plan
4. **Implement:** Make code changes (if approved)
5. **Verify:** Run tests to ensure fixes work
6. **Create PR:** Push changes to branch, create PR with details
7. **Human Review:** Maintainers review code quality
8. **Merge:** Once approved, merge to main

This ensures humans are involved at decision points (plan approval, code review).

---

### Question 4.2 - Conflict Resolution
**An agent's first attempt to fix a test fails. The failure is due to a dependency update that the agent didn't know about. What's the correct response?**

A) Agent retries with different code
B) Agent logs detailed info, raises an issue for human investigation
C) Agent repeatedly retries until it accidentally works
D) Agent gives up silently

**Answer: B**

**Explanation:**
- Agent recognizes the failure isn't agent's fault
- Agent creates detailed issue with:
  - Error logs
  - Attempted fixes
  - Root cause analysis
  - Suggestion for next step
  - Request for human input
- This escalation pattern is essential for complex problems

---

### Question 4.3 - Security Boundary
**An agent discovers a security vulnerability in production code. What should it do?**

A) Create a public GitHub issue describing the vulnerability
B) Post private security advisory, create PR with fix, request urgent review
C) Ignore it and hope nobody notices
D) Delete the vulnerable code

**Answer: B**

**Explanation:**
Security handling requires:
1. **Private channel:** Don't disclose publicly (use GitHub security advisory)
2. **Quick fix:** Create PR with fix
3. **Urgent review:** Request immediate review from security team
4. **Notification:** Alert maintainers privately

Public disclosure can expose vulnerability before fix is deployed.

---

### Question 4.4 - Cost Consideration
**An agent task that run 1000x per day costs $1 per execution. What's the best approach?**

A) Run it anyway, costs are okay
B) Add rate limiting or reduce execution frequency
C) Ignore costs
D) Disable monitoring

**Answer: B**

**Explanation:**
Cost awareness in agent design:
- 1000 executions × $1 = $1000/day = $30,000/month
- **Mitigation strategies:**
  - Rate limiting: Only run when necessary
  - Batching: Process multiple items per execution
  - Optimization: Use cheaper APIs
  - Caching: Avoid redundant API calls
  - Scheduling: Run during off-peak hours

Agents should include cost-awareness in decision logic.

---

### Question 4.5 - Hybrid Human-Agent Workflow
**Design a workflow where agent does initial work but humans handle complex decisions.**

**Answer:**
```yaml
jobs:
  agent_initial_analysis:
    runs-on: ubuntu-latest
    outputs:
      analysis: ${{ steps.analyze.outputs.result }}
    steps:
      - name: Analyze Issue
        id: analyze
        run: |
          # Agent: Straightforward analysis
          # Output complexity assessment
          echo "result=complex" >> $GITHUB_OUTPUT

  human_decision:
    needs: agent_initial_analysis
    if: needs.agent_initial_analysis.outputs.analysis == 'complex'
    runs-on: ubuntu-latest
    environment: human-approval
    steps:
      - name: Wait for Human Decision
        run: |
          # Pauses here for human approval
          # In GitHub UI, human reviews and approves
          echo "Human has approved proceeding"

  agent_implementation:
    needs: human_decision
    runs-on: ubuntu-latest
    steps:
      - name: Implement Approved Solution
        run: |
          # Agent: Executes the approved solution
          echo "Implementing solution..."
```

Pattern: Agent (simple) → Human (complex decision) → Agent (execute)

---

### Question 4.6 - Idempotency
**Why is agent idempotency important?**

A) It sounds technical
B) Agent should produce the same result whether run once or multiple times
C) It's not important
D) Agents are always idempotent

**Answer: B**

**Explanation:**
Idempotency means: `f(f(x)) == f(x)`

Why it matters:
- **Retries:** If agent task is retried, same result expected
- **Replay:** If workflow reruns, shouldn't duplicate work
- **Debugging:** Can rerun without side effects

Example (non-idempotent - BAD):
```python
# Every run adds 1 to counter - not idempotent
counter += 1
```

Example (idempotent - GOOD):
```python
# Every run sets counter to same value - idempotent
if file_exists('counter.txt'):
    counter = read('counter.txt')
else:
    counter = 0
write('counter.txt', counter)
```

---

### Question 4.7 - Rollback Strategy
**An agent pushes a breaking change that causes production issues. The team needs to quickly rollback. What should the workflow support?**

A) No rollback capability needed
B) Save Git SHAs at checkpoints; ability to force-push to known good commit
C) Manually git revert later
D) Just redeploy everything

**Answer: B**

**Explanation:**
Rollback implementation:
```yaml
- name: Save Rollback Point
  run: |
    git commit --allow-empty -m "Rollback point"
    SHA=$(git rev-parse HEAD)
    echo $SHA > .rollback-sha

- name: Make Changes
  run: ./agent-makes-changes.sh

- name: Automatic Rollback on Failure
  if: failure()
  run: |
    SHA=$(cat .rollback-sha)
    git reset --hard $SHA
    git push origin HEAD:main --force
```

Rollback strategy:
1. **Create rollback point** before making changes
2. **Monitor** for failures
3. **Auto-rollback** if critical failure detected
4. **Manual rollback** available for human-triggered issues

---

## SECTION 5: ADVANCED SCENARIOS

### Question 5.1 - Multi-Agent Coordination
**Two agents work on the same codebase. Agent A creates PRs with features, Agent B reviews them. How do you prevent race conditions?**

A) Hope they don't conflict
B) Use GitHub environments and branch protection to ensure sequential execution
C) Run both agents simultaneously
D) Have only one agent

**Answer: B**

**Explanation:**
```yaml
# Agent A: Creates PR
jobs:
  create_pr:
    environment: agent-a-create
    steps:
      - name: Create Feature PR
        run: |
          # Agent A creates PR to develop branch
          # PR has no approvals yet

# Agent B: Reviews PR
jobs:
  review_pr:
    needs: create_pr
    environment: agent-b-review
    steps:
      - name: Review and Approve
        if: no_conflicts_and_tests_pass
        run: |
          # Agent B approves and merges

# Sequential execution via 'needs:' ensures ordering
```

Coordination strategies:
- **Sequential:** Use `needs:` for ordering
- **Locks:** Use branch protection to enforce one change at a time
- **Queuing:** Implement queue system for PRs
- **Conflict detection:** Fail if concurrent changes detected

---

### Question 5.2 - Observability Matrix
**What metrics should you track for agent health monitoring?**

A) None - agents don't need monitoring
B) Success rate, execution time, API call count, error rate, cost per execution, approval latency
C) Just track if agent is running
D) Only track failures

**Answer: B**

**Explanation:**
Essential metrics:
- **Success Rate:** % of agent tasks that complete successfully
- **Execution Time:** How long tasks take (detect slowdowns)
- **API Calls:** Volume of API usage (cost tracking)
- **Error Rate:** % of tasks that fail (reliability)
- **Cost:** $ spent per execution (budget tracking)
- **Approval Latency:** How long humans take to approve

Monitoring dashboard (Prometheus/DataDog):
```
✅ Agent Task Success Rate: 98.5%
⏱️  Average Execution Time: 45 seconds
🔗 API Calls per Task: 12
❌ Error Rate: 1.5%
💰 Cost per Task: $0.05
👤 Human Approval Latency: 2 hours 15 min
```

---

### Question 5.3 - Compliance & Audit
**A compliance auditor asks: "How can we verify that all agent actions were authorized and approved?" What's the complete answer?**

A) We can't, agents do what they want
B) Review GitHub commit history + PR approvals + workflow artifacts
C) Ask the agent
D) Encrypted logs only auditors can access

**Answer: B**

**Explanation:**
Complete audit trail via GitHub:

1. **Who:** Commits signed with agent service account
2. **What:** Diffs show exactly what changed
3. **When:** Commit timestamp
4. **Where:** Repository, branch, files
5. **Why:** Linked to issue/PR
6. **Approval:** PR approvals + CODEOWNERS records
7. **Reasoning:** PR description + agent comments

Audit process:
```bash
# Query GitHub for agent actions in last 30 days
git log --all --since="30 days ago" \
  --author="agent-service-account" \
  --pretty=format:"%h %s %ad" --date=short

# Review all agent PRs
gh pr list --search "author:agent-service-account"

# Check approval records
gh pr view PR_NUMBER --json reviews
```

---

### Question 5.4 - When Agent Should NOT Act
**Under which conditions should agent stop and escalate to human instead of continuing?**

A) When it feels like it
B) Repeated failures, unclear requirements, scope ambiguity, potential system impact, missing dependencies
C) Never stop - just keep trying
D) Only on Mondays

**Answer: B**

**Explanation:**
Agent escalation triggers:
- ✋ **Repeated Failures:** 3+ failed attempts, same error
- ✋ **Unclear Requirements:** Ambiguous issue description
- ✋ **Scope Uncertainty:** Multiple possible solutions, tradeoffs needed
- ✋ **High Impact Changes:** Major refactors, dependency upgrades
- ✋ **Missing Information:** Can't find needed data or context
- ✋ **Exception Cases:** Unusual edge cases
- ✋ **Performance Impact:** Change might impact system performance
- ✋ **Security Concerns:** Potential security implications

Example escalation code:
```python
if failed_attempts >= 3:
    create_issue(
        title="Agent escalation needed",
        body=f"Tried 3 times but {error}. Human input needed."
    )
    return  # Stop execution, let human decide
```

---

### Question 5.5 - Future-Proofing
**You're designing an agent system that will operate for 5+ years. What practices ensure it remains maintainable?**

A) Just build it and hope it works
B) Clear documentation, semantic versioning of agent capabilities, audit logging, rollback capability, modular design
C) Rewrite every year
D) No practices needed

**Answer: B**

**Explanation:**
Long-term maintainability practices:

1. **Documentation:**
   - What agent does and limitations
   - Decision logic explained
   - Examples of success and failure

2. **Versioning:**
   - Agent version in commits
   - Changelog of capability changes
   - Breaking change notifications

3. **Audit Logging:**
   - Complete trail of agent actions
   - Decision rationale saved
   - Historical data for trend analysis

4. **Rollback Capability:**
   - Point-in-time recovery option
   - Tested rollback procedures
   - Communication plan for incidents

5. **Modular Design:**
   - Agents have single responsibility
   - Easy to update without breaking others
   - Composed from testable components

---

## SECTION 6: FINAL INTEGRATION TEST

### Final Scenario - Build from Scratch

**You are designing an agent for a critical mission: automatically deploy security patches to production. Walk through the complete design.**

**Answer (Model Response):**

#### 1. Define Responsibilities (via inputs/outputs/success criteria)

```yaml
Agent: Security Patch Deployment

Inputs:
  - Trigger: Security alert posted to GitHub issue
  - Context: Vulnerability description, patch details, affected systems
  - Approvers: Team lead must approve before deploy

Outputs:
  - PR with security patch applied
  - Test results showing no regression
  - Deployment logs
  - Incident tracking

Success Criteria:
  - ✅ Patch applied within 1 hour of alert
  - ✅ All tests pass (unit, integration, security)
  - ✅ No performance regression
  - ✅ Team lead approval before production deploy
  - ✅ Monitoring confirms deployment successful

Failure Criteria:
  - ❌ Tests fail (cannot deploy broken code)
  - ❌ Deployment fails (rollback and escalate)
  - ❌ Approval timeout (escalate to on-call)
  - ❌ Performance regression detected (rollback)
```

#### 2. Plan → Act → Evaluate Workflow

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - name: Analyze Security Alert
        run: |
          # Parse security issue
          # Determine affected files
          # Generate patch strategy
      - name: Post Plan
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              body: "## Security Patch Plan\n..."
            })

  act:
    needs: [plan]
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v3
      - name: Apply Patch
        run: |
          git checkout -b security-patch-${{ github.run_number }}
          # Apply security patch
          ./apply-patch.sh
          git commit -m "Security patch: [CVE details]"
          git push origin security-patch-${{ github.run_number }}
      - name: Create PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.pulls.create({
              title: "Security: Patch for [CVE]",
              body: "Automated security patch deployment",
              head: "security-patch-${{ github.run_number }}",
              base: "main"
            })

  evaluate:
    needs: [act]
    runs-on: ubuntu-latest
    steps:
      - name: Wait for PR Approval
        run: |
          # Poll for approval from required CODEOWNERS
          while [ $attempts -lt 30 ]; do
            if pr_approved; then
              break
            fi
            sleep 60
            ((attempts++))
          done
      
      - name: Run Final Tests
        run: |
          npm test
          npm run security-scan
          npm run performance-test
      
      - name: Deploy to Production
        if: success()
        environment: production
        run: |
          ./deploy-to-prod.sh
      
      - name: Monitor and Verify
        run: |
          sleep 300  # Wait 5 minutes
          if check_system_health; then
            echo "✅ Deployment successful"
          else
            ./rollback-to-previous.sh
            create_incident("Security patch deployment failed")
          fi
```

#### 3. Governance & Boundaries

```yaml
# Branch Protection on main
- Require PR reviews: 1 (security team CODEOWNER)
- Require status checks: tests, security-scan, performance-test
- Dismiss stale reviews: false
- Require branches up to date: true

# MCP Allow List
- github-mcp (all tools)
- datadog-mcp (monitoring only)
- NO aws-mcp (too dangerous for automated deployment)

# Execution Boundaries
- Repository: this-org/critical-app
- Branches: main only
- Permissions: contents write, pull-requests write
- Environment: production (requires approval)
- Timeout: 30 minutes
- Rate limit: 1 deployment per 6 hours (safety valve)

# Secrets Boundary
- Environment: production-deploy
- Secrets: DEPLOY_KEY, MONITORING_API_KEY
- Excluded: STRIPE_KEYS, DB_PASSWORD
```

#### 4. Observability & Safety

```yaml
- name: Comprehensive Logging
  run: |
    cat >> audit.log << EOF
    {
      "timestamp": "$(date -Iseconds)",
      "action": "security-patch-deploy",
      "cve": "$CVE_NUMBER",
      "patch_version": "$PATCH_VERSION",
      "status": "$STATUS",
      "approval_by": "$APPROVER",
      "deployment_sha": "$(git rev-parse HEAD)",
      "rollback_sha": "$ROLLBACK_SHA"
    }
    EOF

- name: Failure Notifications
  if: failure()
  run: |
    # Alert on-call team immediately
    notify_slack "#security-incidents" "Deployment failed: ${ERROR}"
    create_github_issue "Security patch deployment failed"
    trigger_rollback_procedure
```

#### 5. Key Decisions

| Decision | Reason |
|----------|--------|
| **Human approval required** | Too risky for fully automated deployment |
| **All tests must pass** | Can't deploy broken code |
| **Monitoring + rollback** | Catch failures after deployment |
| **Audit logging** | Compliance and post-incident forensics |
| **Rate limiting** | Prevent accidental deployment loops |
| **Restricted secrets** | Payment/DB secrets not available to agent |
| **CODEOWNERS required** | Security team has final say |

---

## ANSWER KEY BY QUESTION TYPE

| Type | Questions | Key Focus |
|------|-----------|-----------|
| Definition | 1.1, 3.1, 3.2 | Know terminology, understand concepts |
| Scenario | 1.2, 1.4, 2.4, 3.8 | Analyze situations, choose best approach |
| Best Practice | 2.1, 2.7, 3.4 | Know what's safe/secure |
| Risk Management | 1.3, 1.5, 3.11 | Understand governance needs |
| Architecture | 2.2, 2.3, 4.1 | Design patterns, system thinking |
| Technical | 2.5, 2.6, 3.7 | GitHub Actions, MCP specifics |
| Integration | 4.1, 4.5, 5.5 | Full workflow thinking |

---

**Study Tips:**
- Focus on WHY (understand principles, not just facts)
- Practice drawing out workflows (visual understanding helps)
- Test your knowledge by designing small agents
- Review the anti-patterns section for common mistakes
- Remember: Governance > Automation (safety first)

