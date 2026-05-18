---
layout: default
title: Copilot Memory - Repository Facts and User Preferences
description: Comprehensive guide to Copilot Memory, including repository-level facts, user-level preferences, storage, retention, validation, and best practices for organizations and developers.
---

# Copilot Memory: Repository Facts and User Preferences

**Status:** Public Preview | **Last Updated:** May 2026 | **Applies to:** Copilot Enterprise, Business, Pro, and Pro+ plans

## Overview

Copilot Memory enables Copilot to build understanding of your repositories and workflows over time, similar to how a new developer learns a codebase through documentation and experience. Rather than repeatedly explaining coding conventions and architecture in every prompt, Copilot can learn and apply repository-level facts and user-level preferences automatically.

### Memory Types

| Type | Description | Scope | Retention | Who Creates | Who Accesses |
|------|-------------|-------|-----------|-------------|--------------|
| **Repository-Level Facts** | Coding conventions, architectural decisions, build commands, project rules | Single repository | Active use or 28 days | Users with write access | All users with Memory enabled |
| **User-Level Preferences** | Personal coding style, workflow patterns, individual preferences | All repositories | Active use or 28 days | Individual user | Only that user |

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Memory Types](#memory-types)
3. [Storage and Validation](#storage-and-validation)
4. [Retention Policy](#retention-policy)
5. [Privacy and Security](#privacy-and-security)
6. [Where Memory is Used](#where-memory-is-used)
7. [Enabling and Managing Memory](#enabling-and-managing-memory)
8. [Best Practices](#best-practices)
9. [For Organizations](#for-organizations)
10. [Troubleshooting](#troubleshooting)

---

## Quick Start

### What Gets Stored Automatically

Copilot Memory learns from your Copilot interactions and automatically captures:

```
Repository-Level Facts:
✓ Naming conventions for files and functions
✓ Testing patterns and framework usage
✓ Build and deployment commands
✓ Architectural patterns and design decisions
✓ Error handling conventions
✓ Documentation standards

User-Level Preferences:
✓ Preferred code style (spacing, formatting)
✓ Inline comments vs. documentation comments preference
✓ Test coverage expectations
✓ Security considerations the user emphasizes
✓ Communication style with Copilot
```

### How to Benefit

**Before Memory:**
```
User prompt to Copilot: "Write a test file in our style, using our conventions: 
we use Jest with React Testing Library, 80% minimum coverage, 
describe blocks like [Component] > [Feature], following BDD patterns..."
```

**With Memory:**
```
User prompt to Copilot: "Write a test file"
Copilot applies learned patterns automatically.
```

---

## Memory Types

### Repository-Level Facts

**What:** Information about how a specific repository works
- Coding conventions (naming, formatting, structure)
- Architectural decisions and patterns
- Build and deployment processes
- Technology stack and framework choices
- Testing strategies
- Documentation requirements
- CI/CD workflows

**Availability:**
- Created by: Users with write access + Memory enabled
- Available to: All users with Memory enabled in that repository
- Scope: Single repository only

**Example Facts Copilot Might Learn:**
```
Fact 1: "This repository uses Jest with React Testing Library 
        for component testing."
Citation: src/components/__tests__/Button.test.js

Fact 2: "Database migrations are stored in /db/migrations 
        and follow Flyway naming conventions."
Citation: db/migrations/V001__init_schema.sql

Fact 3: "Error handling uses custom AppError class with type codes."
Citation: src/errors/AppError.ts
```

**Cross-Feature Usage:**
Facts learned by one Copilot feature can be used by others:
- Copilot Cloud Agent learns testing patterns → Copilot Code Review applies them
- Copilot Code Review discovers database conventions → Cloud Agent uses them for new migrations
- CLI learns build commands → Chat remembers them

### User-Level Preferences

**What:** Individual preferences about how to work with Copilot
- Preferred code style and formatting
- Comment preferences (inline vs. documentation)
- Communication tone with Copilot
- Test coverage expectations
- Security focus areas
- Performance considerations
- Framework or library preferences

**Availability:**
- Created by: Individual user (Copilot Pro/Pro+ only)
- Available to: Only that user, across all repositories
- Scope: All repositories where user has Copilot access

**Example Preferences:**
```
Preference 1: "User prefers TypeScript with strict mode enabled"
Source: User's interactions across multiple repositories

Preference 2: "User wants comprehensive error messages rather than 
              inline comments"
Source: Feedback from multiple Copilot sessions

Preference 3: "User prioritizes security in code reviews, 
              emphasizing input validation"
Source: Review feedback and explicit instructions
```

**Current Limitations:**
- User-level preferences are NOT applied during code review
- Copilot CLI only applies preferences for the user who initiated the operation
- Only available for Copilot Pro/Pro+ individual users (not yet for Enterprise)

---

## Storage and Validation

### How Memory is Stored

**Repository-Level Facts:**
```
Structure:
{
  fact: "Repository uses Jest with React Testing Library",
  repository: "org/repo",
  citations: [
    "src/components/__tests__/Button.test.js",
    "jest.config.js",
    "package.json#L42"
  ],
  createdBy: "user@example.com",
  createdAt: "2026-05-15T10:30:00Z",
  lastUsed: "2026-05-18T14:22:00Z",
  validated: true
}
```

**User-Level Preferences:**
```
Structure:
{
  preference: "Prefers TypeScript with strict mode",
  user: "user@example.com",
  citations: [
    "Direct quote from user instructions",
    "Inferred from 15 interactions in Python projects"
  ],
  confidence: 0.95,
  createdAt: "2026-04-20T08:15:00Z",
  lastUsed: "2026-05-18T16:45:00Z"
}
```

### Validation Process

**For Repository-Level Facts:**

1. **Initial Capture** — Copilot learns from user-initiated action (e.g., code generation, review)
2. **Citation Storage** — Fact stored with line references pointing to supporting code
3. **Pre-Usage Validation** — Before using fact, Copilot verifies citations still exist and are accurate on current branch
4. **Selective Application** — Only validated facts are used; stale facts are skipped

**Validation ensures:**
- Facts remain accurate as codebase changes
- No outdated conventions are applied
- Citations can be traced back to source code

**For User-Level Preferences:**

1. **Implicit or Explicit Capture** — From user instructions or inferred from patterns
2. **Citation Storage** — Stored with direct quotes or inference details
3. **Best Judgment Confirmation** — Copilot uses judgment to determine if preference still applies
4. **Adaptive Application** — Preferences adjust based on user feedback

---

## Retention Policy

### Auto-Deletion

**28-Day Rule:**
- Any stored fact or preference unused for 28 consecutive days is **automatically deleted**
- Timer resets whenever Copilot **validates and successfully uses** the entry
- Applies to both repository-level facts and user-level preferences

**Example Timeline:**
```
Day 1:   Fact created: "Uses Jest for testing"
Day 5:   Fact used and validated → Timer resets
Day 12:  Fact used and validated → Timer resets
Day 28:  Fact NOT used → Starts deletion countdown
Day 31:  Fact used again → Timer resets before deletion
Day 58:  Fact not used for 28 days → Auto-deleted
```

### Manual Deletion

**Repository Owners:**
- Can review all repository-level facts
- Can manually delete inaccurate or outdated facts
- Via GitHub settings → Copilot Memory management

**Individual Users:**
- Can view and delete personal user-level preferences
- Via Copilot settings on GitHub
- Only delete their own preferences

### Closed Pull Requests

Facts learned from closed/rejected PRs are still captured but validated before use:
- Validation ensures information still applies to current codebase
- Stale patterns from abandoned PRs don't influence behavior
- Useful for learning from experimental branches

---

## Privacy and Security

### Data Isolation

**Repository Scoping:**
- Facts about Repo A are only used when working in Repo A
- No cross-repository knowledge sharing
- Facts cannot leak between repositories
- Preserves security and privacy of each repository

**User Scoping:**
- User-level preferences are tied to individual user account
- Not shared with other users or organizations
- Only user can access and delete their preferences
- Available across all repositories user accesses

### Information Types Captured

**Safe to Capture:**
- Code patterns and conventions
- Build and test commands
- Architectural decisions
- Framework usage
- Error handling patterns

**What is NOT Captured:**
- API keys or secrets
- Credentials or authentication tokens
- Sensitive business logic unrelated to patterns
- Personal data beyond workflow preferences

### Enabling and Disabling

**Individual Users (Copilot Pro/Pro+):**
- Memory is ON by default
- Can be disabled in personal Copilot settings anytime
- Control is at the user level, not per-repository

**Enterprise/Organization (Copilot Business/Enterprise):**
- Memory is OFF by default
- Organization admin can enable in organizational settings
- Once enabled, available to all members with Copilot subscription
- Cannot be disabled per-user (admin control)

---

## Where Memory is Used

### Copilot Cloud Agent

**Applies:**
- ✅ Repository-level facts
- ✅ User-level preferences (Pro/Pro+ only)

**Usage Examples:**
```
User: "Generate a new test file for UserService"

Cloud Agent applies:
1. Testing framework: Jest + React Testing Library
2. File structure: Follow established patterns
3. Naming conventions: describe(...) blocks
4. Coverage expectations: 80% minimum
5. Assertion style: User's preferred patterns
```

### Copilot Code Review

**Applies:**
- ✅ Repository-level facts
- ❌ User-level preferences (NOT applied)

**Usage Examples:**
```
PR Review focuses on:
1. Consistency with codebase patterns (learned facts)
2. Adherence to conventions (stored facts)
3. Testing patterns (repository standards)
4. Architectural alignment (learned decisions)

Personal preferences are NOT applied during review
to ensure consistency for all reviewers.
```

### Copilot CLI

**Applies:**
- ✅ Repository-level facts
- ✅ User-level preferences (ONLY for requesting user)

**Usage Examples:**
```
User runs: copilot --explain-error

CLI uses:
1. Repository facts about error handling
2. User's preferred explanation style
3. Repository-specific context and patterns
4. User's security and performance preferences
```

### Other Features

**Features NOT Yet Using Memory:**
- Copilot Chat (limited memory integration)
- Code completion (uses session context)
- In-IDE suggestions (uses local context)

**Future Expansion:**
- Chat integration improvements planned
- Enhanced IDE integration
- Broader feature coverage in development

---

## Enabling and Managing Memory

### For Individual Users (Copilot Pro/Pro+)

**Default State:** Enabled

**To Disable:**
1. Go to GitHub Settings
2. Navigate to Copilot → Memory
3. Toggle "Enable Copilot Memory" to OFF
4. Confirm action

**Effects of Disabling:**
- ❌ Copilot cannot create new facts or preferences
- ✓ Existing facts/preferences are preserved
- ✓ Re-enabling restores access to previous memories

**Managing Personal Preferences:**
1. Settings → Copilot → Memory → Manage Preferences
2. Review learned preferences with confidence scores
3. Delete preferences you disagree with
4. Edit preference descriptions if needed

### For Organizations (Copilot Business/Enterprise)

**Default State:** Disabled

**To Enable (Admin):**
1. Organization Settings → Copilot → Advanced
2. Select "Enable Copilot Memory"
3. Review privacy and data policies
4. Confirm and save

**Configuration:**
```yaml
# Organization Settings
copilot:
  memory:
    enabled: true
    retention_days: 28
    auto_delete_unused: true
    repository_scoped: true  # Always true for security
```

**What Admins Can Do:**
- Enable/disable for entire organization
- View audit logs of memory usage
- Review repository-level facts (read-only)
- Delete inaccurate facts
- Monitor memory statistics

**What Admins Cannot Do:**
- Access user-level preferences (private)
- Disable memory per-user (org-wide setting)
- Export or backup facts
- Prevent fact creation (automatic from usage)

### Repository-Level Fact Management

**Reviewing Facts:**
```
Repository Settings → Copilot → Memory Facts

Shows:
✓ All repository-level facts
✓ Citation sources
✓ Last used date
✓ Who created it
✓ Confidence/validation status
```

**Deleting Inaccurate Facts:**
1. Find fact in repository memory dashboard
2. Review citations to verify it's outdated
3. Click "Delete" or "Mark as Inaccurate"
4. Copilot will stop using that fact

**Example Deletion Scenario:**
```
Fact: "Uses MySQL for primary database"
Problem: "Migrated to PostgreSQL last month"
Action: Repository owner deletes fact
Result: Copilot stops suggesting MySQL patterns
```

---

## Best Practices

### For Developers

#### 1. Help Copilot Learn Accurate Patterns

```javascript
// ✅ Good - Clear, consistent patterns
// src/errors/AppError.js
class AppError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.code = code;
        this.statusCode = statusCode;
    }
}

// ✅ Copilot learns this pattern and applies it consistently
```

#### 2. Use Consistent Conventions

```typescript
// ✅ Consistent naming for database functions
async function findUserById(id: string): Promise<User> {}
async function findUsersByRole(role: string): Promise<User[]> {}

// ✅ Copilot learns "find*" prefix for queries
// ✅ Learns async/Promise return patterns
// ✅ Learns type annotations

// ❌ Avoid inconsistent patterns that confuse learning
function getUser(id) {}        // Different verb
function users_by_role() {}    // Different naming
let user = getUserSync() {}    // Inconsistent async/sync
```

#### 3. Keep Documentation Updated

```markdown
// Good README that helps Copilot learn
## Development Setup

### Testing
- Framework: Jest
- Coverage: Minimum 80%
- Run: `npm test`
- Test files: `__tests__` folder next to source

### Database
- PostgreSQL 14+
- Migrations: Flyway in `/db/migrations`
- Connection pooling: pg-pool

### Error Handling
- Use AppError class with error codes
- Always provide user-friendly messages
- Log errors to CloudWatch
```

#### 4. Provide Explicit Context

```
❌ Vague prompt:
"Add error handling"

✅ Clear prompt:
"Add error handling following our AppError pattern with 
specific error codes and status codes"

✅ Even better (with Memory):
"Add error handling" 
← Copilot automatically applies learned patterns
```

### For Organizations

#### 1. Establish Clear Conventions

Before Memory can be effective, document standards:

```markdown
# Development Standards Document

## Code Style
- TypeScript with strict mode
- ESLint: config/.eslintrc
- Prettier: auto-format on save

## Testing
- Jest + React Testing Library
- 80% minimum coverage
- BDD-style describe blocks

## Architecture
- Feature-based folder structure
- Services layer for business logic
- React hooks for state management

## Error Handling
- CustomError base class
- Error codes for programmatic handling
- User-friendly messages always
```

#### 2. Create Clear Examples

```
Repository structure:
docs/
  DEVELOPMENT.md        ← Conventions
  ARCHITECTURE.md       ← Patterns
  TESTING_GUIDE.md     ← Test patterns
  ERROR_HANDLING.md    ← Error patterns
```

#### 3. Review and Curate Facts

```
Monthly Task:
1. Go to Organization → Copilot → Memory Dashboard
2. Review repository-level facts
3. Delete outdated facts
4. Verify facts match current codebase
5. Note facts Copilot should learn
```

#### 4. Provide Feedback

Help Copilot learn by giving feedback:
- When Copilot applies correct patterns → Use the suggestion
- When Copilot applies incorrect patterns → Reject and explain
- Over time, preferences and facts align with expectations

### For Open Source Projects

#### 1. Create CONTRIBUTING.md

```markdown
# Contributing

## Code Style
- Follow the existing patterns in `/src`
- Use our naming conventions:
  - Components: PascalCase
  - Utilities: camelCase
  - Constants: UPPER_CASE

## Testing
- Write tests alongside features
- Minimum 85% coverage
- Use Jest + RTL

## Commit Messages
- Format: "feat: description" or "fix: description"
- Reference issues: "fixes #123"
```

#### 2. Review Contributor Code

Reviewing PRs helps Copilot learn what good looks like:
- Consistent feedback on patterns
- Point out when code follows/breaks conventions
- Over time, Copilot learns these expectations

#### 3. Update Documentation

Keep README, Contributing, and other docs fresh:
- Copilot learns from documentation quality
- Clear examples in docs help Memory work better
- Updates signal pattern changes to Copilot

---

## For Organizations

### Security and Compliance Considerations

#### Data Governance

**What's Stored:**
- Code patterns and conventions
- Architectural decisions
- Testing and CI/CD patterns
- Framework and technology choices

**What's NOT Stored:**
- Source code content (only structure)
- Secrets or credentials
- Sensitive business logic
- Customer data

#### Compliance

```
GDPR:     Repository facts don't contain personal data
          User preferences have privacy controls
          
SOC 2:    Memory data stored in secure GitHub infrastructure
          Audit logs available for admins
          
HIPAA:    Not recommended for sensitive health data
          Consider organizational policies
          
FedRAMP:  Not available in FedRAMP environments
```

#### Audit and Monitoring

```
Admin Dashboard provides:
✓ Memory usage statistics
✓ Fact creation trends
✓ User engagement metrics
✓ Audit logs (who accessed/deleted facts)
✓ Data retention tracking
```

### Training and Adoption

#### Phase 1: Awareness
```
Week 1-2:
- Explain Copilot Memory to team
- Show how it improves productivity
- Discuss privacy and security
- Address questions
```

#### Phase 2: Documentation
```
Week 2-3:
- Update CONTRIBUTING.md
- Create DEVELOPMENT_STANDARDS.md
- Add architecture documentation
- Document coding patterns
```

#### Phase 3: Usage
```
Week 3-4:
- Team begins using Copilot
- Copilot learns patterns
- Encourage feedback
- Monitor improvement
```

#### Phase 4: Optimization
```
Week 4+:
- Review learned facts
- Delete outdated patterns
- Refine documentation
- Measure productivity gains
```

---

## Troubleshooting

### Memory Not Capturing Facts

**Problem:** Copilot doesn't seem to be learning repository patterns

**Diagnose:**
1. Check if Memory is enabled for you
2. Verify you have write access to repository
3. Check if facts were created (Admin Dashboard)
4. Confirm your account has Copilot subscription

**Solutions:**
```
If Memory is disabled:
→ Enable in Settings → Copilot → Memory

If write access missing:
→ Request access from repository owner

If no facts created:
→ Use Copilot in the repository
→ Give explicit feedback
→ Wait 24-48 hours for capture
```

### Memory Applying Outdated Patterns

**Problem:** Copilot suggests old conventions that changed

**Causes:**
- Codebase migrated patterns but Memory wasn't updated
- Fact citations are outdated
- 28-day timer hasn't deleted stale facts yet

**Solutions:**
```
1. Repository owner reviews facts
   → Go to Settings → Copilot → Memory Facts

2. Identify outdated facts
   → Look for old technology/pattern

3. Delete incorrect facts
   → Click delete on each stale fact

4. Confirm facts are removed
   → Copilot should stop using them

5. Use Copilot to learn new patterns
   → Generate code with new patterns
   → Copilot learns updated conventions
```

### User-Level Preferences Not Applied

**Problem:** Personal preferences aren't showing in Copilot responses

**Check:**
- Feature supports user preferences?
  - ✅ Cloud Agent
  - ✅ CLI
  - ❌ Code Review
  
- Are you using Copilot Pro/Pro+?
  - ❌ Enterprise/Business plans don't have user preferences yet
  - ✅ Pro/Pro+ plans have full support

- Is Memory enabled in your settings?
  - Go to Settings → Copilot → Memory → ON

**Solutions:**
```
If using Business/Enterprise:
→ Use organization-level facts (repository-level)
→ Contact GitHub about user preferences support

If using Pro/Pro+ but Memory disabled:
→ Enable Memory in Settings

If Memory is enabled:
→ Provide more explicit feedback
→ Over time preferences will refine
→ Use preference management to guide learning
```

### Memory Storage Limits

**Question:** Are there limits on stored facts?

**Answer:**
- No published hard limits yet
- Practical limit: ~1,000-5,000 facts per repository
- Automatic cleanup of unused facts (28-day rule)
- Contact GitHub support for specific scenarios

---

## Quick Reference: Memory Management Checklist

### For Developers
- [ ] Copilot Memory is enabled in your settings
- [ ] You're working in a repository with Memory enabled
- [ ] Your organization (if applicable) has Memory enabled
- [ ] You understand which features use your preferences
- [ ] You provide clear, consistent code patterns

### For Repository Owners
- [ ] Documentation clearly explains coding patterns
- [ ] CONTRIBUTING.md includes conventions and standards
- [ ] Architecture documented in ARCHITECTURE.md
- [ ] Memory facts reviewed monthly
- [ ] Outdated facts deleted when patterns change

### For Organization Admins
- [ ] Copilot Memory enabled in organization settings
- [ ] Privacy and compliance policies reviewed
- [ ] Team trained on Memory capabilities
- [ ] Audit logs monitored quarterly
- [ ] Facts occasionally reviewed for accuracy

### For Security/Compliance
- [ ] Verified Memory doesn't store secrets
- [ ] Confirmed repository scoping (no cross-repo leaks)
- [ ] Documented data retention (28-day auto-delete)
- [ ] Audit logging enabled for admins
- [ ] Compliance with GDPR/SOC2/etc verified

---

## Additional Resources

- **GitHub Copilot Documentation:** https://docs.github.com/en/copilot
- **Managing Copilot Memory:** https://docs.github.com/en/copilot/how-tos/use-copilot-agents/copilot-memory
- **Copilot Cloud Agent:** https://docs.github.com/en/copilot/agents/copilot-cloud-agent
- **Copilot CLI:** https://docs.github.com/en/github-cli/github-cli-manual/gh-copilot

---

## Feedback & Contributing

Found an error or have suggestions for this guide?

- **GitHub Issues:** [gh-certifications/issues](https://github.com/jetstreamin/gh-certifications/issues)
- **Pull Requests:** Contributions welcome!
- **Discussions:** [GitHub Community](https://github.com/orgs/community/discussions)

---

**Last Updated:** May 18, 2026 | **Memory Status:** Public Preview | **License:** MIT
