import 'dart:convert';

import '../../../core/endpoints/viacep_endpoints.dart';
import '../../../core/packages/http_client/abstraction/http_client.dart';
import '../../../core/packages/http_client/exceptions/server_exception.dart';
import '../../domain/entities/location.dart';
import '../../domain/parameters/get_location_by_cep_parameters.dart';
import '../../infrastructure/datasources/location_datasource.dart';
import '../../infrastructure/errors/cep_exceptions.dart';
import '../../infrastructure/mappers/location_mapper.dart';

class LocationDataSourceImplementation implements LocationDataSource {
  final HttpClient httpClient;

  const LocationDataSourceImplementation(this.httpClient);

  @override
  Future<Location> getLocationByCEP(
    GetLocationByCEPParameters parameters,
  ) async {
    final endpoint = ViaCEPEndpoints.getLocationByCEP(parameters.cep);

    final result = await httpClient.get(endpoint);

    switch (result.statusCode) {
      case 200:
        try {
          final Map<String, dynamic> decodedData = jsonDecode(result.data);

          return LocationMapper.fromMap(decodedData);
        } catch (exception) {
          throw UnableToGetLocationUsingCEPException();
        }
      case 400:
        throw InvalidCEPFormatException();
      default:
        throw ServerException(data: '${result.statusCode} - ${result.data}');
    }
  }
}
