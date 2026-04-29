import 'package:flutter/material.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 产前准备 · Checklist
class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  static const _groups = <_Group>[
    _Group('妈妈用', '🤱', AppColors.peach200, [
      _Item('产褥垫', true),
      _Item('一次性内裤 5 条', true),
      _Item('哺乳文胸 × 2', false),
      _Item('出院穿的衣服', false),
    ]),
    _Group('宝宝用', '👶', AppColors.sky300, [
      _Item('新生儿纸尿裤 NB 一包', true),
      _Item('包巾 × 2', false),
      _Item('奶瓶 × 2 + 消毒锅', false),
    ]),
    _Group('证件 & 现金', '📑', AppColors.lemon300, [
      _Item('身份证 × 2', true),
      _Item('孕妇手册 / 产检本', true),
      _Item('现金 2000', false),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _groups.expand((g) => g.items).length;
    final done = _groups.expand((g) => g.items).where((i) => i.done).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('待产包', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 12),

          // 进度 hero
          CreamCard(
            background: AppColors.mint300,
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Sticker(
                  emoji: '🎒',
                  background: Colors.white,
                  size: 56,
                  tilt: -6),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('已收拾',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.mint700)),
                    Text('$done / $total 件',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 22)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: AppColors.ink900, width: 1.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: total == 0 ? 0 : done / total,
                          child: Container(color: AppColors.mint500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          for (final g in _groups) ...[
            Row(children: [
              Sticker(emoji: g.emoji, background: g.bg, size: 28),
              const SizedBox(width: 8),
              Text(g.title,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                '${g.items.where((i) => i.done).length} / ${g.items.length}',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.ink600),
              ),
            ]),
            const SizedBox(height: 8),
            CreamCard(
              flat: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < g.items.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: g.items[i].done
                                ? AppColors.mint500
                                : Colors.white,
                            border: Border.all(
                                color: AppColors.ink900, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: g.items[i].done
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            g.items[i].text,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              decoration: g.items[i].done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: g.items[i].done
                                  ? AppColors.ink400
                                  : AppColors.ink900,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    if (i < g.items.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: DashedDivider(),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _Group {
  final String title, emoji;
  final Color bg;
  final List<_Item> items;
  const _Group(this.title, this.emoji, this.bg, this.items);
}

class _Item {
  final String text;
  final bool done;
  const _Item(this.text, this.done);
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      const dashW = 4.0;
      final n = (c.constrainWidth() / (dashW * 2)).floor();
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(
            n,
            (_) => const SizedBox(
                  width: dashW,
                  height: 1.5,
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.ink200)),
                ))
            .expand((w) => [w, const SizedBox(width: dashW)])
            .toList(),
      );
    });
  }
}
