---
name: release-tag
description: 当用户说「打 tag」「发版」「release」「出新版本」「上 Play」时使用。Bumps pubspec.yaml version, runs analyze+test sanity, commits, tags, pushes — GitHub Actions then auto-builds APK + AAB to a Release.
---

# 打 tag 发版工作流

每一步都先报告再执行。**commit / tag / push 这三步必须先问用户确认**。失败立刻停。

## 1. 预检

```bash
git status
git branch --show-current
```

- 工作树必须干净；脏的 → 报告给用户问怎么处理（提交 / stash / 丢弃）
- 必须在 `main` 分支；不在的话停下提示用户先合并到 main
- `git pull --ff-only origin main` 拿最新

## 2. 决定版本号

读 `pubspec.yaml` 的 `version: X.Y.Z+N`，问用户要哪个：

- **patch**（X.Y.**Z+1**）—— bug 修复 / 文案调整 / 内部重构
- **minor**（X.**Y+1**.0）—— 加新功能不破坏老 API
- **major**（**X+1**.0.0）—— 不兼容变更 / 大改版

build number `+N` 自动 +1（Play 上架时 versionCode 必须单调递增；本地侧载无所谓）。

默认建议 patch。把决定的新 X.Y.Z+M 念给用户确认。

## 3. 改 pubspec + commit

```bash
# 用 Edit 工具改 pubspec.yaml 的 version 行
git add pubspec.yaml
git commit -m "release: vX.Y.Z"
```

## 4. Sanity check（必须都过）

```bash
flutter analyze
flutter test
```

任一失败 → 立刻停，把错误报告给用户，**不要打 tag**。

## 5. 打 tag + push

```bash
git tag vX.Y.Z
git push origin main
git push origin vX.Y.Z
```

## 6. 报告完结

告诉用户：
- 已打 tag `vX.Y.Z`
- 仓库 Actions 会跑 `release` job（5-10 分钟）
- 完事后 Releases 页会有 `good-dad-vX.Y.Z.apk` + `.aab`

可以用 `gh repo view --json url -q .url` 拿仓库 URL，再追加 `/releases` 给用户。

## 红线

- ❌ 永远不要 `git push --force` 推 tag
- ❌ tag 推上去 **不能改名**；版本号错了就再发一版（patch）
- ❌ 不要跳过 sanity check
- ❌ 不要从非 main 分支打 release tag
