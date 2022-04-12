import 'dart:io';

class MockParser {
  static String convertJsonToString(String pathToFile) {
    return File(
      '${Directory.current.uri.path.substring(1)}test/app/$pathToFile',
    ).readAsStringSync();
  }
}
