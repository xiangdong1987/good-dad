---
name: submit-pr
description: 当用户说「提 PR」「发 PR」「上 PR」「提交 pr」「做完了发 PR」「PR 一下」时使用。预检 → push → gh pr create with 模板。
---

# 提交 PR 工作流

## 1. 预检（不通过就停，不要开 PR）

```bash
git branch --show-current
```

- 当前分支不能是 `main`；是的话停下提示用户先拉个 feat/ 或 fix/ 分支

```bash
git status
```

- 有未提交内容 → 让用户决定是 commit 还是 stash 再继续；不要自己 commit

```bash
flutter analyze
flutter test
```

- 任一失败 → 停下来报告，**不 push 不开 PR**
- 用户硬要带着失败提 PR → 也接受，但在 PR 描述里如实标注 `❌ test failing`，让 reviewer 看到

## 2. 看 commit 历史

```bash
git log main..HEAD --oneline
```

- 5 条以内 → 直接走
- 5 条以上 → 提议「commit 太碎，要不要 squash 一下？」（不强求；可以接受用户保留）

## 3. push 分支

```bash
git push -u origin <branch>
# 之前推过就 git push 即可
```

## 4. 起 PR

用 `gh pr create`，body 走 HEREDOC：

```bash
gh pr create --title "<conventional title>" --body "$(cat <<'EOF'
## Summary
- 这个 PR 做了什么（1-3 bullet）
- 为什么做（如果不显然）

## Test plan
- [ ] flutter analyze 0 issue
- [ ] flutter test 全绿
- [ ] 真机 / 模拟器验证：<具体页面 / 流程>
- [ ] （UI 改）截图见下

## Screenshots
（UI 改贴前后对比；非 UI 改这段删掉）

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Title 规则
- conventional commit 格式：`feat: 加 X`、`fix: 修 Y`、`refactor: 抽 Z`、`docs: ...`
- ≤ 70 字符
- 中文 / 英文都行（项目混用）

### Body 写法
- Summary 直接说**做了什么 / 为什么**，不展开「怎么做」（reviewer 看 diff）
- Test plan 务必有勾选项，方便 reviewer 跟着验
- UI 改一定要截图

## 5. 报告

把 `gh pr create` 返回的 URL 给用户：「PR #N 已开 → URL」。
顺便提一句 CI 会自动跑，等绿了再 merge。

## 红线

- ❌ 永远不要 force push 已经推到 origin 的分支（除非用户明确要求 + 是自己的 feat/fix 分支没人协作）
- ❌ PR 描述里**绝不**贴 secrets / API key / keystore 密码 / 用户真实数据
- ❌ 不要自己 merge PR；让用户 / reviewer 决定
- ❌ 不要 PR 到错误的 base branch（默认 main，除非用户说去其它分支）

## 后续

PR 开完不是结束。如果 CI 失败：
- 看日志（`gh run list --branch <branch> --limit 1`）
- 修对应代码
- 同分支再 push（PR 自动更新）

如果 reviewer 要求改：
- 跟着改
- push 同分支
- 不要为了「让 commit 历史好看」rewrite history（force push）—— 让 reviewer 看到完整对话
