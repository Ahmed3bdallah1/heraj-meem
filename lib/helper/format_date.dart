import 'package:intl/intl.dart';

abstract class FormatDate {
  static String call(dynamic value, {bool addJm = false}) {
    const pattern = "d MMM yyy";
    var function = DateFormat(pattern, "en");
    if (addJm) {
      function = function.add_jm();
    }
    late String result;
    if (value is DateTime) {
      result = function.format(value);
    } else if (value is String) {
      result = function.format(DateTime.parse(value));
    } else if (value == null) {
      result = '';
    } else {
      result = value.toString();
    }
    return Bidi.enforceLtrInText(result);
  }
}
