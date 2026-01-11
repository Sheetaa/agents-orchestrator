---
id: "code-review-workflow"
name: "Code Review Workflow"
version: "1.0"
description: "自动化代码审查工作流，支持并行检查、AI 审查和人工审批"
entrypoint: "prepare"

state:
  input: ""
  code_content: null
  security_result: null
  performance_result: null
  style_result: null
  aggregated_result: null
  review_decision: null
  human_decision: null
  deep_analysis: null
  deep_report: null
  final_result: null

config:
  timeout: 300000
  maxIterations: 10

retry:
  maxAttempts: 3
  backoff: exponential
  initialDelay: 1000

onError: "summarize"
---

# Code Review Workflow

自动化代码审查工作流，包含以下特性：

- **并行检查**: 同时进行安全、性能、代码风格检查
- **AI 审查**: 汇总结果并做出决策
- **条件分支**: 根据审查结果走不同路径
- **循环重试**: 支持重新分析
- **人工审批**: 复杂情况需人工介入
- **子流程**: 深度审查作为独立子流程

## Flow

```mermaid
flowchart TD
    %% 开始/结束节点
    begin((开始)) --> prepare[准备代码]
    prepare --> ai_review[AI 审查]
    
    %% 并行检查
    ai_review --> security[安全检查]
    ai_review --> performance[性能检查]
    ai_review --> code_style[代码风格检查]
    
    %% 并行汇聚
    security --> aggregate[汇总结果]
    performance --> aggregate
    code_style --> aggregate
    
    %% 人工审批决策
    aggregate --> human_review{{人工审批}}
    
    %% 条件分支
    human_review -->|approve| summarize[生成总结]
    human_review -->|reject| prepare
    human_review -->|complex| sub_deep_review
    
    %% 深度审查子流程
    subgraph sub_deep_review[深度审查子流程]
        deep_analyze[深度分析] --> deep_report[生成报告]
    end
    
    sub_deep_review --> human_review
    
    %% 结束节点
    summarize --> finish((结束))
    
    %% 样式定义
    classDef startend fill:#2ecc71,stroke:#27ae60,color:#fff
    classDef primary fill:#2980b9,stroke:#2980b9,color:#fff
    classDef subagent fill:#85c1e9,stroke:#85c1e9,color:#000
    classDef human fill:#f39c12,stroke:#f39c12,color:#000
    
    %% 应用样式
    class begin,finish startend
    class ai_review primary
    class prepare,security,performance,code_style,aggregate,summarize subagent
    class deep_analyze,deep_report subagent
    class human_review human
```

## Nodes

### prepare

---
description: "准备并读取要分析的代码"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1

tools:
  read: true
  glob: true
  grep: true

input:
  userInput: "{{state.input}}"

output:
  key: "code_content"

config:
  timeout: 30000
---

你是一个代码准备助手。请根据用户输入，读取并准备要分析的代码内容。

**用户输入:**
{{state.input}}

请读取相关代码文件，并整理成结构化的内容供后续分析使用。

### ai_review

---
description: "AI 审查，分配并行检查任务"
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
maxSteps: 10

tools:
  read: true
  glob: true
  grep: true
  write: false
  edit: false
  bash: false

permission:
  edit: deny
  bash: deny

input:
  userInput: "{{state.input}}"

output:
  key: "code_content"

config:
  timeout: 30000
---

你是一个代码准备助手。请根据用户输入，读取并准备要分析的代码内容。

**用户输入:**
{{state.input}}

请读取相关代码文件，并整理成结构化的内容供后续分析使用。

### security

---
description: "安全漏洞检查"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1

tools:
  read: true
  grep: true

input:
  code: "{{state.code_content}}"

output:
  key: "security_result"
---

你是一个安全审查专家。请检查以下代码中的安全漏洞：

**代码内容:**
{{state.code_content}}

重点检查：
- SQL 注入漏洞
- XSS 跨站脚本攻击
- CSRF 跨站请求伪造
- 敏感信息泄露
- 不安全的依赖
- 权限校验缺失

请输出结构化的安全检查报告。

### performance

---
description: "性能问题检查"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1

tools:
  read: true

input:
  code: "{{state.code_content}}"

output:
  key: "performance_result"
---

你是一个性能优化专家。请检查以下代码中的性能问题：

**代码内容:**
{{state.code_content}}

重点检查：
- N+1 查询问题
- 内存泄漏风险
- 不必要的重复计算
- 缺少缓存优化
- 阻塞操作
- 大数据量处理

请输出结构化的性能检查报告。

### code_style

---
description: "代码风格检查"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
hidden: true

tools:
  read: true

input:
  code: "{{state.code_content}}"

output:
  key: "style_result"
---

你是一个代码质量专家。请检查以下代码的风格和质量问题：

**代码内容:**
{{state.code_content}}

重点检查：
- 命名规范
- 代码结构
- 注释完整性
- 函数复杂度
- 重复代码
- 错误处理

请输出结构化的代码质量报告。

### aggregate

---
description: "汇总所有检查结果"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.2

input:
  security: "{{state.security_result}}"
  performance: "{{state.performance_result}}"
  code_style: "{{state.style_result}}"

output:
  key: "aggregated_result"
---

你是一个代码审查汇总专家。请汇总以下检查结果：

**安全检查结果:**
{{state.security_result}}

**性能检查结果:**
{{state.performance_result}}

**代码风格检查结果:**
{{state.style_result}}

请综合分析并输出：
1. 问题严重程度评估
2. 主要问题列表
3. 改进建议优先级

### ai_review

---
description: "AI 审查员，做出初步决策"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1

input:
  aggregated: "{{state.aggregated_result}}"

output:
  key: "review_decision"
---

你是一个高级代码审查员。基于汇总的检查结果，做出审查决策。

**汇总结果:**
{{state.aggregated_result}}

请根据以下标准做出决策：

- `approved`: 代码质量良好，可以通过
- `rejected`: 存在严重问题，需要重新分析（会触发重新检查）
- `needs_human`: 存在需要人工判断的复杂问题
- `complex`: 需要进行深度审查（会进入深度审查子流程）

**重要：请只返回上述四个标签之一，不要返回其他内容。**

### human_review

---
description: "人工审批节点，做出最终决策"
timeout: 86400000
onTimeout: "summarize"

options:
  - label: "Approve"
    value: "approve"
    description: "代码审查通过，可以合并"
  - label: "Reject"
    value: "reject"
    description: "代码存在问题，需要重新审查"
  - label: "Deep Review"
    value: "complex"
    description: "需要进行深度审查"

allowCustomInput: true

output:
  key: "human_decision"
---

## 请进行人工审批

### 汇总检查结果

{{state.aggregated_result}}

### AI 审查意见

{{state.review_decision}}

### 深度审查报告（如有）

{{state.deep_report}}

---

请选择您的决定，或输入自定义反馈意见。

### deep_analyze

---
description: "深度代码分析"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.2
maxSteps: 20

tools:
  read: true
  grep: true
  glob: true

permission:
  webfetch: allow

input:
  code: "{{state.code_content}}"
  aggregated: "{{state.aggregated_result}}"

output:
  key: "deep_analysis"

config:
  timeout: 120000
  retry:
    maxAttempts: 2
---

你是一个资深代码架构师。请对代码进行深度分析：

**代码内容:**
{{state.code_content}}

**初步检查结果:**
{{state.aggregated_result}}

请进行深度分析，包括：
1. 架构设计评估
2. 可维护性分析
3. 可扩展性评估
4. 测试覆盖度建议
5. 重构建议

### deep_report

---
description: "生成深度审查报告"
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.3

input:
  analysis: "{{state.deep_analysis}}"

output:
  key: "deep_report"
---

你是一个技术文档专家。请基于深度分析结果，生成详细的审查报告：

**深度分析结果:**
{{state.deep_analysis}}

请生成一份结构化的深度审查报告，包括：
1. 执行摘要
2. 详细发现
3. 风险评估
4. 改进路线图
5. 优先级建议

### summarize

---
description: "工作流完成，生成最终总结"
mode: subagent
model: anthropic/claude-sonnet-4-20250514

input:
  decision: "{{state.review_decision}}"
  humanDecision: "{{state.human_decision}}"
  aggregated: "{{state.aggregated_result}}"

output:
  key: "final_result"
---

代码审查工作流已完成。请生成最终总结：

**审查决策:** {{state.review_decision}}
**人工决定:** {{state.human_decision}}
**汇总结果:** {{state.aggregated_result}}

请输出简洁的最终审查结论。
