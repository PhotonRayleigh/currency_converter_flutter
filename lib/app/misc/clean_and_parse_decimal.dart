import 'package:decimal/decimal.dart';

Decimal? cleanAndParseDecimal(String text) {
  String cleanedText = text;
  var regExPattern = RegExp(r"(\d*[.]?\d{0,8}){1}");
  if (regExPattern.hasMatch(text)) {
    if (text.endsWith(".")) cleanedText = text + "0";
    if (text.startsWith(".")) cleanedText = "0" + text;
    return Decimal.parse(cleanedText);
  } else
    return null;
}
