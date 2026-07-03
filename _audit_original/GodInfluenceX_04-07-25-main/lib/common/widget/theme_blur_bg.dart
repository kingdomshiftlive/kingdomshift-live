import 'package:flutter/material.dart';
import 'package:shortzz/utilities/asset_res.dart';

class ThemeBlurBg extends StatelessWidget {
  const ThemeBlurBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/godly_app_background.png",
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
