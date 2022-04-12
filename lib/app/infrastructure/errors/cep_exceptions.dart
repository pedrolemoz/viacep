class CEPException implements Exception {
  final String? message;

  const CEPException({this.message});
}

class InvalidCEPFormatException extends CEPException {}

class UnableToGetLocationUsingCEPException extends CEPException {}
