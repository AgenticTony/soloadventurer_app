import 'package:dio/dio.dart' as dio;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';

class ApiService {
  // TODO: Update these URLs with your actual API endpoints when the backend is ready
  static const String _apiUrl = 'https://api.soloadventurer.com/api';
  static const String _graphqlEndpoint =
      'https://api.soloadventurer.com/graphql';

  late final dio.Dio _dio;
  late final GraphQLClient _graphQLClient;
  final AuthService _authService;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() : _authService = AuthService() {
    _initDio();
    _initGraphQLClient();
  }

  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: _apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authService.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  void _initGraphQLClient() {
    final HttpLink httpLink = HttpLink(_graphqlEndpoint);

    final AuthLink authLink = AuthLink(
      getToken: () =>
          _authService.token != null ? 'Bearer ${_authService.token}' : null,
    );

    final Link link = authLink.concat(httpLink);

    _graphQLClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  // REST API methods
  Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<dio.Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<dio.Response> delete(String path) {
    return _dio.delete(path);
  }

  // GraphQL methods
  Future<QueryResult> query(String queryString,
      {Map<String, dynamic>? variables}) {
    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      variables: variables ?? {},
    );

    return _graphQLClient.query(options);
  }

  Future<QueryResult> mutate(String mutationString,
      {Map<String, dynamic>? variables}) {
    final MutationOptions options = MutationOptions(
      document: gql(mutationString),
      variables: variables ?? {},
    );

    return _graphQLClient.mutate(options);
  }

  Future<Stream<QueryResult>> subscribe(String subscriptionString,
      {Map<String, dynamic>? variables}) async {
    final SubscriptionOptions options = SubscriptionOptions(
      document: gql(subscriptionString),
      variables: variables ?? {},
    );

    return _graphQLClient.subscribe(options);
  }
}
