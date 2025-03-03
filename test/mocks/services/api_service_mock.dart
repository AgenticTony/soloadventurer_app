import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:graphql_flutter/graphql_flutter.dart' hide Response;

/// A mock implementation of [dio.Dio] for testing REST API calls.
class MockDio extends Mock implements dio.Dio {
  /// Sets up the mock for a successful GET request.
  void setupSuccessfulGet(String path, Map<String, dynamic> responseData,
      {Map<String, dynamic>? queryParameters}) {
    when(() => get(
          path,
          queryParameters: queryParameters ?? any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => dio.Response(
          data: responseData,
          statusCode: 200,
          requestOptions: dio.RequestOptions(path: path),
        ));
  }

  /// Sets up the mock for a failed GET request.
  void setupFailedGet(String path, int statusCode, String errorMessage,
      {Map<String, dynamic>? queryParameters}) {
    when(() => get(
          path,
          queryParameters: queryParameters ?? any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(dio.DioException(
      requestOptions: dio.RequestOptions(path: path),
      response: dio.Response(
        data: {'message': errorMessage},
        statusCode: statusCode,
        requestOptions: dio.RequestOptions(path: path),
      ),
      type: dio.DioExceptionType.badResponse,
      message: errorMessage,
    ));
  }

  /// Sets up the mock for a successful POST request.
  void setupSuccessfulPost(String path, Map<String, dynamic> responseData,
      {Map<String, dynamic>? data}) {
    when(() => post(
          path,
          data: data ?? any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => dio.Response(
          data: responseData,
          statusCode: 200,
          requestOptions: dio.RequestOptions(path: path),
        ));
  }

  /// Sets up the mock for a failed POST request.
  void setupFailedPost(String path, int statusCode, String errorMessage,
      {Map<String, dynamic>? data}) {
    when(() => post(
          path,
          data: data ?? any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(dio.DioException(
      requestOptions: dio.RequestOptions(path: path),
      response: dio.Response(
        data: {'message': errorMessage},
        statusCode: statusCode,
        requestOptions: dio.RequestOptions(path: path),
      ),
      type: dio.DioExceptionType.badResponse,
      message: errorMessage,
    ));
  }

  /// Sets up the mock for a successful PUT request.
  void setupSuccessfulPut(String path, Map<String, dynamic> responseData,
      {Map<String, dynamic>? data}) {
    when(() => put(
          path,
          data: data ?? any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => dio.Response(
          data: responseData,
          statusCode: 200,
          requestOptions: dio.RequestOptions(path: path),
        ));
  }

  /// Sets up the mock for a failed PUT request.
  void setupFailedPut(String path, int statusCode, String errorMessage,
      {Map<String, dynamic>? data}) {
    when(() => put(
          path,
          data: data ?? any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(dio.DioException(
      requestOptions: dio.RequestOptions(path: path),
      response: dio.Response(
        data: {'message': errorMessage},
        statusCode: statusCode,
        requestOptions: dio.RequestOptions(path: path),
      ),
      type: dio.DioExceptionType.badResponse,
      message: errorMessage,
    ));
  }

  /// Sets up the mock for a successful DELETE request.
  void setupSuccessfulDelete(String path, Map<String, dynamic> responseData) {
    when(() => delete(
          path,
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => dio.Response(
          data: responseData,
          statusCode: 200,
          requestOptions: dio.RequestOptions(path: path),
        ));
  }

  /// Sets up the mock for a failed DELETE request.
  void setupFailedDelete(String path, int statusCode, String errorMessage) {
    when(() => delete(
          path,
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(dio.DioException(
      requestOptions: dio.RequestOptions(path: path),
      response: dio.Response(
        data: {'message': errorMessage},
        statusCode: statusCode,
        requestOptions: dio.RequestOptions(path: path),
      ),
      type: dio.DioExceptionType.badResponse,
      message: errorMessage,
    ));
  }
}

/// A mock implementation of [GraphQLClient] for testing GraphQL API calls.
class MockGraphQLClient extends Mock implements GraphQLClient {
  /// Sets up the mock for a successful query.
  void setupSuccessfulQuery(
      String queryName, Map<String, dynamic> responseData) {
    when(() => query(any())).thenAnswer((_) async => QueryResult(
          data: responseData,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('')),
        ));
  }

  /// Sets up the mock for a failed query.
  void setupFailedQuery(String queryName, String errorMessage) {
    when(() => query(any())).thenAnswer((_) async => QueryResult(
          data: null,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('')),
          exception: OperationException(
            graphqlErrors: [GraphQLError(message: errorMessage)],
          ),
        ));
  }

  /// Sets up the mock for a successful mutation.
  void setupSuccessfulMutation(
      String mutationName, Map<String, dynamic> responseData) {
    when(() => mutate(any())).thenAnswer((_) async => QueryResult(
          data: responseData,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('')),
        ));
  }

  /// Sets up the mock for a failed mutation.
  void setupFailedMutation(String mutationName, String errorMessage) {
    when(() => mutate(any())).thenAnswer((_) async => QueryResult(
          data: null,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('')),
          exception: OperationException(
            graphqlErrors: [GraphQLError(message: errorMessage)],
          ),
        ));
  }
}
