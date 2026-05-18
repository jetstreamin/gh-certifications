---
layout: default
title: Copilot SDK - Custom Agents Implementation
description: Comprehensive guide to building custom agents with the Copilot SDK, including configuration, sub-agent orchestration, event handling, and best practices.
---

# Copilot SDK: Custom Agents Implementation Guide

**Status:** Public Preview | **Last Updated:** May 2026 | **Applies to:** Copilot SDK v1.0+

## Overview

The Copilot SDK enables you to define **custom agents** with specialized system prompts, tool restrictions, and optional Model Context Protocol (MCP) servers. The SDK runtime automatically delegates user requests to the most appropriate agent (sub-agent) based on intent matching, running each agent in an isolated context while streaming lifecycle events back to the parent session.

### Key Concepts

| Term | Definition |
|------|-----------|
| **Custom Agent** | A named agent config with its own prompt, tools, and optional MCP servers |
| **Sub-Agent** | A custom agent invoked by the runtime to handle part of a task |
| **Inference** | The runtime's ability to auto-select an agent based on user intent |
| **Parent Session** | The session that spawned the sub-agent; receives all lifecycle events |
| **Tool Scoping** | Restricting which tools an agent can access (least privilege principle) |

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Defining Custom Agents](#defining-custom-agents)
3. [Configuration Reference](#configuration-reference)
4. [Sub-Agent Delegation](#sub-agent-delegation)
5. [Event Handling](#event-handling)
6. [Agent Tree UI](#agent-tree-ui)
7. [Tool Scoping](#tool-scoping)
8. [MCP Server Integration](#mcp-server-integration)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

- Copilot SDK installed (`@github/copilot-sdk` or language-specific SDK)
- Active Copilot plan
- TypeScript/JavaScript, Python, Go, .NET, or Java runtime

### Basic Setup

```javascript
import { CopilotClient } from "@github/copilot-sdk";

const client = new CopilotClient();
await client.start();

const session = await client.createSession({
    model: "gpt-4.1",
    customAgents: [
        {
            name: "researcher",
            displayName: "Research Agent",
            description: "Explores codebases and answers questions using read-only tools",
            tools: ["grep", "glob", "view"],
            prompt: "You are a research assistant. Analyze code and answer questions. Do not modify any files.",
        },
        {
            name: "editor",
            displayName: "Editor Agent",
            description: "Makes targeted code changes",
            tools: ["view", "edit", "bash"],
            prompt: "You are a code editor. Make minimal, surgical changes to files as requested.",
        },
    ],
    onPermissionRequest: async () => ({ kind: "approved" }),
});
```

---

## Defining Custom Agents

### Minimal Agent Definition

Every custom agent requires a **name** and **prompt** at minimum:

```javascript
const session = await client.createSession({
    customAgents: [
        {
            name: "assistant",
            prompt: "You are a helpful coding assistant.",
        },
    ],
});
```

### Full Agent Definition

For production use, provide all configuration properties:

```javascript
{
    name: "code-reviewer",
    displayName: "Code Review Agent",
    description: "Analyzes pull requests and suggests improvements",
    tools: ["view", "grep", "bash"],
    prompt: "You are an expert code reviewer. Focus on: readability, performance, security, and best practices. Ask clarifying questions when needed.",
    mcpServers: {
        "github-api": {
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-github"],
        },
    },
    infer: true,
}
```

---

## Configuration Reference

### Agent Configuration Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | ✅ | Unique identifier for the agent (used internally) |
| `displayName` | string | ❌ | Human-readable name shown in UI and events |
| `description` | string | ❌ | What the agent does—helps runtime select it (should be specific) |
| `tools` | string[] or null | ❌ | Names of tools agent can use. `null` or omitted = all tools |
| `prompt` | string | ✅ | System prompt defining agent behavior and expertise |
| `mcpServers` | object | ❌ | MCP server configurations specific to this agent |
| `infer` | boolean | ❌ | Whether runtime can auto-select this agent (default: `true`) |

### Session-Level Agent Selection

```javascript
const session = await client.createSession({
    customAgents: [
        {
            name: "researcher",
            prompt: "You are a research assistant.",
        },
        {
            name: "editor",
            prompt: "You are a code editor.",
        },
    ],
    agent: "researcher", // Pre-select the researcher agent
});
```

---

## Sub-Agent Delegation

### How Sub-Agent Selection Works

When a user sends a prompt to a session with custom agents, the runtime follows this flow:

1. **Intent Matching** — Runtime analyzes the user prompt against each agent's `name` and `description`
2. **Agent Selection** — If a match is found and `infer: true`, runtime selects the agent
3. **Isolated Execution** — Sub-agent runs with its own prompt and restricted tool set
4. **Event Streaming** — Lifecycle events stream back to parent session
5. **Result Integration** — Sub-agent output is incorporated into parent response

### Controlling Inference

Disable auto-selection for sensitive agents using `infer: false`:

```javascript
{
    name: "dangerous-cleanup",
    description: "Deletes unused files and dead code",
    tools: ["bash", "edit", "view"],
    prompt: "You clean up codebases by removing dead code and unused files.",
    infer: false, // Only invoked when user explicitly asks for this agent
}
```

This is useful for:
- High-risk operations (destructive cleanup, bulk deletes)
- Specialized agents that should only be invoked explicitly
- Agents with very specific use cases

---

## Event Handling

### Sub-Agent Event Types

The runtime emits five types of sub-agent events:

| Event Type | Triggered When | Payload Includes |
|-----------|-----------------|------------------|
| `subagent.selected` | Runtime selects an agent for the task | `agentName`, `agentDisplayName`, `tools` |
| `subagent.started` | Sub-agent begins execution | `toolCallId`, `agentName`, `agentDisplayName`, `agentDescription` |
| `subagent.completed` | Sub-agent finishes successfully | `toolCallId`, `agentName`, `agentDisplayName` |
| `subagent.failed` | Sub-agent encounters an error | `toolCallId`, `agentName`, `agentDisplayName`, `error` |
| `subagent.deselected` | Runtime switches away from sub-agent | (minimal payload) |

### Subscribing to Events

```javascript
session.on((event) => {
    switch (event.type) {
        case "subagent.selected":
            console.log(`🎯 Agent selected: ${event.data.agentDisplayName}`);
            console.log(`  Tools: ${event.data.tools?.join(", ") ?? "all"}`);
            break;

        case "subagent.started":
            console.log(`▶ Sub-agent started: ${event.data.agentDisplayName}`);
            console.log(`  Description: ${event.data.agentDescription}`);
            console.log(`  Tool call ID: ${event.data.toolCallId}`);
            break;

        case "subagent.completed":
            console.log(`✅ Sub-agent completed: ${event.data.agentDisplayName}`);
            break;

        case "subagent.failed":
            console.log(`❌ Sub-agent failed: ${event.data.agentDisplayName}`);
            console.log(`  Error: ${event.data.error}`);
            break;

        case "subagent.deselected":
            console.log("↩ Agent deselected, returning to parent");
            break;
    }
});

const response = await session.sendAndWait({
    prompt: "Research how authentication works in this codebase",
});
```

### Best Practice: Error Handling

Always handle `subagent.failed` events in production:

```javascript
session.on((event) => {
    if (event.type === "subagent.failed") {
        logger.error(`Agent ${event.data.agentName} failed: ${event.data.error}`);
        
        // Option 1: Show error in UI
        ui.showError(`${event.data.agentDisplayName} encountered an error: ${event.data.error}`);
        
        // Option 2: Retry with parent agent
        retryWithParent(currentTask);
        
        // Option 3: Fall back to manual user input
        ui.promptUserForAlternative();
    }
});
```

---

## Agent Tree UI

### Tracking Agent Execution Hierarchy

Sub-agent events include `toolCallId` fields that let you reconstruct the execution tree:

```typescript
interface AgentNode {
    toolCallId: string;
    name: string;
    displayName: string;
    status: "running" | "completed" | "failed";
    error?: string;
    startedAt: Date;
    completedAt?: Date;
    parentToolCallId?: string; // For nested agents
}

const agentTree = new Map<string, AgentNode>();

session.on((event) => {
    if (event.type === "subagent.started") {
        agentTree.set(event.data.toolCallId, {
            toolCallId: event.data.toolCallId,
            name: event.data.agentName,
            displayName: event.data.agentDisplayName,
            status: "running",
            startedAt: new Date(event.timestamp),
        });
    }

    if (event.type === "subagent.completed") {
        const node = agentTree.get(event.data.toolCallId);
        if (node) {
            node.status = "completed";
            node.completedAt = new Date(event.timestamp);
        }
    }

    if (event.type === "subagent.failed") {
        const node = agentTree.get(event.data.toolCallId);
        if (node) {
            node.status = "failed";
            node.error = event.data.error;
            node.completedAt = new Date(event.timestamp);
        }
    }

    // Render your UI with the updated tree
    renderAgentTree(agentTree);
});
```

### Rendering Agent Activity

```typescript
function renderAgentTree(agentTree: Map<string, AgentNode>) {
    let html = '<div class="agent-tree">';
    
    agentTree.forEach((node) => {
        const statusIcon = {
            running: "⏳",
            completed: "✅",
            failed: "❌",
        }[node.status];
        
        const duration = node.completedAt 
            ? `${(node.completedAt.getTime() - node.startedAt.getTime()) / 1000}s`
            : "...";
        
        html += `
            <div class="agent-node ${node.status}">
                <span class="icon">${statusIcon}</span>
                <span class="name">${node.displayName}</span>
                <span class="time">${duration}</span>
                ${node.error ? `<span class="error">${node.error}</span>` : ""}
            </div>
        `;
    });
    
    html += '</div>';
    document.getElementById("agent-tree").innerHTML = html;
}
```

---

## Tool Scoping

### Principle of Least Privilege

Restrict each agent to only the tools it needs:

```javascript
const session = await client.createSession({
    customAgents: [
        {
            name: "reader",
            description: "Read-only exploration of the codebase",
            tools: ["grep", "glob", "view"],  // No write access
            prompt: "You explore and analyze code. Never suggest modifications directly.",
        },
        {
            name: "writer",
            description: "Makes code changes",
            tools: ["view", "edit", "bash"],   // Write access
            prompt: "You make precise code changes as instructed.",
        },
        {
            name: "unrestricted",
            description: "Full access agent for complex tasks",
            tools: null,                        // All tools available
            prompt: "You handle complex multi-step tasks using any available tools.",
        },
    ],
});
```

### Tool Availability Rules

| Scenario | Behavior |
|----------|----------|
| `tools: ["grep", "view"]` | Agent can only use grep and view |
| `tools: null` | Agent inherits all session-level tools |
| `tools: []` | Agent has no tools (read-only agent) |
| `tools` not specified | Agent inherits all session-level tools |

---

## MCP Server Integration

### Attaching MCP Servers to Agents

Each custom agent can have its own MCP servers, giving it access to specialized data:

```javascript
const session = await client.createSession({
    customAgents: [
        {
            name: "db-analyst",
            displayName: "Database Analyst",
            description: "Analyzes database schemas and queries",
            prompt: "You are a database expert. Use the database MCP server to analyze schemas and suggest optimizations.",
            mcpServers: {
                "database": {
                    command: "npx",
                    args: ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"],
                },
            },
        },
        {
            name: "github-agent",
            displayName: "GitHub Agent",
            description: "Interacts with GitHub issues and PRs",
            prompt: "You manage GitHub repositories. Use the GitHub MCP server to create issues, manage PRs, and analyze projects.",
            mcpServers: {
                "github": {
                    command: "npx",
                    args: ["-y", "@modelcontextprotocol/server-github"],
                },
            },
        },
    ],
});
```

### Multi-Server Agent

```javascript
{
    name: "full-stack",
    displayName: "Full Stack Agent",
    description: "Handles full-stack development with database and deployment",
    prompt: "You are a full-stack developer. Use database and deployment MCP servers to implement features end-to-end.",
    mcpServers: {
        "database": {
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"],
        },
        "deployment": {
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-kubernetes"],
        },
        "monitoring": {
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-prometheus"],
        },
    },
}
```

---

## Best Practices

### 1. Pair a Researcher with an Editor

A common production pattern: delegate read operations to a specialized researcher, and write operations to a focused editor.

```javascript
customAgents: [
    {
        name: "researcher",
        displayName: "Research Agent",
        description: "Analyzes code structure, finds patterns, and answers questions about the codebase",
        tools: ["grep", "glob", "view"],
        prompt: "You are a code analyst. Thoroughly explore the codebase to answer questions. Never modify files.",
    },
    {
        name: "implementer",
        displayName: "Implementer Agent",
        description: "Implements code changes based on analysis and requirements",
        tools: ["view", "edit", "bash"],
        prompt: "You make minimal, targeted code changes. Always verify changes compile and tests pass.",
    },
]
```

**When to use:**
- Analysis or data gathering tasks → researcher
- Feature implementation or bug fixes → implementer
- Complex tasks requiring exploration then modification → researcher first, then implementer

### 2. Keep Agent Descriptions Specific

The runtime uses `description` for intent matching. Be explicit about what the agent does:

```javascript
// ❌ Too vague — runtime can't distinguish from other agents
{ description: "Helps with code" }

// ✅ Specific — runtime knows when to delegate
{ description: "Analyzes Python test coverage and identifies untested code paths" }

// ✅ Even better — includes expertise and limitations
{ description: "Analyzes Python test coverage using pytest reports, identifies untested code paths, and recommends test cases. Does not modify code." }
```

### 3. Use Specific, Domain-Focused Prompts

Tailor system prompts to the agent's specialty:

```javascript
{
    name: "security-auditor",
    description: "Audits code for security vulnerabilities and compliance issues",
    prompt: `You are a security auditor. Review code for:
        • SQL injection risks
        • XSS vulnerabilities
        • Authentication/authorization flaws
        • Hardcoded credentials
        • Insecure cryptography
        • OWASP Top 10 risks
        
        For each issue found: explain the risk, show the vulnerable code, and suggest a fix.
        Use industry-standard security practices (NIST, CWE, OWASP).`,
}
```

### 4. Handle Failures Gracefully

Sub-agents can fail due to tool errors, network issues, or invalid requests. Always have a fallback:

```javascript
session.on((event) => {
    if (event.type === "subagent.failed") {
        logger.error(`Agent ${event.data.agentName} failed: ${event.data.error}`);
        
        // Log to monitoring system
        analytics.trackError({
            agent: event.data.agentName,
            error: event.data.error,
            timestamp: new Date(),
        });
        
        // Notify user and retry
        ui.showNotification(`${event.data.agentDisplayName} encountered an issue. Retrying...`);
        
        // Retry logic or fallback
        retryOrFallback();
    }
});
```

### 5. Monitor Agent Performance

Track metrics to understand agent behavior:

```typescript
interface AgentMetrics {
    agentName: string;
    totalCalls: number;
    successCount: number;
    failureCount: number;
    averageDuration: number;
    lastError?: string;
}

const metrics = new Map<string, AgentMetrics>();

session.on((event) => {
    if (event.type === "subagent.started") {
        const agentName = event.data.agentName;
        if (!metrics.has(agentName)) {
            metrics.set(agentName, {
                agentName,
                totalCalls: 0,
                successCount: 0,
                failureCount: 0,
                averageDuration: 0,
            });
        }
        const m = metrics.get(agentName)!;
        m.totalCalls++;
    }
    
    if (event.type === "subagent.completed") {
        const agentName = event.data.agentName;
        const m = metrics.get(agentName)!;
        m.successCount++;
    }
    
    if (event.type === "subagent.failed") {
        const agentName = event.data.agentName;
        const m = metrics.get(agentName)!;
        m.failureCount++;
        m.lastError = event.data.error;
    }
});

// Export metrics for monitoring
setInterval(() => {
    const report = Array.from(metrics.values()).map(m => ({
        ...m,
        successRate: (m.successCount / m.totalCalls * 100).toFixed(2) + "%",
        failureRate: (m.failureCount / m.totalCalls * 100).toFixed(2) + "%",
    }));
    console.table(report);
}, 60000); // Every minute
```

### 6. Secure Sensitive Agent Access

For high-privilege agents, require explicit user confirmation:

```javascript
{
    name: "prod-deployment",
    displayName: "Production Deployment",
    description: "Deploys code to production environments",
    infer: false, // No auto-selection
    tools: ["bash", "view"],
    prompt: "You deploy code to production. Always verify deployment safety. Ask for confirmation before major changes.",
    // Add UI check before delegation
}

// In your event handler:
session.on((event) => {
    if (event.type === "subagent.selected" && event.data.agentName === "prod-deployment") {
        ui.showConfirmation(
            "Production deployment agent selected. Continue?",
            () => continueExecution(),
            () => cancelExecution()
        );
    }
});
```

---

## Troubleshooting

### Common Issues

#### Agent Not Being Selected

**Problem:** User requests match an agent, but the runtime doesn't select it.

**Solutions:**
- Check `infer: true` is set (or not `false`)
- Review `description` — it should clearly indicate the agent's capability
- Ensure agent `name` is unique
- Check that user request closely matches agent description

```javascript
// ❌ Unclear description
{ name: "helper", description: "Can help", infer: true }

// ✅ Clear description
{ name: "api-debugger", description: "Debugs REST API issues, analyzes responses, suggests fixes" }
```

#### Tool Not Available to Agent

**Problem:** Sub-agent fails because it can't access a required tool.

**Verify:**
- Tool is in the `tools` array
- Tool name matches exactly (case-sensitive)
- Tool is available on the session

```javascript
// ❌ Tool name doesn't match
tools: ["edit-file"] // But runtime uses "edit"

// ✅ Correct tool name
tools: ["view", "edit", "grep"]
```

#### Sub-Agent Keeps Failing

**Problem:** Sub-agent completes but then fails repeatedly.

**Debug:**
- Add comprehensive event logging
- Check `subagent.failed` event for error details
- Review agent prompt for conflicting instructions
- Verify tool access and permissions

```javascript
session.on((event) => {
    if (event.type === "subagent.failed") {
        console.error("Sub-agent failed:", {
            agent: event.data.agentName,
            error: event.data.error,
            toolCallId: event.data.toolCallId,
            timestamp: event.timestamp,
            fullEvent: event, // Log entire event for debugging
        });
    }
});
```

### SDK Language Support

| Language | Repository | Status |
|----------|------------|--------|
| JavaScript/TypeScript | github/copilot-sdk | ✅ Full Support |
| Python | github/copilot-sdk | ✅ Full Support |
| Go | github/copilot-sdk | ✅ Full Support |
| .NET | github/copilot-sdk | ✅ Full Support |
| Java | github/copilot-sdk-java | ✅ Full Support |

Visit [github/copilot-sdk](https://github.com/github/copilot-sdk) for language-specific examples and documentation.

---

## Quick Reference: Agent Configuration Checklist

- [ ] **name**: Unique identifier (required)
- [ ] **prompt**: Clear system prompt (required)
- [ ] **description**: Specific, capability-focused description
- [ ] **displayName**: Human-readable name for UI
- [ ] **tools**: Scoped tool list (least privilege)
- [ ] **infer**: Set to `false` for sensitive operations
- [ ] **mcpServers**: Any MCP integrations needed
- [ ] **Error handling**: Subscribe to `subagent.failed` events
- [ ] **Monitoring**: Track agent metrics
- [ ] **Testing**: Test intent matching, tool access, error cases

---

## Additional Resources

- **GitHub Copilot SDK Repository**: https://github.com/github/copilot-sdk
- **Official Documentation**: https://docs.github.com/en/copilot/how-tos/copilot-sdk/use-copilot-sdk/custom-agents
- **MCP Documentation**: https://modelcontextprotocol.io/
- **GitHub Copilot Docs**: https://docs.github.com/en/copilot

---

## Feedback & Contributing

Have suggestions for this guide? Found an issue or better pattern?

- **GitHub Issues**: [gh-certifications/issues](https://github.com/jetstreamin/gh-certifications/issues)
- **Pull Requests**: Contributions welcome!
- **Discussions**: [GitHub Community](https://github.com/orgs/community/discussions)

---

**Last Updated:** May 18, 2026 | **Copilot SDK Version:** 1.0+ | **License:** MIT
