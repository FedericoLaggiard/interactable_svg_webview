import 'package:flutter/material.dart';
import 'package:interactable_svg_webview/interactable_svg_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactable SVG Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Interactable SVG demo'),
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

  String _lastText = "- touch the image -";
  final PageController controller = PageController();

  void onHotspot(TouchedItem hotspot) {
    setState(() {
      _lastText = 'HOTSPOT ${hotspot.id}\n'
          '\n'
          '- type: ${hotspot.type}\n'
          '- classes: ${hotspot.classes}\n'
          '- name: ${hotspot.name}\n'
          '\n'
          '--- FULL ELEMENT ---\n'
          '${hotspot.fullEl}';
    });
  }

  void onTouch(TouchedItem el) {
    setState(() {
      _lastText = 'no hotspot ${el.id}\n'
          '\n'
          '- type: ${el.type}\n'
          '- classes: ${el.classes}\n'
          '- name: ${el.name}\n'
          '\n'
          '--- FULL ELEMENT ---\n'
          '${el.fullEl}';
    });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: PageView(
                controller: controller,
                children: [
                  SvgInteractableView(
                    backgroundColor: Colors.green,
                    svgAssetPath: 'assets/purple_muscle.svg',
                    touchableElements: const ['circle', 'path'],
                    hotspotsClasses: const ['hotspot'],
                    onHotspotTouched: onHotspot,
                    onSvgTouched: onTouch,
                  ),
                  SvgInteractableView(
                    backgroundColor: Colors.blue,
                    svgAssetPath: 'assets/police.svg',
                    touchableElements: const ['circle', 'path'],
                    hotspotsClasses: const ['hotspot'],
                    onHotspotTouched: onHotspot,
                    onSvgTouched: onTouch,
                  ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 30),
                scrollDirection: Axis.vertical,
                child: Text(_lastText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
