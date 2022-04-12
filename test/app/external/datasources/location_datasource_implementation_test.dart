import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viacep/app/domain/entities/location.dart';
import 'package:viacep/app/domain/parameters/get_location_by_cep_parameters.dart';
import 'package:viacep/app/external/datasources/location_datasource_implementation.dart';
import 'package:viacep/app/infrastructure/datasources/location_datasource.dart';
import 'package:viacep/app/infrastructure/mappers/location_mapper.dart';
import 'package:viacep/core/endpoints/viacep_endpoints.dart';
import 'package:viacep/core/packages/http_client/abstraction/http_client.dart';
import 'package:viacep/core/packages/http_client/entities/http_response.dart';

import '../../../test_utils/mock_parser.dart';
import '../../../test_utils/mocks_path.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late HttpClient httpClientSpy;
  late LocationDataSource dataSource;
  const tParameters = GetLocationByCEPParameters(cep: '01001000');
  final tLocation = LocationMapper.fromJSON(
    MockParser.convertJsonToString(
      MocksPaths.getLocationByCEP,
    ),
  );
  final tEndpoint = ViaCEPEndpoints.getLocationByCEP(tParameters.cep);

  setUp(() {
    httpClientSpy = HttpClientSpy();
    dataSource = LocationDataSourceImplementation(httpClientSpy);
  });

  test(
      'LocationDataSourceImplementation should respect LocationDataSource abstraction',
      () {
    // Assert
    expect(dataSource, isA<LocationDataSource>());
  });

  test('Should return Location if the status code is 200', () async {
    // Arrange
    when(() => httpClientSpy.get(tEndpoint)).thenAnswer(
      (_) async => HttpResponse(
        url: tEndpoint,
        statusCode: 200,
        data: MockParser.convertJsonToString(
          MocksPaths.getLocationByCEP,
        ),
      ),
    );

    // Act
    final result = await dataSource.getLocationByCEP(tParameters);

    // Assert
    expect(
      result,
      isA<Location>().having(
        (success) => success,
        'Has the expected entity',
        tLocation,
      ),
    );
    verify(() => httpClientSpy.get(tEndpoint));
    verifyNoMoreInteractions(httpClientSpy);
  });
}
