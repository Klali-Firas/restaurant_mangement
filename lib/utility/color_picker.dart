import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<Color> pickDarkColor(String link) async {
  var paletteGenerator = await PaletteGenerator.fromImageProvider(
    Image.network(link).image,
  );
  return paletteGenerator.darkMutedColor?.color ??
      paletteGenerator.darkVibrantColor!.color;
}

Future<Color> pickLightColor(String link) async {
  var paletteGenerator = await PaletteGenerator.fromImageProvider(
    Image.network(link).image,
  );
  return paletteGenerator.lightMutedColor?.color ??
      paletteGenerator.lightVibrantColor!.color;
}
