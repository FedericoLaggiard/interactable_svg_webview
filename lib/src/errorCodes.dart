enum errorCodes {
  NO_SVG('1');

  final String key;
  const errorCodes(this.key);

  factory errorCodes.fromString(String key) {
    if(errorCodes.hasValidKey(key) == false) throw FormatException("Not a valid key $key");
    return errorCodes.values.firstWhere((el) => el.key == key);
  }

  static bool hasValidKey(String key) => errorCodes.values.where((element) => element.key == key).isNotEmpty;
}