# good-dad

> 给准爸爸 / 新手爸爸的本地优先 AI 伴侣。
> Flutter · OpenAI 兼容 LLM（自带 key） · 中文/English/日本語/繁體 · 全本地存储 · 无后端 · 无追踪

## 它做什么

- 🍱 **能不能吃** —— 拍一张食物照，AI 给出孕期友好度判断 + 替代建议
- 👶 **孕期周历** —— 1-42 周可翻看，AI 按周生成宝宝发育 / 妈妈这周注意 / 爸爸能帮的事
- 🍲 **孕期食谱** —— 输入家里食材，AI 推荐两道菜，"换一道"真的换
- 🤰 **肚肚相册** —— 月度时间线 + 当前周高亮
- 📋 **待产包 / 宝宝采购** —— AI 列、你勾、再让 AI 补漏
- 💬 **聊聊** —— 普通聊天 + 自动从对话里沉淀长期记忆 + 自动把"明天 9 点产检"加到日历
- 📅 **日历 + 今日待办** —— 月视图、孕周徽、事件 dot；首页 TodayCard 显示当天 todo
- 🐻 **家庭信息一处管理** —— 当前孕 X 周 Y 天可改，所有 skill 跟着用

## 架构亮点

每个能力都是一份 [SKILL.md](assets/skills/)（Cloud Code 风格）。frontmatter 描述 input/output/temperature，body 是 system prompt。要加新功能基本就是写一份 markdown：

```markdown
---
name: food-safety
input: { image: required }
output: { format: structured }
context: { memory_keys: ["partner.allergies"] }
model: { capability: vision, temperature: 0.2 }
---
你是孕期食品安全顾问...
```

详见 [docs/roadmap.md](docs/roadmap.md)。

## 跑起来

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

第一次启动：填爸爸 / 妈妈称呼 / 当前孕周 → 进设置 → 填 LLM baseURL + key + chat/vision 模型 ID（任何 OpenAI 兼容 endpoint 都行）→ 用起来。

## 本地测试 SKILL.md

不用打包装机，命令行跑：

```bash
GD_BASE_URL=https://api.openai.com/v1 \
GD_API_KEY=sk-... \
GD_VISION_MODEL=gpt-4o \
dart run tool/skill_test.dart food-safety --image dinner.jpg
```

详见 [docs/skill-test.md](docs/skill-test.md)。

## 数据安全

- 本机 SQLite + 本机文件，**完全没有后端**
- LLM 调用直接打到你配置的服务（OpenAI / Claude / 通义 / MiMo / Ollama …）
- API key 存系统级安全存储（iOS Keychain / Android EncryptedSharedPreferences）
- 备份：[docs/backup.md](docs/backup.md)
- 完整隐私政策：[docs/privacy-policy.md](docs/privacy-policy.md)

## 文档导航

| 文档 | 内容 |
|---|---|
| [roadmap.md](docs/roadmap.md) | M1-M7 整体路线图 |
| [skill-test.md](docs/skill-test.md) | 本地命令行测试 SKILL.md |
| [i18n.md](docs/i18n.md) | 多语言架构 |
| [backup.md](docs/backup.md) | 数据备份与恢复 |
| [release-signing.md](docs/release-signing.md) | Android / iOS 发布签名 |
| [github-actions.md](docs/github-actions.md) | GitHub Actions 自动出 APK / 自动建 Release |
| [store-listing.md](docs/store-listing.md) | Play / App Store 上架资料模板 |
| [privacy-policy.md](docs/privacy-policy.md) | 隐私政策（中英） |
| [terms-of-service.md](docs/terms-of-service.md) | 使用条款（中英） |

## Sponsor / Donate

If good-dad is useful to you, consider supporting the project:

- **[Buy Me a Coffee](https://buymeacoffee.com/xiangdong14)** — one-time or monthly support

Thank you.

## License

私有。
