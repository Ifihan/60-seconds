import 'package:drift/drift.dart';

class CachedSessions extends Table {
  TextColumn get id => text()();
  TextColumn get areaId => text()();
  TextColumn get areaName => text()();
  TextColumn get topic => text()();
  TextColumn get mode => text()();
  DateTimeColumn get completedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
