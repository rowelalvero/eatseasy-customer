import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/constants/constants.dart';

class CachedImageLoader extends StatelessWidget {
  CachedImageLoader({super.key, required this.image, this.imageHeight=120, this.imageWidth=200, this.borderRadius, this.fit=BoxFit.fitWidth});
  final String image;
  double? imageHeight;
  double? imageWidth;
  BorderRadius? borderRadius;
  BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(
          borderRadius: borderRadius??BorderRadius.circular(0),
          image: DecorationImage( //image size fill
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(), // you can add pre loader iamge as well to show loading.
      ), //show progress  while loading image
      errorWidget: (context, url, error) => Image.asset("images/flutter.png"),
      //show no image available image on error loading
    );
  }
}
