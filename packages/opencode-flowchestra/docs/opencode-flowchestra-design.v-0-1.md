# OpenCode-Flowchestra Design v0.1

## Overview

OpenCode-Flowchestra is an AI-native multi-agent orchestration framework built as an OpenCode primary agent. It executes workflows defined in Markdown with Mermaid flowcharts. The orchestrator does not parse Mermaid programmatically; it uses AI understanding of the diagram to decide execution order.

Core goals:
- AI understands Mermaid flowchart instead of AST parsing.
- Native OpenCode integration as a primary agent.
- Multi-agent execution via OpenCode subagents.
- In-memory state management only.
- Human-in-the-loop nodes supported.

## Project Structure

```
packages/opencode-flowchestra/
├── README.md
├── agents/
│   └── flowchestra.md
├── prompts/
│   └── flowchestra.md
├── skills/
│   └── flowchestra/
│       └── SKILL.md
└── examples/
    └── code-review.md
```

## Workflow File Locations

Supported workflow locations and priority:

1. Project-level: `.opencode/workflows/`
2. Global: `~/.config/opencode/workflows/`

If multiple workflows match, the agent lists them and asks the user to select one.

## Core Components

### 1. Markdown Agent Definition

`agents/flowchestra.md` defines Flowchestra as a primary agent with task and skill tools enabled, and edit/write disabled.

Design decisions:
- Primary agent so users can switch via Tab.
- Uses Task tool to call subagents per node.
- No file edits from orchestrator.

### 2. Orchestrator System Prompt

`prompts/flowchestra.md` defines how OpenCode-Flowchestra reads and executes workflows:

Key responsibilities:
- Read workflow Markdown and understand Mermaid flowchart.
- Maintain in-memory state and execution metadata.
- Decide which node to execute next.
- Handle sequential, parallel, merge, conditional, and loop structures.
- Call subagents via Task.
- Use Question tool for Human nodes.

### 3. Workflow Execution Skill

`skills/flowchestra/SKILL.md` provides reusable guidance for executing workflows and is loaded by the agent as needed.

## Execution Model

### Runtime Flow

1. Load workflow Markdown.
2. Read YAML frontmatter for metadata, state, and config.
3. Understand Mermaid flowchart and nodes.
4. Initialize in-memory state.
5. Execute from entrypoint or first node.
6. For each node:
   - Agent node: call subagent via Task.
   - Human node: ask user with Question tool.
7. Store outputs into state based on `output.key`.
8. Decide next node based on flowchart edges and output values.
9. Continue until end node or no outgoing edges.

### Parallel Execution

If a node has multiple outgoing edges without distinct labels, all targets are launched in parallel. OpenCode-Flowchestra waits for all tasks to complete before proceeding to merge nodes.

### Conditional Branching

Edges labeled with values are selected based on the previous node output. If no match is found, a `default` label is used if present; otherwise error handling applies.

### Loops

Edges that point back to earlier nodes are treated as loops. The orchestrator tracks iteration counts and respects `maxIterations`.

### Human Nodes

For Human nodes (`{{name}}`), OpenCode-Flowchestra displays the prompt and options, collects user input, and routes based on the selected value.

## State Management

State is stored in-memory during execution. No persistence is required.

Example state shape:

```js
state = {
  input: "user input",
  code_content: null,
  security_result: null,
  _workflow_id: "code-review-workflow",
  _current_node: "prepare",
  _completed_nodes: [],
  _pending_nodes: [],
  _iteration_count: 0,
  _started_at: "2026-01-25T12:00:00Z"
}
```

Template variables supported in prompts:
- `{{state.key}}`
- `{{output}}`
- `{{nodes.node_id.output}}`

## Human-in-the-Loop

Human nodes use the Question tool:
- Render Markdown prompt content with state variables.
- Show option list (label/value/description).
- Allow custom input if configured.
- Store result in state by `output.key`.

## OpenCode Integration

### Triggering

Flowchestra can be triggered by:
- Switching to the primary agent via Tab.
- `@flowchestra` mention.

### Subagent Execution

Each workflow node executes as a subagent via Task, with node-specific prompt/config applied.

## Design Rationale

Why AI understanding instead of parsing:
- Avoids maintaining Mermaid parsers.
- More resilient to format variations.
- Supports natural extensions and comments.

Why OpenCode primary agent:
- Native user experience.
- Reuse OpenCode permissions, tools, skills.
- Easy subagent invocation.

## Future Extensions

1. Workflow templates library.
2. Visual execution tracing.
3. Resume from checkpoints.
4. Workflow composition (call other workflows).
5. Execution history and analytics.
