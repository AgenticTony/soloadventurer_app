import 'package:dio/dio.dart';

/// A mock interceptor for testing that passes through all requests,
/// responses, and errors without modification.
///
/// This does NOT extend [AuthInterceptor] to avoid needing an [AuthRepository]
/// dependency. It implements the same pass-through behavior as [Interceptor].
class MockAuthInterceptor extends Interceptor {
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
