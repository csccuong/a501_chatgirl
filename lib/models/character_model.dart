import 'package:get/get.dart';

class AiConfig {
  String? systemPrompt;
  String? baseImagePrompt;

  AiConfig({this.systemPrompt, this.baseImagePrompt});

  AiConfig.fromJson(Map<String, dynamic> json) {
    systemPrompt = json['system_prompt'];
    baseImagePrompt = json['base_image_prompt'];
  }
}

class CharacterModel {
  String? id;
  Map<String, dynamic>? nameMulti;
  String? gender;
  int? likes;
  Map<String, dynamic>? introduceMulti;
  String? creatorUsername;
  String? avatarUrl;
  int? costPerMessage;
  List<String>? tags;
  Map<String, dynamic>? descriptionMulti;
  List<String>? categoryIds;
  AiConfig? aiConfig;
  List<dynamic>? cards;
  bool? isActive;
  String? createdAt;

  String? get name {
    String lang = Get.locale?.languageCode ?? 'en';
    return nameMulti?[lang] ?? nameMulti?['en'] ?? "";
  }
  
  String? get introduce {
    String lang = Get.locale?.languageCode ?? 'en';
    return introduceMulti?[lang] ?? introduceMulti?['en'] ?? "";
  }
  
  String? get description {
    String lang = Get.locale?.languageCode ?? 'en';
    return descriptionMulti?[lang] ?? descriptionMulti?['en'] ?? "";
  }

  CharacterModel({
    this.id,
    this.nameMulti,
    this.gender,
    this.likes,
    this.introduceMulti,
    this.creatorUsername,
    this.avatarUrl,
    this.costPerMessage,
    this.tags,
    this.descriptionMulti,
    this.categoryIds,
    this.aiConfig,
    this.cards,
    this.isActive,
    this.createdAt,
  });

  CharacterModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    nameMulti = json['name'] is Map ? json['name'] : null;
    gender = json['gender'];
    likes = json['likes'];
    introduceMulti = json['introduce'] is Map ? json['introduce'] : null;
    creatorUsername = json['creator_username'];
    avatarUrl = json['avatar_url'];
    costPerMessage = json['cost_per_message'];
    if (json['tags'] != null) {
      tags = json['tags'].cast<String>();
    }
    descriptionMulti = json['description'] is Map ? json['description'] : null;
    if (json['category_ids'] != null) {
      categoryIds = json['category_ids'].cast<String>();
    }
    aiConfig = json['ai_config'] != null ? AiConfig.fromJson(json['ai_config']) : null;
    if (json['cards'] != null) {
      cards = json['cards'];
    }
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }
}
