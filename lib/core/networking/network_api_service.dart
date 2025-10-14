import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../errors/app_exceptions.dart';
import 'base_api_service.dart';

typedef ResultFuture<T> = Future<Either<AppException, T>>;

class NetworkApiService implements BaseApiService {
  @override
  ResultFuture PostGetApiResponse(String url, Map<String, dynamic> body) async {
    if (kDebugMode) {
      print("post API call....");
      print(url);
      print(body);
    }
    final dynamic responseJson;
    try {
      final token = body.containsKey('auth') ? body['auth'] : '';
      final response = await http
          .post(Uri.parse(url),
          headers: token.isEmpty
              ? {
            'Content-Type': 'application/json; charset=UTF-8',
          }
              : {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
          .timeout(const Duration(seconds: 60));
      responseJson = _returnResponse(response, false, '', url);

      print("responseJson=====>${responseJson}");
    } on SocketException {

      throw const Left(NoInternetException('NoInternetException [0]'));
    } on TimeoutException {

      throw const Left(FetchDataException('Network Request time out[408]'));
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  @override
  ResultFuture getGetApiResponse(String url, Map<String, dynamic> body) async {
    if (kDebugMode) {
      print(url);
      print(body);
    }
    final dynamic responseJson;
    try {
      final token = body.containsKey('auth') ? body['auth'] : '';
      final response = await http
          .get(Uri.parse(url),
          headers: token.isEmpty
              ? {
            'Content-Type': 'application/json; charset=UTF-8',
          }
              : {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          })
          .timeout(const Duration(seconds: 60));
      responseJson = _returnResponse(response, false, '', url);
    } on SocketException {

      throw const Left(NoInternetException('NoInternetException [0]'));
    } on TimeoutException {

      throw const Left(FetchDataException('Network Request time out[408]'));
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  Either<AppException, T> _returnResponse<T>(http.Response response, bool isMultipart, String sessionToken, String url) {
    if (kDebugMode) {
      print(response.statusCode);
    }
    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);
        return Right(responseJson);
      case 201:
        final responseJson = jsonDecode(response.body);

        return Right(responseJson);
      case 401:
        final responseJson = jsonDecode(response.body);
        return Right(responseJson);
      case 400:
        final responseJson = jsonDecode(response.body);
        return Right(responseJson);
      case 500:

        throw Left(InternalServerException(response.body.toString().length < 160 ? response.body.toString() : '${response.reasonPhrase}'));
      case 404:
        final responseJson = jsonDecode(response.body);
        return Right(responseJson);
      default:

        throw const Left(FetchDataException('Error occured while communicating with server')); //// isMultipart ? response.body : jsonDecode(response.body);
    }
  }


  @override
  ResultFuture PutGetApiResponse(String url, Map<String, dynamic> body) async {
    if (kDebugMode) {
      print("post API call....");
      print(url);
      print(body);
    }
    final dynamic responseJson;
    try {
      final token = body.containsKey('auth') ? body['auth'] : '';
      final response = await http
          .put(Uri.parse(url),
          headers: token.isEmpty
              ? {
            'Content-Type': 'application/json; charset=UTF-8',
          }
              : {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
          .timeout(const Duration(seconds: 60));
      responseJson = _returnResponse(response, false, '', url);

      print("responseJson=====>${responseJson}");
    } on SocketException {

      throw const Left(NoInternetException('NoInternetException [0]'));
    } on TimeoutException {

      throw const Left(FetchDataException('Network Request time out[408]'));
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }
}
