import 'dart:async';
import 'dart:math';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MS Undraw - Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        secondaryHeaderColor: Colors.orangeAccent,
        useMaterial3: false,
      ),
      home: ContextMenuOverlay(
        child: MyHomePage(
            title: "${UnDrawIllustration.values.length} Illustrations"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color color = Colors.red;
  UnDrawIllustration illustration = UnDrawIllustration.mobile_application;
  Timer? timer;
  final List<UnDrawIllustration> _filtered = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final FocusNode _focus2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width < 1024 ? 16 : (width - 1024) / 2;

    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _focus.unfocus();
          _controller.clear();
          _filtered.clear();
          setState(() {});

          return KeyEventResult.handled;
        }
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.slash &&
            !_focus.hasFocus) {
          _focus.requestFocus();

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  showAboutDialog(context: context, children: [
                    TextButton(
                        onPressed: () => launchUrlString(
                            "https://pub.dev/packages/ms_undraw"),
                        child:
                            const Text('https://pub.dev/packages/ms_undraw')),
                    TextButton(
                        onPressed: () => launchUrlString("https://undraw.co/"),
                        child: const Text('https://undraw.co/')),
                  ]);
                },
                icon: const Icon(Icons.info))
          ],
          title: TextFormField(
            controller: _controller,
            focusNode: _focus,
            onChanged: (s) {
              timer?.cancel();
              timer = Timer(const Duration(seconds: 1), () {
                _filtered.clear();
                if (s.isNotEmpty) {
                  _filtered.addAll(UnDrawIllustration.values.where((element) =>
                      _changeName(element.name)
                          .toLowerCase()
                          .contains(s.toLowerCase())));
                }
                setState(() {});
              });
            },
            onFieldSubmitted: (s) {
              timer?.cancel();
              _filtered.clear();
              _focus.requestFocus();
              if (s.isNotEmpty) {
                _filtered.addAll(UnDrawIllustration.values.where((element) =>
                    _changeName(element.name)
                        .toLowerCase()
                        .contains(s.toLowerCase())));
              }
              setState(() {});
            },
            cursorColor: Colors.white,
            style: const TextStyle(
              color: Colors.white,
              decorationColor: Colors.white,
            ),
            decoration: InputDecoration(
              label: Text("Type to search"),
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              isDense: true,
              iconColor: Colors.white,
              focusColor: Colors.white,
              prefixIconColor: Colors.white,
              labelStyle: TextStyle(color: Colors.white),
              suffixIconColor: Colors.white,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _filtered.clear();
                    _controller.clear();
                  });
                },
                icon: Icon(Icons.clear, color: Colors.white),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                  .withValues(alpha: 1);
            });
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.color_lens),
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 1,
                mainAxisExtent: 285 + 28 + 16,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16),
            padding: EdgeInsets.only(
                top: 16,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 64),
            itemBuilder: (_, index) {
              final undraw = _filtered.isEmpty
                  ? UnDrawIllustration.values[index]
                  : _filtered[index];
              return ContextMenuRegion(
                contextMenu: GenericContextMenu(
                  buttonConfigs: [
                    ContextMenuButtonConfig("Copy name",
                        onPressed: () => _copyName(undraw)),
                    ContextMenuButtonConfig("Copy widget code",
                        onPressed: () => _copyCode(undraw)),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4))
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(_changeName(undraw.name)),
                      SizedBox(
                        // height: 220+67,
                        child: Center(
                          child: UnDraw(
                            color: color,
                            useMemCache: false,
                            height: 200,
                            width: 200,
                            illustration: undraw,
                            placeholder:
                                const Text("Illustration is loading..."),
                            errorWidget: const Icon(Icons.error_outline,
                                color: Colors.red, size: 50),
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          TextButton.icon(
                              onPressed: () => _copyName(undraw),
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy name")),
                          const Spacer(),
                          TextButton.icon(
                              onPressed: () => _copyCode(undraw),
                              icon: const Icon(Icons.code),
                              label: const Text("Copy Widget code")),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: _filtered.isEmpty
                ? UnDrawIllustration.values.length
                : _filtered.length),
      ),
    );
  }

  String _changeName(String name) {
    return name
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .toList()
        .join(' ')
        .trim();
  }

  _copyName(UnDrawIllustration undraw) {
    Clipboard.setData(ClipboardData(text: "UnDrawIllustration.${undraw.name}"));
  }

  _copyCode(UnDrawIllustration undraw) {
    Clipboard.setData(ClipboardData(text: """UnDraw(
      color: Theme.of(context).primaryColor,
      illustration: UnDrawIllustration.${undraw.name},
    )"""));
  }
}
