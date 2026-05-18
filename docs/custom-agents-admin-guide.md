# Copilot Custom Agents: Organization Administration Guide

> **Status:** Organization Administration  
> **Audience:** Organization Owners, Admins  
> **Prerequisites:** [GH-600 Exam Guide](../gh-600-exam-guide.md)  
> **Status:** Public Preview  
> **Last Updated:** May 2026

## Overview

This guide covers setting up and administering custom agents at the organization level. Custom agents allow organizations to create specialized Copilot instances tailored to specific domains, workflows, and team needs.

**Scope of This Guide:**
- Organization setup and prerequisites
- Repository structure and initialization
- Access control and permissions
- Agent lifecycle management
- Compliance and governance considerations

---

## Quick Reference

### Setup Checklist
- [ ] Verify organization owner status
- [ ] Check enterprise restrictions (if applicable)
- [ ] Create `.github-private` repository from template
- [ ] Set visibility (Internal or Private)
- [ ] Update README with organization guidelines
- [ ] Define agent creation policy
- [ ] Configure access controls
- [ ] Document compliance requirements
- [ ] Plan agent versioning strategy
- [ ] Set up monitoring and audit logs

### Repository Structure
```
.github-private/
├── README.md                      # Organization guidelines & policies
├── agents/
│   ├── agent-template.md          # Template for new agents
│   └── [agent-name]/
│       ├── agent.yaml            # Agent configuration
│       ├── instructions.md        # Agent system prompt
│       ├── tools.yaml            # Tool definitions
│       └── examples/
│           └── example-usage.md   # Usage examples
├── policies/
│   ├── creation-guidelines.md     # How to create agents
│   ├── security-requirements.md   # Security checklist
│   ├── compliance-checklist.md    # Compliance requirements
│   └── approval-process.md        # Review & approval workflow
└── tools/
    ├── shared-tools.yaml         # Organization-wide tools
    └── integrations/
        └── [integration-name].md  # Integration docs
```

---

## Prerequisites

### Who Can Use This Feature?
- **Organization Owners** (full access)
- **Organization Admins** (delegated access)
- Enterprise Owners (can restrict via rulesets)

### Requirements
1. **GitHub Organization** with Copilot subscription
2. **Understanding** of what custom agents are and how they work
3. **Template Repository** access: https://github.com/github/custom-agents-template
4. **Enterprise Restrictions** check (if applicable)

### Enterprise Restrictions
If your organization is part of an enterprise:
- Enterprise owners may configure rulesets restricting custom agents
- Check with enterprise owners before proceeding
- Request permissions if needed

---

## Part 1: Organization Setup

### Step 1: Access Enterprise Settings (If Applicable)

**Check enterprise restrictions:**
```bash
# Contact enterprise owners to verify:
- Can organization create custom agents?
- Are there approved agent templates?
- What compliance requirements apply?
- Who can approve new agents?
```

**Enterprise Configuration Points:**
- Whitelist/Blacklist of organization agents
- Mandatory compliance policies
- Audit and logging requirements
- Approval workflows
- Tool restrictions

### Step 2: Create `.github-private` Repository

**From Template:**
1. Go to: https://github.com/github/custom-agents-template
2. Click **Use this template**
3. Choose owner: **Your Organization**
4. Repository name: **`.github-private`** (exact name required)
5. Description: "Custom agents hub for [Organization Name]"
6. Visibility: Choose one:
   - **Internal** (recommended): All org members can read
   - **Private**: Manually grant access after creation

**Via GitHub CLI:**
```bash
gh repo create .github-private \
  --template=github/custom-agents-template \
  --public=false \
  --internal \
  --org=your-organization
```

### Step 3: Configure Repository Permissions

**Internal Visibility:**
```yaml
# All organization members have read access
# Admins can approve and merge agent changes
# Non-admins can suggest agents via pull requests
```

**Private Visibility with CODEOWNERS:**
```yaml
# .github/CODEOWNERS
# Define who approves agent changes

# All agent changes need approval from agents team
agents/ @your-org/agents-team

# Security-related changes need security review
policies/security-* @your-org/security-team

# Enterprise compliance changes
policies/compliance-* @your-org/compliance-team
```

**Example Access Control:**
```yaml
access_control:
  agent_creation:
    role: "org-member"
    approval: "agents-team"
  
  agent_modification:
    role: "agent-author"
    approval: "agents-team-lead"
  
  agent_deletion:
    role: "agents-team"
    approval: "org-owner"
  
  tool_addition:
    role: "agents-team"
    approval: "security-team"
```

### Step 4: Update Organization README

**Critical Content for `.github-private/README.md`:**

```markdown
# Custom Agents Repository for [Organization]

This repository stores custom Copilot agents for our organization.

## Agent Creation Guidelines

### Before Creating an Agent
- [ ] Agent addresses a real organizational need
- [ ] Documentation plan in place
- [ ] Security review completed
- [ ] Tool permissions reviewed
- [ ] Compliance requirements identified

### Agent Naming Convention
- Use kebab-case: `analysis-agent`, `code-reviewer`
- Prefix with department if applicable: `data-analysis-agent`
- Avoid generic names: Not "helper" but "data-transformation-helper"

### Directory Structure
```
agents/[agent-name]/
├── agent.yaml           # Configuration
├── instructions.md      # System prompt & behavior
├── tools/              # Required tools list
└── examples/           # Usage examples
```

### Required Documentation
- [ ] Purpose and use case
- [ ] System prompt (in `instructions.md`)
- [ ] Tools and permissions needed
- [ ] Example usage scenarios
- [ ] Known limitations

### Security Checklist
- [ ] All tool access follows least privilege
- [ ] No hardcoded secrets or credentials
- [ ] Sensitive data handling documented
- [ ] External API calls reviewed
- [ ] Rate limiting considerations
- [ ] Error handling for failures

### Compliance & Governance
- [ ] Compliance requirements identified
- [ ] Data retention policy specified
- [ ] Audit logging enabled
- [ ] Responsible AI considerations
- [ ] Enterprise policies adherence

### Approval Process
1. Submit pull request to `.github-private`
2. Agents team reviews for guidelines compliance
3. Security team reviews tool permissions
4. Compliance team verifies requirements
5. Merge to main branch

## Organization Policies

See `/policies/` directory for:
- Creation guidelines
- Security requirements
- Compliance checklist
- Approval workflow

## Available Tools

Organization-wide tools available in `/tools/shared-tools.yaml`

For tool requests, see [Tool Request Process](./policies/tool-request-process.md)

## Support

- Questions: Start a discussion in the org
- Issues: Use GitHub Issues in this repo
- Urgent: Contact @agents-team
```

---

## Part 2: Agent Lifecycle Management

### Creation Phase

**Agent Request Template** (`agents/agent-template.md`):
```markdown
# [Agent Name] - Proposal

## Purpose
Briefly describe what this agent does.

## Use Case
Specific workflows or problems this agent solves.

## Key Capabilities
- Capability 1
- Capability 2
- Capability 3

## Required Tools
- Tool 1
- Tool 2

## Data Handled
- What data does it access?
- How is sensitive data protected?

## Estimated Usage
- Who will use this? (teams/roles)
- How frequently?

## Success Metrics
- How will we measure effectiveness?

## Compliance Notes
- Any regulations that apply?
- Data retention requirements?

## Approval Checklist
- [ ] Documented use case
- [ ] Tools reviewed for safety
- [ ] Security team approved
- [ ] Compliance requirements identified
```

### Approval Workflow

```
┌──────────────────────┐
│ Agent Proposed       │
│ (Pull Request)       │
└──────────────────────┘
       ↓
┌──────────────────────────────┐
│ Review Phase                 │
│ - Guidelines compliance      │
│ - Tool permissions           │
│ - Documentation quality      │
└──────────────────────────────┘
       ↓
       ├─→ REQUEST CHANGES → Author updates
       │
       └─→ APPROVED ↓
┌──────────────────────────────┐
│ Security Review              │
│ - Tool access validation     │
│ - API permission check       │
│ - Sensitive data handling    │
└──────────────────────────────┘
       ↓
       ├─→ REQUEST CHANGES → Author updates
       │
       └─→ APPROVED ↓
┌──────────────────────────────┐
│ Compliance Review (if needed)│
│ - Data governance            │
│ - Regulatory requirements    │
│ - Audit trail setup          │
└──────────────────────────────┘
       ↓
       ├─→ REQUEST CHANGES → Author updates
       │
       └─→ APPROVED ↓
┌──────────────────────────────┐
│ MERGED to main               │
│ Agent Active                 │
└──────────────────────────────┘
```

### Deployment Phase

**Agent Activation Checklist:**
- [ ] All approvals obtained
- [ ] Documentation published
- [ ] Team training completed
- [ ] Monitoring configured
- [ ] Rollback plan documented
- [ ] Support contacts identified

**Monitoring Setup:**
```yaml
monitoring:
  usage_metrics:
    - active_users
    - daily_invocations
    - average_response_time
  
  error_tracking:
    - failed_requests
    - error_categories
    - escalation_patterns
  
  quality_metrics:
    - user_satisfaction
    - error_rate
    - tool_success_rate
  
  security_monitoring:
    - unauthorized_access_attempts
    - unusual_tool_usage
    - data_access_patterns
```

### Maintenance Phase

**Regular Reviews** (Quarterly):
- [ ] Usage metrics analysis
- [ ] Error patterns review
- [ ] User feedback assessment
- [ ] Security audit
- [ ] Compliance check
- [ ] Tool permissions validation

**Updates and Patches:**
```yaml
update_process:
  security_patches:
    severity: critical
    lead_time: immediate
    review: security-team
  
  feature_updates:
    severity: minor
    lead_time: 2_weeks
    review: agents-team
  
  capability_deprecation:
    severity: varies
    lead_time: 30_days
    review: stakeholders
```

### Retirement Phase

**Agent Deprecation Process:**

```
Phase 1: ANNOUNCEMENT (Week 1)
├─ Notify all users
├─ Announce sunset date (60-90 days)
├─ Recommend replacement agents
└─ Document migration path

Phase 2: REDUCED SUPPORT (Week 2-4)
├─ No new features added
├─ Bug fixes only for critical issues
├─ Support queries directed to replacements
└─ Usage metrics monitored

Phase 3: READ-ONLY (Week 5-8)
├─ Agent inaccessible for new sessions
├─ Existing sessions continue
├─ Final analytics collected
└─ Data export available

Phase 4: ARCHIVED (Week 9+)
├─ Agent removed from active list
├─ Repository branch archived
├─ Audit logs preserved (compliance-dependent)
└─ Documentation kept for reference
```

**Retirement Documentation:**
```markdown
# [Agent Name] - Retirement Notice

## Timeline
- Announcement: [Date]
- Final Support: [Date]
- Deactivation: [Date]
- Archive: [Date]

## Replacement Agents
- Use [New Agent Name] for [Capability]
- Use [Alternative Agent] for [Use Case]

## Migration Guide
[Step-by-step migration instructions]

## Data & Audit Trail
- Data exported to: [Location]
- Retention period: [Duration]
- Audit logs: [Storage location]
```

---

## Part 3: Compliance & Governance

### Security Requirements Checklist

**Agent Configuration Security:**
- [ ] Agent instructions don't contain secrets
- [ ] Tool credentials use secure storage (e.g., GitHub Secrets)
- [ ] No PII in agent system prompts
- [ ] Error messages don't leak sensitive info

**Tool Permissions:**
- [ ] Each tool has minimum required permissions
- [ ] No broad "all access" grants
- [ ] Tool actions are reversible where possible
- [ ] Dangerous operations logged

**Data Handling:**
- [ ] Specify what data agent can access
- [ ] Document data retention policies
- [ ] Implement data minimization
- [ ] Handle deletion requests

**Audit & Logging:**
- [ ] All agent invocations logged
- [ ] User identity captured
- [ ] Tool usage tracked
- [ ] Decisions recorded
- [ ] Logs retained per policy

**Example Security Policy:**
```yaml
security_policy:
  agent_permissions:
    read_only: ["repository", "issues", "pull_requests"]
    write_limited: ["pull_requests:comment"]
    restricted: ["repository:admin", "organization:admin"]
  
  data_handling:
    pii_treatment: "minimum"
    external_api_calls: "approved_list_only"
    cache_sensitive_data: false
    retention_days: 90
  
  audit:
    log_level: "info"
    log_retention_days: 365
    sensitive_action_alert: true
    monthly_review: true
```

### Compliance Requirements

**Typical Organizational Checklist:**

| Requirement | Implementation | Verification |
|-----------|----------------|--------------|
| **Data Governance** | Agent data access policy | Quarterly audit |
| **Responsible AI** | Agent behavior guidelines | Monthly review |
| **Security** | Tool permission restrictions | Per-agent review |
| **Compliance** | Data retention documented | Compliance team approval |
| **Audit Trail** | All usage logged | Logs retained per policy |
| **Accessibility** | Documentation clarity | User testing |
| **Support** | Team trained & available | Response time SLA |

**Example Compliance Checklist:**
```markdown
# Agent Compliance Checklist

## Data Governance ✓
- [ ] Data sources documented
- [ ] Data access minimized
- [ ] Retention policy specified
- [ ] Deletion procedures defined

## Responsible AI ✓
- [ ] Bias considerations documented
- [ ] Limitations clearly stated
- [ ] User guidance provided
- [ ] Escalation paths defined

## Security ✓
- [ ] Tool permissions reviewed
- [ ] API authentication secure
- [ ] No credentials hardcoded
- [ ] Error messages sanitized

## Compliance ✓
- [ ] Regulatory requirements identified
- [ ] Compliance team approved
- [ ] Audit trail enabled
- [ ] Retention policy documented

## Operational ✓
- [ ] Team trained
- [ ] Documentation complete
- [ ] Support contacts identified
- [ ] Monitoring configured
```

---

## Part 4: Tools Management

### Shared Tools Repository

**Organization-wide tools available in `tools/shared-tools.yaml`:**

```yaml
tools:
  repository_access:
    - list_issues
    - list_pull_requests
    - search_code
    - get_file_content
    - create_pull_request
    - add_pr_comment
  
  code_analysis:
    - run_codeql
    - analyze_dependencies
    - check_security_advisories
  
  documentation:
    - search_documentation
    - generate_api_docs
  
  integration:
    - slack_notification
    - jira_update
    - linear_sync

tools_request_process:
  submit: "Create issue in .github-private"
  review: "Security + Compliance teams"
  approval: "Agents team lead"
  rollout: "Add to shared-tools.yaml"
```

### Tool Request Workflow

**Request Template:**
```markdown
# Tool Request: [Tool Name]

## Purpose
What capability does this tool add?

## Use Cases
- Use case 1
- Use case 2

## Permissions Required
- Permission 1
- Permission 2

## Security Considerations
- Risks identified
- Mitigations proposed

## Compliance Impact
- Data handling requirements
- Audit logging needs
- Retention policies

## Approval Chain
- [ ] Security team: ___
- [ ] Compliance team: ___
- [ ] Agents team lead: ___
```

---

## Part 5: Monitoring & Metrics

### Agent Observability

**Key Metrics to Track:**

```yaml
usage_metrics:
  daily_active_users: "Number of users invoking agent daily"
  invocation_count: "Total agent invocations"
  average_session_length: "Time per session"
  tool_usage_breakdown: "Which tools are most used"
  
performance_metrics:
  response_time_p50: "Median response time"
  response_time_p95: "95th percentile response time"
  tool_success_rate: "Percentage of tool calls succeeding"
  agent_error_rate: "Percentage of failed requests"
  
quality_metrics:
  user_satisfaction: "NPS or thumbs up/down"
  solution_effectiveness: "Did agent solve the problem?"
  false_positive_rate: "Incorrect recommendations"
  escalation_rate: "Requests needing human review"
  
security_metrics:
  unauthorized_access_attempts: "Login/permission violations"
  suspicious_tool_usage: "Unusual patterns detected"
  data_breach_incidents: "Security events"
  tool_permission_violations: "Calls outside scope"
```

### Dashboard Recommendations

**Monthly Review Dashboard:**
- Total invocations (trending)
- Active users (trending)
- Top use cases
- Error rate breakdown
- Response time histogram
- Tool usage breakdown
- User satisfaction score
- Security incidents (if any)

**Quarterly Deep-Dive:**
- Compare to previous quarters
- Identify trending use cases
- Deprecation candidates
- Expansion opportunities
- Security vulnerabilities
- Compliance risks

---

## Part 6: Best Practices

### Agent Design Patterns

**Well-Scoped Agent:**
```yaml
# ✓ GOOD: Focused, documented scope
name: "code-reviewer"
purpose: "Review Python code for style and security"
scope: "Pull requests in python-projects"
tools:
  - read_code
  - add_pr_comment
capabilities:
  - Identify style violations
  - Flag security concerns
  - Suggest improvements
limitations:
  - Does not merge PRs
  - Does not run tests
  - Does not approve deployments
```

**Poorly-Scoped Agent:**
```yaml
# ✗ BAD: Vague, overreaching scope
name: "helper"
purpose: "Help with things"
tools:
  - all_tools_granted
capabilities: "Does everything"
limitations: "None documented"
```

### Documentation Best Practices

**Complete Agent Documentation:**
```markdown
# Agent Name

## What It Does
[Clear 1-2 sentence description]

## When to Use
- Scenario 1
- Scenario 2

## When NOT to Use
- Scenario where it won't work
- Scenario requiring human judgment

## How to Use
1. Step 1
2. Step 2
3. Step 3

## Examples
- Example 1: [Input] → [Output]
- Example 2: [Input] → [Output]

## Known Limitations
- Limitation 1
- Limitation 2

## Support
- Questions: @team-name
- Issues: GitHub Issues
- Urgent: Slack #channel
```

### Access Control Best Practices

**Principle of Least Privilege:**
```yaml
# For each agent, grant ONLY needed permissions

agent: "code-reviewer"
permissions:
  # ✓ GOOD: Only read and comment
  allowed:
    - read:pull_requests
    - write:pull_request_comments
  
  # ✗ BAD: Would grant unnecessary access
  never:
    - write:repository_admin
    - delete:pull_requests
    - approve:changes  # Human job
```

---

## Troubleshooting

### Common Issues

**Issue: Agent not appearing in organization**
- Verify `.github-private` repository exists
- Check repository visibility is Internal or Private
- Wait up to 5 minutes for sync
- Verify organization membership

**Issue: Tool permissions not working**
- Confirm tool declared in `agent.yaml`
- Check organization tool access grants
- Verify GitHub App has required permissions
- Review enterprise restrictions

**Issue: Users can't access agent**
- Check internal/private visibility setting
- Confirm user is organization member
- Verify agent is approved and active
- Check if enterprise disabled the agent

**Issue: Compliance review stuck**
- Clarify specific requirement in comments
- Reference compliance policy docs
- Request compliance team guidance
- Schedule discussion if needed

---

## Resources

- [Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents)
- [GitHub Custom Agents Template](https://github.com/github/custom-agents-template)
- [Testing and Releasing Custom Agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/test-custom-agents)
- [GitHub Copilot Best Practices](https://docs.github.com/en/copilot)

---

**Last Updated:** May 2026  
**Status:** Organization Administration Guide  
**Next:** See [Testing and Releasing Custom Agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/test-custom-agents)
