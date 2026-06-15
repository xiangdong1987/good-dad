import '../../calendar/daily_task.dart';
import '../../calendar/daily_task_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';
import 'date_parser_zh.dart';

class AddCalendarTaskTool extends AgentTool {
  @override
  String get name => 'add_calendar_task';

  @override
  String get descriptionZh => '把待办/产检/里程碑加到日程';

  @override
  String get argsHint =>
      'title:string、date:YYYY-MM-DD|今天|明天|后天|周一、kind?:todo|checkup|milestone|note、notes?:string';

  @override
  bool get writes => true;

  @override
  List<ToolExample> get examples => const [
        ToolExample('帮我加个明天去体检的日程',
            {'title': '去体检', 'date': '明天', 'kind': 'checkup'}),
        ToolExample('提醒我下周一买孕妇维生素',
            {'title': '买孕妇维生素', 'date': '下周一', 'kind': 'todo'}),
        ToolExample('5 月 20 日 NT 检查',
            {'title': 'NT 检查', 'date': '5月20日', 'kind': 'checkup'}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final title = (args['title'] ?? '').toString().trim();
    final dateRaw = (args['date'] ?? '今天').toString().trim();
    final kindRaw = (args['kind'] ?? 'todo').toString().trim();
    final notes = (args['notes'] ?? '').toString().trim();

    if (title.isEmpty) {
      return const ToolResult(speakText: '没听清要加什么，能再说一遍吗');
    }

    final date = parseChineseDate(dateRaw);
    final kind = TaskKind.parse(kindRaw);
    final task = DailyTask(
      title: title,
      notes: notes.isEmpty ? null : notes,
      forDate: date,
      kind: kind,
    );

    final repo = ctx.ref.read(dailyTaskRepositoryProvider);
    final id = await repo.add(task);

    final dateLabel = formatChineseShort(date);
    final speak = '好的，已经在 $dateLabel 加上了：$title';

    return ToolResult(
      speakText: speak,
      undo: UndoSnack(
        label: '已加日程 · 撤销',
        undo: () => repo.delete(id),
      ),
    );
  }
}
