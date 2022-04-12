class CEPException implements Exception {
  final String? message;

  const CEPException({this.message});
}

class UnableToGetLocationUsingCEPException extends CEPException {}
