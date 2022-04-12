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
import 'package:viacep/core/domain/errors/global_failures.dart';
import 'package:viacep/core/infrastructure/handlers/core_exceptions_handler.dart';
import 'package:viacep/core/packages/http_client/exceptions/no_internet_connection_exception.dart';
import 'package:viacep/core/packages/http_client/exceptions/server_exception.dart';

class CoreExceptionsHandlerSpy extends Mock implements CoreExceptionsHandler {}

class LocationDataSourceSpy extends Mock implements LocationDataSource {}

class GetLocationByCEPParametersFake extends Fake
    implements GetLocationByCEPParameters {}

class LocationFake extends Fake implements Location {}

void main() {
  late CoreExceptionsHandler exceptionsHandler;
  late LocationDataSource dataSourceSpy;
  late LocationRepository repository;
  final tParameters = GetLocationByCEPParametersFake();
  final tLocation = LocationFake();

  setUp(() {
    registerFallbackValue(LocationFake());
    registerFallbackValue(GetLocationByCEPParametersFake());
    exceptionsHandler = CoreExceptionsHandlerSpy();
    dataSourceSpy = LocationDataSourceSpy();
    repository = LocationRepositoryImplementation(
      dataSourceSpy,
      exceptionsHandler,
    );
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
    verifyZeroInteractions(exceptionsHandler);
  });

  test(
      'Should return InvalidCEPFormatFailure when the DataSource throw InvalidCEPFormatException',
      () async {
    // Arrange
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(InvalidCEPFormatException());

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(result.fold(id, id), isA<InvalidCEPFormatFailure>());
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verifyNoMoreInteractions(dataSourceSpy);
    verifyZeroInteractions(exceptionsHandler);
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
    verifyZeroInteractions(exceptionsHandler);
  });

  test(
      'Should return NoInternetConnectionFailure when the DataSource throw NoInternetConnectionException',
      () async {
    // Arrange
    const tException = NoInternetConnectionException();
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(tException);
    when(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    ).thenAnswer((_) async => Left(NoInternetConnectionFailure()));

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(result.fold(id, id), isA<NoInternetConnectionFailure>());
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verify(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    );
    verifyNoMoreInteractions(dataSourceSpy);
    verifyNoMoreInteractions(exceptionsHandler);
  });

  test('Should return ServerFailure when the DataSource throw ServerException',
      () async {
    // Arrange
    const tException = ServerException(data: '');
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(tException);
    when(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    ).thenAnswer(
      (_) async => Left(
        ServerFailure(message: 'Exception: ${tException.data}'),
      ),
    );

    // Act
    final result = await repository.getLocationByCEP(tParameters);

    // Assert
    expect(result.fold(id, id), isA<ServerFailure>());
    verify(() => dataSourceSpy.getLocationByCEP(tParameters));
    verify(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    );
    verifyNoMoreInteractions(dataSourceSpy);
    verifyNoMoreInteractions(exceptionsHandler);
  });
  test(
      'Should return CEPFailure when the DataSource throw an unexpected exception',
      () async {
    // Arrange
    const tErrorMessage = 'Unexpected error';
    final tException = Exception(tErrorMessage);
    when(() => dataSourceSpy.getLocationByCEP(tParameters))
        .thenThrow(tException);
    when(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    ).thenAnswer(
      (_) async => Left(CEPFailure(message: tException.toString())),
    );

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
    verify(
      () => exceptionsHandler.handleException<Location>(
        tException,
        onExceptionMismatch: any(named: 'onExceptionMismatch'),
      ),
    );
    verifyNoMoreInteractions(dataSourceSpy);
    verifyNoMoreInteractions(exceptionsHandler);
  });
}
