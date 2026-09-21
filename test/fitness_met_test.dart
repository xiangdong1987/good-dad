import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_met.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';

void main() {
  group('netKcal', () {
    test('净消耗扣掉 MET=1 的基础代谢部分，避免与 TDEE 重复计算', () {
      // swing MET 9.5，70kg 练 10 分钟：(9.5-1) * 70 * 0.0175 * 10 = 104.125
      final kcal = FitnessMet.netKcal(
        kind: ActivityKind.kbBallistic,
        weightKg: 70,
        minutes: 10,
      );
      expect(kcal, 104);
    });

    test('MET 1.0 附近的静止活动不产生净消耗', () {
      final kcal = FitnessMet.netKcal(
        kind: ActivityKind.warmup,
        weightKg: 70,
        minutes: 0,
      );
      expect(kcal, 0);
    });
  });

  group('classify', () {
    test('摆荡类动作归到弹道，中英文都认', () {
      expect(FitnessMet.classify('壶铃摆荡'), ActivityKind.kbBallistic);
      expect(FitnessMet.classify('Kettlebell Swing'), ActivityKind.kbBallistic);
    });

    test('抓举/高翻优先于「举」字匹配到的力量类', () {
      expect(FitnessMet.classify('单手抓举'), ActivityKind.kbSnatch);
      expect(FitnessMet.classify('壶铃高翻'), ActivityKind.kbSnatch);
      expect(FitnessMet.classify('Snatch'), ActivityKind.kbSnatch);
    });

    test('土耳其起立单独归类，强度低于弹道', () {
      expect(FitnessMet.classify('土耳其起立'), ActivityKind.kbTgu);
      expect(FitnessMet.classify('TGU'), ActivityKind.kbTgu);
      expect(ActivityKind.kbTgu.met, lessThan(ActivityKind.kbBallistic.met));
    });

    test('深蹲推举划船归到力量类', () {
      expect(FitnessMet.classify('高脚杯深蹲'), ActivityKind.kbStrength);
      expect(FitnessMet.classify('壶铃推举'), ActivityKind.kbStrength);
      expect(FitnessMet.classify('单臂划船'), ActivityKind.kbStrength);
    });

    test('平板支撑等自重动作归到核心', () {
      expect(FitnessMet.classify('平板支撑'), ActivityKind.core);
      expect(FitnessMet.classify('Plank'), ActivityKind.core);
    });

    test('热身拉伸单独归类', () {
      expect(FitnessMet.classify('动态拉伸'), ActivityKind.warmup);
    });

    test('认不出的动作回退到力量类，不凭空拔高消耗', () {
      expect(FitnessMet.classify('某个没见过的动作'), ActivityKind.kbStrength);
      expect(FitnessMet.classify(''), ActivityKind.kbStrength);
    });
  });

  group('estimateMinutes', () {
    test('弹道动作按 2s/次 + 组间 45s 休息推算时长', () {
      // swing 5×15：75 次 ×2s = 150s，4 次组间休息 ×45s = 180s，共 330s
      const move = TrainingMove(move: '壶铃摆荡', sets: 5, reps: 15, weightKg: 16);
      expect(FitnessMet.estimateMinutes(move), closeTo(5.5, 0.01));
    });

    test('力量动作节奏更慢、休息更长', () {
      // 高脚杯深蹲 3×10：30 次 ×3s = 90s + 2×60s = 120s，共 210s
      const move =
          TrainingMove(move: '高脚杯深蹲', sets: 3, reps: 10, weightKg: 16);
      expect(FitnessMet.estimateMinutes(move), closeTo(3.5, 0.01));
    });

    test('TGU 每次 20s，单次耗时远高于其他动作', () {
      const move = TrainingMove(move: '土耳其起立', sets: 2, reps: 3, weightKg: 12);
      expect(FitnessMet.estimateMinutes(move), closeTo(3.0, 0.01));
    });

    test('核心动作的 reps 当秒数算，不当次数算', () {
      // 平板支撑 3×40s：120s + 2×45s = 210s
      const move = TrainingMove(move: '平板支撑', sets: 3, reps: 40, weightKg: 0);
      expect(FitnessMet.estimateMinutes(move), closeTo(3.5, 0.01));
    });

    test('单组动作没有组间休息', () {
      const move = TrainingMove(move: '壶铃摆荡', sets: 1, reps: 30, weightKg: 16);
      expect(FitnessMet.estimateMinutes(move), closeTo(1.0, 0.01));
    });

    test('组数或次数为 0 时时长为 0', () {
      const move = TrainingMove(move: '壶铃摆荡', sets: 0, reps: 15, weightKg: 16);
      expect(FitnessMet.estimateMinutes(move), 0);
    });
  });

  group('sessionBurn', () {
    test('整节课按动作逐条估时长与净消耗后合计', () {
      const plan = [
        TrainingMove(move: '壶铃摆荡', sets: 5, reps: 15, weightKg: 16),
        TrainingMove(move: '高脚杯深蹲', sets: 3, reps: 10, weightKg: 16),
        TrainingMove(move: '土耳其起立', sets: 2, reps: 3, weightKg: 12),
        TrainingMove(move: '平板支撑', sets: 3, reps: 40, weightKg: 0),
      ];
      final burn = FitnessMet.sessionBurn(plan: plan, weightKg: 75);
      expect(burn.minutes, closeTo(15.5, 0.01));
      expect(burn.kcal, 113);
    });

    test('空计划不产生消耗', () {
      final burn = FitnessMet.sessionBurn(plan: [], weightKg: 75);
      expect(burn.minutes, 0);
      expect(burn.kcal, 0);
    });

    test('体重越大同一节课消耗越高', () {
      const plan = [
        TrainingMove(move: '壶铃摆荡', sets: 5, reps: 15, weightKg: 16),
      ];
      final light = FitnessMet.sessionBurn(plan: plan, weightKg: 60);
      final heavy = FitnessMet.sessionBurn(plan: plan, weightKg: 90);
      expect(heavy.kcal, greaterThan(light.kcal));
      expect(heavy.minutes, closeTo(light.minutes, 0.01));
    });
  });

  group('displayKcal', () {
    test('取整到十位，避免 MET 估算显得比实际精确', () {
      expect(FitnessMet.displayKcal(113), 110);
      expect(FitnessMet.displayKcal(116), 120);
    });

    test('十位以下保留原值，不让小数字归零', () {
      expect(FitnessMet.displayKcal(4), 4);
      expect(FitnessMet.displayKcal(0), 0);
    });
  });

  group('ActivityKind 展示信息', () {
    test('手动记录项只有走路/跑步/骑行/爬楼/抱娃五项', () {
      expect(ActivityKind.manual, [
        ActivityKind.walk,
        ActivityKind.run,
        ActivityKind.bike,
        ActivityKind.stairs,
        ActivityKind.chores,
      ]);
    });

    test('壶铃动作不出现在手动记录项里，它们由训练计划自动算', () {
      expect(ActivityKind.manual.contains(ActivityKind.kbBallistic), isFalse);
      expect(ActivityKind.manual.contains(ActivityKind.core), isFalse);
    });

    test('每个项目都有中文名和 emoji', () {
      for (final k in ActivityKind.values) {
        expect(k.zh, isNotEmpty, reason: '${k.name} 缺中文名');
        expect(k.emoji, isNotEmpty, reason: '${k.name} 缺 emoji');
      }
    });
  });

  group('ActivityKind.parse', () {
    test('按 name 解析 LLM 标注的类型', () {
      expect(ActivityKind.parse('kbBallistic'), ActivityKind.kbBallistic);
      expect(ActivityKind.parse('kbTgu'), ActivityKind.kbTgu);
      expect(ActivityKind.parse('core'), ActivityKind.core);
    });

    test('大小写和空格不敏感', () {
      expect(ActivityKind.parse(' KBBALLISTIC '), ActivityKind.kbBallistic);
    });

    test('认不出或没给时返回 null，交给关键词兜底', () {
      expect(ActivityKind.parse('乱写的'), isNull);
      expect(ActivityKind.parse(null), isNull);
      expect(ActivityKind.parse(''), isNull);
    });

    test('training 只列训练类，不含手动记录的日常项', () {
      expect(ActivityKind.training, isNot(contains(ActivityKind.walk)));
      expect(ActivityKind.training, contains(ActivityKind.kbBallistic));
    });
  });

  group('classify 对真实 LLM 措辞的覆盖', () {
    // 真机上 LLM 输出的是「壶铃摆动」，而关键词表里只有「摆荡」，
    // 结果最典型的弹道动作被归成了力量类。
    test('摆动和摆荡都算弹道', () {
      expect(FitnessMet.classify('壶铃摆动'), ActivityKind.kbBallistic);
      expect(FitnessMet.classify('壶铃摆荡'), ActivityKind.kbBallistic);
    });

    test('起身和起立都算 TGU', () {
      expect(FitnessMet.classify('土耳其起身'), ActivityKind.kbTgu);
      expect(FitnessMet.classify('土耳其起立'), ActivityKind.kbTgu);
    });

    test('挺举归到抓举类而不是力量类', () {
      expect(FitnessMet.classify('壶铃挺举'), ActivityKind.kbSnatch);
    });
  });

  group('sessionBurn 优先用 LLM 标注的类型', () {
    test('move 带 kind 时不再靠关键词猜', () {
      // 动作名故意不含任何弹道关键词，但 kind 标了弹道
      const plan = [
        TrainingMove(
          move: '某个新动作',
          sets: 3,
          reps: 15,
          weightKg: 20,
          kind: ActivityKind.kbBallistic,
        ),
      ];
      final burn = FitnessMet.sessionBurn(plan: plan, weightKg: 94.1);
      // 弹道节奏 2s/次 + 45s 休息 = (45*2 + 2*45)/60 = 3.0 分钟
      expect(burn.minutes, closeTo(3.0, 0.01));
      expect(burn.kcal, 42);
    });

    test('没给 kind 时退回关键词分类', () {
      const plan = [
        TrainingMove(move: '壶铃摆动', sets: 3, reps: 15, weightKg: 20),
      ];
      final burn = FitnessMet.sessionBurn(plan: plan, weightKg: 94.1);
      expect(burn.minutes, closeTo(3.0, 0.01));
    });
  });
}
