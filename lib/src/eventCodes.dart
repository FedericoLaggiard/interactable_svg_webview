enum eventCodes {
  HOTSPOT('HOTSPOT'),
  TOUCH('TOUCH'),
  ERROR('ERROR'),
  READY('READY'),
  RESPONSE('RESPONSE'),
  LOAD_SVG('LOAD_SVG'),
  INIT_EVENTS('INIT_EVENTS'),
  ;

  final String key;
  const eventCodes(this.key);

  factory eventCodes.fromString(String key) {
    if(eventCodes.hasValidKey(key) == false) throw FormatException("Not a valid key $key");
    return eventCodes.values.firstWhere((el) => el.key == key);
  }

  static bool hasValidKey(String key) => eventCodes.values.where((element) => element.key == key).isNotEmpty;
}