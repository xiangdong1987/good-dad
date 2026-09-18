/// 纯计算：按 MET（代谢当量）估算活动消耗。无任何框架依赖。
///
/// MET 取自 Compendium of Physical Activities 的常用值，壶铃各类动作按
/// 「弹道 > 抓举 > 力量 > TGU > 核心 > 热身」的强度梯度归档。
library;

import 'fitness_models.dart';

/// 可估算消耗的固定活动项目。
enum ActivityKind {
  /// 壶铃摆荡等弹道动作。
  kbBallistic(9.5, '壶铃摆荡', '🏋️'),

  /// 壶铃抓举 / 高翻。
  kbSnatch(11.0, '抓举 / 高翻', '💥'),

  /// 壶铃力量动作（深蹲 / 推举 / 划船）。
  kbStrength(6.0, '壶铃力量', '🏋️'),

  /// 土耳其起立。
  kbTgu(5.0, '土耳其起立', '🔄'),

  /// 核心 / 自重（平板支撑、臀桥）。
  core(3.8, '核心 / 自重', '🧘'),

  /// 热身 / 拉伸。
  warmup(2.3, '热身 / 拉伸', '🤸'),

  /// 快走（约 5 km/h）。
  walk(3.5, '快走', '🚶'),

  /// 跑步（约 8 km/h）。
  run(8.3, '跑步', '🏃'),

  /// 骑行通勤（16–19 km/h）。
  bike(6.8, '骑行', '🚲'),

  /// 爬楼梯。
  stairs(8.0, '爬楼梯', '🪜'),

  /// 抱娃 / 家务。
  chores(3.0, '抱娃 / 家务', '👶');

  final double met;

  /// 卡片与选择器上的中文名。
  final String zh;

  /// 贴纸用 emoji（走 `Sticker`，不裸露在文字流里）。
  final String emoji;

  const ActivityKind(this.met, this.zh, this.emoji);

  /// 需要爸爸手动记的项目。壶铃那几项由训练计划自动算，不在这里重复记。
  static const manual = [walk, run, bike, stairs, chores];
}

class FitnessMet {
  /// 1 MET 持续 1 分钟、每公斤体重约消耗的千卡（3.5 / 200）。
  static const _kcalPerMetMinuteKg = 0.0175;

  /// 净消耗：扣掉 MET=1 的基础代谢部分。
  ///
  /// TDEE 里已经算过这段时间的静息代谢，不扣就会重复计算，
  /// 用户会以为自己多出一份可以吃的额度。
  static int netKcal({
    required ActivityKind kind,
    required double weightKg,
    required double minutes,
  }) =>
      _netKcal(kind, weightKg, minutes).round();

  static double _netKcal(ActivityKind kind, double weightKg, double minutes) =>
      (kind.met - 1) * weightKg * _kcalPerMetMinuteKg * minutes;

  /// 计划里的动作名（LLM 生成，中英文混杂）归到固定项目。
  ///
  /// 顺序有意义：「抓举 / 推举」都带「举」字，弹道与抓举必须先于力量类匹配。
  /// 认不出时回退力量类——壶铃计划里力量动作占多数，且不会凭空拔高消耗。
  static ActivityKind classify(String moveName) {
    final s = moveName.toLowerCase();
    bool has(List<String> kws) => kws.any(s.contains);

    if (has(['swing', '摆荡', '甩壶', '荡壶'])) return ActivityKind.kbBallistic;
    if (has(['snatch', 'clean', '抓举', '高翻', '上膊'])) {
      return ActivityKind.kbSnatch;
    }
    if (has(['tgu', 'turkish', '土耳其', '起立'])) return ActivityKind.kbTgu;
    if (has(['plank', '平板', '支撑', '臀桥', '卷腹', '核心', '死虫'])) {
      return ActivityKind.core;
    }
    if (has(['stretch', 'warm', '热身', '拉伸'])) return ActivityKind.warmup;
    return ActivityKind.kbStrength;
  }

  /// 各类动作的节奏：每次秒数 + 组间休息秒数。
  static const _tempo = <ActivityKind, (double, double)>{
    ActivityKind.kbBallistic: (2, 45),
    ActivityKind.kbSnatch: (2, 45),
    ActivityKind.kbStrength: (3, 60),
    ActivityKind.kbTgu: (20, 60),
    // 核心动作的 reps 是秒数而非次数，故每「次」记 1 秒。
    ActivityKind.core: (1, 45),
    ActivityKind.warmup: (1, 15),
  };

  /// 从 sets/reps 反推训练时长（分钟）。
  ///
  /// `TrainingMove` 里没有时长字段，让爸爸练完再填分钟数会增加摩擦，
  /// 所以按动作类型的常见节奏估。结果可在 UI 上手改。
  static double estimateMinutes(TrainingMove move) {
    if (move.sets <= 0 || move.reps <= 0) return 0;
    final (secPerRep, restSec) = _tempo[classify(move.move)] ?? (3, 60);
    final seconds = move.sets * move.reps * secPerRep + (move.sets - 1) * restSec;
    return seconds / 60;
  }

  /// 整节训练的估算时长与净消耗。
  static BurnEstimate sessionBurn({
    required List<TrainingMove> plan,
    required double weightKg,
  }) {
    var minutes = 0.0, kcal = 0.0;
    for (final move in plan) {
      final m = estimateMinutes(move);
      minutes += m;
      kcal += _netKcal(classify(move.move), weightKg, m);
    }
    return BurnEstimate(minutes: minutes, kcal: kcal.round());
  }

  /// 展示用取整：MET 估算误差在 ±20–30%，显示「约 110」比「113」诚实。
  static int displayKcal(int kcal) =>
      kcal < 10 ? kcal : (kcal / 10).round() * 10;
}

/// 一段训练的消耗估算结果。
class BurnEstimate {
  /// 估算时长（分钟）。
  final double minutes;

  /// 净消耗千卡（已扣除基础代谢部分）。
  final int kcal;

  const BurnEstimate({required this.minutes, required this.kcal});

  static const zero = BurnEstimate(minutes: 0, kcal: 0);
}
