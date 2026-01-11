# Agents Orchestrator

A Markdown-based multi-agent orchestration framework using Mermaid flowcharts.

## Overview

Agents Orchestrator allows you to define complex multi-agent workflows in a single Markdown file, combining:

- **YAML frontmatter** for metadata and configuration
- **Mermaid flowchart** for visual workflow definition
- **Markdown sections** for agent prompts and node configuration

## Features

- **Visual Workflow Design** - Use Mermaid flowcharts to define agent interactions
- **Parallel Execution** - Run multiple agents concurrently
- **Conditional Branching** - Route based on agent outputs
- **Human-in-the-Loop** - Include manual approval nodes
- **Subgraphs** - Organize complex workflows into logical groups
- **State Management** - Share data between nodes via global state

## Node Types

| Type | Mermaid Shape | Description |
|------|---------------|-------------|
| Agent | `[name]` Rectangle | AI agent node |
| Human | `{{name}}` Hexagon | Manual approval/input node |

### Agent Mode Colors

Agent nodes are color-coded by mode:

| Mode | Color | Description |
|------|-------|-------------|
| `all` | Dark Blue `#1a5276` | Full permission mode |
| `primary` | Medium Blue `#2980b9` | Primary orchestrating agent |
| `subagent` | Light Blue `#85c1e9` | Sub-agent (default) |

## Quick Example

```mermaid
flowchart TD
    begin((开始)) --> prepare[准备代码]
    prepare --> ai_review[AI 审查]
    
    ai_review --> security[安全检查]
    ai_review --> performance[性能检查]
    ai_review --> code_style[代码风格]
    
    security --> aggregate[汇总结果]
    performance --> aggregate
    code_style --> aggregate
    
    aggregate --> human_review{{人工审批}}
    
    human_review -->|approve| summarize[生成总结]
    human_review -->|reject| prepare
    
    summarize --> finish((结束))
    
    classDef startend fill:#2ecc71,stroke:#27ae60,color:#fff
    classDef primary fill:#2980b9,stroke:#2980b9,color:#fff
    classDef subagent fill:#85c1e9,stroke:#85c1e9,color:#000
    classDef human fill:#f39c12,stroke:#f39c12,color:#000
    
    class begin,finish startend
    class ai_review primary
    class prepare,security,performance,code_style,aggregate,summarize subagent
    class human_review human
```

## Workflow Structures

| Structure | Pattern | Behavior |
|-----------|---------|----------|
| **Sequential** | `A --> B --> C` | Execute in order |
| **Parallel** | `A --> B`, `A --> C` | Run B and C concurrently |
| **Merge** | `B --> D`, `C --> D` | Wait for all upstream nodes |
| **Conditional** | `A --\|yes\| B`, `A --\|no\| C` | Branch based on output |
| **Loop** | `B --> A` (back edge) | Retry/iterate |
| **Subgraph** | `subgraph name[...]` | Group related nodes |

## Documentation

- [Workflow Specification](docs/WORKFLOW_SPEC.md) - Complete specification
- [Workflow Example](docs/WORKFLOW_EXAMPLE.md) - Code review workflow example

## License

MIT