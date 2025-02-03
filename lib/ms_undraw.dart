library ms_undraw;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:ms_undraw/illustrations.g.dart';
import 'package:path_provider/path_provider.dart';

export 'package:ms_undraw/illustrations.g.dart';

final _memCacheSvg = <String, String>{};

class UnDraw extends StatelessWidget {
  UnDraw({
    Key? key,
    required this.illustration,
    required this.color,
    this.semanticLabel,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
    this.colorBlendMode = BlendMode.srcIn,
    this.height,
    this.width,
    this.placeholder,
    this.errorWidget,
    this.padding,
    this.useMemCache = true,
    this.saveToDiskCache = true,
  }) : super(key: key);

  /// Enum [UnDrawIllustration] with all supported illustrations
  final UnDrawIllustration illustration;

  /// The color that will replaced for illustration
  final Color color;

  /// The [Semantics.label] for this picture.
  ///
  /// The value indicates the purpose of the picture, and will be
  /// read out by screen readers.
  final String? semanticLabel;

  /// How to align the picture within its parent widget.
  ///
  /// The alignment aligns the given position in the picture to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// picture with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then a [TextDirection] must be available
  /// when the picture is painted.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to inscribe the picture into the space allocated during layout.
  /// The default is [BoxFit.contain].
  final BoxFit fit;

  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  final BlendMode colorBlendMode;

  /// If specified, the width to use for the SVG.  If unspecified, the SVG
  /// will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the SVG.  If unspecified, the SVG
  /// will take the height of its parent.
  final double? height;

  /// The widget that will appear during loading illustration from the internet
  final Widget? placeholder;

  /// The widget that will appear if occurs an error
  final Widget? errorWidget;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  ///
  /// This padding is in addition to any padding inherent in the [decoration];
  /// see [Decoration.padding].
  final EdgeInsets? padding;

  /// If cache image in memory, if enable reload the same illustration is be more fast
  final bool useMemCache;

  /// If cache image in disk, if enable save the illustration in disk for future use
  /// only works in mobile and desktop
  final bool saveToDiskCache;

  Future<SvgPicture> renderIllustration(
      UnDrawIllustration illustration, Color _exColor) async {
    String image = await _getSvgString(
      illustration.url,
      this.useMemCache,
      this.saveToDiskCache,
    );

    String valueString = color.value.toRadixString(16);
    image = image.replaceAll("#6c63ff", "#" + valueString);
    return SvgPicture.string(
      image,
      height: height,
      width: width,
      alignment: alignment,
      colorBlendMode: colorBlendMode,
      fit: fit,
      semanticsLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: renderIllustration(illustration, color),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: padding ?? EdgeInsets.all(16),
              child: snapshot.data,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: errorWidget ?? Text('Could not load illustration!'),
            );
          } else {
            return Center(
              child: placeholder ?? CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> _getSvgString(
    String url, [
    bool useMemCache = true,
    bool saveToDiskCache = true,
  ]) async {
    var uri = Uri.parse(url);

    if (useMemCache &&
        _memCacheSvg.containsKey(url) &&
        _memCacheSvg[url] != null) {
      return _memCacheSvg[url]!;
    }

    if (!kIsWeb && saveToDiskCache) {
      final file = await _getSvgFile(url);
      if (await file.exists()) {
        String svgString = await file.readAsString();
        if (useMemCache) {
          _memCacheSvg[url] = svgString;
        }
        return svgString;
      }
    }

    http.Response response = await http.get(uri);
    String svgString = response.body;

    if (useMemCache) {
      _memCacheSvg[url] = svgString;
    }

    if (!kIsWeb && saveToDiskCache) {
      final file = await _getSvgFile(url);
      await file.writeAsString(svgString);
    }

    return svgString;
  }

  Future<File> _getSvgFile(String url) async {
    var uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/$fileName';
    return File(filePath);
  }

  /// Preload illustrations to cache
  ///
  /// [illustrations] list of [UnDrawIllustration] to preload
  /// [saveToMemCache] if save to memory cache
  /// [saveToDiskCache] if save to disk cache (only works in mobile and desktop)
  static Future<void> preLoad(
    List<UnDrawIllustration> illustrations, {
    saveToMemCache = true,
    saveToDiskCache = true,
  }) async {
    final unDraw = UnDraw(
        illustration: UnDrawIllustration.empty, color: Colors.transparent);
    for (var i = 0; i < illustrations.length; i++) {
      await unDraw._getSvgString(
        illustrations[i].url,
        saveToMemCache,
        saveToDiskCache,
      );
    }
  }
}
