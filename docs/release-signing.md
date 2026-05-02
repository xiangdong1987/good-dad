# Release 签名与发布

## 1. 生成 keystore（一次，**永远不要丢**）

在仓库根目录运行：

```bash
keytool -genkey -v \
  -keystore android/upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storetype PKCS12
```

按提示输 store password / 你的姓名 / 组织 / 国家代码（CN）。**记下你输的密码**。

## 2. 写 key.properties

```bash
cp android/key.properties.template android/key.properties
```

打开 `android/key.properties` 把 4 个值填好：
```
storePassword=刚才生成时输的 store 密码
keyPassword=刚才生成时输的 key 密码（默认与 store 同）
keyAlias=upload
storeFile=../upload-keystore.jks
```

`.gitignore` 里已经把 `key.properties` + `*.jks` 屏蔽了，**不要**强加进 git。

## 3. 备份（关键）

把 `upload-keystore.jks` + `key.properties` 同时备份到：
- 密码管理器（1Password / Bitwarden 都行）
- 一个加密的云盘（iCloud / Google Drive 加密压缩包）
- 物理介质（U 盘）

**丢了就再也没法以同包名上架升级**，新用户能装但老用户拿不到更新。

## 4. 构建发布版

### Android Play Store（推荐 .aab）
```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

### Android sideload（一般 .apk）
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### 上架前 checklist
- [ ] `pubspec.yaml` 的 `version` 升一档（`1.0.0+1` → `1.0.1+2`，每次提审 build number 都要单调递增）
- [ ] `flutter analyze` 0 issue
- [ ] `flutter test` 全绿
- [ ] 真机跑过 `--release`，不只是 debug
- [ ] 内置 SKILL.md 不含真名 / 真日期（已脱敏）
- [ ] 隐私政策 URL 已上线（GitHub Pages 等）
- [ ] App icon / splash 看起来 OK

## 5. iOS 签名（先跳过；等申请 Apple Developer 后写）

iOS 用 Xcode 自动管理证书，不需要 key.properties。
后续准备：
- $99 Apple Developer 账号
- Xcode 登录 Apple ID
- 在 App Store Connect 创建 App，bundle ID = `com.siyou.good_dad`（或换成你的反域名）
- Xcode → Runner.xcworkspace → Signing & Capabilities → Team 选你的开发者
- `flutter build ipa --release`
- 用 Xcode 的 Organizer 上传到 App Store Connect
- 提交 TestFlight 内测 → 提审

## 6. 一键脚本（可选）

可以加个 `scripts/release-android.sh`：
```bash
#!/usr/bin/env bash
set -e
flutter analyze
flutter test
flutter build appbundle --release
echo "✅ build/app/outputs/bundle/release/app-release.aab"
```
