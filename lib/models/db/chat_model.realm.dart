// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ChatSession extends _ChatSession
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatSession(
    String id,
    String characterId,
    String characterName,
    String characterAvatarUrl,
    String lastMessage,
    DateTime lastActiveTime,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'characterId', characterId);
    RealmObjectBase.set(this, 'characterName', characterName);
    RealmObjectBase.set(this, 'characterAvatarUrl', characterAvatarUrl);
    RealmObjectBase.set(this, 'lastMessage', lastMessage);
    RealmObjectBase.set(this, 'lastActiveTime', lastActiveTime);
  }

  ChatSession._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get characterId =>
      RealmObjectBase.get<String>(this, 'characterId') as String;
  @override
  set characterId(String value) =>
      RealmObjectBase.set(this, 'characterId', value);

  @override
  String get characterName =>
      RealmObjectBase.get<String>(this, 'characterName') as String;
  @override
  set characterName(String value) =>
      RealmObjectBase.set(this, 'characterName', value);

  @override
  String get characterAvatarUrl =>
      RealmObjectBase.get<String>(this, 'characterAvatarUrl') as String;
  @override
  set characterAvatarUrl(String value) =>
      RealmObjectBase.set(this, 'characterAvatarUrl', value);

  @override
  String get lastMessage =>
      RealmObjectBase.get<String>(this, 'lastMessage') as String;
  @override
  set lastMessage(String value) =>
      RealmObjectBase.set(this, 'lastMessage', value);

  @override
  DateTime get lastActiveTime =>
      RealmObjectBase.get<DateTime>(this, 'lastActiveTime') as DateTime;
  @override
  set lastActiveTime(DateTime value) =>
      RealmObjectBase.set(this, 'lastActiveTime', value);

  @override
  Stream<RealmObjectChanges<ChatSession>> get changes =>
      RealmObjectBase.getChanges<ChatSession>(this);

  @override
  Stream<RealmObjectChanges<ChatSession>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ChatSession>(this, keyPaths);

  @override
  ChatSession freeze() => RealmObjectBase.freezeObject<ChatSession>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'characterId': characterId.toEJson(),
      'characterName': characterName.toEJson(),
      'characterAvatarUrl': characterAvatarUrl.toEJson(),
      'lastMessage': lastMessage.toEJson(),
      'lastActiveTime': lastActiveTime.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatSession value) => value.toEJson();
  static ChatSession _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'characterId': EJsonValue characterId,
        'characterName': EJsonValue characterName,
        'characterAvatarUrl': EJsonValue characterAvatarUrl,
        'lastMessage': EJsonValue lastMessage,
        'lastActiveTime': EJsonValue lastActiveTime,
      } =>
        ChatSession(
          fromEJson(id),
          fromEJson(characterId),
          fromEJson(characterName),
          fromEJson(characterAvatarUrl),
          fromEJson(lastMessage),
          fromEJson(lastActiveTime),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatSession._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ChatSession, 'ChatSession', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('characterId', RealmPropertyType.string),
      SchemaProperty('characterName', RealmPropertyType.string),
      SchemaProperty('characterAvatarUrl', RealmPropertyType.string),
      SchemaProperty('lastMessage', RealmPropertyType.string),
      SchemaProperty('lastActiveTime', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ChatMessage extends _ChatMessage
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatMessage(
    String id,
    String sessionId,
    String role,
    String content,
    DateTime createdAt,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'sessionId', sessionId);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  ChatMessage._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get sessionId =>
      RealmObjectBase.get<String>(this, 'sessionId') as String;
  @override
  set sessionId(String value) => RealmObjectBase.set(this, 'sessionId', value);

  @override
  String get role => RealmObjectBase.get<String>(this, 'role') as String;
  @override
  set role(String value) => RealmObjectBase.set(this, 'role', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<ChatMessage>> get changes =>
      RealmObjectBase.getChanges<ChatMessage>(this);

  @override
  Stream<RealmObjectChanges<ChatMessage>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ChatMessage>(this, keyPaths);

  @override
  ChatMessage freeze() => RealmObjectBase.freezeObject<ChatMessage>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'sessionId': sessionId.toEJson(),
      'role': role.toEJson(),
      'content': content.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatMessage value) => value.toEJson();
  static ChatMessage _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'sessionId': EJsonValue sessionId,
        'role': EJsonValue role,
        'content': EJsonValue content,
        'createdAt': EJsonValue createdAt,
      } =>
        ChatMessage(
          fromEJson(id),
          fromEJson(sessionId),
          fromEJson(role),
          fromEJson(content),
          fromEJson(createdAt),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatMessage._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ChatMessage, 'ChatMessage', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('sessionId', RealmPropertyType.string,
          indexType: RealmIndexType.regular),
      SchemaProperty('role', RealmPropertyType.string),
      SchemaProperty('content', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
