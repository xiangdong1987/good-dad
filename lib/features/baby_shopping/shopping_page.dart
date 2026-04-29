import 'package:flutter/material.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 宝宝采购 · Shopping
class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  static const _stages = [
    _Stage('0–1 月', '现在准备', '5 件', true),
    _Stage('1–3 月', '生完再买', '4 件', false),
    _Stage('3–6 月', '别着急', '6 件', false),
    _Stage('6 月+', '到时候说', '8 件', false),
  ];

  static const _items = [
    _Item('🍼', '玻璃奶瓶 240ml', '× 2 个就够', SafetyTag.ok, '必备'),
    _Item('👕', '连体衣 NB', '× 4 件，长得快', SafetyTag.ok, '必备'),
    _Item('🛁', '婴儿浴盆', '能放在脸盆架上的那种', SafetyTag.ok, '必备'),
    _Item('🧴', '婴儿洗发沐浴二合一', '挑无香精款', SafetyTag.caution, '可选'),
    _Item('🧸', '安抚玩偶', '等满月后再买', SafetyTag.avoid, '别急'),
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
              icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('宝宝采购', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          const Text('分阶段买，不囤货也不漏',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 14),

          // 阶段 tab
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stages.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _stages[i];
                return Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: s.active ? AppColors.peach500 : AppColors.cream100,
                    border: Border.all(color: AppColors.ink900, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: s.active ? AppShadows.popLight : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: s.active
                                  ? Colors.white
                                  : AppColors.ink900)),
                      const SizedBox(height: 2),
                      Text('${s.tag} · ${s.count}',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: s.active
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.ink600)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.peach200,
              border: Border.all(color: AppColors.peach700, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(children: const [
              Text('💡', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '前三个月不需要太多玩具——宝宝大部分时间在睡。',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.5),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          for (final it in _items) ...[
            CreamCard(
              flat: true,
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Sticker(
                    emoji: it.emoji,
                    background: AppColors.cream200,
                    size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(it.title,
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 14)),
                        const SizedBox(width: 6),
                        StatusTag(kind: it.tagKind, label: it.tagLabel),
                      ]),
                      const SizedBox(height: 2),
                      Text(it.sub,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppColors.ink600)),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cream100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink900, width: 1.5),
                  ),
                  child: const Icon(Icons.add_rounded, size: 18),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Stage {
  final String name, tag, count;
  final bool active;
  const _Stage(this.name, this.tag, this.count, this.active);
}

class _Item {
  final String emoji, title, sub, tagLabel;
  final SafetyTag tagKind;
  const _Item(this.emoji, this.title, this.sub, this.tagKind, this.tagLabel);
}
