import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import '../utils/result.dart';

class DioClient {
  DioClient({
    String? baseUrl,
    Duration timeout = const Duration(seconds: 20),
    Map<String, String>? headers,
    Dio? dio,
  }) : dio = dio ?? Dio(_options(baseUrl, timeout, headers)) {
    this.dio.interceptors.add(_RetryInterceptor(this.dio));
    if (kDebugMode) {
      this.dio.interceptors.add(
            LogInterceptor(
              requestBody: false,
              responseBody: false,
              requestHeader: false,
              responseHeader: false,
            ),
          );
    }
  }

  final Dio dio;

  static BaseOptions _options(
    String? baseUrl,
    Duration timeout,
    Map<String, String>? headers,
  ) {
    return BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
        'Accept': 'application/json, text/xml;q=0.9, */*;q=0.8',
        ...?headers,
      },
    );
  }

  Future<Result<T>> safeRequest<T>(Future<T> Function(Dio dio) request) async {
    try {
      return Success(await request(dio));
    } on DioException catch (error) {
      return Error(_mapDioException(error).toFailure());
    } on AppException catch (error) {
      return Error(error.toFailure());
    } catch (error) {
      return Error(
          UnknownException(error.toString(), details: error).toFailure());
    }
  }

  static AppException _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        RequestTimeoutException('Request timed out', details: error),
      DioExceptionType.badResponse => BadResponseException(
          'Provider returned HTTP ${error.response?.statusCode}',
          details: error,
        ),
      DioExceptionType.connectionError => NetworkException(
          'Network connection failed',
          details: error,
        ),
      _ =>
        UnknownException(error.message ?? 'Unknown HTTP error', details: error),
    };
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const _maxAttempts = 2;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['retryAttempt'] as int?) ?? 0;
    if (!_shouldRetry(err) || attempt >= _maxAttempts) {
      handler.next(err);
      return;
    }

    final delayMs = 350 * pow(2, attempt).toInt();
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    try {
      final options = err.requestOptions;
      options.extra['retryAttempt'] = attempt + 1;
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  bool _shouldRetry(DioException error) {
    final status = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        status == 429 ||
        (status != null && status >= 500);
  }
}
