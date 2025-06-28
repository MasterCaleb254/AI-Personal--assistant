// message.dart
import 'package:drift/drift.dart';
import 'package:ai_personal_assistant/src/data/drift/database.dart';
import 'package:equatable/equatable.dart';

part 'message.g.dart'; // For drift generated code

@DriftEntity(tableName: 'messages')
class Message extends Table with EquatableMixin {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer()();
  TextColumn get content => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BlobColumn get embedding => blob().nullable()();

  @override
  List<Object?> get props => [id, sessionId, content, isUser];
}