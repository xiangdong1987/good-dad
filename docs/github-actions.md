# GitHub Actions 自动出包

仓库放 `.github/workflows/build-apk.yml` 一个文件，三种触发方式：

| 触发 | 跑什么 | 产物 |
|---|---|---|
| `git push` 到 main / 任何分支 PR | analyze + test + 出 debug APK | **Actions → 该次 run → Artifacts** 下载 `app-debug-<sha>.apk` |
| 手动按钮（仓库 → Actions → Build APK → Run workflow） | 同上 | 同上 |
| `git tag v1.0.0 && git push --tags` | analyze + test + signed release APK + AAB + 创建 GitHub Release | 仓库 **Releases** 页直接下载 |

## 第一次跑（debug 路径，零配置）

把仓库推到 GitHub：

```bash
git add .github/workflows/build-apk.yml
git commit -m "ci: build APK on every push"
git push
```

打开仓库的 **Actions** 标签页就能看到一个 run 在跑。跑完点进去，**Artifacts** 区下载 `app-debug-<sha>.apk` 装到手机就能用。

> 公开仓库 Actions 免费无限制；私有仓库每月 2000 分钟。一次构建 5-8 分钟。

## 把 release 跑通（一次性配置）

先按 [`release-signing.md`](./release-signing.md) 在本机生成 `android/upload-keystore.jks`。**别 commit**。

然后把它编码成 base64，连同密码一起塞进 GitHub Secrets。

### 1. 编码 keystore

在仓库根目录跑：

```bash
base64 -i android/upload-keystore.jks | pbcopy   # macOS，自动复制到剪贴板
# 或 Linux
base64 -w 0 android/upload-keystore.jks | xclip -selection clipboard
```

### 2. 加 4 个 Secret

仓库 → **Settings → Secrets and variables → Actions → New repository secret**：

| Name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | 上一步剪贴板里的那串（很长） |
| `ANDROID_STORE_PASSWORD` | 你 keytool 时输的 store 密码 |
| `ANDROID_KEY_PASSWORD` | 你 keytool 时输的 key 密码（默认与 store 同） |
| `ANDROID_KEY_ALIAS` | `upload`（默认；除非你 keytool 时换过名） |

### 3. 打 tag 触发

```bash
# 先把 pubspec.yaml 的 version 改成 1.0.0+1（CI 会自动用 build name）
git add pubspec.yaml
git commit -m "release: 1.0.0"
git tag v1.0.0
git push origin v1.0.0
```

10 分钟后 **Releases** 页会出现 `good-dad v1.0.0`，附带：
- `good-dad-v1.0.0.apk` —— 朋友直接装
- `good-dad-v1.0.0.aab` —— 你拿去传 Google Play Console

### 4. 验证签名指纹

下载 APK 后跑：
```bash
keytool -printcert -jarfile good-dad-v1.0.0.apk
```
SHA-256 应该跟你本机 `keytool -list -v -keystore android/upload-keystore.jks` 里的对得上。

## iOS？

iOS 在 GitHub Actions 上跑需要 macOS runner（消耗免费配额是 Linux 的 10 倍）+ 苹果证书 + provisioning profile，**M1 阶段不做**。

后续要加：
- `runs-on: macos-latest`
- 用 `Apple-Actions/import-codesign-certs` + `Apple-Actions/download-provisioning-profiles`
- `flutter build ipa --release --export-options-plist=...`
- `xcrun altool --upload-app` 直接上 TestFlight

到时候开个 `build-ipa.yml` 单独管。

## 常见坑

1. **Flutter 版本对不上**：workflow 里写死了 `3.41.5`，跟你本机版本要一致。本机升了记得同步改。
2. **build_runner 没跑**：drift schema 改了 → workflow 自动跑 `dart run build_runner build`，没问题。
3. **测试失败 → release 不出包**：CI 里 `release` job `needs: debug`，只有 debug job（analyze + test）全绿才会跑 release。这是有意的，避免出坏包。
4. **Tag 推完 release 没出来**：检查 4 个 secret 是不是都加好了。少一个 `if: ${{ env.KEYSTORE_BASE64 != '' }}` 这步会跳过，但后面 `flutter build apk --release` 会因为没 keystore 回退到 debug 签名（仍能产出 APK，只是签名不对）。
5. **keystore base64 太长 push 不上**：base64 后是单行 ~3-5KB，正常的。pbcopy/xclip 复制粘贴就行，**不要**直接 cat 命令行回显输入到 secret value，可能丢字符。

## 安全小心

- **永远不 commit** `android/upload-keystore.jks` 和 `android/key.properties`（`.gitignore` 已挡）
- GitHub Secrets 加密存储，但 workflow 里日志禁止 echo —— 我们没 echo，安全
- 仓库变 public 时 secrets 仍可用，但**任何能 push 的 contributor 都能在 workflow 里读 secrets**。开源仓库慎重添加协作者
