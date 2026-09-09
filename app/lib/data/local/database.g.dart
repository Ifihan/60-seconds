// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CachedSessionsTable extends CachedSessions
    with TableInfo<$CachedSessionsTable, CachedSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
      'area_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaNameMeta =
      const VerificationMeta('areaName');
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
      'area_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, areaId, areaName, topic, mode, completedAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<CachedSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(_areaIdMeta,
          areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta));
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('area_name')) {
      context.handle(_areaNameMeta,
          areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta));
    } else if (isInserting) {
      context.missing(_areaNameMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      areaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_id'])!,
      areaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_name'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $CachedSessionsTable createAlias(String alias) {
    return $CachedSessionsTable(attachedDatabase, alias);
  }
}

class CachedSession extends DataClass implements Insertable<CachedSession> {
  final String id;
  final String areaId;
  final String areaName;
  final String topic;
  final String mode;
  final DateTime completedAt;
  final bool synced;
  const CachedSession(
      {required this.id,
      required this.areaId,
      required this.areaName,
      required this.topic,
      required this.mode,
      required this.completedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['area_id'] = Variable<String>(areaId);
    map['area_name'] = Variable<String>(areaName);
    map['topic'] = Variable<String>(topic);
    map['mode'] = Variable<String>(mode);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  CachedSessionsCompanion toCompanion(bool nullToAbsent) {
    return CachedSessionsCompanion(
      id: Value(id),
      areaId: Value(areaId),
      areaName: Value(areaName),
      topic: Value(topic),
      mode: Value(mode),
      completedAt: Value(completedAt),
      synced: Value(synced),
    );
  }

  factory CachedSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSession(
      id: serializer.fromJson<String>(json['id']),
      areaId: serializer.fromJson<String>(json['areaId']),
      areaName: serializer.fromJson<String>(json['areaName']),
      topic: serializer.fromJson<String>(json['topic']),
      mode: serializer.fromJson<String>(json['mode']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'areaId': serializer.toJson<String>(areaId),
      'areaName': serializer.toJson<String>(areaName),
      'topic': serializer.toJson<String>(topic),
      'mode': serializer.toJson<String>(mode),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  CachedSession copyWith(
          {String? id,
          String? areaId,
          String? areaName,
          String? topic,
          String? mode,
          DateTime? completedAt,
          bool? synced}) =>
      CachedSession(
        id: id ?? this.id,
        areaId: areaId ?? this.areaId,
        areaName: areaName ?? this.areaName,
        topic: topic ?? this.topic,
        mode: mode ?? this.mode,
        completedAt: completedAt ?? this.completedAt,
        synced: synced ?? this.synced,
      );
  CachedSession copyWithCompanion(CachedSessionsCompanion data) {
    return CachedSession(
      id: data.id.present ? data.id.value : this.id,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      topic: data.topic.present ? data.topic.value : this.topic,
      mode: data.mode.present ? data.mode.value : this.mode,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSession(')
          ..write('id: $id, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('topic: $topic, ')
          ..write('mode: $mode, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, areaId, areaName, topic, mode, completedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSession &&
          other.id == this.id &&
          other.areaId == this.areaId &&
          other.areaName == this.areaName &&
          other.topic == this.topic &&
          other.mode == this.mode &&
          other.completedAt == this.completedAt &&
          other.synced == this.synced);
}

class CachedSessionsCompanion extends UpdateCompanion<CachedSession> {
  final Value<String> id;
  final Value<String> areaId;
  final Value<String> areaName;
  final Value<String> topic;
  final Value<String> mode;
  final Value<DateTime> completedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const CachedSessionsCompanion({
    this.id = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.topic = const Value.absent(),
    this.mode = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSessionsCompanion.insert({
    required String id,
    required String areaId,
    required String areaName,
    required String topic,
    required String mode,
    required DateTime completedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        areaId = Value(areaId),
        areaName = Value(areaName),
        topic = Value(topic),
        mode = Value(mode),
        completedAt = Value(completedAt);
  static Insertable<CachedSession> custom({
    Expression<String>? id,
    Expression<String>? areaId,
    Expression<String>? areaName,
    Expression<String>? topic,
    Expression<String>? mode,
    Expression<DateTime>? completedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (areaId != null) 'area_id': areaId,
      if (areaName != null) 'area_name': areaName,
      if (topic != null) 'topic': topic,
      if (mode != null) 'mode': mode,
      if (completedAt != null) 'completed_at': completedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? areaId,
      Value<String>? areaName,
      Value<String>? topic,
      Value<String>? mode,
      Value<DateTime>? completedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return CachedSessionsCompanion(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      topic: topic ?? this.topic,
      mode: mode ?? this.mode,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSessionsCompanion(')
          ..write('id: $id, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('topic: $topic, ')
          ..write('mode: $mode, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedSessionsTable cachedSessions = $CachedSessionsTable(this);
  late final CachedSessionsDao cachedSessionsDao =
      CachedSessionsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedSessions];
}

typedef $$CachedSessionsTableCreateCompanionBuilder = CachedSessionsCompanion
    Function({
  required String id,
  required String areaId,
  required String areaName,
  required String topic,
  required String mode,
  required DateTime completedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$CachedSessionsTableUpdateCompanionBuilder = CachedSessionsCompanion
    Function({
  Value<String> id,
  Value<String> areaId,
  Value<String> areaName,
  Value<String> topic,
  Value<String> mode,
  Value<DateTime> completedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$CachedSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$CachedSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaName => $composableBuilder(
      column: $table.areaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$CachedSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$CachedSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedSessionsTable,
    CachedSession,
    $$CachedSessionsTableFilterComposer,
    $$CachedSessionsTableOrderingComposer,
    $$CachedSessionsTableAnnotationComposer,
    $$CachedSessionsTableCreateCompanionBuilder,
    $$CachedSessionsTableUpdateCompanionBuilder,
    (
      CachedSession,
      BaseReferences<_$AppDatabase, $CachedSessionsTable, CachedSession>
    ),
    CachedSession,
    PrefetchHooks Function()> {
  $$CachedSessionsTableTableManager(
      _$AppDatabase db, $CachedSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> areaId = const Value.absent(),
            Value<String> areaName = const Value.absent(),
            Value<String> topic = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedSessionsCompanion(
            id: id,
            areaId: areaId,
            areaName: areaName,
            topic: topic,
            mode: mode,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String areaId,
            required String areaName,
            required String topic,
            required String mode,
            required DateTime completedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedSessionsCompanion.insert(
            id: id,
            areaId: areaId,
            areaName: areaName,
            topic: topic,
            mode: mode,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedSessionsTable,
    CachedSession,
    $$CachedSessionsTableFilterComposer,
    $$CachedSessionsTableOrderingComposer,
    $$CachedSessionsTableAnnotationComposer,
    $$CachedSessionsTableCreateCompanionBuilder,
    $$CachedSessionsTableUpdateCompanionBuilder,
    (
      CachedSession,
      BaseReferences<_$AppDatabase, $CachedSessionsTable, CachedSession>
    ),
    CachedSession,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedSessionsTableTableManager get cachedSessions =>
      $$CachedSessionsTableTableManager(_db, _db.cachedSessions);
}
