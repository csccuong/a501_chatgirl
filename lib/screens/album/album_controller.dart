import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../full_screen_image/full_screen_image_page.dart';
import '../full_screen_image/full_screen_image_controller.dart';

class AlbumController extends BaseController {
  final cardUrls = <String>[].obs;
  final chatUrls = <String>[].obs;

  int get totalItems => cardUrls.length + chatUrls.length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final incomingCardUrls = args['cardUrls'] as List?;
      if (incomingCardUrls != null) {
        cardUrls.assignAll(incomingCardUrls.map((e) => e.toString()));
      } else {
        final legacyCardUrl = args['cardUrl'] as String? ?? '';
        if (legacyCardUrl.isNotEmpty) {
          cardUrls.assignAll([legacyCardUrl]);
        }
      }

      final incomingChatUrls = args['chatUrls'] as List?;
      if (incomingChatUrls != null) {
        chatUrls.assignAll(
          incomingChatUrls
              .map((e) => e.toString())
              .where((url) => url.isNotEmpty)
              .toList(),
        );
      }
    }
  }

  String getUrlForIndex(int index) {
    if (index < cardUrls.length) return cardUrls[index];
    return chatUrls[index - cardUrls.length];
  }

  void openImageAtIndex(int index) {
    Get.toWithController(
      controllerBuilder: () => FullScreenImageController(),
      arguments: {
        'urls': [...cardUrls, ...chatUrls],
        'initialIndex': index,
      },
      page: () => const FullScreenImagePage(),
    );
  }
}
