---
name: feature-branch
description: 当用户说「开发新需求」「做新功能」「新需求」「拉个分支做 X」「加个 X 功能」时使用。从最新 main 拉一个 feat/<kebab> 分支。
---

# 开发新需求 · feat/ 分支

## 1. 拿到一句话需求

如果用户没给，先问一句：「这个需求一句话是什么？」

由这句话生成 kebab-case 分支名（≤4 个英文单词）：
- 「加导出 PDF 功能」 → `feat/export-pdf`
- 「肚肚照拼图」 → `feat/belly-collage`
- 「孕妇食谱收藏」 → `feat/recipe-favorites`
- 「记账」 → `feat/expense-tracking`
- 中英文都行，最终落到英文 kebab：

报告给用户确认这个分支名再继续。

## 2. 预检

```bash
git status
```

- 工作树必须干净
- 脏的 → 报告，问怎么处理（commit / stash / 丢弃）

## 3. 切到 main 拿最新

```bash
git checkout main
git pull --ff-only origin main
```

`pull` 失败（有 diverged）→ 停，把详情给用户。

## 4. 拉新分支

```bash
git checkout -b feat/<kebab>
```

## 5. 报告

「已创建分支 `feat/<kebab>`，从 main 最新代码拉的。可以开始写了。」

提示一下 commit 规范（conventional commit）：
- `feat: ...` 加新功能
- `refactor: ...` 重构不改行为
- `docs: ...` 改文档
- `test: ...` 加测试
- `chore: ...` 杂项

## 不要做

- ❌ 不要在 main 上直接改代码
- ❌ 不要等用户问就自动开始写代码——分支拉好就停，等用户给具体任务
- ❌ 分支前缀只用 `feat/`，不用 `feature/` 或 `dev/`
