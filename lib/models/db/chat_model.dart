import 'package:realm/realm.dart';

part 'chat_model.realm.dart';

@RealmModel()
class _ChatSession {
  @PrimaryKey()
  late String id; // Use characterId as session ID so there's 1 session per character
  
  late String characterId;
  late String characterName;
  late String characterAvatarUrl;
  
  late String lastMessage;
  late DateTime lastActiveTime;
}

@RealmModel()
class _ChatMessage {
  @PrimaryKey()
  late String id;
  
  @Indexed()
  late String sessionId; // Links back to _ChatSession.id
  
  late String role; // "user" or "assistant"
  late String content;
  
  late DateTime createdAt;
}
