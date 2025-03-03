import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#get, [
        path
      ], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future.value(Response(
        requestOptions: RequestOptions(path: path),
        data: null,
      )),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#put, [
        path
      ], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onSendProgress: onSendProgress,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future.value(Response(
        requestOptions: RequestOptions(path: path),
        data: null,
      )),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#post, [
        path
      ], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onSendProgress: onSendProgress,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future.value(Response(
        requestOptions: RequestOptions(path: path),
        data: null,
      )),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return super.noSuchMethod(
      Invocation.method(#delete, [
        path
      ], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
      }),
      returnValue: Future.value(Response(
        requestOptions: RequestOptions(path: path),
        data: null,
      )),
    ) as Future<Response<T>>;
  }
}
