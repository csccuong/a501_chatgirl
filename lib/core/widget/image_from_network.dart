import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_util.dart';

class ImageFromNetwork extends StatelessWidget {
  const ImageFromNetwork(
    this.imageUrl,
    this.placeHolderImg,
    this.imgWidth,
    this.imgHeight,
    this.fit, {
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final String placeHolderImg;
  final double imgWidth;
  final double imgHeight;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        placeHolderImg,
        width: imgWidth,
        height: imgHeight,
        fit: fit,
      );
    } else {
      return CachedNetworkImage(
        width: imgWidth,
        height: imgHeight,
        memCacheWidth: imgWidth > 0 ? (imgWidth * 2).toInt() : 400,
        imageUrl: AppUtil.formatImageUrlWithPlaceholder(imageUrl),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
              // colorFilter:
              // ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          "assets/image_loading.gif",
          width: imgWidth,
          height: imgHeight,
          fit: fit,
        ),
        errorWidget: (context, url, error) => Image.asset(placeHolderImg, width: imgWidth, height: imgHeight, fit: fit),
      );
    }
  }
}
