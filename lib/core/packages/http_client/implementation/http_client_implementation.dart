import 'package:http/http.dart' as http;

import '../abstraction/http_client.dart';
import '../entities/http_response.dart';
import '../exceptions/no_internet_connection_exception.dart';
import '../exceptions/server_exception.dart';
import '../mixins/active_connection_verifier.dart';

class HttpClientImplementation
    with ActiveNetworkVerifier
    implements HttpClient {
  final http.Client httpClient;

  const HttpClientImplementation(this.httpClient);

  @override
  Future<HttpResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    if (await hasActiveNetwork) {
      try {
        final response = await httpClient.get(Uri.parse(url), headers: headers);

        return HttpResponse(
          url: url,
          data: response.body,
          statusCode: response.statusCode,
        );
      } catch (exception) {
        throw ServerException(data: exception.toString());
      }
    }

    throw const NoInternetConnectionException();
  }

  @override
  Future<HttpResponse> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    if (await hasActiveNetwork) {
      try {
        final response = await httpClient.post(
          Uri.parse(url),
          body: body,
          headers: headers,
        );

        return HttpResponse(
          url: url,
          data: response.body,
          statusCode: response.statusCode,
        );
      } catch (exception) {
        throw ServerException(data: exception.toString());
      }
    }

    throw const NoInternetConnectionException();
  }
}
