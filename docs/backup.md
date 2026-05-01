# 数据备份与恢复

> 一句话：**默认情况下卸载重装会丢全部本地数据**。
> good-dad 提供两条防线：手动 `.zip` 备份（推荐）+ 系统级自动备份（兜底）。

## 数据都在哪

| 类型 | 位置 | 进 .zip 备份？ | 系统自动备份？ |
|---|---|---|---|
| SQLite (`good_dad.sqlite`) | `getApplicationDocumentsDirectory()` | ✅ | ✅ Android / ❌ iOS |
| 食物识别照片 | `documents/photos/food/` | ✅ | ✅ Android / ❌ iOS |
| 肚肚照 | `documents/photos/belly/` | ✅ | ✅ Android / ❌ iOS |
| 用户导入的 SKILL.md | `documents/skills/` | ✅ | ✅ Android / ❌ iOS |
| LLM API key | `flutter_secure_storage`（Android EncryptedSharedPreferences / iOS Keychain） | ❌ 故意排除 | ❌（密钥跟设备绑死） |
| 内置 SKILL.md | App assets，固化在安装包里 | 不需要备份 | 不需要备份 |

## 防线 1：手动 `.zip` 备份（推荐）

App 内：**设置 → 备份与恢复 → 导出备份**

- 把 SQLite + photos + 用户 skills 打成 `good_dad_backup_<时间>.zip`
- 弹系统分享面板，发到微信 / iCloud Drive / Google Drive / 邮箱…自己选
- 大小：几 MB（按图片量）
- API key **不**进 zip → 分享出去也不会泄漏

恢复：**设置 → 备份与恢复 → 从备份恢复** → 选 zip → 确认覆盖 → **手动重启 App**。

实现：
- `lib/core/backup/backup_service.dart`（exportToZip / importFromZip）
- 用 `archive` 包打 zip，`file_picker` 选恢复源，`share_plus` 分享导出

适用：iPhone 用户 / 想跨设备 / 想给老婆她也装一份相同数据。

## 防线 2：Android Auto Backup（兜底）

Android 6+ 默认开启，不用任何代码就能：
- 把 App 数据自动备份到用户登录的 Google 账号里（Google Drive 配额从用户的 Drive 扣，每个 App 上限 25MB）
- 卸载重装 / 换新机时自动还原

我们已经在 `AndroidManifest.xml` 里**显式声明**：
- `android:allowBackup="true"`
- `android:fullBackupContent="@xml/backup_rules"` （Android ≤ 11）
- `android:dataExtractionRules="@xml/data_extraction_rules"` （Android 12+）

包含规则在 `android/app/src/main/res/xml/`：
- 包含：DB、文档目录（含照片）、普通 SharedPrefs
- 排除：`FlutterSecureStorage.xml`（API key 由 Keystore 加密，跨设备恢复也读不出来，留在备份里没意义）

适用：Android 用户的「无意识保险」。但条件多：
- 需要登录 Google 账号
- 设备在充电 + 闲置 + 接 WiFi 时才执行（Google 决定的时机）
- App 必须超过 24 小时没启动且最近一次备份超过 24 小时
- ⚠️ 国行设备没 GMS 时这条防线不生效

## iOS 没有自动备份吗？

iCloud 整机备份会包含 App 的 documents 目录，但：
- 用户必须开了 iCloud 备份
- 还原靠 iCloud 整机恢复 (Setup Assistant)，不像 Android 那样靠应用

所以 **iOS 用户更该用手动 .zip 备份**。

## 怎么验证备份通了

1. 进入 App，做点事：填家庭信息、加几条 todo、拍一张食物
2. 设置 → 导出备份 → 分享到微信「文件传输助手」
3. 卸载 App，重装
4. 设置 → 从备份恢复 → 选刚才的 zip
5. 重启 App → 一切回来；唯独需要重新填 LLM key

## 已知限制

- 当前 `BackupService.exportToZip` 不会强制 `db.close()` 才打包；drift 默认 WAL 模式，正常运行下文件已经是 consistent 的（最坏情况丢的是几秒钟内最新写入）。如果要 100% 一致，可以加一个 sync flush 步骤。
- 没做加密。备份 zip 里有聊天内容、记忆、照片——分享时小心。后续可加 password 加密。
- 没做增量。每次都全量。
- 恢复后必须**手动重启**——drift 关闭后重新打开同一文件，部分 provider 不会自动重新订阅。后续可以做平滑替换或 `SystemNavigator.pop()`。
