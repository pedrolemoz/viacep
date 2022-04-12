import 'package:dartz/dartz.dart';

import '../../../core/domain/errors/failure.dart';
import '../entities/location.dart';
import '../errors/cep_failures.dart';
import '../parameters/get_location_by_cep_parameters.dart';
import '../repositories/location_repository.dart';

abstract class GetLocationByCEP {
  Future<Either<Failure, Location>> call(GetLocationByCEPParameters parameters);
}

class GetLocationByCEPImplementation implements GetLocationByCEP {
  final LocationRepository repository;

  const GetLocationByCEPImplementation(this.repository);

  @override
  Future<Either<Failure, Location>> call(
    GetLocationByCEPParameters parameters,
  ) async {
    try {
      if (parameters.cep.length < 8) {
        return Left(InvalidShortCEPFailure());
      }

      if (parameters.cep.length > 8) {
        return Left(InvalidLongCEPFailure());
      }

      if (parameters.cep.contains(RegExp('[A-Za-z]'))) {
        return Left(InvalidAlphanumericCharacterInCEPFailure());
      }

      if (parameters.cep.contains(' ')) {
        return Left(InvalidBlankSpaceInCEPFailure());
      }

      return await repository.getLocationByCEP(parameters);
    } catch (exception) {
      return Left(CEPFailure(message: exception.toString()));
    }
  }
}
