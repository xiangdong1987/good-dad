// ignore_for_file: avoid_print
//
// good-dad 本地技能测试器
//
// 用法（在仓库根目录运行）：
//   GD_BASE_URL=https://api.openai.com/v1 \
//   GD_API_KEY=sk-... \
//   GD_VISION_MODEL=gpt-4o \
//   GD_CHAT_MODEL=gpt-4o-mini \
//   dart run tool/skill_test.dart food-safety --image path/to/photo.jpg
//
//   dart run tool/skill_test.dart pregnancy-recipe --text "家里有鸡蛋、菠菜、虾" --week 24
//
// 这个 CLI 不依赖 Flutter binding（不连数据库、不写文件），完全打到 LLM 看看 SKILL.md 的 prompt 够不够好。

import 'dart:io';
import 'dart:typed_data';

import 'package:good_dad/core/config/llm_config.dart';
import 'package:good_dad/core/llm/openai_compatible_client.dart';
import 'package:good_dad/core/llm/types.dart';
import 'package:good_dad/core/profile/profile.dart';
import 'package:good_dad/core/skill/skill.dart';
import 'package:good_dad/core/skill/skill_parser.dart';
import 'package:good_dad/features/food_safety/food_safety_prompt.dart';

const _usage = '''
good-dad 技能本地测试器

用法:
  dart run tool/skill_test.dart <skill-name> [options]

参数:
  <skill-name>    技能 id（对应 assets/skills/<id>/SKILL.md），例：
                  food-safety / pregnancy-recipe / pregnancy-week / chat / ...

可选:
  --image <path>  传入图片（多模态技能必需）
  --text <text>   传入用户文本，留空时按技能默认（食物识别会用「这个能吃吗？」）
  --week <int>    模拟当前孕周（默认 24）
  --dad <name>    爸爸称呼（默认「老周」）
  --mom <name>    妈妈称呼（默认「小芸」）
  --temperature <num>  覆盖技能里写的 temperature
  --print-prompt  额外打印拼好的 system prompt

环境变量:
  GD_BASE_URL     必填，例 https://api.openai.com/v1
  GD_API_KEY      必填
  GD_CHAT_MODEL   文字模型 id
  GD_VISION_MODEL 视觉模型 id（图片技能必须）
''';

class _Args {
  String? skill;
  String? imagePath;
  String? text;
  int week = 24;
  String dad = '老周';
  String mom = '小芸';
  double? temperature;
  bool printPrompt = false;

  _Args();

  factory _Args.parse(List<String> argv) {
    final a = _Args();
    for (var i = 0; i < argv.length; i++) {
      final v = argv[i];
      String next() {
        if (i + 1 >= argv.length) {
          _die('参数 $v 缺少值');
        }
        return argv[++i];
      }

      switch (v) {
        case '--image':
          a.imagePath = next();
          break;
        case '--text':
          a.text = next();
          break;
        case '--week':
          a.week = int.parse(next());
          break;
        case '--dad':
          a.dad = next();
          break;
        case '--mom':
          a.mom = next();
          break;
        case '--temperature':
          a.temperature = double.parse(next());
          break;
        case '--print-prompt':
          a.printPrompt = true;
          break;
        case '-h':
        case '--help':
          print(_usage);
          exit(0);
        default:
          if (v.startsWith('-')) _die('未知参数: $v');
          a.skill = v;
      }
    }
    if (a.skill == null) _die('要指定 skill 名称');
    return a;
  }
}

Never _die(String msg) {
  stderr.writeln('❌ $msg\n');
  stderr.writeln(_usage);
  exit(2);
}

Future<void> main(List<String> argv) async {
  final args = _Args.parse(argv);

  final cfg = LlmConfig(
    baseUrl: Platform.environment['GD_BASE_URL'] ?? '',
    apiKey: Platform.environment['GD_API_KEY'] ?? '',
    chatModel: Platform.environment['GD_CHAT_MODEL'] ?? '',
    visionModel: Platform.environment['GD_VISION_MODEL'] ?? '',
  );
  if (cfg.baseUrl.isEmpty || cfg.apiKey.isEmpty) {
    _die('GD_BASE_URL / GD_API_KEY 没填');
  }

  // ── 1. 读 SKILL.md ─────────────────────────────────────────────────
  final skillPath = 'assets/skills/${args.skill}/SKILL.md';
  final skillFile = File(skillPath);
  if (!skillFile.existsSync()) {
    _die('找不到 $skillPath');
  }
  final Skill skill =
      SkillParser.parse(args.skill!, skillFile.readAsStringSync());

  print('━' * 60);
  print('技能: ${skill.title} (${skill.name})');
  print('需要视觉: ${skill.needsVision}');
  print('temperature: ${args.temperature ?? skill.temperature}');
  print('━' * 60);

  // ── 2. 准备输入 ────────────────────────────────────────────────────
  if (skill.needsVision && args.imagePath == null) {
    _die('技能 ${skill.name} 需要 --image');
  }

  Uint8List? imgBytes;
  if (args.imagePath != null) {
    final f = File(args.imagePath!);
    if (!f.existsSync()) _die('找不到图片 ${args.imagePath}');
    final raw = f.readAsBytesSync();
    imgBytes = FoodSafetyPrompt.compressImage(raw);
    print('图片: ${args.imagePath}  原始 ${raw.length}B → 压缩后 ${imgBytes.length}B');
  }

  final profile = FamilyProfile(
    dadName: args.dad,
    momName: args.mom,
    dueDate: FamilyProfile.dueDateFromCurrentWeek(args.week),
  );
  print(
      '家庭模拟: 爸爸=${profile.dadName} 妈妈=${profile.momName} 孕周=${profile.currentWeek()}');

  // ── 3. 拼 prompt ──────────────────────────────────────────────────
  final List<LlmMessage> messages;
  if (skill.name == 'food-safety') {
    messages = FoodSafetyPrompt.buildMessages(
        skill, profile, imgBytes!, args.text);
  } else {
    messages = _buildGeneric(skill, profile, args.text, imgBytes);
  }

  if (args.printPrompt) {
    print('\n--- system prompt ---');
    final sys = messages.firstWhere((m) => m.role == LlmRole.system);
    print(sys.textContent);
    print('--- end prompt ---\n');
  }

  // ── 4. 调模型 ─────────────────────────────────────────────────────
  final client = OpenAICompatibleClient(cfg);
  print('\n调用模型... (${skill.needsVision ? cfg.visionModel : cfg.chatModel})');

  final t0 = DateTime.now();
  String raw;
  try {
    raw = await client.chatOnceJson(
      messages,
      temperature: args.temperature ?? skill.temperature,
      needsVision: skill.needsVision,
    );
  } on LlmException catch (e) {
    print('\n❌ LLM 调用失败 (${e.statusCode ?? '?'}): ${e.message}');
    exit(1);
  }
  final ms = DateTime.now().difference(t0).inMilliseconds;
  print('耗时: ${ms}ms\n');

  print('─── Raw output ───────────────────────────');
  print(raw);
  print('──────────────────────────────────────────');

  // ── 5. 结构化技能再多解析一步 ───────────────────────────────────────
  if (skill.name == 'food-safety') {
    final parsed = FoodSafetyPrompt.parseModelOutput(raw);
    print('\n─── Parsed (food-safety) ─────────────────');
    print('verdict:      ${parsed.verdict.name}');
    print('name:         ${parsed.name}');
    print('reason:       ${parsed.reason}');
    print('dos:          ${parsed.dos}');
    print('donts:        ${parsed.donts}');
    print('alternatives: ${parsed.alternatives}');
    print('──────────────────────────────────────────');
  }
}

List<LlmMessage> _buildGeneric(
  Skill skill,
  FamilyProfile profile,
  String? userText,
  Uint8List? imgBytes,
) {
  final ctxLines = <String>[
    '## 家庭信息',
    if (profile.dadName != null) '- 爸爸: ${profile.dadName}',
    if (profile.momName != null) '- 妈妈: ${profile.momName}',
    if (profile.currentWeek() != null) '- 孕周: ${profile.currentWeek()} 周',
  ];
  final sys = '${skill.body.trim()}\n\n${ctxLines.join('\n')}';

  final user = userText?.trim().isNotEmpty == true
      ? userText!.trim()
      : '请按你的角色给出建议。';

  return [
    LlmMessage.system(sys),
    if (imgBytes != null)
      LlmMessage(LlmRole.user, [ImagePart(imgBytes), TextPart(user)])
    else
      LlmMessage.user(user),
  ];
}
