import '../../domain/entities/location.dart';
import '../../domain/parameters/get_location_by_cep_parameters.dart';

abstract class LocationDataSource {
  Future<Location> getLocationByCEP(GetLocationByCEPParameters parameters);
}
