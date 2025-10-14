

class AppException   implements Exception {
  final String? message;

  final dynamic prefix;

  const AppException([this.message, this.prefix]);

  @override
  String toString() {
    return '$message$prefix';
  }

  @override
  List<Object?> get props => [message, prefix];
}

class FetchDataException extends AppException {
  const FetchDataException([String? message])
      : super(message, 'Error During Communication');
}

class InternalServerException extends AppException {
  const InternalServerException([String? message, dynamic status])
      : super(
    message,
    'Internal server error [500]',
  );
}

class BadRequestException extends AppException {
  const BadRequestException([String? message])
      : super(message, 'Invalid request [400]');
}

class UnauthorisedException extends AppException {
  const UnauthorisedException([String? message])
      : super(message, 'Unauthorised request [404]');
}

class InvalidInputException extends AppException {
  const InvalidInputException([String? message])
      : super(message, 'Invalid Input');
}

class NoInternetException extends AppException {
  const NoInternetException([String? message])
      : super(message, 'Communication issue');
}

class APIException implements Exception {
  const APIException({required this.message, required this.statusCode});
  final String message;
  final dynamic statusCode;


}

class ServerException  implements Exception {
  const ServerException({required this.message, required this.statusCode});
  final String message;
  final dynamic statusCode;

}

class CacheException implements Exception {
  const CacheException({required this.message});
  final String message;

}
