// chat_dao.dart
import 'package:drift/drift.dart';
import 'package:ai_personal_assistant/src/data/drift/database.dart';

part 'chat_dao.g.dart'; // Drift DAO generator

@DriftAccessor(tables: [Messages, Sessions])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Future<int> createSession(String title, String agentId) {
    return into(sessions).insert(
      SessionsCompanion.insert(
        title: Value(title),
        agentId: Value(agentId),
    );
  }

  Future<void> archiveSession(int sessionId) {
    return (delete(sessions)..where((s) => s.id.equals(sessionId))).go();
  }

  Stream<List<Session>> watchActiveSessions() {
    return (select(sessions)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .watch();
  }

  Future<int> insertMessage(Message message) {
    return into(messages).insert(message);
  }

  Stream<List<Message>> watchMessages(int sessionId) {
    return (select(messages)
      ..where((m) => m.sessionId.equals(sessionId))
      ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
      .watch();
  }
}