---
layout: default
title: Custom Agent - Implementation Planner
description: Complete guide to creating and using the Implementation Planner custom agent for feature breakdown, technical planning, and generating actionable implementation plans.
---

# Custom Agent: Implementation Planner

**Status:** Tutorial | **Last Updated:** May 2026 | **Applies to:** Copilot Cloud Agent with custom agents

## Overview

The Implementation Planner is a specialized custom agent that helps technical teams break down features into actionable tasks and create detailed implementation plans. Rather than manually documenting requirements, specifications, and rollout strategies, this agent analyzes requirements and generates comprehensive markdown plans that development teams can follow.

### What It Does

```
Input:  "Create a detailed implementation plan for adding user 
         authentication to our web app"
         
Output: 📋 Comprehensive markdown document with:
        ✓ Overview & success criteria
        ✓ Technical approach & architecture
        ✓ Phased implementation breakdown
        ✓ Risk assessment & mitigation
        ✓ Dependency mapping
        ✓ Timeline & effort estimates
```

### When to Use

| Scenario | Good Fit? |
|----------|-----------|
| Breaking down a major feature | ✅ Excellent |
| Planning a large refactor | ✅ Excellent |
| Documenting migration strategies | ✅ Excellent |
| Creating onboarding for new systems | ✅ Good |
| Analyzing quick bug fixes | ❌ Overkill |
| Reviewing pull requests | ❌ Wrong tool |

---

## Table of Contents

1. [Agent Profile](#agent-profile)
2. [Setup Instructions](#setup-instructions)
3. [Using the Agent](#using-the-agent)
4. [Plan Structure](#plan-structure)
5. [Best Practices](#best-practices)
6. [Examples](#examples)
7. [Variations & Customization](#variations--customization)
8. [Integration Patterns](#integration-patterns)
9. [Troubleshooting](#troubleshooting)

---

## Agent Profile

### Configuration

Save this as `.github/agents/implementation-planner.agent.md` in your repository:

```yaml
---
name: implementation-planner
description: Creates detailed implementation plans and technical specifications in markdown format
tools: ["read", "search", "edit"]
---

You are a technical planning specialist focused on creating comprehensive implementation plans. Your responsibilities:

- Analyze requirements and break them down into actionable tasks with clear scope
- Create detailed technical specifications and architecture documentation
- Generate implementation plans with clear steps, dependencies, and realistic timelines
- Document API designs, data models, and system interactions
- Create markdown files with structured plans that development teams can follow

When creating implementation plans, use this structure (adapt sections based on project size):

## Overview
- What problem are we solving and why?
- Success criteria (what does "done" look like?)
- Who will use this and how?

## Technical Approach
- High-level architecture and key technology choices
- Important APIs, data structures, or integrations
- Major technical decisions and trade-offs

## Implementation Plan

Break work into logical phases. For smaller projects, phases might be days; for larger ones, weeks or sprints:

**Phase 1: Foundation**
- Set up core structure (models, database, basic framework)
- Essential configuration and dependencies

**Phase 2: Core Functionality**
- Primary features and user workflows
- Business logic and key integrations

**Phase 3: Polish & Deploy**
- Error handling, testing, and edge cases
- Documentation and deployment preparation

For each phase, list specific tasks with complexity estimates (Small/Medium/Large) and any dependencies.

## Considerations
- **Assumptions**: What are we taking for granted?
- **Constraints**: Time, budget, or technical limitations
- **Risks**: What could go wrong and how to handle it?

## Not Included
- Features or improvements saved for later versions
- Nice-to-have items that aren't essential

Adjust the detail level based on your needs - solo projects might need less formal documentation, while team projects benefit from more thorough planning. Focus on creating a roadmap that helps you stay organized and make progress.
```

### Agent Properties Explained

| Property | Value | Purpose |
|----------|-------|---------|
| `name` | implementation-planner | Unique identifier for the agent |
| `description` | Creates detailed implementation plans... | Helps runtime select agent; shown in UI |
| `tools` | ["read", "search", "edit"] | Agent can read files, search codebase, edit files |

**Why These Tools?**
- `read` — Review existing code and documentation
- `search` — Find patterns and examples in codebase
- `edit` — Create and update plan markdown files

---

## Setup Instructions

### Step 1: Create the Agent File

```bash
# In your repository root
mkdir -p .github/agents
touch .github/agents/implementation-planner.agent.md
```

### Step 2: Add the Agent Profile

Copy the configuration from [Agent Profile](#agent-profile) section above into `.github/agents/implementation-planner.agent.md`

### Step 3: Commit to Repository

```bash
git add .github/agents/implementation-planner.agent.md
git commit -m "feat: add Implementation Planner custom agent"
git push origin main
```

### Step 4: Register in Copilot

1. Go to https://github.com/copilot/agents
2. Use dropdown menus to select your repository and branch
3. Click the **+** button → **Create custom agent**
4. Select "implementation-planner" from the agent list
5. Start using the agent!

### Verification

After setup, you should see:
- ✅ Agent appears in dropdown at github.com/copilot/agents
- ✅ Can select agent and see "implementation-planner" option
- ✅ Agent accepts tasks and generates plans

---

## Using the Agent

### Basic Usage

```
Step 1: Go to github.com/copilot/agents
Step 2: Select your repository and branch
Step 3: Select "implementation-planner" agent from dropdown
Step 4: Enter your task in the text box
Step 5: Click "Start task" or press Enter
Step 6: Follow along as agent generates plan
```

### Example Prompts

**Feature Implementation:**
```
Create a detailed implementation plan for adding user 
authentication to our web app, including technical approach, 
phases, and risk assessment.
```

**Refactoring:**
```
Generate an implementation plan for refactoring our authentication 
module from callback-based to async/await. Include migration 
strategy, risk assessment, and rollback plan.
```

**System Design:**
```
Plan the implementation of a real-time notification system for 
our platform. Include architecture diagram description, database 
schema, API design, and deployment strategy.
```

**Integration:**
```
Create an implementation plan for integrating Stripe payment 
processing into our subscription system. Include security 
considerations, error handling, and testing strategy.
```

### Agent Output

The agent typically generates:

```markdown
# Implementation Plan: User Authentication

## Overview
- Problem: Currently no user authentication system
- Success Criteria: Users can sign up, log in, and maintain sessions
- Users: Web app users, mobile app users

## Technical Approach
- Architecture: JWT-based authentication with refresh tokens
- Tech Stack: Node.js/Express, bcrypt, jsonwebtoken
- Key Decisions: 
  - Stateless JWT over session-based (scalability)
  - Bcrypt for password hashing (industry standard)

## Implementation Plan

### Phase 1: Foundation (Week 1)
- [ ] Set up authentication middleware (Small, no dependencies)
- [ ] Create User model (Small, no dependencies)
- [ ] Configure environment variables (Small, no dependencies)

### Phase 2: Core Features (Weeks 2-3)
- [ ] Implement signup endpoint (Medium, depends on Phase 1)
- [ ] Implement login endpoint (Medium, depends on Phase 1)
- [ ] Add session management (Medium, depends on signup/login)

### Phase 3: Polish & Deploy (Week 4)
- [ ] Add password reset flow (Medium, depends on email service)
- [ ] Implement 2FA (Large, optional for MVP)
- [ ] Write integration tests (Medium, depends on Phase 2)
- [ ] Deploy to staging (Small, depends on tests)

## Considerations
- Assumptions: Email service available, HTTPS in production
- Constraints: Must support both web and mobile apps
- Risks: Security vulnerabilities, performance under load
  - Mitigation: Security audit, load testing

## Not Included
- OAuth integration (Phase 2 feature)
- Single sign-on (Phase 2 feature)
```

### Working with Agent Output

**Reviewing the Plan:**
1. Read through the entire overview
2. Identify any missing phases or tasks
3. Validate complexity estimates (Small/Medium/Large)
4. Check risk assessments

**Using in Your Workflow:**
1. Save plan to repository: `docs/plans/auth-implementation.md`
2. Convert tasks to GitHub Issues
3. Reference plan in pull requests
4. Update as implementation progresses

**Iterating on Plan:**
```
Initial prompt: "Create implementation plan for auth"
Agent response: [Plan without risk assessment]

Follow-up: "Add more detail to the risks section and 
            include security considerations"
Agent response: [Updated plan with expanded risks]
```

---

## Plan Structure

### Overview Section

Provides context and success criteria:

```markdown
## Overview

**Problem Statement:** 
What are we solving and why is it important?

**Success Criteria:**
- User can sign up with email
- User can log in securely
- Sessions persist across page reloads
- etc.

**Who Uses This:**
- Web app users
- Mobile app users
- Automated systems
```

### Technical Approach Section

Guides architecture and design decisions:

```markdown
## Technical Approach

**Architecture:**
- High-level component diagram (describe)
- Key interactions

**Technology Choices:**
- Framework: Express.js (chosen for simplicity/performance)
- Database: PostgreSQL (ACID compliance, scaling)
- Auth: JWT with refresh tokens (stateless, scalable)

**Key APIs & Data Models:**
- User model with password hashing
- JWT payload structure
- Session refresh endpoint

**Trade-offs & Decisions:**
- Stateless JWT vs session-based: chose JWT for horizontal scaling
- Single-server vs distributed: designed for distributed from start
```

### Implementation Plan Section

Breaks work into phases:

```markdown
## Implementation Plan

### Phase 1: Foundation (Estimated: 3-5 days)

Critical setup that all features depend on.

- [ ] Database schema for users (Small)
      - Define User table with fields
      - Create migrations
      
- [ ] Authentication middleware (Medium)
      - JWT verification
      - Error handling
      - Dependency: Database schema
      
- [ ] Configuration & secrets (Small)
      - Environment variables
      - No dependencies

### Phase 2: Core Authentication (Estimated: 1-2 weeks)

Primary user workflows.

- [ ] Signup endpoint (Medium)
      - Validate email format
      - Hash password with bcrypt
      - Create user record
      - Dependency: Phase 1
      
- [ ] Login endpoint (Medium)
      - Find user by email
      - Verify password
      - Generate JWT token
      - Dependency: Phase 1

- [ ] Token refresh endpoint (Small)
      - Validate refresh token
      - Issue new access token
      - Dependency: Login endpoint

### Phase 3: Polish & Deploy (Estimated: 1 week)

Robustness, testing, and deployment.

- [ ] Integration tests (Medium)
      - Test signup flow
      - Test login flow
      - Dependency: Phase 2
      
- [ ] Error handling (Medium)
      - Handle duplicate emails
      - Handle invalid credentials
      - Dependency: Phase 2
      
- [ ] Documentation (Small)
      - API documentation
      - Setup instructions
      - No dependencies
      
- [ ] Deploy to production (Medium)
      - Staging verification
      - Production deployment
      - Dependency: Phase 3 items
```

### Considerations Section

Identifies assumptions, constraints, and risks:

```markdown
## Considerations

**Assumptions:**
- Email service is available
- HTTPS enforced in production
- Browsers support JWT storage
- Database is available 24/7

**Constraints:**
- Must support existing web API clients
- No schema changes to existing User table
- Budget: 2-3 weeks development time
- Team: 2 developers

**Risks & Mitigation:**
- Password compromise: Use bcrypt with proper salting
- Session hijacking: Implement HTTPS + HttpOnly cookies
- Brute force attacks: Add rate limiting, account lockout
- Token expiration: Implement refresh token rotation
```

### Not Included Section

Clarifies what's out of scope:

```markdown
## Not Included

These are valuable but not part of this implementation:

- OAuth integration with Google/GitHub (Phase 2)
- Two-factor authentication (Phase 2)
- Biometric authentication (Phase 2+)
- SAML/enterprise SSO (Phase 3)
- Account recovery flows (Nice-to-have)
- Social login (Nice-to-have)

Scope focused on MVP authentication only.
```

---

## Best Practices

### 1. Provide Clear Context

**Vague Prompt:**
```
"Plan the implementation of our new feature"
```

**Better Prompt:**
```
"Create an implementation plan for adding a real-time 
collaboration feature to our document editor. The feature 
should support multiple users editing the same document 
simultaneously with operational transformation for conflict resolution."
```

### 2. Include Constraints and Goals

```
"Plan the database migration from MySQL to PostgreSQL for 
our production system. Constraints: Must maintain backwards 
compatibility, minimize downtime (target: <1 hour), and 
preserve all existing data. Team: 2 DBAs available for 2 weeks."
```

### 3. Ask for Risk Assessment

```
"Generate an implementation plan for adding payment processing 
to our e-commerce system using Stripe. Include security 
considerations, PCI compliance steps, and failure scenarios."
```

### 4. Specify Team Size and Experience

```
"Create a plan for building a GraphQL API layer. Team: 
3 junior developers, 1 senior. Timeline: 4 weeks. 
Assume they're new to GraphQL - include learning time."
```

### 5. Request Specific Sections

```
"Plan adding a search feature using Elasticsearch. 
Include: architecture diagram (described), data indexing 
strategy, query optimization tips, and how to handle 
index updates during deployments."
```

### 6. Iterate and Refine

**First prompt:**
```
"Create implementation plan for auth system"
```

**Agent generates:** Basic plan

**Follow-up prompt:**
```
"Expand the risk section with more security considerations. 
Also add a section on integration with existing user database."
```

**Agent refines:** Enhanced plan

### 7. Save Plans to Repository

```bash
# Create plans directory
mkdir -p docs/implementation-plans

# Reference in README
# Add to project tracking
# Link from related issues
```

### 8. Convert to GitHub Issues

After generating plan, create issues for each task:

```markdown
# Example GitHub Issue created from plan

## Title: [Auth] Setup authentication middleware

**Description:**
From: Implementation Plan: User Authentication
Phase: Phase 1: Foundation

Implement JWT verification middleware that:
- Validates JWT tokens
- Handles expired tokens
- Returns appropriate errors
- Logs authentication failures

**Checklist:**
- [ ] Create middleware.js
- [ ] Add tests
- [ ] Add error handling

**Depends on:**
- Database schema setup

**Labels:** auth, backend, phase-1
```

---

## Examples

### Example 1: E-Commerce Feature

**Prompt:**
```
Create an implementation plan for adding a shopping cart 
and checkout flow to our e-commerce platform. The system 
needs to handle inventory management, multiple payment methods, 
and tax calculation.
```

**Generated Plan Includes:**
```
Phase 1: Foundation
- Database schema for carts, orders, inventory
- Basic cart API endpoints
- Configuration for payment providers

Phase 2: Core Functionality
- Add items to cart, update quantities
- Checkout flow with payment processing
- Order confirmation and email notifications

Phase 3: Polish
- Inventory management
- Tax calculation service
- Refund handling
- Analytics integration
```

### Example 2: System Migration

**Prompt:**
```
Plan migrating our authentication system from local API keys 
to OAuth2 + OIDC. We need to maintain backwards compatibility 
for existing API clients during transition.
```

**Generated Plan Includes:**
```
Phase 1: Foundation
- Set up OAuth2 provider
- Create OIDC endpoints
- Database schema for OAuth credentials

Phase 2: Migration
- Add OAuth authentication support (parallel with existing)
- Gradual client migration with sunset dates
- Monitoring and rollback capability

Phase 3: Cleanup
- Deprecate API key authentication
- Remove legacy code
- Full documentation update
```

### Example 3: Performance Optimization

**Prompt:**
```
Generate implementation plan for optimizing our API performance. 
Current response times: 500ms average. Target: 100ms average. 
Team: 2 backend engineers, 1 DBA, 1 week available.
```

**Generated Plan Includes:**
```
Phase 1: Profiling & Analysis
- Identify bottlenecks
- Measure current baseline
- Establish metrics

Phase 2: Optimization
- Database query optimization
- Add caching layer (Redis)
- Implement database indexing

Phase 3: Deployment
- A/B testing
- Gradual rollout
- Performance monitoring
```

---

## Variations & Customization

### For Solo Developers

**Customize Agent Prompt:**
```
You are a technical planning specialist for solo developers.
When creating plans:
- Keep phases to 2-3 days maximum (dev days, not calendar days)
- Prioritize MVP over perfection
- Include learning time for new technologies
- Suggest async-friendly milestones
- Highlight quick wins to maintain momentum
```

### For Agile Teams

**Customize Agent Prompt:**
```
You are a planning specialist for agile teams using 
2-week sprints.

When creating plans:
- Break down into sprint-sized chunks
- Estimate story points (Small=1, Medium=3, Large=5)
- Identify sprint-based milestones
- Include sprint planning section
- Note dependencies between sprints
- Suggest retrospective talking points
```

### For Enterprise Teams

**Customize Agent Prompt:**
```
You are a planning specialist for large enterprise teams.

When creating plans:
- Include compliance and security checkpoints
- Break into quarters with milestones
- Include change management sections
- Note stakeholder communication needs
- Include rollback and contingency planning
- Suggest post-deployment monitoring

For each phase, include:
- Approval gates
- Documentation requirements
- Training needs
```

### For Mobile Development

**Customize Agent Prompt:**
```
You are a planning specialist for mobile development.

When creating plans:
- Consider iOS and Android separately if needed
- Include platform-specific considerations
- Break into app version releases
- Include beta testing phases
- Note backward compatibility concerns
- Include analytics instrumentation
- Consider app store submission timelines
```

---

## Integration Patterns

### Pattern 1: Planning Sprint Work

**Workflow:**
```
1. Product manager provides feature request
2. Request Implementation Planner agent
3. Agent generates detailed plan
4. Team reviews and refines
5. Create issues for sprint
6. Reference plan in sprint board
```

**Commands:**
```
Plan ticket: "Plan implementing notification preferences 
             for users - include database changes, API, and UI"

Generated plan serves as:
- Sprint scope document
- Epic definition
- Dependency mapping
```

### Pattern 2: Onboarding New Developers

**Workflow:**
```
1. New developer joins project
2. Use Implementation Planner to generate system overview
3. Create implementation plans for common tasks
4. New developer uses plans as reference
5. Plans help understand architecture and decisions
```

**Example Prompt:**
```
"Create detailed implementation plan for adding a new API 
endpoint to our system, explaining all architectural patterns 
and conventions we use. Make it suitable as an onboarding 
guide for new developers."
```

### Pattern 3: Architecture Documentation

**Workflow:**
```
1. Major feature needs documentation
2. Generate implementation plan from past work
3. Save as architecture reference
4. Future features reference for consistency
```

**Example Prompt:**
```
"Based on our existing codebase, generate an implementation 
plan template for adding new database-backed features. Include 
all our conventions, patterns, and best practices."
```

### Pattern 4: Refactoring Strategy

**Workflow:**
```
1. Identify code that needs refactoring
2. Ask agent for improvement plan
3. Generate step-by-step refactoring plan
4. Execute with reduced risk
```

**Example Prompt:**
```
"Generate a safe refactoring plan for converting our 
component-based React code to hooks. Include: gradual 
migration strategy, testing approach, and rollback plan 
in case of issues."
```

---

## Troubleshooting

### Agent Not Available

**Problem:** Can't find "implementation-planner" in agent dropdown

**Solutions:**
1. Verify file exists: `.github/agents/implementation-planner.agent.md`
2. Check file is committed to repository
3. Verify correct branch is selected at github.com/copilot/agents
4. Refresh page or wait 30 seconds for cache
5. Check YAML frontmatter is valid

### Plan Lacks Detail

**Problem:** Generated plan is too high-level or missing sections

**Better Prompts:**
```
Add these to your prompt:
- "Include detailed subsections for each phase"
- "Add complexity estimates for each task"
- "Include risk assessment and mitigation"
- "Provide dependency information between tasks"
- "Include testing strategy for each phase"
```

### Plan Seems Incomplete

**Problem:** Agent didn't cover all aspects

**Solutions:**
1. Ask follow-up questions to refine
2. Provide more context in initial prompt
3. Ask specifically for missing sections
4. Reference existing similar plans for examples

**Example Follow-up:**
```
"The plan looks good. Now add:
- Security considerations for each phase
- Performance requirements and testing approach
- Monitoring and alerting strategy
- Documentation that needs to be created"
```

### Plan Doesn't Match Team Capacity

**Problem:** Plan assumes different team size or skills

**Better Initial Prompt:**
```
"Create implementation plan for [feature]. 
Constraints:
- Team: 1 junior dev, 1 senior dev
- Timeline: 3 weeks
- Technologies: They know Python but not Go
- Include learning time for new technologies"
```

### Multiple Versions of Plan

**Problem:** Need different plans for different stakeholders

**Approach:**
```
Prompt 1: "Create technical implementation plan for developers"
Prompt 2: "Create executive summary of same feature for stakeholders"
Prompt 3: "Create project management plan with milestones"
```

### Integrating Plan into Workflow

**Question:** How do I convert plan to GitHub Issues?

**Approach:**
1. Save plan to repository
2. For each task in plan:
   - Create GitHub Issue
   - Title: Task name from plan
   - Description: Task details
   - Add labels for phase and complexity
   - Link related issues
3. Create GitHub Project and add issues
4. Reference plan document in issue details

---

## Quick Reference: Using Implementation Planner

### Setup Checklist
- [ ] Create `.github/agents/` directory
- [ ] Add agent profile to `implementation-planner.agent.md`
- [ ] Commit and push to main branch
- [ ] Visit github.com/copilot/agents
- [ ] Select repository and agent from dropdown

### Effective Prompts Checklist
- [ ] Clearly describe what feature/task to plan
- [ ] Include constraints (time, team size, budget)
- [ ] Specify any specific technologies or patterns
- [ ] Request risk assessment if applicable
- [ ] Ask for specific sections you need
- [ ] Include team experience level

### Plan Review Checklist
- [ ] Overview clearly describes the problem
- [ ] Success criteria are measurable
- [ ] Technical approach is well-documented
- [ ] Phases are logically organized
- [ ] Task complexity estimates are reasonable
- [ ] Dependencies are clearly noted
- [ ] Risks and mitigation are addressed
- [ ] Timeline is realistic for your team

### Using Generated Plans Checklist
- [ ] Save plan to repository for reference
- [ ] Create GitHub Issues from tasks
- [ ] Add labels for phase and complexity
- [ ] Link related issues as dependencies
- [ ] Reference plan in sprint planning
- [ ] Update plan as implementation progresses
- [ ] Share with team for feedback

---

## Additional Resources

- **Custom Agents Documentation:** https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/create-custom-agents
- **Custom Agents Configuration:** https://docs.github.com/en/copilot/reference/custom-agents-configuration
- **About Custom Agents:** https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents
- **Copilot Cloud Agent:** https://docs.github.com/en/copilot/agents/copilot-cloud-agent
- **Awesome GitHub Copilot Customizations:** https://github.com/github/awesome-copilot/tree/main/agents

---

## Feedback & Contributing

Have suggestions or custom variations of this agent?

- **GitHub Issues:** [gh-certifications/issues](https://github.com/jetstreamin/gh-certifications/issues)
- **Pull Requests:** Contributions welcome!
- **Discussions:** [GitHub Community](https://github.com/orgs/community/discussions)

---

**Last Updated:** May 18, 2026 | **Agent Status:** Production Ready | **License:** MIT
