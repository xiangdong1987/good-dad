# 本地测试技能 (skill_test CLI)

不用打包装机，直接在终端测 SKILL.md 的 prompt 效果——改完 `assets/skills/*/SKILL.md` 立刻 rerun，看模型怎么回答。

## 设置环境变量

把你的 LLM 配置塞到环境变量里。可以在 `~/.zshrc` 写一段：

```bash
export GD_BASE_URL='https://api.openai.com/v1'
export GD_API_KEY='sk-...'
export GD_CHAT_MODEL='gpt-4o-mini'
export GD_VISION_MODEL='gpt-4o'
```

或者每次跑命令时前置：

```bash
GD_BASE_URL=... GD_API_KEY=... GD_VISION_MODEL=... dart run tool/skill_test.dart ...
```

## 食物识别（带图）

```bash
dart run tool/skill_test.dart food-safety \
  --image ~/Downloads/dinner.jpg \
  --week 24
```

会打印：
- 图片压缩前后字节数
- 模拟的家庭信息
- 模型 raw 输出（原始 JSON 或啥都行）
- 解析后的结构化字段：verdict / name / reason / dos / donts / alternatives
- 总耗时

要看完整 system prompt 加 `--print-prompt`。

## 文字技能（孕期食谱、周建议、聊天）

```bash
dart run tool/skill_test.dart pregnancy-recipe \
  --text "家里有鸡蛋、菠菜、虾" \
  --week 24
```

文字技能不需要 `--image`。

## 常用诊断

| 现象 | 原因 |
|------|------|
| `❌ LLM 调用失败 (400) Not supported model X` | 视觉模型 ID 错。先在 App 设置「查看可用模型」找正确名字。 |
| 食物识别返回 verdict=unknown，rawText 是大段中文 | 模型没遵守「只输出 JSON」。把 SKILL.md 末尾再加一句强约束，或换更聪明的模型。 |
| 食物识别返回「图片无法确认是否为可食用食物」 | 大概率你选的模型**不是真正的视觉模型**——它没看到图。换支持 vision 的模型 id。 |
| 解析正确但内容浅薄 | 临时 `--temperature 0.6` 看效果；或在 SKILL.md body 里加 few-shot 案例。 |

## 调整 SKILL.md 流程

1. 改 `assets/skills/<name>/SKILL.md`
2. 跑 `dart run tool/skill_test.dart <name> ...`
3. 看 raw 输出，决定再改还是收工
4. 改完 `flutter build apk --debug` 一次推到手机看 App 效果

> SkillLoader 在 App 内有缓存；运行 App 时改 SKILL.md 要重启进程才生效（debug build 改 assets 一般 hot restart 即可）。
