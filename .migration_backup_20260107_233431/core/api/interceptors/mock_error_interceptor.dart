import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';

/// A mock implementation of [ErrorInterceptor] for testing
class MockErrorInterceptor extends ErrorInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
