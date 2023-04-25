import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:interactable_svg_webview/src/jsMessage.dart';
import 'package:interactable_svg_webview/src/touchedItem.dart';
import 'package:interactable_svg_webview/src/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'eventCodes.dart';

const JS_CHANNEL_NAME = 'jsChannel';
const HTML_PAGE_PATH = 'packages/interactable_svg_webview/lib/htmlPage/index.html';

/// Display an SVG and make it interactable using a webview
///
class SvgInteractableView extends StatefulWidget {
  /// The background color applied to the web view (white if not specified)
  final Color backgroundColor;
  /// The asset path of the SVG to load in the webview
  final String svgAssetPath;
  /// Width of the webview (by default screen width)
  final double? width;
  /// Height of the webview (by default screeh height)
  final double? height;
  /// Callback for loading complete (this will ensure that the SVG is loaded and the interaction system is ready)
  final Function? onLoadCompleted;
  /// Callback for hotspot touched by the user
  final Function(TouchedItem item)? onHotspotTouched;
  /// Callback for when the user is clicking outside an hotspot but inside the SVG
  final Function(TouchedItem item)? onSvgTouched;
  /// Callback for receiving errors from the webview WARNING: if this is not listen to, all the error will be discarded
  final Function? onPageErrors;
  /// List of classes that must be handled as hotspot
  final List<String>? hotspotsClasses;
  /// Elements on which the webview must handle the touch event (ex: 'path' or 'circle')
  final List<String> touchableElements;

  const SvgInteractableView({
    super.key,
    required this.svgAssetPath,
    required this.touchableElements,
    this.onLoadCompleted,
    this.onHotspotTouched,
    this.onSvgTouched,
    this.width,
    this.height,
    Color? backgroundColor,
    this.onPageErrors,
    this.hotspotsClasses,
  }) : backgroundColor= Colors.white;

  @override
  State<SvgInteractableView> createState() => _SvgInteractableViewState();
}

class _SvgInteractableViewState extends State<SvgInteractableView> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();

    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(widget.backgroundColor);
    _controller.addJavaScriptChannel(JS_CHANNEL_NAME, onMessageReceived: _onJSMessageReceived);
    _controller.setNavigationDelegate( NavigationDelegate(
      // onProgress: (int progress) { print(progress); },
      // onPageStarted: (String url) { print("page started"); },
      // onPageFinished: (String url) { print("page finished"); },
      onWebResourceError: (WebResourceError error) {
        widget.onPageErrors != null ? widget.onPageErrors!(error.description) : null;
      },
    ));
    _controller.loadFlutterAsset(HTML_PAGE_PATH).whenComplete(_onPageLoadComplete);

  }

  void _onPageLoadComplete() async {

  }

  void _onJSReady() async {
    try {
      String svgXml = await loadAsset(widget.svgAssetPath);
      _sendLoadSVG(svgXml);
    }catch (error){
      rethrow;
    }
  }
  void _onJSTouchEvent(event){
    Map<String, dynamic> json = jsonDecode(event);
    TouchedItem it = TouchedItem.fromJson(json);
    widget.onSvgTouched != null ? widget.onSvgTouched!(it) : null;
  }
  void _onJSHotspotEvent(event) {
    Map<String, dynamic> json = jsonDecode(event);
    TouchedItem it = TouchedItem.fromJson(json);
    widget.onHotspotTouched != null ? widget.onHotspotTouched!(it) : null;
  }
  void _onJSError(event) {
    widget.onPageErrors != null ? widget.onPageErrors!(event) : null;
  }
  void _onJSResponse(responseCode) {
    switch(responseCode) {
      case "SVG_LOADED":
        String hotspots = widget.hotspotsClasses !=null ? "[${widget.hotspotsClasses!.map((e) => "\\\"$e\\\"").join(",")}]" : "[]";
        String touchables = "[${widget.touchableElements.map((e) => "\\\"$e\\\"").join(",")}]";
        String jsData = '{ \\\"hotspotClasses\\\": $hotspots, \\\"touchableEl\\\":  $touchables}';

        _sendJSMessage(JsMessage(message: eventCodes.INIT_EVENTS, data: jsData ));
        break;
      case "EVENTS_READY":
        widget.onLoadCompleted != null ? widget.onLoadCompleted!() : null;
        break;
      default:
        widget.onPageErrors != null ? widget.onPageErrors!(responseCode) : null;
    }
  }

  void _onJSMessageReceived(JavaScriptMessage stringMessage) {
    JsMessage message = JsMessage.fromJson(json.decode(stringMessage.message));

    switch(message.message) {
      case eventCodes.READY:
        _onJSReady();
        break;
      case eventCodes.ERROR:
        _onJSError(message.data);
        break;
      case eventCodes.HOTSPOT:
        _onJSHotspotEvent(message.data);
        break;
      case eventCodes.TOUCH:
        _onJSTouchEvent(message.data);
        break;
      case eventCodes.RESPONSE:
        _onJSResponse(message.data);
        break;
      default:
        break;
    }
  }

  void _sendLoadSVG(svgXml) {
    _controller.runJavaScript('window.onLoadSVG(`$svgXml`)');
  }

  void _sendJSMessage(JsMessage message) {
    _controller.runJavaScript(
        "window.onFlutterMessage('${jsonEncode(message.toJson())}')"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.red, width: 1),
            // ),
            width: widget.width ?? MediaQuery.of(context).size.width,
            height: widget.height ?? MediaQuery.of(context).size.height,
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        )
    );
  }
}