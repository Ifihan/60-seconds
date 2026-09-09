import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/cached_sessions_table.dart';
import 'daos/cached_sessions_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [CachedSessions], daos: [CachedSessionsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, '60s.db'));
    return NativeDatabase.createInBackground(file);
  });
}
