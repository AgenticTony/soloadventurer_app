import 'package:soloadventurer/utils/geocoding_service.dart';

/// Example demonstrating GeocodingService usage
///
/// These examples show how to use the geocoding service
/// for searching locations and reverse geocoding.
class GeocodingServiceExample {
  final GeocodingService _geocodingService = GeocodingService.instance;

  /// Example 1: Search for locations by address
  Future<void> searchExample() async {
    try {
      // Search for the Eiffel Tower
      final results = await _geocodingService.searchLocations(
        'Eiffel Tower, Paris',
        limit: 5,
      );

      for (final result in results) {
        print('Found: ${result.name}');
        print('Address: ${result.fullAddress}');
        print('Coordinates: ${result.latitude}, ${result.longitude}');
        print('---');
      }
    } catch (e) {
      print('Error searching: $e');
    }
  }

  /// Example 2: Get address from coordinates (reverse geocoding)
  Future<void> reverseGeocodingExample() async {
    try {
      // Get address for Eiffel Tower coordinates
      final address = await _geocodingService.getAddressFromCoordinates(
        48.8584, // Latitude
        2.2945, // Longitude
      );

      if (address != null) {
        print('Location Name: ${address.name}');
        print('Full Address: ${address.fullAddress}');
        print('City: ${address.locality}');
        print('Country: ${address.country}');
      } else {
        print('No address found for these coordinates');
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
  }

  /// Example 3: Search with error handling
  Future<void> searchWithErrorHandling() async {
    try {
      final results = await _geocodingService.searchLocations(
        'Tokyo Tower, Tokyo',
      );

      if (results.isEmpty) {
        print('No locations found');
      } else {
        print('Found ${results.length} location(s)');
        for (final result in results) {
          print('- ${result.name}');
          print('  ${result.fullAddress}');
        }
      }
    } catch (e) {
      // GeocodingException is thrown on failure
      print('Failed to search: $e');
      // Handle error (show message to user, etc.)
    }
  }

  /// Example 4: Multiple searches
  Future<void> multipleSearches() async {
    final searches = [
      'Statue of Liberty',
      'Golden Gate Bridge',
      'Sydney Opera House',
    ];

    for (final query in searches) {
      print('\nSearching for: $query');
      try {
        final results = await _geocodingService.searchLocations(query);
        if (results.isNotEmpty) {
          final first = results.first;
          print('  Top result: ${first.name}');
          print('  Coordinates: ${first.latitude}, ${first.longitude}');
        }
      } catch (e) {
        print('  Error: $e');
      }
    }
  }

  /// Example 5: Using GeocodingResult data
  Future<void> useResultData() async {
    try {
      final results =
          await _geocodingService.searchLocations('Big Ben, London');

      if (results.isNotEmpty) {
        final location = results.first;

        // Access all available data
        print('Name: ${location.name}');
        print('Street: ${location.street}');
        print('City: ${location.locality}');
        print('State/Province: ${location.administrativeArea}');
        print('Country: ${location.country}');
        print('Postal Code: ${location.postalCode}');
        print('Latitude: ${location.latitude}');
        print('Longitude: ${location.longitude}');

        // Convert to JSON for storage
        final json = location.toJson();
        print('JSON: $json');

        // Create copy with modified data
        final modified = location.copyWith(
          name: 'Big Ben, London, UK',
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

/// Example usage in main function
void main() async {
  final example = GeocodingServiceExample();

  print('=== Geocoding Service Examples ===\n');

  print('Example 1: Search for locations');
  await example.searchExample();

  print('\nExample 2: Reverse geocoding');
  await example.reverseGeocodingExample();

  print('\nExample 3: Search with error handling');
  await example.searchWithErrorHandling();

  print('\nExample 4: Multiple searches');
  await example.multipleSearches();

  print('\nExample 5: Using result data');
  await example.useResultData();
}
