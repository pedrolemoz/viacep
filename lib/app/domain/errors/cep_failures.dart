import '../../../core/domain/errors/failure.dart';

class CEPFailure extends Failure {
  const CEPFailure({String? message}) : super(message: message);
}

class InvalidLongCEPFailure extends CEPFailure {}

class InvalidShortCEPFailure extends CEPFailure {}

class InvalidAlphanumericCharacterInCEPFailure extends CEPFailure {}

class InvalidBlankSpaceInCEPFailure extends CEPFailure {}

class UnableToGetLocationUsingCEPFailure extends CEPFailure {}
