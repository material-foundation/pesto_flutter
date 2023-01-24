import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:palette_generator/palette_generator.dart';

class ImageTheme extends StatelessWidget {
  const ImageTheme({
    super.key,
    required this.path,
    required this.child,
  });
  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: colorSchemeFromImage(theme.colorScheme, path),
      builder: (context, snapshot) {
        final scheme = snapshot.data ?? theme.colorScheme;
        return Theme(
          data: theme.copyWith(colorScheme: scheme),
          child: child,
        );
      },
    );
  }

  Future<List<Color>?> sourceColorsFromImage(String path) async {
    try {
      final pixels = await imageToPixels(path);
      if (pixels == null || pixels.isEmpty) return null;
      final result = await QuantizerCelebi().quantize(pixels, 128);
      final ranked = Score.score(result.colorToCount);
      return ranked.map((e) => Color(e)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<List<int>?> imageToPixels(String path) async {
    try {
      final provider = await PaletteGenerator.fromImageProvider(
        AssetImage(path),
      );
      return provider.colors.map((e) => e.value).toList();
    } catch (e) {
      debugPrint('error converting image to pixels: $e');
      return null;
    }
  }

  Future<ColorScheme> colorSchemeFromImage(
    ColorScheme base,
    String path,
  ) async {
    final colors = await sourceColorsFromImage(path);
    if (colors == null || colors.isEmpty) return base;
    final to = base.primary.value;
    final from = colors[0].value;
    final blended = Color(Blend.harmonize(from, to));
    final scheme = ColorScheme.fromSeed(
      seedColor: blended,
      brightness: base.brightness,
    );
    return scheme;
  }
}
