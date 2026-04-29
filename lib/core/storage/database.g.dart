// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillNameMeta =
      const VerificationMeta('skillName');
  @override
  late final GeneratedColumn<String> skillName = GeneratedColumn<String>(
      'skill_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, title, skillName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ChatSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('skill_name')) {
      context.handle(_skillNameMeta,
          skillName.isAcceptableOrUnknown(data['skill_name']!, _skillNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      skillName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skill_name']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSessionRow extends DataClass implements Insertable<ChatSessionRow> {
  final int id;
  final String title;
  final String? skillName;
  final DateTime createdAt;
  const ChatSessionRow(
      {required this.id,
      required this.title,
      this.skillName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || skillName != null) {
      map['skill_name'] = Variable<String>(skillName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      title: Value(title),
      skillName: skillName == null && nullToAbsent
          ? const Value.absent()
          : Value(skillName),
      createdAt: Value(createdAt),
    );
  }

  factory ChatSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSessionRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      skillName: serializer.fromJson<String?>(json['skillName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'skillName': serializer.toJson<String?>(skillName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatSessionRow copyWith(
          {int? id,
          String? title,
          Value<String?> skillName = const Value.absent(),
          DateTime? createdAt}) =>
      ChatSessionRow(
        id: id ?? this.id,
        title: title ?? this.title,
        skillName: skillName.present ? skillName.value : this.skillName,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatSessionRow copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSessionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      skillName: data.skillName.present ? data.skillName.value : this.skillName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('skillName: $skillName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, skillName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSessionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.skillName == this.skillName &&
          other.createdAt == this.createdAt);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSessionRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> skillName;
  final Value<DateTime> createdAt;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.skillName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.skillName = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ChatSessionRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? skillName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (skillName != null) 'skill_name': skillName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatSessionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? skillName,
      Value<DateTime>? createdAt}) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      skillName: skillName ?? this.skillName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (skillName.present) {
      map['skill_name'] = Variable<String>(skillName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('skillName: $skillName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chat_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skillRunIdMeta =
      const VerificationMeta('skillRunId');
  @override
  late final GeneratedColumn<int> skillRunId = GeneratedColumn<int>(
      'skill_run_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tokensInMeta =
      const VerificationMeta('tokensIn');
  @override
  late final GeneratedColumn<int> tokensIn = GeneratedColumn<int>(
      'tokens_in', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tokensOutMeta =
      const VerificationMeta('tokensOut');
  @override
  late final GeneratedColumn<int> tokensOut = GeneratedColumn<int>(
      'tokens_out', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
      'ts', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        role,
        content,
        imagePath,
        skillRunId,
        tokensIn,
        tokensOut,
        ts
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<MessageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('skill_run_id')) {
      context.handle(
          _skillRunIdMeta,
          skillRunId.isAcceptableOrUnknown(
              data['skill_run_id']!, _skillRunIdMeta));
    }
    if (data.containsKey('tokens_in')) {
      context.handle(_tokensInMeta,
          tokensIn.isAcceptableOrUnknown(data['tokens_in']!, _tokensInMeta));
    }
    if (data.containsKey('tokens_out')) {
      context.handle(_tokensOutMeta,
          tokensOut.isAcceptableOrUnknown(data['tokens_out']!, _tokensOutMeta));
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      skillRunId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_run_id']),
      tokensIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tokens_in']),
      tokensOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tokens_out']),
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final int id;
  final int sessionId;
  final String role;
  final String content;
  final String? imagePath;
  final int? skillRunId;
  final int? tokensIn;
  final int? tokensOut;
  final DateTime ts;
  const MessageRow(
      {required this.id,
      required this.sessionId,
      required this.role,
      required this.content,
      this.imagePath,
      this.skillRunId,
      this.tokensIn,
      this.tokensOut,
      required this.ts});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || skillRunId != null) {
      map['skill_run_id'] = Variable<int>(skillRunId);
    }
    if (!nullToAbsent || tokensIn != null) {
      map['tokens_in'] = Variable<int>(tokensIn);
    }
    if (!nullToAbsent || tokensOut != null) {
      map['tokens_out'] = Variable<int>(tokensOut);
    }
    map['ts'] = Variable<DateTime>(ts);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      skillRunId: skillRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(skillRunId),
      tokensIn: tokensIn == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensIn),
      tokensOut: tokensOut == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOut),
      ts: Value(ts),
    );
  }

  factory MessageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      skillRunId: serializer.fromJson<int?>(json['skillRunId']),
      tokensIn: serializer.fromJson<int?>(json['tokensIn']),
      tokensOut: serializer.fromJson<int?>(json['tokensOut']),
      ts: serializer.fromJson<DateTime>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'imagePath': serializer.toJson<String?>(imagePath),
      'skillRunId': serializer.toJson<int?>(skillRunId),
      'tokensIn': serializer.toJson<int?>(tokensIn),
      'tokensOut': serializer.toJson<int?>(tokensOut),
      'ts': serializer.toJson<DateTime>(ts),
    };
  }

  MessageRow copyWith(
          {int? id,
          int? sessionId,
          String? role,
          String? content,
          Value<String?> imagePath = const Value.absent(),
          Value<int?> skillRunId = const Value.absent(),
          Value<int?> tokensIn = const Value.absent(),
          Value<int?> tokensOut = const Value.absent(),
          DateTime? ts}) =>
      MessageRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        role: role ?? this.role,
        content: content ?? this.content,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        skillRunId: skillRunId.present ? skillRunId.value : this.skillRunId,
        tokensIn: tokensIn.present ? tokensIn.value : this.tokensIn,
        tokensOut: tokensOut.present ? tokensOut.value : this.tokensOut,
        ts: ts ?? this.ts,
      );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      skillRunId:
          data.skillRunId.present ? data.skillRunId.value : this.skillRunId,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
      ts: data.ts.present ? data.ts.value : this.ts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('imagePath: $imagePath, ')
          ..write('skillRunId: $skillRunId, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, role, content, imagePath,
      skillRunId, tokensIn, tokensOut, ts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.imagePath == this.imagePath &&
          other.skillRunId == this.skillRunId &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut &&
          other.ts == this.ts);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> imagePath;
  final Value<int?> skillRunId;
  final Value<int?> tokensIn;
  final Value<int?> tokensOut;
  final Value<DateTime> ts;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.skillRunId = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.ts = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String role,
    required String content,
    this.imagePath = const Value.absent(),
    this.skillRunId = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.ts = const Value.absent(),
  })  : sessionId = Value(sessionId),
        role = Value(role),
        content = Value(content);
  static Insertable<MessageRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? imagePath,
    Expression<int>? skillRunId,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
    Expression<DateTime>? ts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (imagePath != null) 'image_path': imagePath,
      if (skillRunId != null) 'skill_run_id': skillRunId,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
      if (ts != null) 'ts': ts,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<String>? role,
      Value<String>? content,
      Value<String?>? imagePath,
      Value<int?>? skillRunId,
      Value<int?>? tokensIn,
      Value<int?>? tokensOut,
      Value<DateTime>? ts}) {
    return MessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      skillRunId: skillRunId ?? this.skillRunId,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
      ts: ts ?? this.ts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (skillRunId.present) {
      map['skill_run_id'] = Variable<int>(skillRunId.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('imagePath: $imagePath, ')
          ..write('skillRunId: $skillRunId, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }
}

class $MemoriesTable extends Memories
    with TableInfo<$MemoriesTable, MemoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, name, description, body, status, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(Insertable<MemoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {type, name},
      ];
  @override
  MemoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class MemoryRow extends DataClass implements Insertable<MemoryRow> {
  final int id;

  /// user | feedback | project | reference
  final String type;

  /// e.g. partner.due_date
  final String name;
  final String description;
  final String body;

  /// active | pending (候选记忆抽屉里的，等用户确认)
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemoryRow(
      {required this.id,
      required this.type,
      required this.name,
      required this.description,
      required this.body,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['body'] = Variable<String>(body);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      description: Value(description),
      body: Value(body),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      body: serializer.fromJson<String>(json['body']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'body': serializer.toJson<String>(body),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemoryRow copyWith(
          {int? id,
          String? type,
          String? name,
          String? description,
          String? body,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MemoryRow(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        body: body ?? this.body,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MemoryRow copyWithCompanion(MemoriesCompanion data) {
    return MemoryRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      body: data.body.present ? data.body.value : this.body,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, name, description, body, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.description == this.description &&
          other.body == this.body &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemoriesCompanion extends UpdateCompanion<MemoryRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> name;
  final Value<String> description;
  final Value<String> body;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.body = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MemoriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String name,
    required String description,
    required String body,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : type = Value(type),
        name = Value(name),
        description = Value(description),
        body = Value(body);
  static Insertable<MemoryRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? body,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MemoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? name,
      Value<String>? description,
      Value<String>? body,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MemoriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      body: body ?? this.body,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SkillRunsTable extends SkillRuns
    with TableInfo<$SkillRunsTable, SkillRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skillNameMeta =
      const VerificationMeta('skillName');
  @override
  late final GeneratedColumn<String> skillName = GeneratedColumn<String>(
      'skill_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputJsonMeta =
      const VerificationMeta('inputJson');
  @override
  late final GeneratedColumn<String> inputJson = GeneratedColumn<String>(
      'input_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outputJsonMeta =
      const VerificationMeta('outputJson');
  @override
  late final GeneratedColumn<String> outputJson = GeneratedColumn<String>(
      'output_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latencyMsMeta =
      const VerificationMeta('latencyMs');
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
      'latency_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tokensInMeta =
      const VerificationMeta('tokensIn');
  @override
  late final GeneratedColumn<int> tokensIn = GeneratedColumn<int>(
      'tokens_in', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tokensOutMeta =
      const VerificationMeta('tokensOut');
  @override
  late final GeneratedColumn<int> tokensOut = GeneratedColumn<int>(
      'tokens_out', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        skillName,
        inputJson,
        outputJson,
        latencyMs,
        tokensIn,
        tokensOut,
        error,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skill_runs';
  @override
  VerificationContext validateIntegrity(Insertable<SkillRunRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skill_name')) {
      context.handle(_skillNameMeta,
          skillName.isAcceptableOrUnknown(data['skill_name']!, _skillNameMeta));
    } else if (isInserting) {
      context.missing(_skillNameMeta);
    }
    if (data.containsKey('input_json')) {
      context.handle(_inputJsonMeta,
          inputJson.isAcceptableOrUnknown(data['input_json']!, _inputJsonMeta));
    } else if (isInserting) {
      context.missing(_inputJsonMeta);
    }
    if (data.containsKey('output_json')) {
      context.handle(
          _outputJsonMeta,
          outputJson.isAcceptableOrUnknown(
              data['output_json']!, _outputJsonMeta));
    }
    if (data.containsKey('latency_ms')) {
      context.handle(_latencyMsMeta,
          latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta));
    }
    if (data.containsKey('tokens_in')) {
      context.handle(_tokensInMeta,
          tokensIn.isAcceptableOrUnknown(data['tokens_in']!, _tokensInMeta));
    }
    if (data.containsKey('tokens_out')) {
      context.handle(_tokensOutMeta,
          tokensOut.isAcceptableOrUnknown(data['tokens_out']!, _tokensOutMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkillRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillRunRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      skillName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skill_name'])!,
      inputJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_json'])!,
      outputJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output_json']),
      latencyMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latency_ms']),
      tokensIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tokens_in']),
      tokensOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tokens_out']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SkillRunsTable createAlias(String alias) {
    return $SkillRunsTable(attachedDatabase, alias);
  }
}

class SkillRunRow extends DataClass implements Insertable<SkillRunRow> {
  final int id;
  final String skillName;
  final String inputJson;
  final String? outputJson;
  final int? latencyMs;
  final int? tokensIn;
  final int? tokensOut;
  final String? error;
  final DateTime createdAt;
  const SkillRunRow(
      {required this.id,
      required this.skillName,
      required this.inputJson,
      this.outputJson,
      this.latencyMs,
      this.tokensIn,
      this.tokensOut,
      this.error,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skill_name'] = Variable<String>(skillName);
    map['input_json'] = Variable<String>(inputJson);
    if (!nullToAbsent || outputJson != null) {
      map['output_json'] = Variable<String>(outputJson);
    }
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    if (!nullToAbsent || tokensIn != null) {
      map['tokens_in'] = Variable<int>(tokensIn);
    }
    if (!nullToAbsent || tokensOut != null) {
      map['tokens_out'] = Variable<int>(tokensOut);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SkillRunsCompanion toCompanion(bool nullToAbsent) {
    return SkillRunsCompanion(
      id: Value(id),
      skillName: Value(skillName),
      inputJson: Value(inputJson),
      outputJson: outputJson == null && nullToAbsent
          ? const Value.absent()
          : Value(outputJson),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      tokensIn: tokensIn == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensIn),
      tokensOut: tokensOut == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOut),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      createdAt: Value(createdAt),
    );
  }

  factory SkillRunRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillRunRow(
      id: serializer.fromJson<int>(json['id']),
      skillName: serializer.fromJson<String>(json['skillName']),
      inputJson: serializer.fromJson<String>(json['inputJson']),
      outputJson: serializer.fromJson<String?>(json['outputJson']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      tokensIn: serializer.fromJson<int?>(json['tokensIn']),
      tokensOut: serializer.fromJson<int?>(json['tokensOut']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skillName': serializer.toJson<String>(skillName),
      'inputJson': serializer.toJson<String>(inputJson),
      'outputJson': serializer.toJson<String?>(outputJson),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'tokensIn': serializer.toJson<int?>(tokensIn),
      'tokensOut': serializer.toJson<int?>(tokensOut),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SkillRunRow copyWith(
          {int? id,
          String? skillName,
          String? inputJson,
          Value<String?> outputJson = const Value.absent(),
          Value<int?> latencyMs = const Value.absent(),
          Value<int?> tokensIn = const Value.absent(),
          Value<int?> tokensOut = const Value.absent(),
          Value<String?> error = const Value.absent(),
          DateTime? createdAt}) =>
      SkillRunRow(
        id: id ?? this.id,
        skillName: skillName ?? this.skillName,
        inputJson: inputJson ?? this.inputJson,
        outputJson: outputJson.present ? outputJson.value : this.outputJson,
        latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
        tokensIn: tokensIn.present ? tokensIn.value : this.tokensIn,
        tokensOut: tokensOut.present ? tokensOut.value : this.tokensOut,
        error: error.present ? error.value : this.error,
        createdAt: createdAt ?? this.createdAt,
      );
  SkillRunRow copyWithCompanion(SkillRunsCompanion data) {
    return SkillRunRow(
      id: data.id.present ? data.id.value : this.id,
      skillName: data.skillName.present ? data.skillName.value : this.skillName,
      inputJson: data.inputJson.present ? data.inputJson.value : this.inputJson,
      outputJson:
          data.outputJson.present ? data.outputJson.value : this.outputJson,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillRunRow(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('inputJson: $inputJson, ')
          ..write('outputJson: $outputJson, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, skillName, inputJson, outputJson,
      latencyMs, tokensIn, tokensOut, error, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillRunRow &&
          other.id == this.id &&
          other.skillName == this.skillName &&
          other.inputJson == this.inputJson &&
          other.outputJson == this.outputJson &&
          other.latencyMs == this.latencyMs &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut &&
          other.error == this.error &&
          other.createdAt == this.createdAt);
}

class SkillRunsCompanion extends UpdateCompanion<SkillRunRow> {
  final Value<int> id;
  final Value<String> skillName;
  final Value<String> inputJson;
  final Value<String?> outputJson;
  final Value<int?> latencyMs;
  final Value<int?> tokensIn;
  final Value<int?> tokensOut;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  const SkillRunsCompanion({
    this.id = const Value.absent(),
    this.skillName = const Value.absent(),
    this.inputJson = const Value.absent(),
    this.outputJson = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SkillRunsCompanion.insert({
    this.id = const Value.absent(),
    required String skillName,
    required String inputJson,
    this.outputJson = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : skillName = Value(skillName),
        inputJson = Value(inputJson);
  static Insertable<SkillRunRow> custom({
    Expression<int>? id,
    Expression<String>? skillName,
    Expression<String>? inputJson,
    Expression<String>? outputJson,
    Expression<int>? latencyMs,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillName != null) 'skill_name': skillName,
      if (inputJson != null) 'input_json': inputJson,
      if (outputJson != null) 'output_json': outputJson,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SkillRunsCompanion copyWith(
      {Value<int>? id,
      Value<String>? skillName,
      Value<String>? inputJson,
      Value<String?>? outputJson,
      Value<int?>? latencyMs,
      Value<int?>? tokensIn,
      Value<int?>? tokensOut,
      Value<String?>? error,
      Value<DateTime>? createdAt}) {
    return SkillRunsCompanion(
      id: id ?? this.id,
      skillName: skillName ?? this.skillName,
      inputJson: inputJson ?? this.inputJson,
      outputJson: outputJson ?? this.outputJson,
      latencyMs: latencyMs ?? this.latencyMs,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skillName.present) {
      map['skill_name'] = Variable<String>(skillName.value);
    }
    if (inputJson.present) {
      map['input_json'] = Variable<String>(inputJson.value);
    }
    if (outputJson.present) {
      map['output_json'] = Variable<String>(outputJson.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillRunsCompanion(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('inputJson: $inputJson, ')
          ..write('outputJson: $outputJson, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BellyPhotosTable extends BellyPhotos
    with TableInfo<$BellyPhotosTable, BellyPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BellyPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pregnancyWeekMeta =
      const VerificationMeta('pregnancyWeek');
  @override
  late final GeneratedColumn<int> pregnancyWeek = GeneratedColumn<int>(
      'pregnancy_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aiCommentMeta =
      const VerificationMeta('aiComment');
  @override
  late final GeneratedColumn<String> aiComment = GeneratedColumn<String>(
      'ai_comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, takenAt, pregnancyWeek, imagePath, aiComment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'belly_photos';
  @override
  VerificationContext validateIntegrity(Insertable<BellyPhotoRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('pregnancy_week')) {
      context.handle(
          _pregnancyWeekMeta,
          pregnancyWeek.isAcceptableOrUnknown(
              data['pregnancy_week']!, _pregnancyWeekMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('ai_comment')) {
      context.handle(_aiCommentMeta,
          aiComment.isAcceptableOrUnknown(data['ai_comment']!, _aiCommentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BellyPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BellyPhotoRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
      pregnancyWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pregnancy_week']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      aiComment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_comment']),
    );
  }

  @override
  $BellyPhotosTable createAlias(String alias) {
    return $BellyPhotosTable(attachedDatabase, alias);
  }
}

class BellyPhotoRow extends DataClass implements Insertable<BellyPhotoRow> {
  final int id;
  final DateTime takenAt;
  final int? pregnancyWeek;
  final String imagePath;
  final String? aiComment;
  const BellyPhotoRow(
      {required this.id,
      required this.takenAt,
      this.pregnancyWeek,
      required this.imagePath,
      this.aiComment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || pregnancyWeek != null) {
      map['pregnancy_week'] = Variable<int>(pregnancyWeek);
    }
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || aiComment != null) {
      map['ai_comment'] = Variable<String>(aiComment);
    }
    return map;
  }

  BellyPhotosCompanion toCompanion(bool nullToAbsent) {
    return BellyPhotosCompanion(
      id: Value(id),
      takenAt: Value(takenAt),
      pregnancyWeek: pregnancyWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(pregnancyWeek),
      imagePath: Value(imagePath),
      aiComment: aiComment == null && nullToAbsent
          ? const Value.absent()
          : Value(aiComment),
    );
  }

  factory BellyPhotoRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BellyPhotoRow(
      id: serializer.fromJson<int>(json['id']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      pregnancyWeek: serializer.fromJson<int?>(json['pregnancyWeek']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      aiComment: serializer.fromJson<String?>(json['aiComment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'pregnancyWeek': serializer.toJson<int?>(pregnancyWeek),
      'imagePath': serializer.toJson<String>(imagePath),
      'aiComment': serializer.toJson<String?>(aiComment),
    };
  }

  BellyPhotoRow copyWith(
          {int? id,
          DateTime? takenAt,
          Value<int?> pregnancyWeek = const Value.absent(),
          String? imagePath,
          Value<String?> aiComment = const Value.absent()}) =>
      BellyPhotoRow(
        id: id ?? this.id,
        takenAt: takenAt ?? this.takenAt,
        pregnancyWeek:
            pregnancyWeek.present ? pregnancyWeek.value : this.pregnancyWeek,
        imagePath: imagePath ?? this.imagePath,
        aiComment: aiComment.present ? aiComment.value : this.aiComment,
      );
  BellyPhotoRow copyWithCompanion(BellyPhotosCompanion data) {
    return BellyPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      pregnancyWeek: data.pregnancyWeek.present
          ? data.pregnancyWeek.value
          : this.pregnancyWeek,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      aiComment: data.aiComment.present ? data.aiComment.value : this.aiComment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BellyPhotoRow(')
          ..write('id: $id, ')
          ..write('takenAt: $takenAt, ')
          ..write('pregnancyWeek: $pregnancyWeek, ')
          ..write('imagePath: $imagePath, ')
          ..write('aiComment: $aiComment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, takenAt, pregnancyWeek, imagePath, aiComment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BellyPhotoRow &&
          other.id == this.id &&
          other.takenAt == this.takenAt &&
          other.pregnancyWeek == this.pregnancyWeek &&
          other.imagePath == this.imagePath &&
          other.aiComment == this.aiComment);
}

class BellyPhotosCompanion extends UpdateCompanion<BellyPhotoRow> {
  final Value<int> id;
  final Value<DateTime> takenAt;
  final Value<int?> pregnancyWeek;
  final Value<String> imagePath;
  final Value<String?> aiComment;
  const BellyPhotosCompanion({
    this.id = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.pregnancyWeek = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.aiComment = const Value.absent(),
  });
  BellyPhotosCompanion.insert({
    this.id = const Value.absent(),
    required DateTime takenAt,
    this.pregnancyWeek = const Value.absent(),
    required String imagePath,
    this.aiComment = const Value.absent(),
  })  : takenAt = Value(takenAt),
        imagePath = Value(imagePath);
  static Insertable<BellyPhotoRow> custom({
    Expression<int>? id,
    Expression<DateTime>? takenAt,
    Expression<int>? pregnancyWeek,
    Expression<String>? imagePath,
    Expression<String>? aiComment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (takenAt != null) 'taken_at': takenAt,
      if (pregnancyWeek != null) 'pregnancy_week': pregnancyWeek,
      if (imagePath != null) 'image_path': imagePath,
      if (aiComment != null) 'ai_comment': aiComment,
    });
  }

  BellyPhotosCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? takenAt,
      Value<int?>? pregnancyWeek,
      Value<String>? imagePath,
      Value<String?>? aiComment}) {
    return BellyPhotosCompanion(
      id: id ?? this.id,
      takenAt: takenAt ?? this.takenAt,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      imagePath: imagePath ?? this.imagePath,
      aiComment: aiComment ?? this.aiComment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (pregnancyWeek.present) {
      map['pregnancy_week'] = Variable<int>(pregnancyWeek.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (aiComment.present) {
      map['ai_comment'] = Variable<String>(aiComment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BellyPhotosCompanion(')
          ..write('id: $id, ')
          ..write('takenAt: $takenAt, ')
          ..write('pregnancyWeek: $pregnancyWeek, ')
          ..write('imagePath: $imagePath, ')
          ..write('aiComment: $aiComment')
          ..write(')'))
        .toString();
  }
}

class $PregnancyProfileTable extends PregnancyProfile
    with TableInfo<$PregnancyProfileTable, PregnancyProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnancyProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dadNameMeta =
      const VerificationMeta('dadName');
  @override
  late final GeneratedColumn<String> dadName = GeneratedColumn<String>(
      'dad_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _momNameMeta =
      const VerificationMeta('momName');
  @override
  late final GeneratedColumn<String> momName = GeneratedColumn<String>(
      'mom_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastPeriodMeta =
      const VerificationMeta('lastPeriod');
  @override
  late final GeneratedColumn<DateTime> lastPeriod = GeneratedColumn<DateTime>(
      'last_period', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _partnerInfoJsonMeta =
      const VerificationMeta('partnerInfoJson');
  @override
  late final GeneratedColumn<String> partnerInfoJson = GeneratedColumn<String>(
      'partner_info_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dadName, momName, dueDate, lastPeriod, partnerInfoJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancy_profile';
  @override
  VerificationContext validateIntegrity(
      Insertable<PregnancyProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dad_name')) {
      context.handle(_dadNameMeta,
          dadName.isAcceptableOrUnknown(data['dad_name']!, _dadNameMeta));
    }
    if (data.containsKey('mom_name')) {
      context.handle(_momNameMeta,
          momName.isAcceptableOrUnknown(data['mom_name']!, _momNameMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('last_period')) {
      context.handle(
          _lastPeriodMeta,
          lastPeriod.isAcceptableOrUnknown(
              data['last_period']!, _lastPeriodMeta));
    }
    if (data.containsKey('partner_info_json')) {
      context.handle(
          _partnerInfoJsonMeta,
          partnerInfoJson.isAcceptableOrUnknown(
              data['partner_info_json']!, _partnerInfoJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PregnancyProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PregnancyProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dadName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dad_name']),
      momName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mom_name']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      lastPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_period']),
      partnerInfoJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}partner_info_json']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PregnancyProfileTable createAlias(String alias) {
    return $PregnancyProfileTable(attachedDatabase, alias);
  }
}

class PregnancyProfileRow extends DataClass
    implements Insertable<PregnancyProfileRow> {
  final int id;
  final String? dadName;
  final String? momName;
  final DateTime? dueDate;
  final DateTime? lastPeriod;
  final String? partnerInfoJson;
  final DateTime updatedAt;
  const PregnancyProfileRow(
      {required this.id,
      this.dadName,
      this.momName,
      this.dueDate,
      this.lastPeriod,
      this.partnerInfoJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || dadName != null) {
      map['dad_name'] = Variable<String>(dadName);
    }
    if (!nullToAbsent || momName != null) {
      map['mom_name'] = Variable<String>(momName);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || lastPeriod != null) {
      map['last_period'] = Variable<DateTime>(lastPeriod);
    }
    if (!nullToAbsent || partnerInfoJson != null) {
      map['partner_info_json'] = Variable<String>(partnerInfoJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PregnancyProfileCompanion toCompanion(bool nullToAbsent) {
    return PregnancyProfileCompanion(
      id: Value(id),
      dadName: dadName == null && nullToAbsent
          ? const Value.absent()
          : Value(dadName),
      momName: momName == null && nullToAbsent
          ? const Value.absent()
          : Value(momName),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      lastPeriod: lastPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPeriod),
      partnerInfoJson: partnerInfoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerInfoJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory PregnancyProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PregnancyProfileRow(
      id: serializer.fromJson<int>(json['id']),
      dadName: serializer.fromJson<String?>(json['dadName']),
      momName: serializer.fromJson<String?>(json['momName']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      lastPeriod: serializer.fromJson<DateTime?>(json['lastPeriod']),
      partnerInfoJson: serializer.fromJson<String?>(json['partnerInfoJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dadName': serializer.toJson<String?>(dadName),
      'momName': serializer.toJson<String?>(momName),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'lastPeriod': serializer.toJson<DateTime?>(lastPeriod),
      'partnerInfoJson': serializer.toJson<String?>(partnerInfoJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PregnancyProfileRow copyWith(
          {int? id,
          Value<String?> dadName = const Value.absent(),
          Value<String?> momName = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> lastPeriod = const Value.absent(),
          Value<String?> partnerInfoJson = const Value.absent(),
          DateTime? updatedAt}) =>
      PregnancyProfileRow(
        id: id ?? this.id,
        dadName: dadName.present ? dadName.value : this.dadName,
        momName: momName.present ? momName.value : this.momName,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        lastPeriod: lastPeriod.present ? lastPeriod.value : this.lastPeriod,
        partnerInfoJson: partnerInfoJson.present
            ? partnerInfoJson.value
            : this.partnerInfoJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PregnancyProfileRow copyWithCompanion(PregnancyProfileCompanion data) {
    return PregnancyProfileRow(
      id: data.id.present ? data.id.value : this.id,
      dadName: data.dadName.present ? data.dadName.value : this.dadName,
      momName: data.momName.present ? data.momName.value : this.momName,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      lastPeriod:
          data.lastPeriod.present ? data.lastPeriod.value : this.lastPeriod,
      partnerInfoJson: data.partnerInfoJson.present
          ? data.partnerInfoJson.value
          : this.partnerInfoJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyProfileRow(')
          ..write('id: $id, ')
          ..write('dadName: $dadName, ')
          ..write('momName: $momName, ')
          ..write('dueDate: $dueDate, ')
          ..write('lastPeriod: $lastPeriod, ')
          ..write('partnerInfoJson: $partnerInfoJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dadName, momName, dueDate, lastPeriod, partnerInfoJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PregnancyProfileRow &&
          other.id == this.id &&
          other.dadName == this.dadName &&
          other.momName == this.momName &&
          other.dueDate == this.dueDate &&
          other.lastPeriod == this.lastPeriod &&
          other.partnerInfoJson == this.partnerInfoJson &&
          other.updatedAt == this.updatedAt);
}

class PregnancyProfileCompanion extends UpdateCompanion<PregnancyProfileRow> {
  final Value<int> id;
  final Value<String?> dadName;
  final Value<String?> momName;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> lastPeriod;
  final Value<String?> partnerInfoJson;
  final Value<DateTime> updatedAt;
  const PregnancyProfileCompanion({
    this.id = const Value.absent(),
    this.dadName = const Value.absent(),
    this.momName = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.lastPeriod = const Value.absent(),
    this.partnerInfoJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PregnancyProfileCompanion.insert({
    this.id = const Value.absent(),
    this.dadName = const Value.absent(),
    this.momName = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.lastPeriod = const Value.absent(),
    this.partnerInfoJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<PregnancyProfileRow> custom({
    Expression<int>? id,
    Expression<String>? dadName,
    Expression<String>? momName,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? lastPeriod,
    Expression<String>? partnerInfoJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dadName != null) 'dad_name': dadName,
      if (momName != null) 'mom_name': momName,
      if (dueDate != null) 'due_date': dueDate,
      if (lastPeriod != null) 'last_period': lastPeriod,
      if (partnerInfoJson != null) 'partner_info_json': partnerInfoJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PregnancyProfileCompanion copyWith(
      {Value<int>? id,
      Value<String?>? dadName,
      Value<String?>? momName,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? lastPeriod,
      Value<String?>? partnerInfoJson,
      Value<DateTime>? updatedAt}) {
    return PregnancyProfileCompanion(
      id: id ?? this.id,
      dadName: dadName ?? this.dadName,
      momName: momName ?? this.momName,
      dueDate: dueDate ?? this.dueDate,
      lastPeriod: lastPeriod ?? this.lastPeriod,
      partnerInfoJson: partnerInfoJson ?? this.partnerInfoJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dadName.present) {
      map['dad_name'] = Variable<String>(dadName.value);
    }
    if (momName.present) {
      map['mom_name'] = Variable<String>(momName.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (lastPeriod.present) {
      map['last_period'] = Variable<DateTime>(lastPeriod.value);
    }
    if (partnerInfoJson.present) {
      map['partner_info_json'] = Variable<String>(partnerInfoJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyProfileCompanion(')
          ..write('id: $id, ')
          ..write('dadName: $dadName, ')
          ..write('momName: $momName, ')
          ..write('dueDate: $dueDate, ')
          ..write('lastPeriod: $lastPeriod, ')
          ..write('partnerInfoJson: $partnerInfoJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChecklistTemplatesTable extends ChecklistTemplates
    with TableInfo<$ChecklistTemplatesTable, ChecklistTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skillNameMeta =
      const VerificationMeta('skillName');
  @override
  late final GeneratedColumn<String> skillName = GeneratedColumn<String>(
      'skill_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMdMeta = const VerificationMeta('bodyMd');
  @override
  late final GeneratedColumn<String> bodyMd = GeneratedColumn<String>(
      'body_md', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, skillName, title, bodyMd, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChecklistTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skill_name')) {
      context.handle(_skillNameMeta,
          skillName.isAcceptableOrUnknown(data['skill_name']!, _skillNameMeta));
    } else if (isInserting) {
      context.missing(_skillNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body_md')) {
      context.handle(_bodyMdMeta,
          bodyMd.isAcceptableOrUnknown(data['body_md']!, _bodyMdMeta));
    } else if (isInserting) {
      context.missing(_bodyMdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {skillName},
      ];
  @override
  ChecklistTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistTemplateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      skillName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skill_name'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      bodyMd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_md'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChecklistTemplatesTable createAlias(String alias) {
    return $ChecklistTemplatesTable(attachedDatabase, alias);
  }
}

class ChecklistTemplateRow extends DataClass
    implements Insertable<ChecklistTemplateRow> {
  final int id;
  final String skillName;
  final String title;
  final String bodyMd;
  final DateTime updatedAt;
  const ChecklistTemplateRow(
      {required this.id,
      required this.skillName,
      required this.title,
      required this.bodyMd,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skill_name'] = Variable<String>(skillName);
    map['title'] = Variable<String>(title);
    map['body_md'] = Variable<String>(bodyMd);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChecklistTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ChecklistTemplatesCompanion(
      id: Value(id),
      skillName: Value(skillName),
      title: Value(title),
      bodyMd: Value(bodyMd),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChecklistTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistTemplateRow(
      id: serializer.fromJson<int>(json['id']),
      skillName: serializer.fromJson<String>(json['skillName']),
      title: serializer.fromJson<String>(json['title']),
      bodyMd: serializer.fromJson<String>(json['bodyMd']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skillName': serializer.toJson<String>(skillName),
      'title': serializer.toJson<String>(title),
      'bodyMd': serializer.toJson<String>(bodyMd),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChecklistTemplateRow copyWith(
          {int? id,
          String? skillName,
          String? title,
          String? bodyMd,
          DateTime? updatedAt}) =>
      ChecklistTemplateRow(
        id: id ?? this.id,
        skillName: skillName ?? this.skillName,
        title: title ?? this.title,
        bodyMd: bodyMd ?? this.bodyMd,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChecklistTemplateRow copyWithCompanion(ChecklistTemplatesCompanion data) {
    return ChecklistTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      skillName: data.skillName.present ? data.skillName.value : this.skillName,
      title: data.title.present ? data.title.value : this.title,
      bodyMd: data.bodyMd.present ? data.bodyMd.value : this.bodyMd,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistTemplateRow(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, skillName, title, bodyMd, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistTemplateRow &&
          other.id == this.id &&
          other.skillName == this.skillName &&
          other.title == this.title &&
          other.bodyMd == this.bodyMd &&
          other.updatedAt == this.updatedAt);
}

class ChecklistTemplatesCompanion
    extends UpdateCompanion<ChecklistTemplateRow> {
  final Value<int> id;
  final Value<String> skillName;
  final Value<String> title;
  final Value<String> bodyMd;
  final Value<DateTime> updatedAt;
  const ChecklistTemplatesCompanion({
    this.id = const Value.absent(),
    this.skillName = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMd = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChecklistTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String skillName,
    required String title,
    required String bodyMd,
    this.updatedAt = const Value.absent(),
  })  : skillName = Value(skillName),
        title = Value(title),
        bodyMd = Value(bodyMd);
  static Insertable<ChecklistTemplateRow> custom({
    Expression<int>? id,
    Expression<String>? skillName,
    Expression<String>? title,
    Expression<String>? bodyMd,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillName != null) 'skill_name': skillName,
      if (title != null) 'title': title,
      if (bodyMd != null) 'body_md': bodyMd,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChecklistTemplatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? skillName,
      Value<String>? title,
      Value<String>? bodyMd,
      Value<DateTime>? updatedAt}) {
    return ChecklistTemplatesCompanion(
      id: id ?? this.id,
      skillName: skillName ?? this.skillName,
      title: title ?? this.title,
      bodyMd: bodyMd ?? this.bodyMd,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skillName.present) {
      map['skill_name'] = Variable<String>(skillName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyMd.present) {
      map['body_md'] = Variable<String>(bodyMd.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChecklistInstancesTable extends ChecklistInstances
    with TableInfo<$ChecklistInstancesTable, ChecklistInstanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
      'template_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES checklist_templates (id) ON DELETE SET NULL'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, templateId, title, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_instances';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChecklistInstanceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistInstanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistInstanceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChecklistInstancesTable createAlias(String alias) {
    return $ChecklistInstancesTable(attachedDatabase, alias);
  }
}

class ChecklistInstanceRow extends DataClass
    implements Insertable<ChecklistInstanceRow> {
  final int id;
  final int? templateId;
  final String title;
  final DateTime createdAt;
  const ChecklistInstanceRow(
      {required this.id,
      this.templateId,
      required this.title,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<int>(templateId);
    }
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChecklistInstancesCompanion toCompanion(bool nullToAbsent) {
    return ChecklistInstancesCompanion(
      id: Value(id),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      title: Value(title),
      createdAt: Value(createdAt),
    );
  }

  factory ChecklistInstanceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistInstanceRow(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<int?>(json['templateId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<int?>(templateId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChecklistInstanceRow copyWith(
          {int? id,
          Value<int?> templateId = const Value.absent(),
          String? title,
          DateTime? createdAt}) =>
      ChecklistInstanceRow(
        id: id ?? this.id,
        templateId: templateId.present ? templateId.value : this.templateId,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
      );
  ChecklistInstanceRow copyWithCompanion(ChecklistInstancesCompanion data) {
    return ChecklistInstanceRow(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistInstanceRow(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, title, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistInstanceRow &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.title == this.title &&
          other.createdAt == this.createdAt);
}

class ChecklistInstancesCompanion
    extends UpdateCompanion<ChecklistInstanceRow> {
  final Value<int> id;
  final Value<int?> templateId;
  final Value<String> title;
  final Value<DateTime> createdAt;
  const ChecklistInstancesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChecklistInstancesCompanion.insert({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    required String title,
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ChecklistInstanceRow> custom({
    Expression<int>? id,
    Expression<int>? templateId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChecklistInstancesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? templateId,
      Value<String>? title,
      Value<DateTime>? createdAt}) {
    return ChecklistInstancesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistInstancesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _instanceIdMeta =
      const VerificationMeta('instanceId');
  @override
  late final GeneratedColumn<int> instanceId = GeneratedColumn<int>(
      'instance_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES checklist_instances (id) ON DELETE CASCADE'));
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checkedMeta =
      const VerificationMeta('checked');
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
      'checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, instanceId, parentId, title, checked, notes, photoPath, sort];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_items';
  @override
  VerificationContext validateIntegrity(Insertable<ChecklistItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('instance_id')) {
      context.handle(
          _instanceIdMeta,
          instanceId.isAcceptableOrUnknown(
              data['instance_id']!, _instanceIdMeta));
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(_checkedMeta,
          checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      instanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}instance_id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      checked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}checked'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItemRow extends DataClass
    implements Insertable<ChecklistItemRow> {
  final int id;
  final int instanceId;
  final int? parentId;
  final String title;
  final bool checked;
  final String? notes;
  final String? photoPath;
  final int sort;
  const ChecklistItemRow(
      {required this.id,
      required this.instanceId,
      this.parentId,
      required this.title,
      required this.checked,
      this.notes,
      this.photoPath,
      required this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['instance_id'] = Variable<int>(instanceId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['title'] = Variable<String>(title);
    map['checked'] = Variable<bool>(checked);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['sort'] = Variable<int>(sort);
    return map;
  }

  ChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      checked: Value(checked),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      sort: Value(sort),
    );
  }

  factory ChecklistItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItemRow(
      id: serializer.fromJson<int>(json['id']),
      instanceId: serializer.fromJson<int>(json['instanceId']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      checked: serializer.fromJson<bool>(json['checked']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'instanceId': serializer.toJson<int>(instanceId),
      'parentId': serializer.toJson<int?>(parentId),
      'title': serializer.toJson<String>(title),
      'checked': serializer.toJson<bool>(checked),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'sort': serializer.toJson<int>(sort),
    };
  }

  ChecklistItemRow copyWith(
          {int? id,
          int? instanceId,
          Value<int?> parentId = const Value.absent(),
          String? title,
          bool? checked,
          Value<String?> notes = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          int? sort}) =>
      ChecklistItemRow(
        id: id ?? this.id,
        instanceId: instanceId ?? this.instanceId,
        parentId: parentId.present ? parentId.value : this.parentId,
        title: title ?? this.title,
        checked: checked ?? this.checked,
        notes: notes.present ? notes.value : this.notes,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        sort: sort ?? this.sort,
      );
  ChecklistItemRow copyWithCompanion(ChecklistItemsCompanion data) {
    return ChecklistItemRow(
      id: data.id.present ? data.id.value : this.id,
      instanceId:
          data.instanceId.present ? data.instanceId.value : this.instanceId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      checked: data.checked.present ? data.checked.value : this.checked,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      sort: data.sort.present ? data.sort.value : this.sort,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemRow(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('checked: $checked, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, instanceId, parentId, title, checked, notes, photoPath, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItemRow &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.checked == this.checked &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.sort == this.sort);
}

class ChecklistItemsCompanion extends UpdateCompanion<ChecklistItemRow> {
  final Value<int> id;
  final Value<int> instanceId;
  final Value<int?> parentId;
  final Value<String> title;
  final Value<bool> checked;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int> sort;
  const ChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.checked = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.sort = const Value.absent(),
  });
  ChecklistItemsCompanion.insert({
    this.id = const Value.absent(),
    required int instanceId,
    this.parentId = const Value.absent(),
    required String title,
    this.checked = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.sort = const Value.absent(),
  })  : instanceId = Value(instanceId),
        title = Value(title);
  static Insertable<ChecklistItemRow> custom({
    Expression<int>? id,
    Expression<int>? instanceId,
    Expression<int>? parentId,
    Expression<String>? title,
    Expression<bool>? checked,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? sort,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (checked != null) 'checked': checked,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (sort != null) 'sort': sort,
    });
  }

  ChecklistItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? instanceId,
      Value<int?>? parentId,
      Value<String>? title,
      Value<bool>? checked,
      Value<String?>? notes,
      Value<String?>? photoPath,
      Value<int>? sort}) {
    return ChecklistItemsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      checked: checked ?? this.checked,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      sort: sort ?? this.sort,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<int>(instanceId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('checked: $checked, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $SkillRunsTable skillRuns = $SkillRunsTable(this);
  late final $BellyPhotosTable bellyPhotos = $BellyPhotosTable(this);
  late final $PregnancyProfileTable pregnancyProfile =
      $PregnancyProfileTable(this);
  late final $ChecklistTemplatesTable checklistTemplates =
      $ChecklistTemplatesTable(this);
  late final $ChecklistInstancesTable checklistInstances =
      $ChecklistInstancesTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        chatSessions,
        messages,
        memories,
        skillRuns,
        bellyPhotos,
        pregnancyProfile,
        checklistTemplates,
        checklistInstances,
        checklistItems
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('chat_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('messages', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('checklist_templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('checklist_instances', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('checklist_instances',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('checklist_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ChatSessionsTableCreateCompanionBuilder = ChatSessionsCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> skillName,
  Value<DateTime> createdAt,
});
typedef $$ChatSessionsTableUpdateCompanionBuilder = ChatSessionsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> skillName,
  Value<DateTime> createdAt,
});

class $$ChatSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatSessionsTable,
    ChatSessionRow,
    $$ChatSessionsTableFilterComposer,
    $$ChatSessionsTableOrderingComposer,
    $$ChatSessionsTableCreateCompanionBuilder,
    $$ChatSessionsTableUpdateCompanionBuilder> {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatSessionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatSessionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> skillName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChatSessionsCompanion(
            id: id,
            title: title,
            skillName: skillName,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> skillName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChatSessionsCompanion.insert(
            id: id,
            title: title,
            skillName: skillName,
            createdAt: createdAt,
          ),
        ));
}

class $$ChatSessionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter messagesRefs(
      ComposableFilter Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required int sessionId,
  required String role,
  required String content,
  Value<String?> imagePath,
  Value<int?> skillRunId,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<DateTime> ts,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<String> role,
  Value<String> content,
  Value<String?> imagePath,
  Value<int?> skillRunId,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<DateTime> ts,
});

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    MessageRow,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int?> skillRunId = const Value.absent(),
            Value<int?> tokensIn = const Value.absent(),
            Value<int?> tokensOut = const Value.absent(),
            Value<DateTime> ts = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            imagePath: imagePath,
            skillRunId: skillRunId,
            tokensIn: tokensIn,
            tokensOut: tokensOut,
            ts: ts,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required String role,
            required String content,
            Value<String?> imagePath = const Value.absent(),
            Value<int?> skillRunId = const Value.absent(),
            Value<int?> tokensIn = const Value.absent(),
            Value<int?> tokensOut = const Value.absent(),
            Value<DateTime> ts = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            imagePath: imagePath,
            skillRunId: skillRunId,
            tokensIn: tokensIn,
            tokensOut: tokensOut,
            ts: ts,
          ),
        ));
}

class $$MessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get skillRunId => $state.composableBuilder(
      column: $state.table.skillRunId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get tokensIn => $state.composableBuilder(
      column: $state.table.tokensIn,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get tokensOut => $state.composableBuilder(
      column: $state.table.tokensOut,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $state.db.chatSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ChatSessionsTableFilterComposer(ComposerState($state.db,
                $state.db.chatSessions, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get skillRunId => $state.composableBuilder(
      column: $state.table.skillRunId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get tokensIn => $state.composableBuilder(
      column: $state.table.tokensIn,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get tokensOut => $state.composableBuilder(
      column: $state.table.tokensOut,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $state.db.chatSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ChatSessionsTableOrderingComposer(ComposerState($state.db,
                $state.db.chatSessions, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$MemoriesTableCreateCompanionBuilder = MemoriesCompanion Function({
  Value<int> id,
  required String type,
  required String name,
  required String description,
  required String body,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MemoriesTableUpdateCompanionBuilder = MemoriesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> name,
  Value<String> description,
  Value<String> body,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MemoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MemoriesTable,
    MemoryRow,
    $$MemoriesTableFilterComposer,
    $$MemoriesTableOrderingComposer,
    $$MemoriesTableCreateCompanionBuilder,
    $$MemoriesTableUpdateCompanionBuilder> {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MemoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MemoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MemoriesCompanion(
            id: id,
            type: type,
            name: name,
            description: description,
            body: body,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String name,
            required String description,
            required String body,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MemoriesCompanion.insert(
            id: id,
            type: type,
            name: name,
            description: description,
            body: body,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$MemoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get body => $state.composableBuilder(
      column: $state.table.body,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MemoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get body => $state.composableBuilder(
      column: $state.table.body,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SkillRunsTableCreateCompanionBuilder = SkillRunsCompanion Function({
  Value<int> id,
  required String skillName,
  required String inputJson,
  Value<String?> outputJson,
  Value<int?> latencyMs,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<String?> error,
  Value<DateTime> createdAt,
});
typedef $$SkillRunsTableUpdateCompanionBuilder = SkillRunsCompanion Function({
  Value<int> id,
  Value<String> skillName,
  Value<String> inputJson,
  Value<String?> outputJson,
  Value<int?> latencyMs,
  Value<int?> tokensIn,
  Value<int?> tokensOut,
  Value<String?> error,
  Value<DateTime> createdAt,
});

class $$SkillRunsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillRunsTable,
    SkillRunRow,
    $$SkillRunsTableFilterComposer,
    $$SkillRunsTableOrderingComposer,
    $$SkillRunsTableCreateCompanionBuilder,
    $$SkillRunsTableUpdateCompanionBuilder> {
  $$SkillRunsTableTableManager(_$AppDatabase db, $SkillRunsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SkillRunsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SkillRunsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> skillName = const Value.absent(),
            Value<String> inputJson = const Value.absent(),
            Value<String?> outputJson = const Value.absent(),
            Value<int?> latencyMs = const Value.absent(),
            Value<int?> tokensIn = const Value.absent(),
            Value<int?> tokensOut = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SkillRunsCompanion(
            id: id,
            skillName: skillName,
            inputJson: inputJson,
            outputJson: outputJson,
            latencyMs: latencyMs,
            tokensIn: tokensIn,
            tokensOut: tokensOut,
            error: error,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String skillName,
            required String inputJson,
            Value<String?> outputJson = const Value.absent(),
            Value<int?> latencyMs = const Value.absent(),
            Value<int?> tokensIn = const Value.absent(),
            Value<int?> tokensOut = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SkillRunsCompanion.insert(
            id: id,
            skillName: skillName,
            inputJson: inputJson,
            outputJson: outputJson,
            latencyMs: latencyMs,
            tokensIn: tokensIn,
            tokensOut: tokensOut,
            error: error,
            createdAt: createdAt,
          ),
        ));
}

class $$SkillRunsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SkillRunsTable> {
  $$SkillRunsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get inputJson => $state.composableBuilder(
      column: $state.table.inputJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get outputJson => $state.composableBuilder(
      column: $state.table.outputJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get latencyMs => $state.composableBuilder(
      column: $state.table.latencyMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get tokensIn => $state.composableBuilder(
      column: $state.table.tokensIn,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get tokensOut => $state.composableBuilder(
      column: $state.table.tokensOut,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get error => $state.composableBuilder(
      column: $state.table.error,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SkillRunsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SkillRunsTable> {
  $$SkillRunsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get inputJson => $state.composableBuilder(
      column: $state.table.inputJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get outputJson => $state.composableBuilder(
      column: $state.table.outputJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get latencyMs => $state.composableBuilder(
      column: $state.table.latencyMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get tokensIn => $state.composableBuilder(
      column: $state.table.tokensIn,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get tokensOut => $state.composableBuilder(
      column: $state.table.tokensOut,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get error => $state.composableBuilder(
      column: $state.table.error,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BellyPhotosTableCreateCompanionBuilder = BellyPhotosCompanion
    Function({
  Value<int> id,
  required DateTime takenAt,
  Value<int?> pregnancyWeek,
  required String imagePath,
  Value<String?> aiComment,
});
typedef $$BellyPhotosTableUpdateCompanionBuilder = BellyPhotosCompanion
    Function({
  Value<int> id,
  Value<DateTime> takenAt,
  Value<int?> pregnancyWeek,
  Value<String> imagePath,
  Value<String?> aiComment,
});

class $$BellyPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BellyPhotosTable,
    BellyPhotoRow,
    $$BellyPhotosTableFilterComposer,
    $$BellyPhotosTableOrderingComposer,
    $$BellyPhotosTableCreateCompanionBuilder,
    $$BellyPhotosTableUpdateCompanionBuilder> {
  $$BellyPhotosTableTableManager(_$AppDatabase db, $BellyPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BellyPhotosTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BellyPhotosTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
            Value<int?> pregnancyWeek = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<String?> aiComment = const Value.absent(),
          }) =>
              BellyPhotosCompanion(
            id: id,
            takenAt: takenAt,
            pregnancyWeek: pregnancyWeek,
            imagePath: imagePath,
            aiComment: aiComment,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime takenAt,
            Value<int?> pregnancyWeek = const Value.absent(),
            required String imagePath,
            Value<String?> aiComment = const Value.absent(),
          }) =>
              BellyPhotosCompanion.insert(
            id: id,
            takenAt: takenAt,
            pregnancyWeek: pregnancyWeek,
            imagePath: imagePath,
            aiComment: aiComment,
          ),
        ));
}

class $$BellyPhotosTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BellyPhotosTable> {
  $$BellyPhotosTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get pregnancyWeek => $state.composableBuilder(
      column: $state.table.pregnancyWeek,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get aiComment => $state.composableBuilder(
      column: $state.table.aiComment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BellyPhotosTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BellyPhotosTable> {
  $$BellyPhotosTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get pregnancyWeek => $state.composableBuilder(
      column: $state.table.pregnancyWeek,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get aiComment => $state.composableBuilder(
      column: $state.table.aiComment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PregnancyProfileTableCreateCompanionBuilder
    = PregnancyProfileCompanion Function({
  Value<int> id,
  Value<String?> dadName,
  Value<String?> momName,
  Value<DateTime?> dueDate,
  Value<DateTime?> lastPeriod,
  Value<String?> partnerInfoJson,
  Value<DateTime> updatedAt,
});
typedef $$PregnancyProfileTableUpdateCompanionBuilder
    = PregnancyProfileCompanion Function({
  Value<int> id,
  Value<String?> dadName,
  Value<String?> momName,
  Value<DateTime?> dueDate,
  Value<DateTime?> lastPeriod,
  Value<String?> partnerInfoJson,
  Value<DateTime> updatedAt,
});

class $$PregnancyProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PregnancyProfileTable,
    PregnancyProfileRow,
    $$PregnancyProfileTableFilterComposer,
    $$PregnancyProfileTableOrderingComposer,
    $$PregnancyProfileTableCreateCompanionBuilder,
    $$PregnancyProfileTableUpdateCompanionBuilder> {
  $$PregnancyProfileTableTableManager(
      _$AppDatabase db, $PregnancyProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PregnancyProfileTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PregnancyProfileTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> dadName = const Value.absent(),
            Value<String?> momName = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> lastPeriod = const Value.absent(),
            Value<String?> partnerInfoJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PregnancyProfileCompanion(
            id: id,
            dadName: dadName,
            momName: momName,
            dueDate: dueDate,
            lastPeriod: lastPeriod,
            partnerInfoJson: partnerInfoJson,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> dadName = const Value.absent(),
            Value<String?> momName = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> lastPeriod = const Value.absent(),
            Value<String?> partnerInfoJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PregnancyProfileCompanion.insert(
            id: id,
            dadName: dadName,
            momName: momName,
            dueDate: dueDate,
            lastPeriod: lastPeriod,
            partnerInfoJson: partnerInfoJson,
            updatedAt: updatedAt,
          ),
        ));
}

class $$PregnancyProfileTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PregnancyProfileTable> {
  $$PregnancyProfileTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dadName => $state.composableBuilder(
      column: $state.table.dadName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get momName => $state.composableBuilder(
      column: $state.table.momName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastPeriod => $state.composableBuilder(
      column: $state.table.lastPeriod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get partnerInfoJson => $state.composableBuilder(
      column: $state.table.partnerInfoJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PregnancyProfileTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PregnancyProfileTable> {
  $$PregnancyProfileTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dadName => $state.composableBuilder(
      column: $state.table.dadName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get momName => $state.composableBuilder(
      column: $state.table.momName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastPeriod => $state.composableBuilder(
      column: $state.table.lastPeriod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get partnerInfoJson => $state.composableBuilder(
      column: $state.table.partnerInfoJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChecklistTemplatesTableCreateCompanionBuilder
    = ChecklistTemplatesCompanion Function({
  Value<int> id,
  required String skillName,
  required String title,
  required String bodyMd,
  Value<DateTime> updatedAt,
});
typedef $$ChecklistTemplatesTableUpdateCompanionBuilder
    = ChecklistTemplatesCompanion Function({
  Value<int> id,
  Value<String> skillName,
  Value<String> title,
  Value<String> bodyMd,
  Value<DateTime> updatedAt,
});

class $$ChecklistTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChecklistTemplatesTable,
    ChecklistTemplateRow,
    $$ChecklistTemplatesTableFilterComposer,
    $$ChecklistTemplatesTableOrderingComposer,
    $$ChecklistTemplatesTableCreateCompanionBuilder,
    $$ChecklistTemplatesTableUpdateCompanionBuilder> {
  $$ChecklistTemplatesTableTableManager(
      _$AppDatabase db, $ChecklistTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChecklistTemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ChecklistTemplatesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> skillName = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> bodyMd = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChecklistTemplatesCompanion(
            id: id,
            skillName: skillName,
            title: title,
            bodyMd: bodyMd,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String skillName,
            required String title,
            required String bodyMd,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChecklistTemplatesCompanion.insert(
            id: id,
            skillName: skillName,
            title: title,
            bodyMd: bodyMd,
            updatedAt: updatedAt,
          ),
        ));
}

class $$ChecklistTemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChecklistTemplatesTable> {
  $$ChecklistTemplatesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bodyMd => $state.composableBuilder(
      column: $state.table.bodyMd,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter checklistInstancesRefs(
      ComposableFilter Function($$ChecklistInstancesTableFilterComposer f) f) {
    final $$ChecklistInstancesTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.checklistInstances,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder, parentComposers) =>
                $$ChecklistInstancesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.checklistInstances,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$ChecklistTemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChecklistTemplatesTable> {
  $$ChecklistTemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get skillName => $state.composableBuilder(
      column: $state.table.skillName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bodyMd => $state.composableBuilder(
      column: $state.table.bodyMd,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChecklistInstancesTableCreateCompanionBuilder
    = ChecklistInstancesCompanion Function({
  Value<int> id,
  Value<int?> templateId,
  required String title,
  Value<DateTime> createdAt,
});
typedef $$ChecklistInstancesTableUpdateCompanionBuilder
    = ChecklistInstancesCompanion Function({
  Value<int> id,
  Value<int?> templateId,
  Value<String> title,
  Value<DateTime> createdAt,
});

class $$ChecklistInstancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChecklistInstancesTable,
    ChecklistInstanceRow,
    $$ChecklistInstancesTableFilterComposer,
    $$ChecklistInstancesTableOrderingComposer,
    $$ChecklistInstancesTableCreateCompanionBuilder,
    $$ChecklistInstancesTableUpdateCompanionBuilder> {
  $$ChecklistInstancesTableTableManager(
      _$AppDatabase db, $ChecklistInstancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChecklistInstancesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ChecklistInstancesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> templateId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChecklistInstancesCompanion(
            id: id,
            templateId: templateId,
            title: title,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> templateId = const Value.absent(),
            required String title,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChecklistInstancesCompanion.insert(
            id: id,
            templateId: templateId,
            title: title,
            createdAt: createdAt,
          ),
        ));
}

class $$ChecklistInstancesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChecklistInstancesTable> {
  $$ChecklistInstancesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ChecklistTemplatesTableFilterComposer get templateId {
    final $$ChecklistTemplatesTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $state.db.checklistTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ChecklistTemplatesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.checklistTemplates,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }

  ComposableFilter checklistItemsRefs(
      ComposableFilter Function($$ChecklistItemsTableFilterComposer f) f) {
    final $$ChecklistItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.checklistItems,
        getReferencedColumn: (t) => t.instanceId,
        builder: (joinBuilder, parentComposers) =>
            $$ChecklistItemsTableFilterComposer(ComposerState($state.db,
                $state.db.checklistItems, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ChecklistInstancesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChecklistInstancesTable> {
  $$ChecklistInstancesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ChecklistTemplatesTableOrderingComposer get templateId {
    final $$ChecklistTemplatesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $state.db.checklistTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ChecklistTemplatesTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.checklistTemplates,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$ChecklistItemsTableCreateCompanionBuilder = ChecklistItemsCompanion
    Function({
  Value<int> id,
  required int instanceId,
  Value<int?> parentId,
  required String title,
  Value<bool> checked,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<int> sort,
});
typedef $$ChecklistItemsTableUpdateCompanionBuilder = ChecklistItemsCompanion
    Function({
  Value<int> id,
  Value<int> instanceId,
  Value<int?> parentId,
  Value<String> title,
  Value<bool> checked,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<int> sort,
});

class $$ChecklistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChecklistItemsTable,
    ChecklistItemRow,
    $$ChecklistItemsTableFilterComposer,
    $$ChecklistItemsTableOrderingComposer,
    $$ChecklistItemsTableCreateCompanionBuilder,
    $$ChecklistItemsTableUpdateCompanionBuilder> {
  $$ChecklistItemsTableTableManager(
      _$AppDatabase db, $ChecklistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChecklistItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChecklistItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> instanceId = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> checked = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> sort = const Value.absent(),
          }) =>
              ChecklistItemsCompanion(
            id: id,
            instanceId: instanceId,
            parentId: parentId,
            title: title,
            checked: checked,
            notes: notes,
            photoPath: photoPath,
            sort: sort,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int instanceId,
            Value<int?> parentId = const Value.absent(),
            required String title,
            Value<bool> checked = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> sort = const Value.absent(),
          }) =>
              ChecklistItemsCompanion.insert(
            id: id,
            instanceId: instanceId,
            parentId: parentId,
            title: title,
            checked: checked,
            notes: notes,
            photoPath: photoPath,
            sort: sort,
          ),
        ));
}

class $$ChecklistItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get parentId => $state.composableBuilder(
      column: $state.table.parentId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get checked => $state.composableBuilder(
      column: $state.table.checked,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ChecklistInstancesTableFilterComposer get instanceId {
    final $$ChecklistInstancesTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.instanceId,
            referencedTable: $state.db.checklistInstances,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ChecklistInstancesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.checklistInstances,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$ChecklistItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get parentId => $state.composableBuilder(
      column: $state.table.parentId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get checked => $state.composableBuilder(
      column: $state.table.checked,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ChecklistInstancesTableOrderingComposer get instanceId {
    final $$ChecklistInstancesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.instanceId,
            referencedTable: $state.db.checklistInstances,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ChecklistInstancesTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.checklistInstances,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$SkillRunsTableTableManager get skillRuns =>
      $$SkillRunsTableTableManager(_db, _db.skillRuns);
  $$BellyPhotosTableTableManager get bellyPhotos =>
      $$BellyPhotosTableTableManager(_db, _db.bellyPhotos);
  $$PregnancyProfileTableTableManager get pregnancyProfile =>
      $$PregnancyProfileTableTableManager(_db, _db.pregnancyProfile);
  $$ChecklistTemplatesTableTableManager get checklistTemplates =>
      $$ChecklistTemplatesTableTableManager(_db, _db.checklistTemplates);
  $$ChecklistInstancesTableTableManager get checklistInstances =>
      $$ChecklistInstancesTableTableManager(_db, _db.checklistInstances);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(_db, _db.checklistItems);
}
