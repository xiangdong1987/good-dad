import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/memory/memory.dart';
import 'package:good_dad/features/italian_vocab/italian_vocab_models.dart';
import 'package:good_dad/features/italian_vocab/italian_vocab_runner.dart';

void main() {
  group('SavedVocab.fromMemory', () {
    test('从规范 body 反解 it/zh/note', () {
      final m = const MemoryEntry(
        id: 7,
        type: MemoryType.reference,
        name: 'vocab.it.divieto_di_sosta',
        description: 'divieto di sosta · 禁止停车',
        body: 'it: divieto di sosta\n'
            'zh: 禁止停车\n'
            'note: m. 复合名词\n'
            'source: italian-license',
      );
      final v = SavedVocab.fromMemory(m);
      expect(v.it, 'divieto di sosta');
      expect(v.zh, '禁止停车');
      expect(v.note, 'm. 复合名词');
      expect(v.memoryId, 7);
    });

    test('body 没匹配字段时回退到 description', () {
      final m = const MemoryEntry(
        id: 1,
        type: MemoryType.reference,
        name: 'vocab.it.foo',
        description: 'foo · bar',
        body: '随便写的内容',
      );
      final v = SavedVocab.fromMemory(m);
      expect(v.it, 'foo · bar');
      expect(v.zh, '');
    });

    test('toPromptLine 拼接格式', () {
      const v = SavedVocab(
        memoryId: 1,
        it: 'sorpasso',
        zh: '超车',
        note: 'm. 名词',
      );
      expect(v.toPromptLine(3), '3. sorpasso — 超车 (m. 名词)');
    });

    test('toPromptLine 在 zh / note 缺失时也能用', () {
      const v =
          SavedVocab(memoryId: 1, it: 'ciao', zh: '', note: '');
      expect(v.toPromptLine(1), '1. ciao');
    });
  });

  group('ItalianVocabRunner.parseSession', () {
    test('纯 JSON 直接解析多张卡', () {
      final raw = '''
{
  "cards": [
    {
      "word_it": "divieto di sosta",
      "word_zh": "禁止停车",
      "example_it": "Qui c'è il divieto di sosta.",
      "example_zh": "这里禁止停车。",
      "quiz_question_it": "Qui c'è il ___ di sosta.",
      "quiz_options": ["divieto", "obbligo", "segnale", "limite"],
      "quiz_answer": "divieto",
      "tip": "divieto m. 名词；记反义词 obbligo（必须）"
    },
    {
      "word_it": "precedenza",
      "word_zh": "优先权",
      "example_it": "Devi dare la precedenza a destra.",
      "example_zh": "你要让右边优先。",
      "quiz_question_it": "Devi dare la ___ a destra.",
      "quiz_options": ["precedenza", "priorità", "stop", "via"],
      "quiz_answer": "precedenza",
      "tip": "f. 名词；dare la precedenza = 让行"
    }
  ]
}
''';
      final s = ItalianVocabRunner.parseSession(raw);
      expect(s.cards.length, 2);
      expect(s.cards.first.wordIt, 'divieto di sosta');
      expect(s.cards.first.quizOptions, hasLength(4));
      expect(s.cards.last.quizAnswer, 'precedenza');
    });

    test('被 markdown 围栏包裹也能扣出 JSON', () {
      final raw = '```json\n{"cards": [{"word_it": "ciao", "word_zh": "你好",'
          '"example_it": "Ciao!", "example_zh": "你好！",'
          '"quiz_question_it": "___, come stai?",'
          '"quiz_options": ["Ciao", "Addio", "Buona", "Salve"],'
          '"quiz_answer": "Ciao", "tip": ""}]}\n```';
      final s = ItalianVocabRunner.parseSession(raw);
      expect(s.cards, hasLength(1));
      expect(s.cards.first.wordIt, 'ciao');
    });

    test('完全不是 JSON 时返回空 cards 但保留 raw', () {
      const raw = '抱歉我没法回答';
      final s = ItalianVocabRunner.parseSession(raw);
      expect(s.cards, isEmpty);
      expect(s.rawText, raw);
    });
  });
}
