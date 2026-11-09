import 'package:get/get.dart';
import 'character_model.dart';

class CategoryModel {
  String? id;
  String? slug;
  Map<String, dynamic>? nameMulti;
  int? order;
  bool? isActive;
  List<String>? characterIds;
  List<CharacterModel>? characters;
  String? createdAt;

  String? get name {
    String lang = Get.locale?.languageCode ?? 'en';
    return nameMulti?[lang] ?? nameMulti?['en'] ?? "";
  }

  CategoryModel({
    this.id,
    this.slug,
    this.nameMulti,
    this.order,
    this.isActive,
    this.characterIds,
    this.characters,
    this.createdAt,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    slug = json['slug'];
    nameMulti = json['name'] is Map ? json['name'] : null;
    order = json['order'];
    isActive = json['is_active'];
    if (json['character_ids'] != null) {
      characterIds = json['character_ids'].cast<String>();
    }
    if (json['characters'] != null) {
       characters = <CharacterModel>[];
       json['characters'].forEach((v) {
         characters!.add(CharacterModel.fromJson(v));
       });
    }
    createdAt = json['created_at'];
  }
}
