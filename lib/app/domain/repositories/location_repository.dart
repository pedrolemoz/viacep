import 'package:dartz/dartz.dart';

import '../../../core/domain/errors/failure.dart';
import '../entities/location.dart';
import '../parameters/get_location_by_cep_parameters.dart';

abstract class LocationRepository {
  Future<Either<Failure, Location>> getLocationByCEP(
    GetLocationByCEPParameters parameters,
  );
}
