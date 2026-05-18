---
layout: default
title: GH-600 Hard Practice Tests
description: Two difficult GH-600 practice tests with answer keys, scoring guidance, and a fast-pass prep checklist.
---

<!-- markdownlint-disable MD022 MD024 MD025 -->

# GH-600 Hard Practice Tests

**Status:** Exam Prep Feature | **Last Updated:** May 2026 | **Applies to:** Microsoft Certified: GitHub Agentic AI Developer (GH-600)

## How to Use This Guide

- Take the tests closed-book.
- Time yourself: 35 minutes per test.
- Score each test immediately after finishing.
- Review the answer key only after you commit to answers.
- If you miss more than 3 questions in a test, re-read the related GH-600 section before retesting.

## Fast-Pass Prep Checklist

Before you take the tests, make sure you can explain these without notes:

- Where agents belong in the SDLC
- The difference between planning and execution
- How to choose safe tools and scopes
- When to require human approval
- How to use observability, logs, and audit trails
- How to recover from agent failures
- How to coordinate multiple agents without conflict
- How guardrails and least privilege reduce risk

## Timed Mock Exam Mode

Use this feature when you want a realistic first-try rehearsal instead of isolated practice.

- Time limit: 60 minutes total
- Format: 20 questions, mixed across Practice Test A, B, and C
- Scoring: 1 point per correct answer, no partial credit
- Pass threshold: 17/20 or higher
- Hard fail conditions: more than 3 misses overall, or any miss on approvals, guardrails, or least-privilege questions

### How to Run It

1. Set a timer for 60 minutes.
2. Answer all 20 questions without notes.
3. Mark any question you are unsure about, but do not stop to research.
4. Score immediately after finishing.
5. Review only the missed topics, then retake the same set 24 hours later.

### What Success Looks Like

- You can choose the safest answer quickly.
- You can explain the risk, control, and tradeoff in one sentence.
- You can identify when the correct answer is "slower but safer."
- You consistently prefer scoped tools, human approval, and auditable artifacts over broad autonomy.

---

## Practice Test A: Hard Scenario Set

### Question 1
A team wants an agent to triage failing pull request checks, propose a fix, and open a PR automatically. Which control is most important to require first?

A. Allow the agent to modify any file in the repository
B. Require explicit human approval before merge or PR publication
C. Disable observability so the agent is faster
D. Let the agent choose its own tools dynamically

### Question 2
An agent keeps making correct suggestions but fails when a required tool is missing. What is the best next step?

A. Increase the agent temperature
B. Add more memory to the agent
C. Restrict the agent to the exact tools it needs and verify availability
D. Remove all approval gates

### Question 3
Which setup best matches least privilege for a repository analysis agent?

A. `tools: null` so the agent can do anything
B. Read-only tools such as view/search and no write access
C. Full access to edit, delete, merge, and deploy
D. No logging because logging slows the agent down

### Question 4
An enterprise wants to use cloud-agent-style automation on protected repositories. What should be planned first?

A. Which meme format the agent should use in PR comments
B. Which enterprise and organization policies, rulesets, and runner settings apply
C. How to bypass review checks for faster merges
D. How to hide audit logs from administrators

### Question 5
A reviewer asks why an agent should not reason and act in the same step for a high-risk change. What is the strongest answer?

A. Because it is slower
B. Because separation of planning and action enables validation before impact
C. Because agents are always wrong
D. Because memory cannot be used during action

### Question 6
A multi-agent workflow has two agents changing the same file. What is the best control?

A. Let both agents write and resolve conflicts later
B. Add conflict detection and resource locks before execution
C. Remove all checkpoints
D. Ignore the conflict if the agents are both confident

### Question 7
An agent completes a task, but admins cannot reconstruct what happened. What capability is most important?

A. More model tokens
B. Session logs, signed commits, and artifact-based traceability
C. Hidden prompt comments
D. Automatic deletion of every log after completion

### Question 8
Which evaluation signal is the strongest for deciding whether an agent change is acceptable?

A. Whether the output looks clever
B. Whether the agent uses the longest response
C. Whether tests pass, security checks are clean, and the result meets success criteria
D. Whether the agent sounded confident

### Question 9
A question asks about safe agent operations in production. Which answer is best?

A. Give the agent broad permissions and let it self-correct
B. Use human-in-the-loop approvals, scoped tools, logs, and rollback paths
C. Remove rulesets to reduce friction
D. Avoid asking the agent to explain itself

### Question 10
What is the most important reason to review failures after an agent run?

A. To generate more buzz
B. To identify whether the root cause was reasoning, permissions, tools, context, or resources
C. To avoid writing documentation
D. To make the agent sound more human

### Answer Key A

1. **B** - High-risk agent actions need explicit human approval before the result is finalized.
2. **C** - Tool availability and exact scoping are fundamental. Missing tools should be fixed directly.
3. **B** - Read-only, scoped tools are the safest starting point.
4. **B** - Enterprise policy, rulesets, and runner settings are the key guardrails for cloud-agent-style automation.
5. **B** - Planning and execution must be separated so plans can be validated before action.
6. **B** - Conflict detection and locks prevent duplicated or contradictory work.
7. **B** - Signed commits, logs, and artifacts make the work auditable.
8. **C** - Exam answers should focus on measurable success criteria, not vibes.
9. **B** - This is the core production pattern: approvals, scoped tools, logs, rollback.
10. **B** - Failure analysis is about root cause, not blame.

---

## Practice Test B: Harder Mixed-Mode Set

### Question 1
A repo uses Copilot Memory, custom instructions, and code review. What is the strongest reason to keep repository facts current?

A. So the agent can skip validation entirely
B. So the agent and reviewer behavior stays aligned with current repo conventions
C. So every response becomes identical
D. So users no longer need to explain context

### Question 2
A manager wants the agent to create a branch, propose fixes, and open a draft PR, but not merge anything. Which autonomy level best fits?

A. Manual-only
B. Advisory
C. Scoped with approval
D. Fully autonomous with no audit trail

### Question 3
Which is the best example of a guardrail?

A. Letting the agent use any tool available
B. Blocking secrets from code and requiring code-owner review for sensitive files
C. Increasing token limits
D. Allowing every action to auto-merge

### Question 4
The agent is producing useful output, but the team cannot tell which inputs caused the decision. What should be added?

A. A larger font in the UI
B. Structured logs and inspectable artifacts
C. More randomness in the model
D. A second agent with the same permissions

### Question 5
A question asks how to reduce risk when an agent handles high-impact changes. Which is the best option?

A. Remove human review to keep the workflow fast
B. Use least privilege, explicit approvals, and rollback paths
C. Let the agent decide when the change is too risky
D. Disable telemetry so nobody gets confused

### Question 6
A workflow needs one agent to analyze code, another to propose edits, and a third to validate results. What orchestration pattern is this?

A. Sequential pipeline
B. Random walk
C. Broadcast-only chat
D. Single-agent loop

### Question 7
An agent repeatedly fails after a repository structure change. Which troubleshooting approach is best?

A. Re-run blindly until it works
B. Review the changed context, update instructions or state, and retest
C. Disable logs
D. Delete the evaluation criteria

### Question 8
A team asks whether a model switch is the best solution for inconsistent code review quality. What is the best answer?

A. Yes, always switch models
B. No, first tune instructions, context, policies, and evaluation; model switching may not be supported or appropriate
C. Model quality does not matter
D. The agent should guess

### Question 9
What is the best reason to use artifacts like JSON or SARIF during agent workflows?

A. They look professional
B. They make outputs machine-readable, reviewable, and auditable
C. They hide mistakes
D. They replace all humans

### Question 10
Which response best fits a good GH-600 exam answer?

A. "It depends" with no detail
B. A direct answer that names the control, the risk, and the tradeoff
C. A long story with no conclusion
D. A vague opinion about AI

### Answer Key B

1. **B** - Current repository facts improve alignment with real conventions and reduce stale guidance.
2. **C** - Draft PR creation plus approvals is scoped autonomy, not full autonomy.
3. **B** - That is a clear policy and access guardrail.
4. **B** - Structured logs and artifacts provide traceability.
5. **B** - Least privilege plus approval and rollback is the safest production pattern.
6. **A** - Analyze, propose, and validate in order is a sequential workflow.
7. **B** - Changes in repo context often require updated instructions, state, or tool assumptions.
8. **B** - Tuning the workflow should come before assuming the model itself is the problem.
9. **B** - SARIF and JSON make output portable for review and audit.
10. **B** - Strong exam answers name the control, risk, and tradeoff explicitly.

---

## Score Yourself

- **18-20 correct across both tests:** Strong first-try readiness
- **15-17 correct:** Good, but review the weak areas and retest
- **Below 15:** Re-read the guide sections on guardrails, evaluation, and multi-agent workflows before trying again

## Review Targets

If you missed questions, review these sections in [GH-600 Exam Study Guide](./gh-600-exam-guide.md):

- SDLC integration and planning vs. action
- Tool selection and least privilege
- Memory, state, and context drift
- Evaluation and failure analysis
- Multi-agent coordination
- Guardrails and accountability

---

## Fast Answer Pattern

For most GH-600 questions, the strongest answer usually mentions:

1. The risk
2. The control
3. The approval or audit requirement
4. The way to verify the result

If an answer lacks one of those, it is usually too weak for the exam.

---

## Practice Test C: Tradeoff Challenge

This set is deliberately harder. Every question forces a choice between competing priorities such as safety, speed, autonomy, auditability, and scope.

### Tradeoff Question 1
A team wants faster agent execution on release day, but the repository contains sensitive deployment scripts. What is the best tradeoff?

A. Remove approvals so the agent can move faster
B. Keep the scoped approval gate and narrow the agent's write access
C. Turn off logs so execution feels simpler
D. Let the agent choose any deployment tool it wants

### Tradeoff Question 2
An agent can either make a broad fix quickly or take longer to validate each change against tests and policy. What should you prefer?

A. The broad fix, because speed is the top objective
B. The validated fix, because safety and correctness matter more than raw speed
C. The broad fix, but only on weekdays
D. No fix at all until a human rewrites the prompt manually

### Tradeoff Question 3
An AI workflow can run with full autonomy, but the change touches authentication logic. What is the safest choice?

A. Full autonomy because the model is confident
B. Advisory output with human approval before any merge or release
C. Skip review and rely on unit tests alone
D. Ask the agent to self-certify the change

### Tradeoff Question 4
The agent needs more context to solve a task, but expanding context also increases the chance of stale or irrelevant instructions. What is the best approach?

A. Add all available context permanently
B. Add only the minimum necessary context and prune stale instructions regularly
C. Remove context entirely
D. Let the agent invent missing details

### Tradeoff Question 5
A team wants rich observability, but they worry logs could expose sensitive data. What is the best tradeoff?

A. Disable all logging
B. Keep structured logs, but redact secrets and sensitive content
C. Copy secrets into the log so they can be reviewed later
D. Make logs private to the agent only

### Tradeoff Question 6
Two agents are useful, but they sometimes produce contradictory edits. What should you prioritize?

A. More parallelism, even if conflicts increase
B. Coordination and conflict detection before execution
C. Removing one agent permanently
D. Ignoring contradictions if both outputs seem reasonable

### Tradeoff Question 7
A review workflow can either auto-merge successful agent output or require a human to approve the final change. Which is the better exam answer for a risky repo?

A. Auto-merge for anything the agent marks as successful
B. Human approval for risky changes, even if it slows the workflow
C. Auto-merge all changes from trusted repos
D. Merge only if the agent uses a large model

### Tradeoff Question 8
The agent is failing because one tool is unreliable, but replacing the tool would delay delivery. What is the best immediate choice?

A. Keep the unreliable tool and ignore failures
B. Narrow the task, add fallback validation, and restrict the tool's use until reliability improves
C. Add more randomness to the model
D. Turn the task into a full autonomous workflow

### Tradeoff Question 9
A workflow can generate very detailed reasoning traces, but the team also wants concise, reviewable artifacts. What is the best answer?

A. Keep every trace forever in raw form only
B. Store concise, structured artifacts and retain deeper traces only where needed for audit or debugging
C. Delete artifacts after each run
D. Replace artifacts with screenshots only

### Tradeoff Question 10
The exam asks for the best production pattern for an agent that writes code. What should you choose?

A. Maximum autonomy with no guardrails
B. Scoped tools, clear approvals, logs, and rollback paths
C. No tool use at all
D. The shortest answer, regardless of risk

### Answer Key C

1. **B** - Keep the approval gate and narrow access; this preserves safety while still allowing progress.
2. **B** - The exam consistently favors correctness and validation over raw speed.
3. **B** - Authentication changes are high impact and should not be fully autonomous.
4. **B** - Minimum necessary context reduces drift while still supporting the task.
5. **B** - Observability is valuable, but sensitive data must be redacted.
6. **B** - Coordination and conflict prevention are more important than raw parallel speed.
7. **B** - Risky changes should still require a human decision point.
8. **B** - Reduce scope, add fallback validation, and avoid over-trusting a weak tool.
9. **B** - Structured artifacts give the best balance of auditability and review efficiency.
10. **B** - This is the core safe production pattern for agentic code-writing workflows.
