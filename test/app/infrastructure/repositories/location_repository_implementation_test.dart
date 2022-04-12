import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viacep/app/domain/entities/location.dart';
import 'package:viacep/app/domain/errors/cep_failures.dart';
import 'package:viacep/app/domain/parameters/get_location_by_cep_parameters.dart';
import 'package:viacep/app/domain/repositories/location_repository.dart';
import 'package:viacep/app/infrastructure/datasources/location_datasource.dart';
import 'package:viacep/app/infrastructure/errors/cep_exceptions.dart';
import 'package:viacep/app/infrastructure/repositories/location_repository_implementation.dart';

class LocationDataSourceSpy extends Mock implements LocationDataSource {}

class GetLocationByCEPParametersFake extends Fake
    implements GetLocationByCEPParameters {}

class LocationFake extends Fake implements Location {}

void main() {
  late LocationDataSource dataSourceSpy;
  late LocationRepository repository;
  final tParameters = GetLocationByCEPParametersFake();
  final tLocation = LocationFake();

  setUp(() {
    registerFallbackValue(LocationFake());
    registerFallbackValue(GetLocationByCEPParametersFake());
    dataSourceSpy = LocationDataSourceSpy();
    repository = LocationRepositoryImplementation(dataSourceSpy);
  });

  test(
      'LocationRepositoryImplementation should respect LocationRepository abstraction',
      () {
    // Assert
    expect(repository, isA<LocationRepository>());
  });

  test('Should return Location in success case', () async {
    // Arrange
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenAnswer((_) async => tLocation);

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(
      result.fold(id, id),
      isA<Location>().having(
        (success) => success,
        'Has the expected entity',
        tLocation,
      ),
    );
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verifyNoMoreInteractions(dataSourceSpy);
  });

  test(
      'Should return UnableToGetLocationUsingCEPFailure when the DataSource throw UnableToGetLocationUsingCEPException',
      () async {
    // Arrange
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(UnableToGetLocationUsingCEPException());

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(result.fold(id, id), isA<UnableToGetLocationUsingCEPFailure>());
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verifyNoMoreInteractions(dataSourceSpy);
  });

  test(
      'Should return CEPFailure when the DataSource throw an unexpected exception',
      () async {
    // Arrange
    const tErrorMessage = 'Unexpected error';
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(Exception(tErrorMessage));

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(
      result.fold(id, id),
      isA<CEPFailure>().having(
        (failure) => failure.message,
        'Has the error message from exception',
        'Exception: $tErrorMessage',
      ),
    );
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verifyNoMoreInteractions(dataSourceSpy);
  });
}
