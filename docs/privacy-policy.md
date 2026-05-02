# Privacy Policy · 隐私政策

> **生效日期 / Effective date**: 2026-05-02
> **最后更新 / Last updated**: 2026-05-02
> **联系方式 / Contact**: <填一个你愿意公开的邮箱，比如 hello@yourname.dev>

> ⚠️ 上架前请把上面联系方式 + 下面所有占位（标了 `<>` 的部分）替换为真实信息，再以 `https://<your-pages>/privacy/` 形式公开发布。GitHub Pages / Cloudflare Pages 都免费且足够。

---

## 中文版

### 我们是谁
good-dad（以下简称「本应用」）是一款帮助准爸爸 / 新手爸爸的私人 AI 助手。开发者：<你的名字 / 你工作室名>。

### 我们收集什么数据
**本应用本身不收集、不上传、不存储任何用户数据到我们的服务器**。

具体来说：
- **家庭信息**（爸爸/妈妈称呼、当前孕周、预产期）：仅保存在你本机的加密存储里
- **聊天记录、记忆条目、待办事项、产前清单、宝宝采购清单、孕周建议**：保存在你本机的 SQLite 数据库（位于 App 沙盒内部）
- **拍摄的照片**（食物识别照、孕肚照、聊天附图）：保存在你本机文件系统内 App 沙盒目录
- **LLM API 凭据**（baseURL / api key / 模型名）：保存在系统级安全存储（iOS Keychain / Android EncryptedSharedPreferences）

我们的服务器**不持有**任何这些数据。

### 数据离开你设备的唯一情况
当你使用 AI 功能（拍照识别、聊天、生成食谱、生成清单、孕周建议等）时，本应用会把请求**直接**发送到 **你自己配置的第三方 LLM 服务**（例如 OpenAI、Anthropic、阿里云通义千问、小米 MiMo Token Plan、本地 Ollama 等）。

- 请求内容包括：你输入的文字、附带的图片、本应用从你本地数据库中拼装的相关上下文（家庭信息片段、相关记忆条目）
- 请求**不**经过我们的服务器中转
- 数据由你选择的 LLM 服务商处理，受**他们的**隐私政策约束（在他们的官网查阅）
- 你可以随时在「设置」里清除 LLM 配置以停止任何数据外发

### 我们不收集
- 不收集姓名、电子邮箱、电话、设备 ID、位置、广告标识符
- 不嵌入任何第三方分析 SDK（无 Google Analytics、Firebase、TalkingData、友盟等）
- 不嵌入任何广告
- 不追踪你的使用习惯

### 权限说明
- **相机**：用于食物识别、孕肚照、聊天附图。照片仅保存在你本机
- **照片库**：用于从相册选择上述场景的图片
- **本地通知**：用于每周一/周四 9:00 的孕期周报提醒
- **网络**：用于和你配置的 LLM 服务通信

不需要时可随时在系统设置里关闭这些权限，App 仍可使用未涉及该权限的功能。

### 数据备份
本应用提供「设置 → 备份与恢复 → 导出备份」生成 .zip 文件，包含本机数据库 + 照片 + 用户导入的 SKILL.md。**导出的 zip 不含 LLM API key**（key 不离开本机加密存储）。

zip 文件由你自行管理（保存到微信、iCloud、Google Drive、本地硬盘均可）。我们对你导出后的文件不可见、不持有。

Android 系统级 Auto Backup（备份到 Google Drive）默认启用，由系统按 Google 政策处理；本应用对此不参与决策。

### 儿童隐私
本应用面向准爸爸 / 父亲使用，不面向 13 岁以下儿童。我们不刻意收集儿童数据。

### 健康/医疗免责
本应用提供的孕期、育儿、食品安全建议**仅供参考**，**不构成医疗建议**。任何健康问题请咨询专业医生 / 营养师 / 助产士。

### 政策变更
本政策可能更新；更新后会在本页面修改「最后更新」日期。重大变更我们会在 App 内通知。

### 联系
有问题请发邮件到 <你的邮箱>。

---

## English version

### Who we are
good-dad (the "App") is a personal AI assistant for expecting and new dads. Developer: <Your name>.

### What data we collect
**The App itself does not collect, upload, or store any user data on our servers.**

Specifically:
- **Family info** (dad/mom names, current pregnancy week, due date): stored on your device only.
- **Chat history, memories, todos, prenatal/shopping checklists, weekly briefs**: stored in a local SQLite database inside the App's sandbox.
- **Photos you take** (food, belly, chat attachments): stored in the App's local sandbox.
- **LLM API credentials** (baseURL / api key / model name): stored in OS-level secure storage (iOS Keychain / Android EncryptedSharedPreferences).

Our servers hold none of this.

### When data leaves your device
When you use AI features, the App sends requests **directly** to the **third-party LLM service you configured** (e.g. OpenAI, Anthropic, Alibaba Tongyi, Xiaomi MiMo, local Ollama). The request includes your input text, attached images, and locally-assembled context (family info slice, relevant memories).

- Requests do **not** go through our servers.
- Data is processed by your chosen LLM provider under **their** privacy policy.
- You can clear the LLM config any time in Settings to stop all data egress.

### What we do not collect
We do not collect names, emails, phone numbers, device IDs, location, or ad identifiers. The App embeds no analytics SDK and no ads, and does not track usage.

### Permissions
- **Camera**: food recognition, belly photos, chat attachments. Photos stay on device.
- **Photo library**: pick photos from gallery.
- **Local notifications**: weekly Mon/Thu 9:00 pregnancy briefs.
- **Network**: communicate with your configured LLM service.

You can revoke any permission in OS settings; unrelated features still work.

### Backups
"Settings → Backup & restore → Export" produces a .zip with the local database, photos, and user-imported SKILL.md files. **The zip does NOT include LLM API keys.** You manage the zip yourself; we never see it.

Android system Auto Backup to Google Drive is enabled by default and governed by Google's policies; we do not control it.

### Children
This app is for adults; it is not directed at children under 13. We do not knowingly collect data from children.

### Health disclaimer
Pregnancy, childcare, and food-safety guidance from this App is **for reference only** and **does not constitute medical advice**. Consult a licensed physician, dietitian, or midwife for health decisions.

### Changes
We may update this policy; the "Last updated" date will reflect changes. Material changes will be announced in-app.

### Contact
Email <your email>.
