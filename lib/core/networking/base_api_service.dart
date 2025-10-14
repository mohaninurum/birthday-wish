import 'network_api_service.dart';

abstract interface class BaseApiService {
  ResultFuture getGetApiResponse(String serviceUrl, Map<String, dynamic> body);
  ResultFuture PostGetApiResponse(String serviceUrl, Map<String, dynamic> body);
  ResultFuture PutGetApiResponse(String serviceUrl, Map<String, dynamic> body);
}
