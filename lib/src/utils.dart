import 'package:flutter/services.dart';

Future<String> loadAsset(assetPath) async {
  return await rootBundle.loadString(assetPath);
}