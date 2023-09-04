import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

//A library which allows to pick dominante color from image
//the library isn't used in the app for now

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
