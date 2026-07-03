import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:video_player/video_player.dart';

class CustomImage extends StatelessWidget {
  final Size size;
  final double strokeWidth;
  final String? image;
  final double radius;
  final double? cornerSmoothing;
  final VoidCallback? onTap;
  final bool isShowPlaceHolder;
  final Color? strokeColor;
  final BoxFit? fit;
  final bool isImageLoaderVisible;
  final String? fullName;
  final bool isStokeOutSide;
  final String? placeHolderImage;

  const CustomImage({
    super.key,
    required this.size,
    this.strokeWidth = 0,
    this.image,
    this.radius = 180,
    this.onTap,
    this.cornerSmoothing,
    this.isShowPlaceHolder = false,
    this.strokeColor,
    this.fit,
    this.isImageLoaderVisible = true,
    this.fullName,
    this.isStokeOutSide = true,
    this.placeHolderImage,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = image ?? '';
    double cornerSmoothing = this.cornerSmoothing ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: fit == BoxFit.fitWidth ? null : size.height,
        width: size.width,
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
              cornerRadius: radius, cornerSmoothing: cornerSmoothing),
          child: Stack(
            children: [
              imageUrl.isEmpty
                  ? ImageErrorWidget(
                      size: size,
                      radius: radius,
                      cornerSmoothing: cornerSmoothing,
                      isShowPlaceHolder: isShowPlaceHolder,
                      fullName: fullName,
                      placeHolderImage: placeHolderImage,
                    )
                  : Container(
                      height: fit == BoxFit.fitWidth ? null : size.height,
                      width: size.width,
                      margin: EdgeInsets.all(!isStokeOutSide ? 0 : strokeWidth),
                      constraints: BoxConstraints(maxHeight: size.height),
                      child: ClipSmoothRect(
                        radius: SmoothBorderRadius(
                            cornerRadius: radius,
                            cornerSmoothing: cornerSmoothing),
                        child: CachedNetworkImage(
                          fit: fit ?? BoxFit.cover,
                          imageUrl: imageUrl,
                          cacheKey: imageUrl,
                          placeholder: (context, url) {
                            return isImageLoaderVisible
                                ? Shimmer.fromColors(
                                    baseColor: bgGrey(context),
                                    highlightColor: bgMediumGrey(context),
                                    child: Container(
                                      height: size.height,
                                      width: size.width,
                                      decoration: BoxDecoration(
                                          color: bgGrey(context),
                                          borderRadius:
                                              BorderRadius.circular(radius)),
                                    ))
                                : const SizedBox();
                          },
                          errorWidget: (context, error, stackTrace) {
                            return ImageErrorWidget(
                                size: size,
                                radius: radius,
                                cornerSmoothing: cornerSmoothing,
                                isShowPlaceHolder: isShowPlaceHolder,
                                fullName: fullName,
                                placeHolderImage: placeHolderImage);
                          },
                        ),
                      ),
                    ),
              if (strokeWidth > 0)
                Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: radius),
                      side: BorderSide(
                          color: strokeColor ??
                              whitePure(context).withValues(alpha: .3),
                          width: strokeWidth),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageErrorWidget extends StatelessWidget {
  final double radius;
  final double cornerSmoothing;
  final bool isShowPlaceHolder;
  final Size size;
  final String? fullName;
  final double? placeHolderColorOpacity;
  final String? placeHolderImage;

  const ImageErrorWidget(
      {super.key,
      required this.radius,
      required this.cornerSmoothing,
      this.isShowPlaceHolder = false,
      required this.size,
      this.fullName,
      this.placeHolderColorOpacity,
      this.placeHolderImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
                cornerRadius: radius, cornerSmoothing: cornerSmoothing)),
        gradient: isShowPlaceHolder
            ? StyleRes.disabledGreyGradient(
                opacity: placeHolderColorOpacity ?? 1)
            : StyleRes.themeGradient,
      ),
      alignment: Alignment.center,
      child: isShowPlaceHolder
          ? LayoutBuilder(builder: (context, constraints) {
              return Image.asset(placeHolderImage ?? AssetRes.icNoImage,
                  height: constraints.maxHeight / 2,
                  width: constraints.maxWidth / 2,
                  color: textDarkGrey(context));
            })
          : Text(
              (fullName?[0] ?? AppRes.appName[0]).toUpperCase(),
              style: TextStyleCustom.unboundedMedium500(
                  fontSize:
                      size.height / 2, // Fallback to 50 if size is not finite
                  color: whitePure(context),
                  opacity: 0.4),
            ),
    );
  }
}

class MediaDisplayWidget extends StatefulWidget {
  final Size size;
  final double strokeWidth;
  final String? image;
  final double radius;
  final double? cornerSmoothing;
  final VoidCallback? onTap;
  final bool isShowPlaceHolder;
  final Color? strokeColor;
  final BoxFit? fit;
  final bool isImageLoaderVisible;
  final String? fullName;
  final bool isStokeOutSide;
  final String? placeHolderImage;

  const MediaDisplayWidget({
    super.key,
    required this.size,
    this.strokeWidth = 0,
    this.image,
    this.radius = 180,
    this.onTap,
    this.cornerSmoothing,
    this.isShowPlaceHolder = false,
    this.strokeColor,
    this.fit,
    this.isImageLoaderVisible = true,
    this.fullName,
    this.isStokeOutSide = true,
    this.placeHolderImage,
  });

  @override
  State<MediaDisplayWidget> createState() => _MediaDisplayWidgetState();
}

class _MediaDisplayWidgetState extends State<MediaDisplayWidget> {
  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check if the URL is a video based on its extension
    _isVideo = _isVideoUrl(widget.image ?? '');
    if (_isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.image!))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
        }).catchError((error) {
          setState(() {
            _isInitialized =
                false; // Fallback to placeholder if initialization fails
          });
        });
      // Add listener to detect video completion
      _controller?.addListener(_videoListener);
    }
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv');
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      // Check if video has reached the end
      if (_controller!.value.position >= _controller!.value.duration) {
        setState(() {
          _controller!.pause(); // Pause the video
          _controller!.seekTo(Duration.zero); // Reset to start
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener); // Clean up listener
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo) {
      // Fallback to CustomImage for non-video URLs
      return CustomImage(
        size: widget.size,
        strokeWidth: widget.strokeWidth,
        image: widget.image,
        radius: widget.radius,
        onTap: widget.onTap,
        cornerSmoothing: widget.cornerSmoothing,
        isShowPlaceHolder: widget.isShowPlaceHolder,
        strokeColor: widget.strokeColor,
        fit: widget.fit,
        isImageLoaderVisible: widget.isImageLoaderVisible,
        fullName: widget.fullName,
        isStokeOutSide: widget.isStokeOutSide,
        placeHolderImage: widget.placeHolderImage,
      );
    }

    // Video thumbnail display with play functionality
    return GestureDetector(
      onTap: widget
          .onTap, // Keep existing onTap for navigating to full-screen player
      child: SizedBox(
        height: widget.fit == BoxFit.fitWidth ? null : widget.size.height,
        width: widget.size.width,
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: widget.radius,
            cornerSmoothing: widget.cornerSmoothing ?? 0,
          ),
          child: Stack(
            children: [
              _isInitialized && _controller != null
                  ? VideoPlayer(_controller!)
                  : Container(
                      height: widget.size.height,
                      width: widget.size.width,
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: widget.radius,
                            cornerSmoothing: widget.cornerSmoothing ?? 0,
                          ),
                        ),
                        gradient: widget.isShowPlaceHolder
                            ? StyleRes.disabledGreyGradient()
                            : StyleRes.themeGradient,
                      ),
                      child: widget.isShowPlaceHolder
                          ? Center(
                              child: Shimmer.fromColors(
                                baseColor: bgGrey(context),
                                highlightColor: bgMediumGrey(context),
                                child: Container(
                                  height: widget.size.height,
                                  width: widget.size.width,
                                  decoration: BoxDecoration(
                                    color: bgGrey(context),
                                    borderRadius:
                                        BorderRadius.circular(widget.radius),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
              if (_isInitialized && _controller != null)
                Center(
                  child: AnimatedOpacity(
                    opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.strokeWidth > 0)
                Container(
                  height: widget.size.height,
                  width: widget.size.width,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius:
                          SmoothBorderRadius(cornerRadius: widget.radius),
                      side: BorderSide(
                        color: widget.strokeColor ??
                            whitePure(context).withValues(alpha: 0.3),
                        width: widget.strokeWidth,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
