import 'package:flutter/material.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 本周孕期 · Pregnancy Week
class PregnancyWeekPage extends StatelessWidget {
  const PregnancyWeekPage({super.key});

  static const _items = [
    ('👂', '听力发育中', '能听见你的声音了'),
    ('🫁', '肺部在练习', '为出生那一口呼吸做准备'),
    ('👀', '眼皮还闭着', '但能感受到光的明暗'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          // 大数字
          Center(
            child: Column(children: [
              const Text('孕第 24 周 · 还有 16 周',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: AppColors.ink600)),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 90,
                      height: 1,
                      color: AppColors.peach700,
                      letterSpacing: -3),
                  children: [
                    TextSpan(text: '24'),
                    TextSpan(
                        text: 'w',
                        style: TextStyle(
                            fontSize: 32, color: AppColors.ink400)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text.rich(TextSpan(
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink700),
                  children: [
                    TextSpan(text: '宝宝跟'),
                    TextSpan(
                        text: '玉米',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.peach700)),
                    TextSpan(text: '差不多大 🌽'),
                  ])),
            ]),
          ),
          const SizedBox(height: 18),

          // 宝宝插画卡
          CreamCard(
            background: AppColors.sky300,
            padding: const EdgeInsets.all(20),
            child: Stack(children: const [
              Positioned(
                top: 0,
                right: 0,
                child: Sticker(
                    emoji: '🌽',
                    background: AppColors.lemon300,
                    size: 36,
                    tilt: 6),
              ),
              Center(
                child: Column(children: [
                  Text('👶', style: TextStyle(fontSize: 96, height: 1)),
                  SizedBox(height: 8),
                  Text('约 30cm · 600g',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink700)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          Text('本周宝宝在干嘛',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final it in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CreamCard(
                flat: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                radius: AppRadius.md,
                child: Row(children: [
                  Sticker(
                      emoji: it.$1,
                      background: AppColors.peach200,
                      size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.$2,
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 14)),
                        Text(it.$3,
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: AppColors.ink600)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          const SizedBox(height: 8),

          // 爸爸 tip
          CreamCard(
            background: AppColors.lemon300,
            padding: const EdgeInsets.all(14),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Sticker(
                      emoji: '💡',
                      background: Colors.white,
                      size: 36,
                      tilt: -4),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('这周爸爸可以',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: Color(0xFF8A6B14))),
                        SizedBox(height: 2),
                        Text('每晚跟宝宝说 3 分钟话——它真的能听到了。',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
