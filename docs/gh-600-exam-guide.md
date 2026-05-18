<!-- markdownlint-disable-file -->
# GH-600 Exam Study Guide: Developing in Agentic AI Systems

> **Exam:** Microsoft Certified: GitHub Agentic AI Developer  
> **Passing Score:** 700 or higher  
> **Duration:** 60 minutes  
> **Questions:** Scenario-based and practical application  
> **Last Updated:** May 2026

## Exam Overview

GH-600 certifies expertise in **operating, integrating, supervising, and governing AI agents** inside production-grade SDLC workflows. You'll demonstrate the ability to:

- Design agent architectures aligned with SDLC processes
- Implement safe tool use and environment integration
- Manage agent memory, state, and execution
- Evaluate and tune agent behavior
- Orchestrate multi-agent workflows safely
- Implement guardrails and accountability

**Target Audience:** Subject matter experts operating agents in production with GitHub as the system of record, working with architects, platform engineers, developers, and security engineers.

---

## Skill Areas at a Glance

| Skill Area | Weight | Focus |
|-----------|--------|-------|
| **Prepare agent architecture and SDLC processes** | 15–20% | Integration, boundaries, observability |
| **Implement tool use and environment interaction** | 20–25% | Tools, MCP, safe execution paths |
| **Manage memory, state, and execution** | 10–15% | Memory strategies, state persistence, continuity |
| **Perform evaluation, error analysis, and tuning** | 15–20% | Success criteria, failure analysis, optimization |
| **Orchestrate multi-agent coordination** | 15–20% | Multi-agent workflows, conflicts, lifecycle |
| **Implement guardrails and accountability** | 10–15% | Autonomy levels, human-in-the-loop, least privilege |

---

## Skill Area 1: Prepare Agent Architecture and SDLC Processes (15–20%)

### A. Integrate Agents into the Software Development Lifecycle

**Key Concepts:**
- Identify steps for agents to perform within SDLC workflows
- Identify and mitigate common anti-patterns
- Define inputs, outputs, and success criteria

**Best Practices:**
- **Anti-pattern:** Agents making decisions without human verification
- **Solution:** Require explicit approval checkpoints for critical changes
- **Anti-pattern:** Vague success criteria
- **Solution:** Define quantifiable metrics (code coverage, test pass rate, security scans)
- **Anti-pattern:** Agents working without observability
- **Solution:** Generate inspectable artifacts and logs for every decision

**Example Task Definition:**
```
INPUT: Pull request with failing tests
AGENT STEPS:
  1. Analyze test failures (collect evidence)
  2. Generate plan (structured output for review)
  3. Propose fixes (code suggestions)
  4. WAIT for human approval
  5. Submit changes as new PR
OUTPUT: New PR link, test results, analysis report
SUCCESS CRITERIA: All tests pass, no new warnings, reviewer approval
```

### B. Define Boundaries Between Planning, Reasoning, and Action

**Key Concepts:**
- Separate planning from execution
- Output structured plans before taking action
- Validate plans before execution
- Prevent unauthorized action

**Pattern Implementation:**
```
┌─────────────────────────────────────────┐
│ 1. PLANNING PHASE                      │
│ - Analyze context                      │
│ - Generate structured plan             │
│ - Output for human review              │
└─────────────────────────────────────────┘
           ↓ (approval required)
┌─────────────────────────────────────────┐
│ 2. REASONING PHASE                     │
│ - Validate plan assumptions            │
│ - Check for conflicts                  │
│ - Prepare execution steps              │
└─────────────────────────────────────────┘
           ↓ (validation passed)
┌─────────────────────────────────────────┐
│ 3. ACTION PHASE                        │
│ - Execute pre-approved steps           │
│ - Document decisions                   │
│ - Report results                       │
└─────────────────────────────────────────┘
```

**Validation Checklist:**
- [ ] Plan includes all necessary context
- [ ] Plan identifies potential risks
- [ ] Plan specifies rollback strategy
- [ ] Agent has received explicit approval
- [ ] Execution logs all decisions

### C. Configure Observability and Control for Autonomous Agents

**Autonomy Levels:**

| Level | Description | Control | Approval |
|-------|-------------|---------|----------|
| **Level 1: Advisory** | Agent suggests, human executes | Read-only | N/A |
| **Level 2: Gated** | Agent acts after approval | Approval gate | Per-action |
| **Level 3: Scoped** | Agent acts within defined scope | Guardrails | Per-category |
| **Level 4: Autonomous** | Agent acts independently | Audit trail | Post-hoc review |

**Implementing Observability:**
- **Artifacts:** Generate reports, diffs, and analysis in standard formats (JSON, SARIF)
- **Logs:** Structured logs for every decision with context
- **Integration:** Make results available in GitHub UI (PRs, checks, issues)
- **Audit Trail:** Preserve complete execution history for compliance

**Example Configuration:**
```yaml
agent:
  name: "CodeQA"
  autonomy_level: "scoped"
  
  observability:
    artifacts:
      - name: "analysis_report"
        format: "json"
        location: "/artifacts/report.json"
      - name: "code_diff"
        format: "unified"
        location: "/artifacts/changes.diff"
    
    logs:
      level: "debug"
      retention_days: 90
  
  control_points:
    - trigger: "create_pull_request"
      required_approval: true
    - trigger: "merge_to_main"
      required_approval: true
    - trigger: "suggest_refactor"
      required_approval: false
```

---

## Skill Area 2: Implement Tool Use and Environment Interaction (20–25%)

### A. Select and Configure Agent Tools

**Tool Selection Criteria:**
- **Necessity:** Is this tool required for the task?
- **Safety:** Can the tool cause unintended side effects?
- **Scope:** Does the tool operate within acceptable boundaries?
- **Audit:** Can tool usage be fully logged and audited?

**Tool Configuration Pattern:**
```yaml
tools:
  - name: "git_create_branch"
    enabled: true
    permissions:
      - "refs/heads/*"
      - scope: "branch_prefix:codeqa/fix-*"
    rate_limit: 5_per_hour
    audit: true
    
  - name: "code_analysis"
    enabled: true
    permissions:
      - "read:repository"
    parameters:
      max_files: 100
      timeout_seconds: 300
    audit: true
    
  - name: "create_pull_request"
    enabled: true
    permissions:
      - "write:pull_requests"
    constraints:
      - "require_draft: true"
      - "require_description: true"
    audit: true
```

### B. Configure MCP (Model Context Protocol) Servers

**MCP Overview:**
- Standardized protocol for agents to access tools
- Client-server architecture
- Supports GitHub and remote servers
- Registry-based discovery

**MCP Server Types:**
- **GitHub MCP:** Native integration with GitHub API
- **Remote MCP:** SSH/HTTP-based servers
- **Registry MCP:** Discovered via MCP registries

**Configuration Steps:**

1. **Add GitHub MCP Server:**
```json
{
  "mcpServers": {
    "github": {
      "command": "gh-mcp",
      "args": ["serve"],
      "env": {
        "GH_TOKEN": "${GH_TOKEN}"
      }
    }
  }
}
```

2. **Configure Remote MCP Server:**
```json
{
  "remoteServers": {
    "security-scanner": {
      "url": "ssh://scan-server.example.com:2222",
      "auth": "ssh-key",
      "allowlist": ["analyze-code", "check-deps"]
    }
  }
}
```

3. **Set Registry and Allow-list:**
```json
{
  "registry": {
    "url": "https://mcp-registry.github.com/v1",
    "cache_ttl": 3600
  },
  "allowed_mcp_servers": [
    "github/official",
    "npm/security-audit",
    "codeql/analyzer"
  ]
}
```

### C. Integrate Agents Within Development Environments

**Execution Context Evaluation:**
- Repository scope: Single repo vs. organization-wide
- Branch scope: `main` vs. feature branches
- CI/CD integration: When agents run in workflows
- Environment constraints: Network, resource, time limits

**Repository Scope Configuration:**
```yaml
agent:
  scope:
    type: "repository"
    repositories:
      - "owner/repo-name"
    branches:
      - pattern: "main"
        actions: ["analyze", "suggest"]
      - pattern: "develop"
        actions: ["analyze", "suggest", "auto-fix"]
      - pattern: "codeqa/*"
        actions: ["analyze", "suggest", "auto-fix", "create-pr"]
```

**CI Workflow Integration:**
```yaml
name: Agent-Assisted Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  code-qa:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Run CodeQA Agent
        uses: github-agents/codeqa-agent@v1
        with:
          token: ${{ secrets.GH_TOKEN }}
          scope: "current-pr"
          report_format: "sarif"
      
      - name: Upload SARIF Report
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: ./reports/codeqa.sarif
```

### D. Operate Agents with Safe Execution Paths and Robust Error Handling

**Error Handling Strategy:**
```
┌──────────────┐
│ Agent Action │
└──────────────┘
       ↓
┌──────────────────────────────┐
│ Try Execution               │
│ - Monitor for errors        │
│ - Track resource usage      │
└──────────────────────────────┘
       ↓ (error detected)
┌──────────────────────────────┐
│ Error Classification        │
│ - Transient vs. permanent   │
│ - Recoverable vs. critical  │
└──────────────────────────────┘
       ↓
       ├─→ Transient → RETRY (exponential backoff)
       ├─→ Recoverable → ESCALATE (human review)
       └─→ Critical → ROLLBACK (restore previous state)
```

**Implementation Pattern:**
```python
class AgentExecutor:
    def execute_with_safety(self, task):
        for attempt in range(max_retries := 3):
            try:
                result = self.execute(task)
                self.log_success(result)
                return result
            
            except TransientError as e:
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt  # exponential backoff
                    time.sleep(wait_time)
                    continue
                else:
                    self.escalate_to_human(task, e)
            
            except RecoverableError as e:
                self.rollback()
                self.escalate_to_human(task, e)
                return None
            
            except CriticalError as e:
                self.emergency_rollback()
                self.alert_security_team(e)
                return None
        
        return None
```

**Traceability Implementation:**
- Assign unique execution ID to each task
- Log all decisions with timestamp and actor
- Create audit trail in GitHub (PR comments, check runs)
- Generate post-execution reports

---

## Skill Area 3: Manage Memory, State, and Execution (10–15%)

### A. Implement Agent Memory Strategies

**Memory Types:**

| Type | Duration | Scope | Use Case |
|------|----------|-------|----------|
| **Short-term** | Single task | Session | Current context, recent decisions |
| **Long-term** | Persistent | Agent | Learned patterns, historical context |
| **External** | Persistent | Shared | Shared knowledge base, team artifacts |

**Memory Scoping:**
```python
class AgentMemory:
    def __init__(self):
        self.short_term = {}  # Task-specific (auto-clear after task)
        self.long_term = {}   # Agent-specific (persist across tasks)
        self.external = RemoteKnowledgeBase()  # Shared (team-wide)
    
    def remember(self, key, value, scope="short_term", ttl=None):
        """Add to memory with optional time-to-live"""
        if scope == "short_term":
            self.short_term[key] = (value, ttl)
        elif scope == "long_term":
            self.long_term[key] = value
        elif scope == "external":
            self.external.store(key, value)
    
    def recall(self, key, scope="all"):
        """Retrieve from memory"""
        if scope in ["short_term", "all"]:
            if key in self.short_term:
                return self.short_term[key][0]
        if scope in ["long_term", "all"]:
            if key in self.long_term:
                return self.long_term[key]
        if scope in ["external", "all"]:
            return self.external.retrieve(key)
        return None
    
    def prune(self):
        """Remove expired entries"""
        current_time = time.time()
        for key, (value, ttl) in list(self.short_term.items()):
            if ttl and current_time > ttl:
                del self.short_term[key]
```

**Memory Expiration Rules:**
```yaml
memory:
  short_term:
    expiration: 3600  # 1 hour
    max_size: 100_mb
    
  long_term:
    expiration: 2592000  # 30 days
    max_size: 1_gb
    pruning_strategy: "lru"  # Least recently used
    
  external:
    expiration: 7776000  # 90 days
    access_pattern: "shared"
    pruning_strategy: "manual"
```

### B. Persist Agent State and Manage Context Drift

**State Persistence Pattern:**
```python
class AgentState:
    def capture_checkpoint(self, task_id):
        """Create durable artifact of current state"""
        checkpoint = {
            "task_id": task_id,
            "timestamp": datetime.now().isoformat(),
            "progress": self.current_progress,
            "decisions": self.decision_log,
            "memory": self.serialize_memory(),
            "next_steps": self.remaining_steps
        }
        self.persist_to_artifact(checkpoint)
        return checkpoint
    
    def resume_from_checkpoint(self, checkpoint):
        """Resume work without repeating steps"""
        self.verify_checkpoint_integrity(checkpoint)
        self.restore_memory(checkpoint["memory"])
        self.skip_completed_steps(checkpoint["progress"])
        self.restore_decisions(checkpoint["decisions"])
        return checkpoint["next_steps"]
    
    def detect_drift(self, current_state, last_checkpoint):
        """Detect if state has diverged"""
        decisions_unchanged = self.verify_decisions(
            current_state["decisions"],
            last_checkpoint["decisions"]
        )
        if not decisions_unchanged:
            return True  # Context drift detected
        return False
    
    def correct_drift(self, current_state, checkpoint):
        """Correct divergence"""
        self.restore_state(checkpoint)
        self.log_drift_correction(current_state, checkpoint)
```

### C. Ensure Continuity Across Tools and Environments

**State Sharing Pattern:**
```yaml
state_management:
  shared_context:
    format: "json"
    storage: "github-artifacts"
    
  handoff_protocol:
    - source_agent: "analyzer"
      target_agent: "fixer"
      data_to_share:
        - "findings"
        - "recommendations"
        - "execution_context"
      validation: "strict"
    
  conflict_prevention:
    - rule: "prevent_duplicate_work"
      check: "compare_task_ids"
    - rule: "prevent_stale_context"
      check: "verify_timestamps"
      max_age_seconds: 300
    - rule: "lock_shared_resources"
      resources: ["codebase", "deployment"]
      ttl: 3600
```

---

## Skill Area 4: Perform Evaluation, Error Analysis, and Tuning (15–20%)

### A. Define Success Criteria and Evaluation Signals

**Evaluation Framework:**
```yaml
evaluation:
  success_criteria:
    functional:
      - "all_tests_pass: true"
      - "code_coverage >= 80%"
      - "no_new_security_vulnerabilities"
    
    operational:
      - "execution_time <= 300 seconds"
      - "memory_usage <= 512mb"
      - "api_calls <= 1000"
    
    compliance:
      - "adheres_to_style_guide: true"
      - "includes_documentation: true"
      - "peer_review_approved: true"
  
  evaluation_signals:
    quantitative:
      - metric: "test_pass_rate"
        target: 100
        weight: 0.3
      
      - metric: "code_coverage"
        target: 85
        weight: 0.2
      
      - metric: "security_scan_critical_count"
        target: 0
        weight: 0.3
      
      - metric: "performance_degradation"
        target: 0
        weight: 0.2
    
    qualitative:
      - reviewer_feedback
      - code_quality_assessment
      - architectural_alignment
  
  automated_scanning:
    tools:
      - codeql
      - dependabot
      - sonarqube
    format: "sarif"
    fail_on_critical: true
```

### B. Analyze Agent Failures and Identify Root Causes

**Failure Analysis Process:**
```
┌────────────────────────┐
│ Failure Detected       │
└────────────────────────┘
       ↓
┌────────────────────────────────────────┐
│ Collect Evidence                       │
│ - Logs (debug level)                   │
│ - Agent plan (structured output)       │
│ - Execution trace                      │
│ - Tool outputs and errors              │
│ - Workflow artifacts                   │
└────────────────────────────────────────┘
       ↓
┌────────────────────────────────────────┐
│ Classify Root Cause                    │
│ - Reasoning error                      │
│ - Tool misuse                          │
│ - Context/environment issue            │
│ - Permission/access issue              │
│ - Resource exhaustion                  │
└────────────────────────────────────────┘
       ↓
┌────────────────────────────────────────┐
│ Determine Action                       │
│ - Retry with same config               │
│ - Adjust agent instructions            │
│ - Modify tool permissions              │
│ - Scale resources                      │
│ - Escalate to human                    │
└────────────────────────────────────────┘
```

### C. Tune Agent Behavior Based on Results

**Tuning Levers:**

| Lever | Effect | Example |
|-------|--------|---------|
| **Instructions** | Change reasoning approach | Add constraint: "check for X before Y" |
| **Tools** | Modify tool access | Reduce API quota; remove dangerous tools |
| **Memory** | Adjust context availability | Increase short-term memory size |
| **Constraints** | Enforce boundaries | Add approval gate for high-risk changes |
| **Workflows** | Change execution pattern | Add validation step between decisions |

**Tuning Implementation:**
```python
class AgentTuner:
    def analyze_failures(self, failure_log):
        """Categorize failures and identify patterns"""
        patterns = {
            "reasoning_errors": [],
            "tool_misuse": [],
            "context_issues": []
        }
        for failure in failure_log:
            patterns[failure.category].append(failure)
        return patterns
    
    def recommend_tuning(self, patterns):
        """Generate tuning recommendations"""
        recommendations = []
        
        if len(patterns["reasoning_errors"]) > 3:
            recommendations.append({
                "lever": "instructions",
                "change": "Add reasoning constraint",
                "priority": "high"
            })
        
        if len(patterns["tool_misuse"]) > 2:
            recommendations.append({
                "lever": "tools",
                "change": "Restrict tool access",
                "priority": "high"
            })
        
        if len(patterns["context_issues"]) > 1:
            recommendations.append({
                "lever": "memory",
                "change": "Increase context window",
                "priority": "medium"
            })
        
        return recommendations
    
    def apply_tuning(self, recommendation):
        """Apply recommended change"""
        if recommendation["lever"] == "instructions":
            self.agent.add_instruction(recommendation["change"])
        elif recommendation["lever"] == "tools":
            self.agent.restrict_tools(recommendation["change"])
        elif recommendation["lever"] == "memory":
            self.agent.increase_memory(recommendation["change"])
```

---

## Skill Area 5: Orchestrate Multi-Agent Coordination (15–20%)

### A. Operate and Manage Multi-Agent Workflows

**Orchestration Patterns:**

| Pattern | Use Case | Example |
|---------|----------|---------|
| **Sequential** | Task pipeline | Analyzer → Fixer → Tester |
| **Parallel** | Independent work | 3 agents reviewing different files |
| **Hierarchical** | Decision tree | Manager agent → Specialist agents |
| **Mesh** | Complex interactions | All agents can communicate |

**Sequential Pattern:**
```yaml
workflow:
  name: "code-quality-pipeline"
  agents:
    - name: "analyzer"
      task: "analyze_code"
      outputs:
        - "findings.json"
    
    - name: "fixer"
      task: "fix_issues"
      depends_on: "analyzer"
      inputs:
        - "analyzer:findings.json"
      outputs:
        - "fixes.diff"
    
    - name: "tester"
      task: "test_fixes"
      depends_on: "fixer"
      inputs:
        - "fixer:fixes.diff"
      outputs:
        - "test_results.json"
```

**Parallel Pattern with Conflict Detection:**
```yaml
workflow:
  name: "multi-file-analysis"
  parallelism: 3
  agents:
    - name: "reviewer_1"
      files: ["src/core/*"]
    - name: "reviewer_2"
      files: ["src/api/*"]
    - name: "reviewer_3"
      files: ["src/utils/*"]
  
  conflict_detection:
    enabled: true
    checks:
      - overlapping_changes: "reject"
      - contradictory_recommendations: "escalate"
      - duplicate_effort: "deduplicate"
```

### B. Configure Observability for Multi-Agent Behavior

**Multi-Agent Artifact Generation:**
```yaml
artifacts:
  agent_decisions:
    format: "json"
    content:
      - agent_id
      - decision_timestamp
      - decision_rationale
      - confidence_level
    example: |
      {
        "agent_id": "analyzer-001",
        "timestamp": "2026-05-18T10:30:00Z",
        "decision": "security_vulnerability_found",
        "rationale": "SQL injection possible in query builder",
        "confidence": 0.95,
        "evidence": ["line_42", "line_58"]
      }
  
  handoff_log:
    format: "jsonl"
    content:
      - from_agent
      - to_agent
      - data_passed
      - validation_result
  
  coordination_report:
    format: "markdown"
    sections:
      - workflow_summary
      - agent_activities (timeline)
      - decisions_made
      - conflicts_resolved
      - final_outcome
```

### C. Detect and Respond to Multi-Agent Failures

**Failure Detection:**
```python
class MultiAgentHealthMonitor:
    def check_agent_status(self, agent_id):
        """Assess individual agent health"""
        return {
            "running": self.is_running(agent_id),
            "responsive": self.ping(agent_id),
            "error_rate": self.get_error_rate(agent_id),
            "last_heartbeat": self.get_last_heartbeat(agent_id),
            "resource_usage": self.get_resource_usage(agent_id)
        }
    
    def detect_workflow_degradation(self):
        """Identify overall workflow issues"""
        issues = []
        
        # Stalled agents
        for agent in self.agents:
            status = self.check_agent_status(agent.id)
            if self.is_stalled(status):
                issues.append(f"Agent {agent.id} stalled")
        
        # Conflicts
        if self.has_overlapping_changes():
            issues.append("Conflicting code changes detected")
        
        # Deadlocks
        if self.has_circular_dependency():
            issues.append("Workflow deadlock detected")
        
        return issues
    
    def recovery_strategy(self, issue):
        """Select recovery approach"""
        if "stalled" in issue:
            return "restart_agent"
        elif "conflict" in issue:
            return "resolve_conflict"
        elif "deadlock" in issue:
            return "rollback_workflow"
        else:
            return "escalate_human"
```

**Multi-Agent Recovery Pattern:**
```
┌──────────────────────────────┐
│ Failure Detected             │
│ (degradation, conflict, etc) │
└──────────────────────────────┘
       ↓
┌──────────────────────────────┐
│ Isolate Problem              │
│ - Stop dependent agents      │
│ - Preserve state             │
└──────────────────────────────┘
       ↓
       ├─→ Transient → Restart affected agent
       ├─→ Conflict → Resolve and retry
       └─→ Critical → Rollback entire workflow
       ↓
┌──────────────────────────────┐
│ Restart Workflow             │
│ - Resume from checkpoint     │
│ - Skip completed stages      │
│ - Continue execution         │
└──────────────────────────────┘
```

### D. Manage Agent Lifecycle

**Agent Addition to Existing Workflow:**
```yaml
workflow_update:
  operation: "add_agent"
  agent:
    name: "security-reviewer"
    task: "security_analysis"
    position: "after:code-fixer"
  
  validation:
    - can_accept_inputs_from: "code-fixer"
    - produces_outputs_for: "test-runner"
    - has_required_permissions: true
  
  migration_strategy:
    existing_runs: "continue-without-new-agent"
    new_runs: "include-new-agent"
```

**Agent Retirement Pattern:**
```yaml
agent_retirement:
  agent: "legacy-linter"
  
  decommission_plan:
    phase_1:
      duration: "1 week"
      status: "deprecated"
      warning: "Agent will be retired soon"
    
    phase_2:
      duration: "2 weeks"
      status: "read-only"
      action: "Accept results but block new tasks"
    
    phase_3:
      status: "retired"
      action: "Remove from workflows"
    
  preservation:
    archive_logs: true
    preserve_artifacts: true
    migration_path: "to-new-linter-agent"
```

---

## Skill Area 6: Implement Guardrails and Accountability (10–15%)

### A. Define Autonomy Levels

**Risk-Based Autonomy Classification:**

| Risk Level | Action Type | Example | Autonomy |
|-----------|-------------|---------|----------|
| **Low** | Suggestion/analysis | Code review findings | Advisory |
| **Low-Medium** | Automated fix | Auto-format code | Gated with confirmation |
| **Medium** | Feature addition | Add utility function | Scoped + approval |
| **Medium-High** | Config change | Update CI settings | Scoped + approval |
| **High** | Deletion | Remove deprecated code | Manual only |
| **Critical** | Deployment | Merge to production | Manual + audit trail |

**Risk Assessment Framework:**
```python
class RiskClassifier:
    def classify(self, action):
        """Determine risk level and autonomy"""
        risk_score = 0
        
        # Impact assessment
        if action.affects_security:
            risk_score += 50
        if action.affects_deployment:
            risk_score += 40
        if action.is_irreversible:
            risk_score += 30
        if action.affects_production:
            risk_score += 50
        
        # Scope assessment
        if action.scope == "organization":
            risk_score += 20
        elif action.scope == "repository":
            risk_score += 10
        elif action.scope == "branch":
            risk_score += 5
        
        # Determine autonomy
        if risk_score >= 100:
            return "manual-only"
        elif risk_score >= 70:
            return "scoped-with-approval"
        elif risk_score >= 40:
            return "gated-with-confirmation"
        else:
            return "advisory"
```

### B. Implement Guardrails and Human-in-the-Loop Workflows

**Guardrail Types:**

| Type | Purpose | Example |
|------|---------|---------|
| **Policy guardrail** | Enforce rules | "No secrets in code" |
| **Scope guardrail** | Limit domain | "Only modify docs, not core" |
| **Permission guardrail** | Control access | "Create PR but not merge" |
| **Time guardrail** | Enforce timing | "Changes only during business hours" |

**Implementation:**
```python
class Guardrails:
    def __init__(self):
        self.policy_rules = []
        self.scope_limits = {}
        self.permissions = {}
        self.time_constraints = {}
    
    def check_action(self, agent_action):
        """Validate action against all guardrails"""
        violations = []
        
        # Check policies
        for rule in self.policy_rules:
            if not rule.validate(agent_action):
                violations.append({
                    "type": "policy",
                    "rule": rule.name,
                    "action": "block"
                })
        
        # Check scope
        if not self.is_within_scope(agent_action):
            violations.append({
                "type": "scope",
                "reason": "outside_allowed_domain",
                "action": "block"
            })
        
        # Check permissions
        if not self.has_permission(agent_action):
            violations.append({
                "type": "permission",
                "required": agent_action.required_permission,
                "action": "escalate"
            })
        
        # Check timing
        if not self.is_within_time_window(agent_action):
            violations.append({
                "type": "timing",
                "reason": "outside_approved_hours",
                "action": "defer"
            })
        
        return violations
    
    def determine_action(self, violations):
        """Decide on guardrail violation response"""
        if not violations:
            return "proceed"
        
        actions = [v["action"] for v in violations]
        
        if "block" in actions:
            return "reject"  # Don't allow at all
        elif "escalate" in actions:
            return "require-approval"  # Require human approval
        elif "defer" in actions:
            return "schedule"  # Schedule for later
        else:
            return "proceed"
```

**Human-in-the-Loop Workflow:**
```yaml
approval_workflow:
  triggers:
    - high_risk_action
    - guardrail_violation
    - policy_override
  
  approval_process:
    - step: "request_review"
      reviewers: "security-team"
      timeout: 3600
    
    - step: "capture_justification"
      required_for: "override"
      fields: ["reason", "risk_acceptance", "owner"]
    
    - step: "record_decision"
      audit_trail: true
      include: ["who", "what", "when", "why"]
  
  approval_levels:
    - level: "standard"
      min_approvers: 1
      for_actions: ["code_changes", "feature_addition"]
    
    - level: "elevated"
      min_approvers: 2
      for_actions: ["config_change", "permission_grant"]
    
    - level: "security"
      min_approvers: "security-lead"
      for_actions: ["security_policy_bypass"]
```

### C. Scope Permissions and Enforce Least-Privilege Access

**Least-Privilege Architecture:**
```yaml
agent_permissions:
  base:
    read: true  # Can always read
    write: false
    delete: false
    approve: false
  
  capabilities:
    analyze_code:
      scopes: ["read:code", "read:tests"]
      resources: ["*"]
    
    suggest_changes:
      scopes: ["read:code", "write:pull_requests"]
      resources: ["feature-branches/*"]
      constraints: "must_create_draft: true"
    
    approve_changes:
      scopes: ["write:pull_requests", "approve:changes"]
      resources: ["main-branch"]
      constraints: "requires_security_check: true"
    
    merge_code:
      scopes: ["write:code", "write:pull_requests"]
      resources: ["develop-branch"]
      constraints: "requires_approval: true"
  
  revoke_immediately: true
  audit_all_usage: true
```

**Enforcement:**
```python
class PermissionEnforcer:
    def can_perform_action(self, agent_id, action, resource):
        """Check if agent has permission"""
        agent_perms = self.get_agent_permissions(agent_id)
        
        # Check if action is in capabilities
        if action not in agent_perms["capabilities"]:
            return False, "action_not_permitted"
        
        capability = agent_perms["capabilities"][action]
        
        # Check resource scope
        if not self.matches_resource_pattern(resource, capability["resources"]):
            return False, "resource_out_of_scope"
        
        # Check constraints
        for constraint in capability.get("constraints", []):
            if not self.validate_constraint(constraint):
                return False, f"constraint_failed: {constraint}"
        
        # Log access
        self.audit_log(agent_id, action, resource, "granted")
        return True, "permitted"
```

---

## First-Try Prep Feature: 3-Day Cram Plan

Use this when you want the guide to function as an exam-ready feature, not just reference material.

### Day 1: Core Concepts

- Read the full guide once end to end.
- Focus on agent architecture, SDLC integration, tool use, memory/state, evaluation, multi-agent coordination, and guardrails.
- Write a one-page summary for each skill area.
- For each area, answer: what it is, why it matters, what can go wrong, and how to control it.

### Day 2: Scenario Practice

- Do 6 to 10 timed scenarios.
- Force yourself to choose between safety, speed, approval, observability, and least privilege.
- Practice explaining tradeoffs out loud in 60 seconds or less.
- Revisit the sections on planning vs. action, observability, error recovery, tuning, orchestration, and guardrails.

### Day 3: Final Pass

- Take a full mock run with no notes for 60 minutes.
- Mark every question you were unsure about and review only those topics.
- Memorize the recurring exam patterns: human-in-the-loop for risky actions, explicit approvals for high-impact changes, scoped tools, logs and traceability, and separate planning from execution.
- Do a final skim of your one-page summaries.

### Last-Hour Checklist

- Can you explain autonomy levels?
- Can you pick the right tool scope?
- Can you decide when to escalate to a human?
- Can you describe how to recover from agent failure?
- Can you justify observability and audit requirements?

---

## Hard Practice Tests

Use the dedicated hard-mode practice tests to pressure-test your readiness before you spend money on the exam.

- [GH-600 Hard Practice Tests](./gh-600-practice-tests.md) - Two difficult practice exams with answer keys, scoring guidance, and a fast-pass checklist.
- [GH-600 Native Mock Exam](./gh-600-native-mock-exam.html) - Native browser exam mode with 60 timed questions, automatic scoring, study mode, flash cards, keyboard shortcuts, read-aloud mode, and answer reveal with explanations.
- [GH-600 Training Game](./gh-600-training-game.html) - Tetris-style quiz game: answer correctly to unlock piece control, route drops into the right zone, and climb the scoreboard.

---

## Study Tips & Resources

### Key Concepts to Master
1. **SDLC Integration:** How agents fit into the development lifecycle
2. **Safety First:** Always design for human oversight and control
3. **Observability:** Make agent decisions transparent and auditable
4. **Evaluation:** Define clear success metrics before deployment
5. **Coordination:** Orchestrate multiple agents without chaos
6. **Accountability:** Maintain audit trails and control points

### Practice Scenarios
- **Scenario 1:** Design an agent to automate code reviews with appropriate guardrails
- **Scenario 2:** Implement error recovery for an agent that failed mid-task
- **Scenario 3:** Set autonomy levels for agents working on different repositories
- **Scenario 4:** Coordinate two agents working on interdependent tasks
- **Scenario 5:** Analyze agent failure logs and recommend tuning changes

### Recommended Resources
- **Microsoft Learn:** Foundations of Agentic AI in GitHub
- **GitHub Docs:** Agent Framework, Tools, MCP Servers
- **GitHub Blog:** Latest agent patterns and best practices
- **Community:** GitHub Community Discussions for GH-600 topics

### Exam Tips
- **Read carefully:** Scenario-based questions require attention to detail
- **Consider tradeoffs:** Autonomy vs. safety, speed vs. reliability
- **Think operations:** Focus on production considerations, not just initial setup
- **Review failures:** Understand error handling and recovery patterns
- **Remember accountability:** Always include audit trails and controls

---

**Last Updated:** May 18, 2026  
**Version:** 1.0  
**Certification:** Microsoft Certified: GitHub Agentic AI Developer (GH-600)
