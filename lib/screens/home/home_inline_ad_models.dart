import 'package:flutter/material.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';

enum HomeInlineAdSlotStatus {
  idle,
  loading,
  ready,
  loaded,
  failed,
}

enum HomeGridPlacementType {
  content,
  inlineAd,
}

class HomeGridPlacement {
  const HomeGridPlacement._({
    required this.type,
    required this.index,
  });

  const HomeGridPlacement.content(int characterIndex)
      : this._(
          type: HomeGridPlacementType.content,
          index: characterIndex,
        );

  const HomeGridPlacement.inlineAd(int slotIndex)
      : this._(
          type: HomeGridPlacementType.inlineAd,
          index: slotIndex,
        );

  final HomeGridPlacementType type;
  final int index;

  bool get isContent => type == HomeGridPlacementType.content;

  bool get isInlineAd => type == HomeGridPlacementType.inlineAd;

  int get characterIndex => index;

  int get slotIndex => index;
}

class HomeInlineAdLogicalKeys {
  static const String homeInlineDefault = 'home_inline_default';
}

@immutable
class HomeInlineAdConfig {
  const HomeInlineAdConfig({
    this.logicalKey,
    this.rawAdUnitId,
    this.factoryId = 'nativeItemMedia',
    this.backgroundColor = const Color(0xFF161821),
  }) : assert(
          logicalKey != null || rawAdUnitId != null,
          'Either logicalKey or rawAdUnitId must be provided.',
        );

  const HomeInlineAdConfig.homeInline({
    String logicalKey = HomeInlineAdLogicalKeys.homeInlineDefault,
  }) : this(
          logicalKey: logicalKey,
        );

  final String? logicalKey;
  final String? rawAdUnitId;
  final String factoryId;
  final Color backgroundColor;

  String get resolvedAdUnitId {
    if (rawAdUnitId != null && rawAdUnitId!.isNotEmpty) {
      return rawAdUnitId!;
    }

    switch (logicalKey) {
      case HomeInlineAdLogicalKeys.homeInlineDefault:
        return MyAdIdName.nativeHome.getId;
      default:
        return MyAdIdName.nativeHome.getId;
    }
  }
}
