import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viacep/app/domain/entities/location.dart';
import 'package:viacep/app/domain/errors/cep_failures.dart';
import 'package:viacep/app/domain/parameters/get_location_by_cep_parameters.dart';
import 'package:viacep/app/domain/repositories/location_repository.dart';
import 'package:viacep/app/domain/usecases/get_location_by_cep.dart';

class LocationRepositorySpy extends Mock implements LocationRepository {}

class LocationFake extends Fake implements Location {}

void main() {
  late LocationRepository repository;
  late GetLocationByCEP usecase;

  setUp(() {
    registerFallbackValue(LocationFake());
    repository = LocationRepositorySpy();
    usecase = GetLocationByCEPImplementation(repository);
  });

  test(
      'GetLocationByCEPImplementation should respect GetLocationByCEP abstraction',
      () {
    // Assert
    expect(usecase, isA<GetLocationByCEP>());
  });

  test('Should return Location in success case', () async {
    // Arrange
    const parameters = GetLocationByCEPParameters(cep: '01001000');
    final tLocation = LocationFake();
    when(() => repository.getLocationByCEP(parameters))
        .thenAnswer((_) async => Right(tLocation));

    // Act
    final result = await usecase(parameters);

    // Assert
    expect(
      result.fold(id, id),
      isA<Location>().having(
        (success) => success,
        'Has the expected entity',
        tLocation,
      ),
    );
    verify(() => repository.getLocationByCEP(parameters));
    verifyNoMoreInteractions(repository);
  });

  group('CEP validation tests', () {
    test(
        'Should return InvalidLongCEPFailure if the entered CEP has more than 8 digits',
        () async {
      // Arrange
      const parameters = GetLocationByCEPParameters(cep: '950100100');

      // Act
      final result = await usecase(parameters);

      // Assert
      expect(result.fold(id, id), isA<InvalidLongCEPFailure>());
      verifyZeroInteractions(repository);
    });

    test(
        'Should return InvalidShortCEPFailure if the entered CEP has less than 8 digits',
        () async {
      // Arrange
      const parameters = GetLocationByCEPParameters(cep: '9501000');

      // Act
      final result = await usecase(parameters);

      // Assert
      expect(result.fold(id, id), isA<InvalidShortCEPFailure>());
      verifyZeroInteractions(repository);
    });

    test(
        'Should return InvalidAlphanumericCharacterInCEPFailure if the entered CEP has an alphanumeric character',
        () async {
      // Arrange
      const parameters = GetLocationByCEPParameters(cep: '95010A10');

      // Act
      final result = await usecase(parameters);

      // Assert
      expect(
        result.fold(id, id),
        isA<InvalidAlphanumericCharacterInCEPFailure>(),
      );
      verifyZeroInteractions(repository);
    });

    test(
        'Should return InvalidBlankSpaceInCEPFailure if the entered CEP has a blank space',
        () async {
      // Arrange
      const parameters = GetLocationByCEPParameters(cep: '9501 010');

      // Act
      final result = await usecase(parameters);

      // Assert
      expect(result.fold(id, id), isA<InvalidBlankSpaceInCEPFailure>());
      verifyZeroInteractions(repository);
    });
  });

  test('Should return CEPFailure when an unexpected error occurs', () async {
    // Arrange
    const parameters = GetLocationByCEPParameters(cep: '01001000');
    const errorMessage = 'Unexpected error';
    when(() => repository.getLocationByCEP(parameters))
        .thenThrow(Exception(errorMessage));

    // Act
    final result = await usecase(parameters);

    // Assert
    expect(
      result.fold(id, id),
      isA<CEPFailure>().having(
        (failure) => failure.message,
        'Has the error message from exception',
        'Exception: $errorMessage',
      ),
    );
    verify(() => repository.getLocationByCEP(parameters));
    verifyNoMoreInteractions(repository);
  });
}
