import 'package:interactable_svg_webview/src/eventCodes.dart';

class JsMessage {
  final eventCodes message;
  final String data;

  JsMessage({
    required this.message,
    required this.data,
  });

  factory JsMessage.fromJson(Map<String, dynamic> json) => _$JsMessageFromJson(json);
  Map<String, dynamic> toJson() => _$JsMessageToJson(this);

}

JsMessage _$JsMessageFromJson(Map<String, dynamic> json) =>
  JsMessage(
    message: eventCodes.fromString(json['message']),
    data: json['data'] as String,
  );

Map<String, dynamic> _$JsMessageToJson(JsMessage instance) =>
  <String, dynamic>{
    'message': instance.message.key,
    'data': instance.data,
  };


