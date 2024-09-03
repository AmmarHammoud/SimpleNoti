import 'package:flutter/material.dart';

///A dart file to provide the application with the ability of print debug
///messages with colorful output.
///The logic behind this feature is to specify the color by its code which will be applied
///to all the output after it, then resetting to the default after the job is done

///Colors' codes
const String _cyan = '\x1B[36m';
const String _red = '\x1B[31m';
const String _green = '\x1B[32m';
const String _blue = '\x1B[34m';
const String _yellow = '\x1B[33m';
const String _reset = '\x1B[0m';
const String _magenta = '\x1B[35m';

logCyan(String t) {
  debugPrint('$_cyan${"💎 $t"}$_reset');
}

logRed(String t) {
  debugPrint('$_red${"🚨 $t"}$_reset');
}

logMagenta(String t) {
  debugPrint('$_magenta${"☑️ $t"}$_reset');
}

logGreen(String t) {
  debugPrint('$_green${"✅ $t"}$_reset');
}

logBlue(String t) {
  debugPrint('$_blue${"🟦 $t"}$_reset');
}

logYellow(String t) {
  debugPrint('$_yellow${"💡 $t"}$_reset');
}
