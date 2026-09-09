import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/cached_sessions_table.dart';

part 'cached_sessions_dao.g.dart';

@DriftAccessor(tables: [CachedSessions])
class CachedSessionsDao extends DatabaseAccessor<AppDatabase>
    with _$CachedSessionsDaoMixin {
  CachedSessionsDao(super.db);

  Future<void> insertSession(CachedSessionsCompanion session) =>
      into(cachedSessions).insert(session);

  Future<List<CachedSession>> getPendingSessions() =>
      (select(cachedSessions)..where((s) => s.synced.equals(false))).get();

  Future<void> markSynced(String id) =>
      (update(cachedSessions)..where((s) => s.id.equals(id)))
          .write(const CachedSessionsCompanion(synced: Value(true)));

  Future<void> deleteSession(String id) =>
      (delete(cachedSessions)..where((s) => s.id.equals(id))).go();
}
