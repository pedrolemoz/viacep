import 'package:dartz/dartz.dart';

import '../../../core/domain/errors/failure.dart';
import '../../domain/entities/location.dart';
import '../../domain/errors/cep_failures.dart';
import '../../domain/parameters/get_location_by_cep_parameters.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';
import '../errors/cep_exceptions.dart';

class LocationRepositoryImplementation implements LocationRepository {
  final LocationDataSource dataSource;

  const LocationRepositoryImplementation(this.dataSource);

  @override
  Future<Either<Failure, Location>> getLocationByCEP(
    GetLocationByCEPParameters parameters,
  ) async {
    try {
      return Right(await dataSource.getLocationByCEP(parameters));
    } on InvalidCEPFormatException {
      return Left(InvalidCEPFormatFailure());
    } on UnableToGetLocationUsingCEPException {
      return Left(UnableToGetLocationUsingCEPFailure());
    } catch (exception) {
      return Left(CEPFailure(message: exception.toString()));
    }
  }
}
