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

class $DailyTasksTable extends DailyTasks
    with TableInfo<$DailyTasksTable, DailyTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
      'done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _forDateMeta =
      const VerificationMeta('forDate');
  @override
  late final GeneratedColumn<DateTime> forDate = GeneratedColumn<DateTime>(
      'for_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('todo'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, notes, done, forDate, kind, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<DailyTaskRow> instance,
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
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('done')) {
      context.handle(
          _doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('for_date')) {
      context.handle(_forDateMeta,
          forDate.isAcceptableOrUnknown(data['for_date']!, _forDateMeta));
    } else if (isInserting) {
      context.missing(_forDateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
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
  DailyTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      done: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      forDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}for_date'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DailyTasksTable createAlias(String alias) {
    return $DailyTasksTable(attachedDatabase, alias);
  }
}

class DailyTaskRow extends DataClass implements Insertable<DailyTaskRow> {
  final int id;
  final String title;
  final String? notes;
  final bool done;

  /// 该任务关联的日期（取当地零点；用 epoch ms 存）。
  final DateTime forDate;
  final String kind;
  final DateTime createdAt;
  const DailyTaskRow(
      {required this.id,
      required this.title,
      this.notes,
      required this.done,
      required this.forDate,
      required this.kind,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['done'] = Variable<bool>(done);
    map['for_date'] = Variable<DateTime>(forDate);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyTasksCompanion toCompanion(bool nullToAbsent) {
    return DailyTasksCompanion(
      id: Value(id),
      title: Value(title),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      done: Value(done),
      forDate: Value(forDate),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory DailyTaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTaskRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      done: serializer.fromJson<bool>(json['done']),
      forDate: serializer.fromJson<DateTime>(json['forDate']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'done': serializer.toJson<bool>(done),
      'forDate': serializer.toJson<DateTime>(forDate),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyTaskRow copyWith(
          {int? id,
          String? title,
          Value<String?> notes = const Value.absent(),
          bool? done,
          DateTime? forDate,
          String? kind,
          DateTime? createdAt}) =>
      DailyTaskRow(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes.present ? notes.value : this.notes,
        done: done ?? this.done,
        forDate: forDate ?? this.forDate,
        kind: kind ?? this.kind,
        createdAt: createdAt ?? this.createdAt,
      );
  DailyTaskRow copyWithCompanion(DailyTasksCompanion data) {
    return DailyTaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      done: data.done.present ? data.done.value : this.done,
      forDate: data.forDate.present ? data.forDate.value : this.forDate,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('done: $done, ')
          ..write('forDate: $forDate, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, notes, done, forDate, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.done == this.done &&
          other.forDate == this.forDate &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class DailyTasksCompanion extends UpdateCompanion<DailyTaskRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<bool> done;
  final Value<DateTime> forDate;
  final Value<String> kind;
  final Value<DateTime> createdAt;
  const DailyTasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.done = const Value.absent(),
    this.forDate = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyTasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.done = const Value.absent(),
    required DateTime forDate,
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        forDate = Value(forDate);
  static Insertable<DailyTaskRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<bool>? done,
    Expression<DateTime>? forDate,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (done != null) 'done': done,
      if (forDate != null) 'for_date': forDate,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyTasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? notes,
      Value<bool>? done,
      Value<DateTime>? forDate,
      Value<String>? kind,
      Value<DateTime>? createdAt}) {
    return DailyTasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      done: done ?? this.done,
      forDate: forDate ?? this.forDate,
      kind: kind ?? this.kind,
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (forDate.present) {
      map['for_date'] = Variable<DateTime>(forDate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('done: $done, ')
          ..write('forDate: $forDate, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyBriefsTable extends WeeklyBriefs
    with TableInfo<$WeeklyBriefsTable, WeeklyBriefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyBriefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int> week = GeneratedColumn<int>(
      'week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _structuredJsonMeta =
      const VerificationMeta('structuredJson');
  @override
  late final GeneratedColumn<String> structuredJson = GeneratedColumn<String>(
      'structured_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, week, rawText, structuredJson, generatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_briefs';
  @override
  VerificationContext validateIntegrity(Insertable<WeeklyBriefRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week')) {
      context.handle(
          _weekMeta, week.isAcceptableOrUnknown(data['week']!, _weekMeta));
    } else if (isInserting) {
      context.missing(_weekMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('structured_json')) {
      context.handle(
          _structuredJsonMeta,
          structuredJson.isAcceptableOrUnknown(
              data['structured_json']!, _structuredJsonMeta));
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {week},
      ];
  @override
  WeeklyBriefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyBriefRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      week: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      structuredJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}structured_json']),
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
    );
  }

  @override
  $WeeklyBriefsTable createAlias(String alias) {
    return $WeeklyBriefsTable(attachedDatabase, alias);
  }
}

class WeeklyBriefRow extends DataClass implements Insertable<WeeklyBriefRow> {
  final int id;

  /// 孕周 1-42，唯一。
  final int week;
  final String rawText;
  final String? structuredJson;
  final DateTime generatedAt;
  const WeeklyBriefRow(
      {required this.id,
      required this.week,
      required this.rawText,
      this.structuredJson,
      required this.generatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week'] = Variable<int>(week);
    map['raw_text'] = Variable<String>(rawText);
    if (!nullToAbsent || structuredJson != null) {
      map['structured_json'] = Variable<String>(structuredJson);
    }
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  WeeklyBriefsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyBriefsCompanion(
      id: Value(id),
      week: Value(week),
      rawText: Value(rawText),
      structuredJson: structuredJson == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredJson),
      generatedAt: Value(generatedAt),
    );
  }

  factory WeeklyBriefRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyBriefRow(
      id: serializer.fromJson<int>(json['id']),
      week: serializer.fromJson<int>(json['week']),
      rawText: serializer.fromJson<String>(json['rawText']),
      structuredJson: serializer.fromJson<String?>(json['structuredJson']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'week': serializer.toJson<int>(week),
      'rawText': serializer.toJson<String>(rawText),
      'structuredJson': serializer.toJson<String?>(structuredJson),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  WeeklyBriefRow copyWith(
          {int? id,
          int? week,
          String? rawText,
          Value<String?> structuredJson = const Value.absent(),
          DateTime? generatedAt}) =>
      WeeklyBriefRow(
        id: id ?? this.id,
        week: week ?? this.week,
        rawText: rawText ?? this.rawText,
        structuredJson:
            structuredJson.present ? structuredJson.value : this.structuredJson,
        generatedAt: generatedAt ?? this.generatedAt,
      );
  WeeklyBriefRow copyWithCompanion(WeeklyBriefsCompanion data) {
    return WeeklyBriefRow(
      id: data.id.present ? data.id.value : this.id,
      week: data.week.present ? data.week.value : this.week,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      structuredJson: data.structuredJson.present
          ? data.structuredJson.value
          : this.structuredJson,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyBriefRow(')
          ..write('id: $id, ')
          ..write('week: $week, ')
          ..write('rawText: $rawText, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, week, rawText, structuredJson, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyBriefRow &&
          other.id == this.id &&
          other.week == this.week &&
          other.rawText == this.rawText &&
          other.structuredJson == this.structuredJson &&
          other.generatedAt == this.generatedAt);
}

class WeeklyBriefsCompanion extends UpdateCompanion<WeeklyBriefRow> {
  final Value<int> id;
  final Value<int> week;
  final Value<String> rawText;
  final Value<String?> structuredJson;
  final Value<DateTime> generatedAt;
  const WeeklyBriefsCompanion({
    this.id = const Value.absent(),
    this.week = const Value.absent(),
    this.rawText = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  WeeklyBriefsCompanion.insert({
    this.id = const Value.absent(),
    required int week,
    required String rawText,
    this.structuredJson = const Value.absent(),
    this.generatedAt = const Value.absent(),
  })  : week = Value(week),
        rawText = Value(rawText);
  static Insertable<WeeklyBriefRow> custom({
    Expression<int>? id,
    Expression<int>? week,
    Expression<String>? rawText,
    Expression<String>? structuredJson,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (week != null) 'week': week,
      if (rawText != null) 'raw_text': rawText,
      if (structuredJson != null) 'structured_json': structuredJson,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  WeeklyBriefsCompanion copyWith(
      {Value<int>? id,
      Value<int>? week,
      Value<String>? rawText,
      Value<String?>? structuredJson,
      Value<DateTime>? generatedAt}) {
    return WeeklyBriefsCompanion(
      id: id ?? this.id,
      week: week ?? this.week,
      rawText: rawText ?? this.rawText,
      structuredJson: structuredJson ?? this.structuredJson,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (structuredJson.present) {
      map['structured_json'] = Variable<String>(structuredJson.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyBriefsCompanion(')
          ..write('id: $id, ')
          ..write('week: $week, ')
          ..write('rawText: $rawText, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $FitnessProfilesTable extends FitnessProfiles
    with TableInfo<$FitnessProfilesTable, FitnessProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FitnessProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('male'));
  static const VerificationMeta _kettlebellsKgMeta =
      const VerificationMeta('kettlebellsKg');
  @override
  late final GeneratedColumn<String> kettlebellsKg = GeneratedColumn<String>(
      'kettlebells_kg', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _experienceMeta =
      const VerificationMeta('experience');
  @override
  late final GeneratedColumn<String> experience = GeneratedColumn<String>(
      'experience', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('novice'));
  static const VerificationMeta _dailyMinutesMeta =
      const VerificationMeta('dailyMinutes');
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
      'daily_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
      'goal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('maintain'));
  static const VerificationMeta _injuriesMeta =
      const VerificationMeta('injuries');
  @override
  late final GeneratedColumn<String> injuries = GeneratedColumn<String>(
      'injuries', aliasedName, true,
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
  List<GeneratedColumn> get $columns => [
        id,
        heightCm,
        weightKg,
        age,
        sex,
        kettlebellsKg,
        experience,
        dailyMinutes,
        goal,
        injuries,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fitness_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<FitnessProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('kettlebells_kg')) {
      context.handle(
          _kettlebellsKgMeta,
          kettlebellsKg.isAcceptableOrUnknown(
              data['kettlebells_kg']!, _kettlebellsKgMeta));
    }
    if (data.containsKey('experience')) {
      context.handle(
          _experienceMeta,
          experience.isAcceptableOrUnknown(
              data['experience']!, _experienceMeta));
    }
    if (data.containsKey('daily_minutes')) {
      context.handle(
          _dailyMinutesMeta,
          dailyMinutes.isAcceptableOrUnknown(
              data['daily_minutes']!, _dailyMinutesMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('injuries')) {
      context.handle(_injuriesMeta,
          injuries.isAcceptableOrUnknown(data['injuries']!, _injuriesMeta));
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
  FitnessProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FitnessProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height_cm']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      kettlebellsKg: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kettlebells_kg'])!,
      experience: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}experience'])!,
      dailyMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_minutes'])!,
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal'])!,
      injuries: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}injuries']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FitnessProfilesTable createAlias(String alias) {
    return $FitnessProfilesTable(attachedDatabase, alias);
  }
}

class FitnessProfileRow extends DataClass
    implements Insertable<FitnessProfileRow> {
  final int id;
  final int? heightCm;
  final double? weightKg;
  final int? age;
  final String sex;

  /// 手边壶铃重量列表 JSON，如 "[8,12,16]"
  final String kettlebellsKg;
  final String experience;
  final int dailyMinutes;
  final String goal;
  final String? injuries;
  final DateTime updatedAt;
  const FitnessProfileRow(
      {required this.id,
      this.heightCm,
      this.weightKg,
      this.age,
      required this.sex,
      required this.kettlebellsKg,
      required this.experience,
      required this.dailyMinutes,
      required this.goal,
      this.injuries,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    map['sex'] = Variable<String>(sex);
    map['kettlebells_kg'] = Variable<String>(kettlebellsKg);
    map['experience'] = Variable<String>(experience);
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    map['goal'] = Variable<String>(goal);
    if (!nullToAbsent || injuries != null) {
      map['injuries'] = Variable<String>(injuries);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FitnessProfilesCompanion toCompanion(bool nullToAbsent) {
    return FitnessProfilesCompanion(
      id: Value(id),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      sex: Value(sex),
      kettlebellsKg: Value(kettlebellsKg),
      experience: Value(experience),
      dailyMinutes: Value(dailyMinutes),
      goal: Value(goal),
      injuries: injuries == null && nullToAbsent
          ? const Value.absent()
          : Value(injuries),
      updatedAt: Value(updatedAt),
    );
  }

  factory FitnessProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FitnessProfileRow(
      id: serializer.fromJson<int>(json['id']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      age: serializer.fromJson<int?>(json['age']),
      sex: serializer.fromJson<String>(json['sex']),
      kettlebellsKg: serializer.fromJson<String>(json['kettlebellsKg']),
      experience: serializer.fromJson<String>(json['experience']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      goal: serializer.fromJson<String>(json['goal']),
      injuries: serializer.fromJson<String?>(json['injuries']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'heightCm': serializer.toJson<int?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'age': serializer.toJson<int?>(age),
      'sex': serializer.toJson<String>(sex),
      'kettlebellsKg': serializer.toJson<String>(kettlebellsKg),
      'experience': serializer.toJson<String>(experience),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'goal': serializer.toJson<String>(goal),
      'injuries': serializer.toJson<String?>(injuries),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FitnessProfileRow copyWith(
          {int? id,
          Value<int?> heightCm = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<int?> age = const Value.absent(),
          String? sex,
          String? kettlebellsKg,
          String? experience,
          int? dailyMinutes,
          String? goal,
          Value<String?> injuries = const Value.absent(),
          DateTime? updatedAt}) =>
      FitnessProfileRow(
        id: id ?? this.id,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        age: age.present ? age.value : this.age,
        sex: sex ?? this.sex,
        kettlebellsKg: kettlebellsKg ?? this.kettlebellsKg,
        experience: experience ?? this.experience,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        goal: goal ?? this.goal,
        injuries: injuries.present ? injuries.value : this.injuries,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FitnessProfileRow copyWithCompanion(FitnessProfilesCompanion data) {
    return FitnessProfileRow(
      id: data.id.present ? data.id.value : this.id,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      age: data.age.present ? data.age.value : this.age,
      sex: data.sex.present ? data.sex.value : this.sex,
      kettlebellsKg: data.kettlebellsKg.present
          ? data.kettlebellsKg.value
          : this.kettlebellsKg,
      experience:
          data.experience.present ? data.experience.value : this.experience,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      goal: data.goal.present ? data.goal.value : this.goal,
      injuries: data.injuries.present ? data.injuries.value : this.injuries,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FitnessProfileRow(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('kettlebellsKg: $kettlebellsKg, ')
          ..write('experience: $experience, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('goal: $goal, ')
          ..write('injuries: $injuries, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, heightCm, weightKg, age, sex,
      kettlebellsKg, experience, dailyMinutes, goal, injuries, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FitnessProfileRow &&
          other.id == this.id &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.age == this.age &&
          other.sex == this.sex &&
          other.kettlebellsKg == this.kettlebellsKg &&
          other.experience == this.experience &&
          other.dailyMinutes == this.dailyMinutes &&
          other.goal == this.goal &&
          other.injuries == this.injuries &&
          other.updatedAt == this.updatedAt);
}

class FitnessProfilesCompanion extends UpdateCompanion<FitnessProfileRow> {
  final Value<int> id;
  final Value<int?> heightCm;
  final Value<double?> weightKg;
  final Value<int?> age;
  final Value<String> sex;
  final Value<String> kettlebellsKg;
  final Value<String> experience;
  final Value<int> dailyMinutes;
  final Value<String> goal;
  final Value<String?> injuries;
  final Value<DateTime> updatedAt;
  const FitnessProfilesCompanion({
    this.id = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.kettlebellsKg = const Value.absent(),
    this.experience = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.goal = const Value.absent(),
    this.injuries = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FitnessProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.kettlebellsKg = const Value.absent(),
    this.experience = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.goal = const Value.absent(),
    this.injuries = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<FitnessProfileRow> custom({
    Expression<int>? id,
    Expression<int>? heightCm,
    Expression<double>? weightKg,
    Expression<int>? age,
    Expression<String>? sex,
    Expression<String>? kettlebellsKg,
    Expression<String>? experience,
    Expression<int>? dailyMinutes,
    Expression<String>? goal,
    Expression<String>? injuries,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (kettlebellsKg != null) 'kettlebells_kg': kettlebellsKg,
      if (experience != null) 'experience': experience,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (goal != null) 'goal': goal,
      if (injuries != null) 'injuries': injuries,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FitnessProfilesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? heightCm,
      Value<double?>? weightKg,
      Value<int?>? age,
      Value<String>? sex,
      Value<String>? kettlebellsKg,
      Value<String>? experience,
      Value<int>? dailyMinutes,
      Value<String>? goal,
      Value<String?>? injuries,
      Value<DateTime>? updatedAt}) {
    return FitnessProfilesCompanion(
      id: id ?? this.id,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      kettlebellsKg: kettlebellsKg ?? this.kettlebellsKg,
      experience: experience ?? this.experience,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      goal: goal ?? this.goal,
      injuries: injuries ?? this.injuries,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (kettlebellsKg.present) {
      map['kettlebells_kg'] = Variable<String>(kettlebellsKg.value);
    }
    if (experience.present) {
      map['experience'] = Variable<String>(experience.value);
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (injuries.present) {
      map['injuries'] = Variable<String>(injuries.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FitnessProfilesCompanion(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('kettlebellsKg: $kettlebellsKg, ')
          ..write('experience: $experience, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('goal: $goal, ')
          ..write('injuries: $injuries, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MealLogsTable extends MealLogs
    with TableInfo<$MealLogsTable, MealLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
      'meal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _foodsJsonMeta =
      const VerificationMeta('foodsJson');
  @override
  late final GeneratedColumn<String> foodsJson = GeneratedColumn<String>(
      'foods_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
      'kcal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinGMeta =
      const VerificationMeta('proteinG');
  @override
  late final GeneratedColumn<int> proteinG = GeneratedColumn<int>(
      'protein_g', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _carbGMeta = const VerificationMeta('carbG');
  @override
  late final GeneratedColumn<int> carbG = GeneratedColumn<int>(
      'carb_g', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<int> fatG = GeneratedColumn<int>(
      'fat_g', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
      'edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("edited" IN (0, 1))'),
      defaultValue: const Constant(false));
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
        date,
        meal,
        photoPath,
        foodsJson,
        kcal,
        proteinG,
        carbG,
        fatG,
        edited,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_logs';
  @override
  VerificationContext validateIntegrity(Insertable<MealLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
          _mealMeta, meal.isAcceptableOrUnknown(data['meal']!, _mealMeta));
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('foods_json')) {
      context.handle(_foodsJsonMeta,
          foodsJson.isAcceptableOrUnknown(data['foods_json']!, _foodsJsonMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    if (data.containsKey('protein_g')) {
      context.handle(_proteinGMeta,
          proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta));
    }
    if (data.containsKey('carb_g')) {
      context.handle(
          _carbGMeta, carbG.isAcceptableOrUnknown(data['carb_g']!, _carbGMeta));
    }
    if (data.containsKey('fat_g')) {
      context.handle(
          _fatGMeta, fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta));
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited']!, _editedMeta));
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
  MealLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      meal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      foodsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foods_json'])!,
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kcal'])!,
      proteinG: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}protein_g'])!,
      carbG: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carb_g'])!,
      fatG: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fat_g'])!,
      edited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}edited'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MealLogsTable createAlias(String alias) {
    return $MealLogsTable(attachedDatabase, alias);
  }
}

class MealLogRow extends DataClass implements Insertable<MealLogRow> {
  final int id;
  final String date;
  final String meal;
  final String? photoPath;

  /// 食物清单 JSON，如 [{"name":"米饭","grams":150}]
  final String foodsJson;
  final int kcal;
  final int proteinG;
  final int carbG;
  final int fatG;
  final bool edited;
  final DateTime createdAt;
  const MealLogRow(
      {required this.id,
      required this.date,
      required this.meal,
      this.photoPath,
      required this.foodsJson,
      required this.kcal,
      required this.proteinG,
      required this.carbG,
      required this.fatG,
      required this.edited,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['meal'] = Variable<String>(meal);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['foods_json'] = Variable<String>(foodsJson);
    map['kcal'] = Variable<int>(kcal);
    map['protein_g'] = Variable<int>(proteinG);
    map['carb_g'] = Variable<int>(carbG);
    map['fat_g'] = Variable<int>(fatG);
    map['edited'] = Variable<bool>(edited);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealLogsCompanion toCompanion(bool nullToAbsent) {
    return MealLogsCompanion(
      id: Value(id),
      date: Value(date),
      meal: Value(meal),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      foodsJson: Value(foodsJson),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbG: Value(carbG),
      fatG: Value(fatG),
      edited: Value(edited),
      createdAt: Value(createdAt),
    );
  }

  factory MealLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      meal: serializer.fromJson<String>(json['meal']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      foodsJson: serializer.fromJson<String>(json['foodsJson']),
      kcal: serializer.fromJson<int>(json['kcal']),
      proteinG: serializer.fromJson<int>(json['proteinG']),
      carbG: serializer.fromJson<int>(json['carbG']),
      fatG: serializer.fromJson<int>(json['fatG']),
      edited: serializer.fromJson<bool>(json['edited']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'meal': serializer.toJson<String>(meal),
      'photoPath': serializer.toJson<String?>(photoPath),
      'foodsJson': serializer.toJson<String>(foodsJson),
      'kcal': serializer.toJson<int>(kcal),
      'proteinG': serializer.toJson<int>(proteinG),
      'carbG': serializer.toJson<int>(carbG),
      'fatG': serializer.toJson<int>(fatG),
      'edited': serializer.toJson<bool>(edited),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MealLogRow copyWith(
          {int? id,
          String? date,
          String? meal,
          Value<String?> photoPath = const Value.absent(),
          String? foodsJson,
          int? kcal,
          int? proteinG,
          int? carbG,
          int? fatG,
          bool? edited,
          DateTime? createdAt}) =>
      MealLogRow(
        id: id ?? this.id,
        date: date ?? this.date,
        meal: meal ?? this.meal,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        foodsJson: foodsJson ?? this.foodsJson,
        kcal: kcal ?? this.kcal,
        proteinG: proteinG ?? this.proteinG,
        carbG: carbG ?? this.carbG,
        fatG: fatG ?? this.fatG,
        edited: edited ?? this.edited,
        createdAt: createdAt ?? this.createdAt,
      );
  MealLogRow copyWithCompanion(MealLogsCompanion data) {
    return MealLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      foodsJson: data.foodsJson.present ? data.foodsJson.value : this.foodsJson,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbG: data.carbG.present ? data.carbG.value : this.carbG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      edited: data.edited.present ? data.edited.value : this.edited,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('photoPath: $photoPath, ')
          ..write('foodsJson: $foodsJson, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbG: $carbG, ')
          ..write('fatG: $fatG, ')
          ..write('edited: $edited, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, meal, photoPath, foodsJson, kcal,
      proteinG, carbG, fatG, edited, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.photoPath == this.photoPath &&
          other.foodsJson == this.foodsJson &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbG == this.carbG &&
          other.fatG == this.fatG &&
          other.edited == this.edited &&
          other.createdAt == this.createdAt);
}

class MealLogsCompanion extends UpdateCompanion<MealLogRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> meal;
  final Value<String?> photoPath;
  final Value<String> foodsJson;
  final Value<int> kcal;
  final Value<int> proteinG;
  final Value<int> carbG;
  final Value<int> fatG;
  final Value<bool> edited;
  final Value<DateTime> createdAt;
  const MealLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.foodsJson = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.edited = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MealLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String meal,
    this.photoPath = const Value.absent(),
    this.foodsJson = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.edited = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : date = Value(date),
        meal = Value(meal);
  static Insertable<MealLogRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? meal,
    Expression<String>? photoPath,
    Expression<String>? foodsJson,
    Expression<int>? kcal,
    Expression<int>? proteinG,
    Expression<int>? carbG,
    Expression<int>? fatG,
    Expression<bool>? edited,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (photoPath != null) 'photo_path': photoPath,
      if (foodsJson != null) 'foods_json': foodsJson,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbG != null) 'carb_g': carbG,
      if (fatG != null) 'fat_g': fatG,
      if (edited != null) 'edited': edited,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MealLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? meal,
      Value<String?>? photoPath,
      Value<String>? foodsJson,
      Value<int>? kcal,
      Value<int>? proteinG,
      Value<int>? carbG,
      Value<int>? fatG,
      Value<bool>? edited,
      Value<DateTime>? createdAt}) {
    return MealLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      photoPath: photoPath ?? this.photoPath,
      foodsJson: foodsJson ?? this.foodsJson,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbG: carbG ?? this.carbG,
      fatG: fatG ?? this.fatG,
      edited: edited ?? this.edited,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (foodsJson.present) {
      map['foods_json'] = Variable<String>(foodsJson.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<int>(proteinG.value);
    }
    if (carbG.present) {
      map['carb_g'] = Variable<int>(carbG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<int>(fatG.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('photoPath: $photoPath, ')
          ..write('foodsJson: $foodsJson, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbG: $carbG, ')
          ..write('fatG: $fatG, ')
          ..write('edited: $edited, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TrainingLogsTable extends TrainingLogs
    with TableInfo<$TrainingLogsTable, TrainingLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planJsonMeta =
      const VerificationMeta('planJson');
  @override
  late final GeneratedColumn<String> planJson = GeneratedColumn<String>(
      'plan_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
      'done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _feelingMeta =
      const VerificationMeta('feeling');
  @override
  late final GeneratedColumn<String> feeling = GeneratedColumn<String>(
      'feeling', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, date, planJson, done, feeling];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_logs';
  @override
  VerificationContext validateIntegrity(Insertable<TrainingLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('plan_json')) {
      context.handle(_planJsonMeta,
          planJson.isAcceptableOrUnknown(data['plan_json']!, _planJsonMeta));
    }
    if (data.containsKey('done')) {
      context.handle(
          _doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('feeling')) {
      context.handle(_feelingMeta,
          feeling.isAcceptableOrUnknown(data['feeling']!, _feelingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {date},
      ];
  @override
  TrainingLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      planJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_json'])!,
      done: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      feeling: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feeling']),
    );
  }

  @override
  $TrainingLogsTable createAlias(String alias) {
    return $TrainingLogsTable(attachedDatabase, alias);
  }
}

class TrainingLogRow extends DataClass implements Insertable<TrainingLogRow> {
  final int id;
  final String date;
  final String planJson;
  final bool done;
  final String? feeling;
  const TrainingLogRow(
      {required this.id,
      required this.date,
      required this.planJson,
      required this.done,
      this.feeling});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['plan_json'] = Variable<String>(planJson);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || feeling != null) {
      map['feeling'] = Variable<String>(feeling);
    }
    return map;
  }

  TrainingLogsCompanion toCompanion(bool nullToAbsent) {
    return TrainingLogsCompanion(
      id: Value(id),
      date: Value(date),
      planJson: Value(planJson),
      done: Value(done),
      feeling: feeling == null && nullToAbsent
          ? const Value.absent()
          : Value(feeling),
    );
  }

  factory TrainingLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      planJson: serializer.fromJson<String>(json['planJson']),
      done: serializer.fromJson<bool>(json['done']),
      feeling: serializer.fromJson<String?>(json['feeling']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'planJson': serializer.toJson<String>(planJson),
      'done': serializer.toJson<bool>(done),
      'feeling': serializer.toJson<String?>(feeling),
    };
  }

  TrainingLogRow copyWith(
          {int? id,
          String? date,
          String? planJson,
          bool? done,
          Value<String?> feeling = const Value.absent()}) =>
      TrainingLogRow(
        id: id ?? this.id,
        date: date ?? this.date,
        planJson: planJson ?? this.planJson,
        done: done ?? this.done,
        feeling: feeling.present ? feeling.value : this.feeling,
      );
  TrainingLogRow copyWithCompanion(TrainingLogsCompanion data) {
    return TrainingLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      planJson: data.planJson.present ? data.planJson.value : this.planJson,
      done: data.done.present ? data.done.value : this.done,
      feeling: data.feeling.present ? data.feeling.value : this.feeling,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('planJson: $planJson, ')
          ..write('done: $done, ')
          ..write('feeling: $feeling')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, planJson, done, feeling);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.planJson == this.planJson &&
          other.done == this.done &&
          other.feeling == this.feeling);
}

class TrainingLogsCompanion extends UpdateCompanion<TrainingLogRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> planJson;
  final Value<bool> done;
  final Value<String?> feeling;
  const TrainingLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.planJson = const Value.absent(),
    this.done = const Value.absent(),
    this.feeling = const Value.absent(),
  });
  TrainingLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.planJson = const Value.absent(),
    this.done = const Value.absent(),
    this.feeling = const Value.absent(),
  }) : date = Value(date);
  static Insertable<TrainingLogRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? planJson,
    Expression<bool>? done,
    Expression<String>? feeling,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (planJson != null) 'plan_json': planJson,
      if (done != null) 'done': done,
      if (feeling != null) 'feeling': feeling,
    });
  }

  TrainingLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? planJson,
      Value<bool>? done,
      Value<String?>? feeling}) {
    return TrainingLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      planJson: planJson ?? this.planJson,
      done: done ?? this.done,
      feeling: feeling ?? this.feeling,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (planJson.present) {
      map['plan_json'] = Variable<String>(planJson.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (feeling.present) {
      map['feeling'] = Variable<String>(feeling.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('planJson: $planJson, ')
          ..write('done: $done, ')
          ..write('feeling: $feeling')
          ..write(')'))
        .toString();
  }
}

class $DailyPlansTable extends DailyPlans
    with TableInfo<$DailyPlansTable, DailyPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
      'target_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trainingPlanJsonMeta =
      const VerificationMeta('trainingPlanJson');
  @override
  late final GeneratedColumn<String> trainingPlanJson = GeneratedColumn<String>(
      'training_plan_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _dietGuidanceMeta =
      const VerificationMeta('dietGuidance');
  @override
  late final GeneratedColumn<String> dietGuidance = GeneratedColumn<String>(
      'diet_guidance', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _kcalTargetMeta =
      const VerificationMeta('kcalTarget');
  @override
  late final GeneratedColumn<int> kcalTarget = GeneratedColumn<int>(
      'kcal_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinTargetMeta =
      const VerificationMeta('proteinTarget');
  @override
  late final GeneratedColumn<int> proteinTarget = GeneratedColumn<int>(
      'protein_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _carbTargetMeta =
      const VerificationMeta('carbTarget');
  @override
  late final GeneratedColumn<int> carbTarget = GeneratedColumn<int>(
      'carb_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fatTargetMeta =
      const VerificationMeta('fatTarget');
  @override
  late final GeneratedColumn<int> fatTarget = GeneratedColumn<int>(
      'fat_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deficitSummaryMeta =
      const VerificationMeta('deficitSummary');
  @override
  late final GeneratedColumn<String> deficitSummary = GeneratedColumn<String>(
      'deficit_summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        targetDate,
        trainingPlanJson,
        dietGuidance,
        kcalTarget,
        proteinTarget,
        carbTarget,
        fatTarget,
        deficitSummary,
        generatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_plans';
  @override
  VerificationContext validateIntegrity(Insertable<DailyPlanRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('training_plan_json')) {
      context.handle(
          _trainingPlanJsonMeta,
          trainingPlanJson.isAcceptableOrUnknown(
              data['training_plan_json']!, _trainingPlanJsonMeta));
    }
    if (data.containsKey('diet_guidance')) {
      context.handle(
          _dietGuidanceMeta,
          dietGuidance.isAcceptableOrUnknown(
              data['diet_guidance']!, _dietGuidanceMeta));
    }
    if (data.containsKey('kcal_target')) {
      context.handle(
          _kcalTargetMeta,
          kcalTarget.isAcceptableOrUnknown(
              data['kcal_target']!, _kcalTargetMeta));
    }
    if (data.containsKey('protein_target')) {
      context.handle(
          _proteinTargetMeta,
          proteinTarget.isAcceptableOrUnknown(
              data['protein_target']!, _proteinTargetMeta));
    }
    if (data.containsKey('carb_target')) {
      context.handle(
          _carbTargetMeta,
          carbTarget.isAcceptableOrUnknown(
              data['carb_target']!, _carbTargetMeta));
    }
    if (data.containsKey('fat_target')) {
      context.handle(_fatTargetMeta,
          fatTarget.isAcceptableOrUnknown(data['fat_target']!, _fatTargetMeta));
    }
    if (data.containsKey('deficit_summary')) {
      context.handle(
          _deficitSummaryMeta,
          deficitSummary.isAcceptableOrUnknown(
              data['deficit_summary']!, _deficitSummaryMeta));
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetDate};
  @override
  DailyPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPlanRow(
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_date'])!,
      trainingPlanJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}training_plan_json'])!,
      dietGuidance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diet_guidance'])!,
      kcalTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kcal_target'])!,
      proteinTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}protein_target'])!,
      carbTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carb_target'])!,
      fatTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fat_target'])!,
      deficitSummary: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deficit_summary'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
    );
  }

  @override
  $DailyPlansTable createAlias(String alias) {
    return $DailyPlansTable(attachedDatabase, alias);
  }
}

class DailyPlanRow extends DataClass implements Insertable<DailyPlanRow> {
  final String targetDate;

  /// 训练动作 JSON，如 [{"move":"高脚杯深蹲","sets":3,"reps":10,"weightKg":12,"note":""}]
  final String trainingPlanJson;
  final String dietGuidance;
  final int kcalTarget;
  final int proteinTarget;
  final int carbTarget;
  final int fatTarget;
  final String deficitSummary;
  final DateTime generatedAt;
  const DailyPlanRow(
      {required this.targetDate,
      required this.trainingPlanJson,
      required this.dietGuidance,
      required this.kcalTarget,
      required this.proteinTarget,
      required this.carbTarget,
      required this.fatTarget,
      required this.deficitSummary,
      required this.generatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_date'] = Variable<String>(targetDate);
    map['training_plan_json'] = Variable<String>(trainingPlanJson);
    map['diet_guidance'] = Variable<String>(dietGuidance);
    map['kcal_target'] = Variable<int>(kcalTarget);
    map['protein_target'] = Variable<int>(proteinTarget);
    map['carb_target'] = Variable<int>(carbTarget);
    map['fat_target'] = Variable<int>(fatTarget);
    map['deficit_summary'] = Variable<String>(deficitSummary);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  DailyPlansCompanion toCompanion(bool nullToAbsent) {
    return DailyPlansCompanion(
      targetDate: Value(targetDate),
      trainingPlanJson: Value(trainingPlanJson),
      dietGuidance: Value(dietGuidance),
      kcalTarget: Value(kcalTarget),
      proteinTarget: Value(proteinTarget),
      carbTarget: Value(carbTarget),
      fatTarget: Value(fatTarget),
      deficitSummary: Value(deficitSummary),
      generatedAt: Value(generatedAt),
    );
  }

  factory DailyPlanRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPlanRow(
      targetDate: serializer.fromJson<String>(json['targetDate']),
      trainingPlanJson: serializer.fromJson<String>(json['trainingPlanJson']),
      dietGuidance: serializer.fromJson<String>(json['dietGuidance']),
      kcalTarget: serializer.fromJson<int>(json['kcalTarget']),
      proteinTarget: serializer.fromJson<int>(json['proteinTarget']),
      carbTarget: serializer.fromJson<int>(json['carbTarget']),
      fatTarget: serializer.fromJson<int>(json['fatTarget']),
      deficitSummary: serializer.fromJson<String>(json['deficitSummary']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetDate': serializer.toJson<String>(targetDate),
      'trainingPlanJson': serializer.toJson<String>(trainingPlanJson),
      'dietGuidance': serializer.toJson<String>(dietGuidance),
      'kcalTarget': serializer.toJson<int>(kcalTarget),
      'proteinTarget': serializer.toJson<int>(proteinTarget),
      'carbTarget': serializer.toJson<int>(carbTarget),
      'fatTarget': serializer.toJson<int>(fatTarget),
      'deficitSummary': serializer.toJson<String>(deficitSummary),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  DailyPlanRow copyWith(
          {String? targetDate,
          String? trainingPlanJson,
          String? dietGuidance,
          int? kcalTarget,
          int? proteinTarget,
          int? carbTarget,
          int? fatTarget,
          String? deficitSummary,
          DateTime? generatedAt}) =>
      DailyPlanRow(
        targetDate: targetDate ?? this.targetDate,
        trainingPlanJson: trainingPlanJson ?? this.trainingPlanJson,
        dietGuidance: dietGuidance ?? this.dietGuidance,
        kcalTarget: kcalTarget ?? this.kcalTarget,
        proteinTarget: proteinTarget ?? this.proteinTarget,
        carbTarget: carbTarget ?? this.carbTarget,
        fatTarget: fatTarget ?? this.fatTarget,
        deficitSummary: deficitSummary ?? this.deficitSummary,
        generatedAt: generatedAt ?? this.generatedAt,
      );
  DailyPlanRow copyWithCompanion(DailyPlansCompanion data) {
    return DailyPlanRow(
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      trainingPlanJson: data.trainingPlanJson.present
          ? data.trainingPlanJson.value
          : this.trainingPlanJson,
      dietGuidance: data.dietGuidance.present
          ? data.dietGuidance.value
          : this.dietGuidance,
      kcalTarget:
          data.kcalTarget.present ? data.kcalTarget.value : this.kcalTarget,
      proteinTarget: data.proteinTarget.present
          ? data.proteinTarget.value
          : this.proteinTarget,
      carbTarget:
          data.carbTarget.present ? data.carbTarget.value : this.carbTarget,
      fatTarget: data.fatTarget.present ? data.fatTarget.value : this.fatTarget,
      deficitSummary: data.deficitSummary.present
          ? data.deficitSummary.value
          : this.deficitSummary,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlanRow(')
          ..write('targetDate: $targetDate, ')
          ..write('trainingPlanJson: $trainingPlanJson, ')
          ..write('dietGuidance: $dietGuidance, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinTarget: $proteinTarget, ')
          ..write('carbTarget: $carbTarget, ')
          ..write('fatTarget: $fatTarget, ')
          ..write('deficitSummary: $deficitSummary, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      targetDate,
      trainingPlanJson,
      dietGuidance,
      kcalTarget,
      proteinTarget,
      carbTarget,
      fatTarget,
      deficitSummary,
      generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPlanRow &&
          other.targetDate == this.targetDate &&
          other.trainingPlanJson == this.trainingPlanJson &&
          other.dietGuidance == this.dietGuidance &&
          other.kcalTarget == this.kcalTarget &&
          other.proteinTarget == this.proteinTarget &&
          other.carbTarget == this.carbTarget &&
          other.fatTarget == this.fatTarget &&
          other.deficitSummary == this.deficitSummary &&
          other.generatedAt == this.generatedAt);
}

class DailyPlansCompanion extends UpdateCompanion<DailyPlanRow> {
  final Value<String> targetDate;
  final Value<String> trainingPlanJson;
  final Value<String> dietGuidance;
  final Value<int> kcalTarget;
  final Value<int> proteinTarget;
  final Value<int> carbTarget;
  final Value<int> fatTarget;
  final Value<String> deficitSummary;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const DailyPlansCompanion({
    this.targetDate = const Value.absent(),
    this.trainingPlanJson = const Value.absent(),
    this.dietGuidance = const Value.absent(),
    this.kcalTarget = const Value.absent(),
    this.proteinTarget = const Value.absent(),
    this.carbTarget = const Value.absent(),
    this.fatTarget = const Value.absent(),
    this.deficitSummary = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPlansCompanion.insert({
    required String targetDate,
    this.trainingPlanJson = const Value.absent(),
    this.dietGuidance = const Value.absent(),
    this.kcalTarget = const Value.absent(),
    this.proteinTarget = const Value.absent(),
    this.carbTarget = const Value.absent(),
    this.fatTarget = const Value.absent(),
    this.deficitSummary = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : targetDate = Value(targetDate);
  static Insertable<DailyPlanRow> custom({
    Expression<String>? targetDate,
    Expression<String>? trainingPlanJson,
    Expression<String>? dietGuidance,
    Expression<int>? kcalTarget,
    Expression<int>? proteinTarget,
    Expression<int>? carbTarget,
    Expression<int>? fatTarget,
    Expression<String>? deficitSummary,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetDate != null) 'target_date': targetDate,
      if (trainingPlanJson != null) 'training_plan_json': trainingPlanJson,
      if (dietGuidance != null) 'diet_guidance': dietGuidance,
      if (kcalTarget != null) 'kcal_target': kcalTarget,
      if (proteinTarget != null) 'protein_target': proteinTarget,
      if (carbTarget != null) 'carb_target': carbTarget,
      if (fatTarget != null) 'fat_target': fatTarget,
      if (deficitSummary != null) 'deficit_summary': deficitSummary,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPlansCompanion copyWith(
      {Value<String>? targetDate,
      Value<String>? trainingPlanJson,
      Value<String>? dietGuidance,
      Value<int>? kcalTarget,
      Value<int>? proteinTarget,
      Value<int>? carbTarget,
      Value<int>? fatTarget,
      Value<String>? deficitSummary,
      Value<DateTime>? generatedAt,
      Value<int>? rowid}) {
    return DailyPlansCompanion(
      targetDate: targetDate ?? this.targetDate,
      trainingPlanJson: trainingPlanJson ?? this.trainingPlanJson,
      dietGuidance: dietGuidance ?? this.dietGuidance,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbTarget: carbTarget ?? this.carbTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      deficitSummary: deficitSummary ?? this.deficitSummary,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (trainingPlanJson.present) {
      map['training_plan_json'] = Variable<String>(trainingPlanJson.value);
    }
    if (dietGuidance.present) {
      map['diet_guidance'] = Variable<String>(dietGuidance.value);
    }
    if (kcalTarget.present) {
      map['kcal_target'] = Variable<int>(kcalTarget.value);
    }
    if (proteinTarget.present) {
      map['protein_target'] = Variable<int>(proteinTarget.value);
    }
    if (carbTarget.present) {
      map['carb_target'] = Variable<int>(carbTarget.value);
    }
    if (fatTarget.present) {
      map['fat_target'] = Variable<int>(fatTarget.value);
    }
    if (deficitSummary.present) {
      map['deficit_summary'] = Variable<String>(deficitSummary.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlansCompanion(')
          ..write('targetDate: $targetDate, ')
          ..write('trainingPlanJson: $trainingPlanJson, ')
          ..write('dietGuidance: $dietGuidance, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinTarget: $proteinTarget, ')
          ..write('carbTarget: $carbTarget, ')
          ..write('fatTarget: $fatTarget, ')
          ..write('deficitSummary: $deficitSummary, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogsTable extends ActivityLogs
    with TableInfo<$ActivityLogsTable, ActivityLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _minutesMeta =
      const VerificationMeta('minutes');
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
      'minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
      'kcal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, kind, minutes, kcal, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(_minutesMeta,
          minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
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
  ActivityLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      minutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes'])!,
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kcal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ActivityLogsTable createAlias(String alias) {
    return $ActivityLogsTable(attachedDatabase, alias);
  }
}

class ActivityLogRow extends DataClass implements Insertable<ActivityLogRow> {
  final int id;
  final String date;
  final String kind;
  final int minutes;
  final int kcal;
  final DateTime createdAt;
  const ActivityLogRow(
      {required this.id,
      required this.date,
      required this.kind,
      required this.minutes,
      required this.kcal,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['kind'] = Variable<String>(kind);
    map['minutes'] = Variable<int>(minutes);
    map['kcal'] = Variable<int>(kcal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      id: Value(id),
      date: Value(date),
      kind: Value(kind),
      minutes: Value(minutes),
      kcal: Value(kcal),
      createdAt: Value(createdAt),
    );
  }

  factory ActivityLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      minutes: serializer.fromJson<int>(json['minutes']),
      kcal: serializer.fromJson<int>(json['kcal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'kind': serializer.toJson<String>(kind),
      'minutes': serializer.toJson<int>(minutes),
      'kcal': serializer.toJson<int>(kcal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActivityLogRow copyWith(
          {int? id,
          String? date,
          String? kind,
          int? minutes,
          int? kcal,
          DateTime? createdAt}) =>
      ActivityLogRow(
        id: id ?? this.id,
        date: date ?? this.date,
        kind: kind ?? this.kind,
        minutes: minutes ?? this.minutes,
        kcal: kcal ?? this.kcal,
        createdAt: createdAt ?? this.createdAt,
      );
  ActivityLogRow copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('minutes: $minutes, ')
          ..write('kcal: $kcal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, kind, minutes, kcal, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.minutes == this.minutes &&
          other.kcal == this.kcal &&
          other.createdAt == this.createdAt);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityLogRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> kind;
  final Value<int> minutes;
  final Value<int> kcal;
  final Value<DateTime> createdAt;
  const ActivityLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.minutes = const Value.absent(),
    this.kcal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String kind,
    this.minutes = const Value.absent(),
    this.kcal = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : date = Value(date),
        kind = Value(kind);
  static Insertable<ActivityLogRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? kind,
    Expression<int>? minutes,
    Expression<int>? kcal,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (minutes != null) 'minutes': minutes,
      if (kcal != null) 'kcal': kcal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ActivityLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? kind,
      Value<int>? minutes,
      Value<int>? kcal,
      Value<DateTime>? createdAt}) {
    return ActivityLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      minutes: minutes ?? this.minutes,
      kcal: kcal ?? this.kcal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('minutes: $minutes, ')
          ..write('kcal: $kcal, ')
          ..write('createdAt: $createdAt')
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
  late final $DailyTasksTable dailyTasks = $DailyTasksTable(this);
  late final $WeeklyBriefsTable weeklyBriefs = $WeeklyBriefsTable(this);
  late final $FitnessProfilesTable fitnessProfiles =
      $FitnessProfilesTable(this);
  late final $MealLogsTable mealLogs = $MealLogsTable(this);
  late final $TrainingLogsTable trainingLogs = $TrainingLogsTable(this);
  late final $DailyPlansTable dailyPlans = $DailyPlansTable(this);
  late final $ActivityLogsTable activityLogs = $ActivityLogsTable(this);
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
        checklistItems,
        dailyTasks,
        weeklyBriefs,
        fitnessProfiles,
        mealLogs,
        trainingLogs,
        dailyPlans,
        activityLogs
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

typedef $$DailyTasksTableCreateCompanionBuilder = DailyTasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> notes,
  Value<bool> done,
  required DateTime forDate,
  Value<String> kind,
  Value<DateTime> createdAt,
});
typedef $$DailyTasksTableUpdateCompanionBuilder = DailyTasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> notes,
  Value<bool> done,
  Value<DateTime> forDate,
  Value<String> kind,
  Value<DateTime> createdAt,
});

class $$DailyTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyTasksTable,
    DailyTaskRow,
    $$DailyTasksTableFilterComposer,
    $$DailyTasksTableOrderingComposer,
    $$DailyTasksTableCreateCompanionBuilder,
    $$DailyTasksTableUpdateCompanionBuilder> {
  $$DailyTasksTableTableManager(_$AppDatabase db, $DailyTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DailyTasksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DailyTasksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> done = const Value.absent(),
            Value<DateTime> forDate = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DailyTasksCompanion(
            id: id,
            title: title,
            notes: notes,
            done: done,
            forDate: forDate,
            kind: kind,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> notes = const Value.absent(),
            Value<bool> done = const Value.absent(),
            required DateTime forDate,
            Value<String> kind = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DailyTasksCompanion.insert(
            id: id,
            title: title,
            notes: notes,
            done: done,
            forDate: forDate,
            kind: kind,
            createdAt: createdAt,
          ),
        ));
}

class $$DailyTasksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get done => $state.composableBuilder(
      column: $state.table.done,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get forDate => $state.composableBuilder(
      column: $state.table.forDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DailyTasksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get done => $state.composableBuilder(
      column: $state.table.done,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get forDate => $state.composableBuilder(
      column: $state.table.forDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WeeklyBriefsTableCreateCompanionBuilder = WeeklyBriefsCompanion
    Function({
  Value<int> id,
  required int week,
  required String rawText,
  Value<String?> structuredJson,
  Value<DateTime> generatedAt,
});
typedef $$WeeklyBriefsTableUpdateCompanionBuilder = WeeklyBriefsCompanion
    Function({
  Value<int> id,
  Value<int> week,
  Value<String> rawText,
  Value<String?> structuredJson,
  Value<DateTime> generatedAt,
});

class $$WeeklyBriefsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeeklyBriefsTable,
    WeeklyBriefRow,
    $$WeeklyBriefsTableFilterComposer,
    $$WeeklyBriefsTableOrderingComposer,
    $$WeeklyBriefsTableCreateCompanionBuilder,
    $$WeeklyBriefsTableUpdateCompanionBuilder> {
  $$WeeklyBriefsTableTableManager(_$AppDatabase db, $WeeklyBriefsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WeeklyBriefsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WeeklyBriefsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> week = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String?> structuredJson = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              WeeklyBriefsCompanion(
            id: id,
            week: week,
            rawText: rawText,
            structuredJson: structuredJson,
            generatedAt: generatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int week,
            required String rawText,
            Value<String?> structuredJson = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              WeeklyBriefsCompanion.insert(
            id: id,
            week: week,
            rawText: rawText,
            structuredJson: structuredJson,
            generatedAt: generatedAt,
          ),
        ));
}

class $$WeeklyBriefsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WeeklyBriefsTable> {
  $$WeeklyBriefsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get week => $state.composableBuilder(
      column: $state.table.week,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawText => $state.composableBuilder(
      column: $state.table.rawText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get structuredJson => $state.composableBuilder(
      column: $state.table.structuredJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get generatedAt => $state.composableBuilder(
      column: $state.table.generatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WeeklyBriefsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WeeklyBriefsTable> {
  $$WeeklyBriefsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get week => $state.composableBuilder(
      column: $state.table.week,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawText => $state.composableBuilder(
      column: $state.table.rawText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get structuredJson => $state.composableBuilder(
      column: $state.table.structuredJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get generatedAt => $state.composableBuilder(
      column: $state.table.generatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FitnessProfilesTableCreateCompanionBuilder = FitnessProfilesCompanion
    Function({
  Value<int> id,
  Value<int?> heightCm,
  Value<double?> weightKg,
  Value<int?> age,
  Value<String> sex,
  Value<String> kettlebellsKg,
  Value<String> experience,
  Value<int> dailyMinutes,
  Value<String> goal,
  Value<String?> injuries,
  Value<DateTime> updatedAt,
});
typedef $$FitnessProfilesTableUpdateCompanionBuilder = FitnessProfilesCompanion
    Function({
  Value<int> id,
  Value<int?> heightCm,
  Value<double?> weightKg,
  Value<int?> age,
  Value<String> sex,
  Value<String> kettlebellsKg,
  Value<String> experience,
  Value<int> dailyMinutes,
  Value<String> goal,
  Value<String?> injuries,
  Value<DateTime> updatedAt,
});

class $$FitnessProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FitnessProfilesTable,
    FitnessProfileRow,
    $$FitnessProfilesTableFilterComposer,
    $$FitnessProfilesTableOrderingComposer,
    $$FitnessProfilesTableCreateCompanionBuilder,
    $$FitnessProfilesTableUpdateCompanionBuilder> {
  $$FitnessProfilesTableTableManager(
      _$AppDatabase db, $FitnessProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FitnessProfilesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FitnessProfilesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<String> kettlebellsKg = const Value.absent(),
            Value<String> experience = const Value.absent(),
            Value<int> dailyMinutes = const Value.absent(),
            Value<String> goal = const Value.absent(),
            Value<String?> injuries = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FitnessProfilesCompanion(
            id: id,
            heightCm: heightCm,
            weightKg: weightKg,
            age: age,
            sex: sex,
            kettlebellsKg: kettlebellsKg,
            experience: experience,
            dailyMinutes: dailyMinutes,
            goal: goal,
            injuries: injuries,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<String> kettlebellsKg = const Value.absent(),
            Value<String> experience = const Value.absent(),
            Value<int> dailyMinutes = const Value.absent(),
            Value<String> goal = const Value.absent(),
            Value<String?> injuries = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FitnessProfilesCompanion.insert(
            id: id,
            heightCm: heightCm,
            weightKg: weightKg,
            age: age,
            sex: sex,
            kettlebellsKg: kettlebellsKg,
            experience: experience,
            dailyMinutes: dailyMinutes,
            goal: goal,
            injuries: injuries,
            updatedAt: updatedAt,
          ),
        ));
}

class $$FitnessProfilesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FitnessProfilesTable> {
  $$FitnessProfilesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get heightCm => $state.composableBuilder(
      column: $state.table.heightCm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get weightKg => $state.composableBuilder(
      column: $state.table.weightKg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get age => $state.composableBuilder(
      column: $state.table.age,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sex => $state.composableBuilder(
      column: $state.table.sex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kettlebellsKg => $state.composableBuilder(
      column: $state.table.kettlebellsKg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get experience => $state.composableBuilder(
      column: $state.table.experience,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dailyMinutes => $state.composableBuilder(
      column: $state.table.dailyMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get goal => $state.composableBuilder(
      column: $state.table.goal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get injuries => $state.composableBuilder(
      column: $state.table.injuries,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FitnessProfilesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FitnessProfilesTable> {
  $$FitnessProfilesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get heightCm => $state.composableBuilder(
      column: $state.table.heightCm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get weightKg => $state.composableBuilder(
      column: $state.table.weightKg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get age => $state.composableBuilder(
      column: $state.table.age,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sex => $state.composableBuilder(
      column: $state.table.sex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kettlebellsKg => $state.composableBuilder(
      column: $state.table.kettlebellsKg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get experience => $state.composableBuilder(
      column: $state.table.experience,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dailyMinutes => $state.composableBuilder(
      column: $state.table.dailyMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get goal => $state.composableBuilder(
      column: $state.table.goal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get injuries => $state.composableBuilder(
      column: $state.table.injuries,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MealLogsTableCreateCompanionBuilder = MealLogsCompanion Function({
  Value<int> id,
  required String date,
  required String meal,
  Value<String?> photoPath,
  Value<String> foodsJson,
  Value<int> kcal,
  Value<int> proteinG,
  Value<int> carbG,
  Value<int> fatG,
  Value<bool> edited,
  Value<DateTime> createdAt,
});
typedef $$MealLogsTableUpdateCompanionBuilder = MealLogsCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<String> meal,
  Value<String?> photoPath,
  Value<String> foodsJson,
  Value<int> kcal,
  Value<int> proteinG,
  Value<int> carbG,
  Value<int> fatG,
  Value<bool> edited,
  Value<DateTime> createdAt,
});

class $$MealLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealLogsTable,
    MealLogRow,
    $$MealLogsTableFilterComposer,
    $$MealLogsTableOrderingComposer,
    $$MealLogsTableCreateCompanionBuilder,
    $$MealLogsTableUpdateCompanionBuilder> {
  $$MealLogsTableTableManager(_$AppDatabase db, $MealLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MealLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MealLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> meal = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String> foodsJson = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<int> proteinG = const Value.absent(),
            Value<int> carbG = const Value.absent(),
            Value<int> fatG = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MealLogsCompanion(
            id: id,
            date: date,
            meal: meal,
            photoPath: photoPath,
            foodsJson: foodsJson,
            kcal: kcal,
            proteinG: proteinG,
            carbG: carbG,
            fatG: fatG,
            edited: edited,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String meal,
            Value<String?> photoPath = const Value.absent(),
            Value<String> foodsJson = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<int> proteinG = const Value.absent(),
            Value<int> carbG = const Value.absent(),
            Value<int> fatG = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MealLogsCompanion.insert(
            id: id,
            date: date,
            meal: meal,
            photoPath: photoPath,
            foodsJson: foodsJson,
            kcal: kcal,
            proteinG: proteinG,
            carbG: carbG,
            fatG: fatG,
            edited: edited,
            createdAt: createdAt,
          ),
        ));
}

class $$MealLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MealLogsTable> {
  $$MealLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get meal => $state.composableBuilder(
      column: $state.table.meal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get foodsJson => $state.composableBuilder(
      column: $state.table.foodsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get proteinG => $state.composableBuilder(
      column: $state.table.proteinG,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get carbG => $state.composableBuilder(
      column: $state.table.carbG,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get fatG => $state.composableBuilder(
      column: $state.table.fatG,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get edited => $state.composableBuilder(
      column: $state.table.edited,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MealLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MealLogsTable> {
  $$MealLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get meal => $state.composableBuilder(
      column: $state.table.meal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get foodsJson => $state.composableBuilder(
      column: $state.table.foodsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get proteinG => $state.composableBuilder(
      column: $state.table.proteinG,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get carbG => $state.composableBuilder(
      column: $state.table.carbG,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get fatG => $state.composableBuilder(
      column: $state.table.fatG,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get edited => $state.composableBuilder(
      column: $state.table.edited,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TrainingLogsTableCreateCompanionBuilder = TrainingLogsCompanion
    Function({
  Value<int> id,
  required String date,
  Value<String> planJson,
  Value<bool> done,
  Value<String?> feeling,
});
typedef $$TrainingLogsTableUpdateCompanionBuilder = TrainingLogsCompanion
    Function({
  Value<int> id,
  Value<String> date,
  Value<String> planJson,
  Value<bool> done,
  Value<String?> feeling,
});

class $$TrainingLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainingLogsTable,
    TrainingLogRow,
    $$TrainingLogsTableFilterComposer,
    $$TrainingLogsTableOrderingComposer,
    $$TrainingLogsTableCreateCompanionBuilder,
    $$TrainingLogsTableUpdateCompanionBuilder> {
  $$TrainingLogsTableTableManager(_$AppDatabase db, $TrainingLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TrainingLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TrainingLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> planJson = const Value.absent(),
            Value<bool> done = const Value.absent(),
            Value<String?> feeling = const Value.absent(),
          }) =>
              TrainingLogsCompanion(
            id: id,
            date: date,
            planJson: planJson,
            done: done,
            feeling: feeling,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            Value<String> planJson = const Value.absent(),
            Value<bool> done = const Value.absent(),
            Value<String?> feeling = const Value.absent(),
          }) =>
              TrainingLogsCompanion.insert(
            id: id,
            date: date,
            planJson: planJson,
            done: done,
            feeling: feeling,
          ),
        ));
}

class $$TrainingLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TrainingLogsTable> {
  $$TrainingLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get planJson => $state.composableBuilder(
      column: $state.table.planJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get done => $state.composableBuilder(
      column: $state.table.done,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get feeling => $state.composableBuilder(
      column: $state.table.feeling,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TrainingLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TrainingLogsTable> {
  $$TrainingLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get planJson => $state.composableBuilder(
      column: $state.table.planJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get done => $state.composableBuilder(
      column: $state.table.done,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get feeling => $state.composableBuilder(
      column: $state.table.feeling,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DailyPlansTableCreateCompanionBuilder = DailyPlansCompanion Function({
  required String targetDate,
  Value<String> trainingPlanJson,
  Value<String> dietGuidance,
  Value<int> kcalTarget,
  Value<int> proteinTarget,
  Value<int> carbTarget,
  Value<int> fatTarget,
  Value<String> deficitSummary,
  Value<DateTime> generatedAt,
  Value<int> rowid,
});
typedef $$DailyPlansTableUpdateCompanionBuilder = DailyPlansCompanion Function({
  Value<String> targetDate,
  Value<String> trainingPlanJson,
  Value<String> dietGuidance,
  Value<int> kcalTarget,
  Value<int> proteinTarget,
  Value<int> carbTarget,
  Value<int> fatTarget,
  Value<String> deficitSummary,
  Value<DateTime> generatedAt,
  Value<int> rowid,
});

class $$DailyPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyPlansTable,
    DailyPlanRow,
    $$DailyPlansTableFilterComposer,
    $$DailyPlansTableOrderingComposer,
    $$DailyPlansTableCreateCompanionBuilder,
    $$DailyPlansTableUpdateCompanionBuilder> {
  $$DailyPlansTableTableManager(_$AppDatabase db, $DailyPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DailyPlansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DailyPlansTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> targetDate = const Value.absent(),
            Value<String> trainingPlanJson = const Value.absent(),
            Value<String> dietGuidance = const Value.absent(),
            Value<int> kcalTarget = const Value.absent(),
            Value<int> proteinTarget = const Value.absent(),
            Value<int> carbTarget = const Value.absent(),
            Value<int> fatTarget = const Value.absent(),
            Value<String> deficitSummary = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlansCompanion(
            targetDate: targetDate,
            trainingPlanJson: trainingPlanJson,
            dietGuidance: dietGuidance,
            kcalTarget: kcalTarget,
            proteinTarget: proteinTarget,
            carbTarget: carbTarget,
            fatTarget: fatTarget,
            deficitSummary: deficitSummary,
            generatedAt: generatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String targetDate,
            Value<String> trainingPlanJson = const Value.absent(),
            Value<String> dietGuidance = const Value.absent(),
            Value<int> kcalTarget = const Value.absent(),
            Value<int> proteinTarget = const Value.absent(),
            Value<int> carbTarget = const Value.absent(),
            Value<int> fatTarget = const Value.absent(),
            Value<String> deficitSummary = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlansCompanion.insert(
            targetDate: targetDate,
            trainingPlanJson: trainingPlanJson,
            dietGuidance: dietGuidance,
            kcalTarget: kcalTarget,
            proteinTarget: proteinTarget,
            carbTarget: carbTarget,
            fatTarget: fatTarget,
            deficitSummary: deficitSummary,
            generatedAt: generatedAt,
            rowid: rowid,
          ),
        ));
}

class $$DailyPlansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableFilterComposer(super.$state);
  ColumnFilters<String> get targetDate => $state.composableBuilder(
      column: $state.table.targetDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get trainingPlanJson => $state.composableBuilder(
      column: $state.table.trainingPlanJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dietGuidance => $state.composableBuilder(
      column: $state.table.dietGuidance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kcalTarget => $state.composableBuilder(
      column: $state.table.kcalTarget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get proteinTarget => $state.composableBuilder(
      column: $state.table.proteinTarget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get carbTarget => $state.composableBuilder(
      column: $state.table.carbTarget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get fatTarget => $state.composableBuilder(
      column: $state.table.fatTarget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deficitSummary => $state.composableBuilder(
      column: $state.table.deficitSummary,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get generatedAt => $state.composableBuilder(
      column: $state.table.generatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DailyPlansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableOrderingComposer(super.$state);
  ColumnOrderings<String> get targetDate => $state.composableBuilder(
      column: $state.table.targetDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get trainingPlanJson => $state.composableBuilder(
      column: $state.table.trainingPlanJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dietGuidance => $state.composableBuilder(
      column: $state.table.dietGuidance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kcalTarget => $state.composableBuilder(
      column: $state.table.kcalTarget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get proteinTarget => $state.composableBuilder(
      column: $state.table.proteinTarget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get carbTarget => $state.composableBuilder(
      column: $state.table.carbTarget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get fatTarget => $state.composableBuilder(
      column: $state.table.fatTarget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deficitSummary => $state.composableBuilder(
      column: $state.table.deficitSummary,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get generatedAt => $state.composableBuilder(
      column: $state.table.generatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ActivityLogsTableCreateCompanionBuilder = ActivityLogsCompanion
    Function({
  Value<int> id,
  required String date,
  required String kind,
  Value<int> minutes,
  Value<int> kcal,
  Value<DateTime> createdAt,
});
typedef $$ActivityLogsTableUpdateCompanionBuilder = ActivityLogsCompanion
    Function({
  Value<int> id,
  Value<String> date,
  Value<String> kind,
  Value<int> minutes,
  Value<int> kcal,
  Value<DateTime> createdAt,
});

class $$ActivityLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityLogsTable,
    ActivityLogRow,
    $$ActivityLogsTableFilterComposer,
    $$ActivityLogsTableOrderingComposer,
    $$ActivityLogsTableCreateCompanionBuilder,
    $$ActivityLogsTableUpdateCompanionBuilder> {
  $$ActivityLogsTableTableManager(_$AppDatabase db, $ActivityLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ActivityLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ActivityLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> minutes = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ActivityLogsCompanion(
            id: id,
            date: date,
            kind: kind,
            minutes: minutes,
            kcal: kcal,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String kind,
            Value<int> minutes = const Value.absent(),
            Value<int> kcal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ActivityLogsCompanion.insert(
            id: id,
            date: date,
            kind: kind,
            minutes: minutes,
            kcal: kcal,
            createdAt: createdAt,
          ),
        ));
}

class $$ActivityLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get minutes => $state.composableBuilder(
      column: $state.table.minutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ActivityLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get minutes => $state.composableBuilder(
      column: $state.table.minutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
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
  $$DailyTasksTableTableManager get dailyTasks =>
      $$DailyTasksTableTableManager(_db, _db.dailyTasks);
  $$WeeklyBriefsTableTableManager get weeklyBriefs =>
      $$WeeklyBriefsTableTableManager(_db, _db.weeklyBriefs);
  $$FitnessProfilesTableTableManager get fitnessProfiles =>
      $$FitnessProfilesTableTableManager(_db, _db.fitnessProfiles);
  $$MealLogsTableTableManager get mealLogs =>
      $$MealLogsTableTableManager(_db, _db.mealLogs);
  $$TrainingLogsTableTableManager get trainingLogs =>
      $$TrainingLogsTableTableManager(_db, _db.trainingLogs);
  $$DailyPlansTableTableManager get dailyPlans =>
      $$DailyPlansTableTableManager(_db, _db.dailyPlans);
  $$ActivityLogsTableTableManager get activityLogs =>
      $$ActivityLogsTableTableManager(_db, _db.activityLogs);
}
