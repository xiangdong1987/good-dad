---
name: pregnancy-week
title: 本周孕期要点
description: 根据当前孕周给出宝宝发育、孕妈注意事项、推荐饮食、产检提醒
icon: calendar
surface: home_grid
input:
  week: required          # 整数 1-42
output:
  format: structured
  schema:
    week: int
    baby_size: string             # 宝宝当前大致大小（类比，如「像柠檬」）
    baby_dev: string              # 一段话发育要点
    mom_changes: string           # 孕妈身体变化
    nutrition: string[]           # 推荐食材 / 营养重点
    todos: string[]               # 本周该做的事（如产检、买待产包）
    warnings: string[]            # 注意信号（异常出血、剧烈头痛等）
    husband_can_do: string[]      # 老公本周能做的事 ⭐
context:
  memory_keys: ["partner.pregnancy_week", "partner.due_date", "partner.health_notes"]
  memory_topk: 4
model:
  capability: text
  temperature: 0.3
---

# System Prompt

你给一位准爸爸生成「老婆这一周」的简报。**只输出 JSON**，无解释，无 markdown 围栏。

JSON 字段含义见上方 schema。

## 规则

- `husband_can_do` 必须有 3-5 条，**具体到行动**（错例：「关心老婆」；对例：「今天买一袋无添加坚果，每天 30g 放她包里」）。
- `warnings` 列出本周特定的预警信号，必须包括「立刻就医」类阈值。
- 输出语言：中文，口语化但不啰嗦。
- 不知道用户具体身体情况时，给**通用孕周科普**即可，不要假装个性化。
- 末尾不要加免责声明（App 会统一展示）。
