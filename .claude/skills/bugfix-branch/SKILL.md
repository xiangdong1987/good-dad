---
name: bugfix-branch
description: 当用户说「修 bug」「修复 X」「解决一个问题」「拉个分支修 bug」时使用。从最新 main 拉一个 fix/<kebab> 分支，鼓励先写一个能复现的失败测试。
---

# 修 bug · fix/ 分支

## 1. 拿到 bug 现象

如果用户没给，先问一句：「具体什么现象？什么时候触发？最好有截图或错误信息」

由现象生成 kebab-case 分支名：
- 「日历加的事项不显示」 → `fix/calendar-event-not-rendering`
- 「聊聊页 _db 重复初始化炸了」 → `fix/chat-late-final-double-init`
- 「Mimo 模型识别食物返回 unknown」 → `fix/food-safety-unknown-verdict`

## 2. 预检 + 拉分支

```bash
git status                                    # 必须干净
git checkout main
git pull --ff-only origin main
git checkout -b fix/<kebab>
```

## 3. 强烈推荐：先写一个能复现的失败测试

跟用户说：「在动手修之前，建议先写一个能稳定复现这个 bug 的测试。这样修完才能确认真的修了，以后也不会回归。」

- Dart 逻辑 bug → 加 `test/<area>_test.dart` 用例
- UI bug → widget test 模拟操作
- 跨流程 bug → integration test（如果有）

写完先跑：测试**必须红**（fail）才说明真复现到了。

如果用户说「不用」/「先快速修了再说」也尊重，不强求。

## 4. 报告

「已创建分支 `fix/<kebab>`，从 main 最新代码拉的。」
「建议先：① 写复现测试 ② 让测试红 ③ 修代码 ④ 看测试变绿。」
「告诉我具体怎么修。」

## commit 规范

- `fix: ...` 修 bug 主体
- `test: ...` 加复现测试（如果分两次提）
- 在 PR 描述里写「本 PR 修了 #issue」（如果有 issue）

## 红线

- ❌ 不要顺手 refactor —— 那是另一个 PR
- ❌ 不要在 main 上直接改
- ❌ 不要跳过验证就声明修好
- ❌ 不要 force push 别人的分支
