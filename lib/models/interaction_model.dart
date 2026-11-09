class InteractionModel {
  String? id;
  String? userId;
  String? characterId;
  int? intimacyLevel;
  int? intimacyExp;
  int? messagesExchanged;
  int? giftsSent;
  List<dynamic>? unlockedOutfits;
  List<dynamic>? unlockedActions;
  String? lastInteractedAt;

  InteractionModel({
    this.id,
    this.userId,
    this.characterId,
    this.intimacyLevel,
    this.intimacyExp,
    this.messagesExchanged,
    this.giftsSent,
    this.unlockedOutfits,
    this.unlockedActions,
    this.lastInteractedAt,
  });

  InteractionModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['user_id'];
    characterId = json['character_id'];
    intimacyLevel = json['intimacy_level'];
    intimacyExp = json['intimacy_exp'];
    messagesExchanged = json['messages_exchanged'];
    giftsSent = json['gifts_sent'];
    unlockedOutfits = json['unlocked_outfits'];
    unlockedActions = json['unlocked_actions'];
    lastInteractedAt = json['last_interacted_at'];
  }
}
