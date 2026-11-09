import 'package:flutter/material.dart';

import '../utils/app_util.dart';

class ImageFromNetworkFullWidth extends StatelessWidget {
  const ImageFromNetworkFullWidth(
    this.imageUrl,
    this.placeHolderImg,
    this.fit, {
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final String placeHolderImg;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return imageUrl.isNotEmpty
        ? FadeInImage.assetNetwork(
            placeholder: 'assets/image_loading.gif',
            image: AppUtil.formatImageUrlWithPlaceholder(imageUrl),
            fit: fit,
            width: double.infinity,
            placeholderErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                placeHolderImg,
                fit: fit,
                width: double.infinity,
              );
            },
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                placeHolderImg,
                fit: fit,
                width: double.infinity,
              );
            },
          )
        : Image.asset(
            placeHolderImg,
            fit: fit,
            width: double.infinity,
          );
  }
}
