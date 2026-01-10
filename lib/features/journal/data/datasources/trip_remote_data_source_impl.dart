import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';

/// Implementation of [TripRemoteDataSource] using Supabase
class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final SupabaseClient _client;

  TripRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    try {
      final response =
          await _client.from('trips').insert(trip.toJson()).select().single();

      return TripModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to create trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create trip: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TripModel> getTrip(String tripId) async {
    try {
      final response =
          await _client.from('trips').select().eq('id', tripId).single();

      return TripModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '404' || e.code == 'PGRST116') {
        throw const ServerException(
          message: 'Trip not found',
          statusCode: 404,
        );
      }
      throw ServerException(
        message: 'Failed to get trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get trip: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TripModel>> getTrips() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final response = await _client
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get trips: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get trips: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TripModel>> getTripsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final response = await _client
          .from('trips')
          .select()
          .eq('user_id', userId)
          .gte('start_date', startDate.toIso8601String())
          .lte('start_date', endDate.toIso8601String())
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get trips by date range: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get trips by date range: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TripModel>> getOngoingTrips() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('trips')
          .select()
          .eq('user_id', userId)
          .or('end_date.is.null,end_date.gte.$now')
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get ongoing trips: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get ongoing trips: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    try {
      final response = await _client
          .from('trips')
          .update(trip.toJson())
          .eq('id', trip.id)
          .select()
          .single();

      return TripModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update trip: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      await _client.from('trips').delete().eq('id', tripId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete trip: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<int> getEntryCountForTrip(String tripId) async {
    try {
      final response = await _client
          .from('journal_entries')
          .select('id', count: CountOption.exact)
          .eq('trip_id', tripId);

      return response.count ?? 0;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get entry count: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entry count: $e',
        statusCode: 500,
      );
    }
  }
}
