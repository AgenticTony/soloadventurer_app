import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/cache/memory_cache.dart';
import 'package:soloadventurer/core/config/viator_config.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

import 'viator_service.dart';

part 'viator_service_impl.g.dart';

/// Real implementation of [ViatorService] using Viator Transactional API.
///
/// Uses the v1 REST endpoints with API-key authentication.
/// Responses are cached in memory to stay within rate limits.
class ViatorServiceImpl implements ViatorService {
  final Dio _dio;
  final String _apiKey;

  /// Cache for product search results.
  final MemoryCache<String, ViatorSearchResult> _searchCache;

  /// Cache for product details.
  final MemoryCache<String, ViatorProductDetail> _detailsCache;

  /// Cache for availability checks.
  final MemoryCache<String, List<ViatorAvailability>> _availabilityCache;

  /// Cache for destination lookups.
  final MemoryCache<String, List<ViatorDestination>> _destinationCache;

  static const _baseUrl = 'https://api.viator.com/v1';

  /// Creates a [ViatorServiceImpl].
  ///
  /// Optionally accepts a [dio] instance and [apiKey] for testing.
  /// When [apiKey] is not provided, reads from [ViatorConfig].
  ViatorServiceImpl({Dio? dio, String? apiKey})
      : _apiKey = apiKey ?? ViatorConfig.apiKey,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            )),
        _searchCache = MemoryCache<String, ViatorSearchResult>(
          config: const MemoryCacheConfig(
            maxSize: 50,
            defaultTtl: Duration(minutes: 30),
          ),
        ),
        _detailsCache = MemoryCache<String, ViatorProductDetail>(
          config: const MemoryCacheConfig(
            maxSize: 100,
            defaultTtl: Duration(hours: 2),
          ),
        ),
        _availabilityCache = MemoryCache<String, List<ViatorAvailability>>(
          config: const MemoryCacheConfig(
            maxSize: 50,
            defaultTtl: Duration(minutes: 10),
          ),
        ),
        _destinationCache = MemoryCache<String, List<ViatorDestination>>(
          config: const MemoryCacheConfig(
            maxSize: 50,
            defaultTtl: Duration(hours: 24),
          ),
        );

  /// Common headers for Viator API.
  Map<String, String> get _headers => {
        'exp-api-key': _apiKey,
        'Accept': 'application/json',
        'Accept-Language': 'en-US',
      };

  // ---------------------------------------------------------------------------
  // Product endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ViatorSearchResult> searchProducts({
    required String destinationId,
    ViatorSearchFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    if (_apiKey.isEmpty) {
      return const ViatorSearchResult(products: [], totalCount: 0, hasMore: false);
    }

    final cacheKey = 'search:$destinationId:${filter?.query ?? ""}:$page:$limit';
    final cached = _searchCache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/products/bulk',
        data: {
          'destId': destinationId,
          'currency': 'USD',
          'language': 'en',
          'page': page,
          'limit': limit,
          if (filter?.query != null) 'text': filter!.query,
          if (filter?.category != null) 'filter': {'categories': [filter!.category]},
          if (filter?.minPrice != null)
            'priceFilter': {
              'from': filter!.minPrice,
              'to': filter.maxPrice,
            },
          if (filter?.minRating != null) 'rating': filter!.minRating,
        },
        options: Options(headers: _headers),
      );

      final result = _parseSearchResponse(response.data);
      await _searchCache.put(cacheKey, result);
      return result;
    } on DioException catch (_) {
      return const ViatorSearchResult(products: [], totalCount: 0, hasMore: false);
    }
  }

  @override
  Future<ViatorProductDetail?> getProductDetails(String productCode) async {
    if (_apiKey.isEmpty) return null;

    final cacheKey = 'details:$productCode';
    final cached = _detailsCache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/products/$productCode',
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return null;

      final detail = _parseProductDetail(data);
      if (detail != null) {
        await _detailsCache.put(cacheKey, detail);
      }
      return detail;
    } on DioException catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Availability endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<List<ViatorAvailability>> checkAvailability({
    required String productCode,
    required DateTime date,
  }) async {
    if (_apiKey.isEmpty) return [];

    final dateStr = _formatDate(date);
    final cacheKey = 'avail:$productCode:$dateStr';
    final cached = _availabilityCache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/availability/check',
        data: {
          'productCode': productCode,
          'travelDate': dateStr,
          'currency': 'USD',
          'language': 'en',
        },
        options: Options(headers: _headers),
      );

      final result = _parseAvailability(response.data);
      await _availabilityCache.put(cacheKey, result);
      return result;
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, List<DateTime>>> getAvailabilitySchedules({
    required List<String> productCodes,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_apiKey.isEmpty) return {};

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/availability/schedules/bulk',
        data: {
          'productCodes': productCodes,
          'startDate': _formatDate(startDate),
          'endDate': _formatDate(endDate),
          'currency': 'USD',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return {};

      final result = <String, List<DateTime>>{};
      final schedules = data['schedules'] as Map<String, dynamic>?;
      if (schedules != null) {
        for (final entry in schedules.entries) {
          final dates = (entry.value as List<dynamic>)
              .map((d) => DateTime.tryParse(d.toString()) ?? DateTime.now())
              .toList();
          result[entry.key] = dates;
        }
      }
      return result;
    } on DioException catch (_) {
      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // Booking endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ViatorBookingHold?> holdBooking({
    required String productCode,
    required ViatorAvailability availability,
    required int travelerCount,
  }) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/bookings/cart/hold',
        data: {
          'productCode': productCode,
          'availabilityId': availability.id,
          'travelDate': _formatDate(availability.startTime),
          'travelerCount': travelerCount,
          'currency': 'USD',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return null;

      return ViatorBookingHold(
        holdToken: data['holdToken'] as String? ?? '',
        expiresAt: DateTime.tryParse(data['expiresAt']?.toString() ?? '') ??
            DateTime.now().add(const Duration(minutes: 30)),
        pricePerTraveler:
            (data['pricePerTraveler'] as num?)?.toDouble() ?? availability.price,
        totalPrice: (data['totalPrice'] as num?)?.toDouble() ??
            availability.price * travelerCount,
        currency: data['currency'] as String? ?? 'USD',
      );
    } on DioException catch (_) {
      return null;
    }
  }

  @override
  Future<ViatorBooking?> bookBooking({
    required String holdToken,
    required List<ViatorTravelerDetail> travelerDetails,
  }) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/bookings/cart/book',
        data: {
          'holdToken': holdToken,
          'travelers': travelerDetails
              .map((t) => {
                    'firstName': t.firstName,
                    'lastName': t.lastName,
                    'email': t.email,
                    if (t.phone != null) 'phone': t.phone,
                    if (t.questionAnswers.isNotEmpty)
                      'questionAnswers': t.questionAnswers,
                  })
              .toList(),
        },
        options: Options(headers: _headers),
      );

      return _parseBooking(response.data);
    } on DioException catch (_) {
      return null;
    }
  }

  @override
  Future<ViatorBooking?> getBookingStatus(String bookingRef) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/bookings/status',
        queryParameters: {'bookingRef': bookingRef},
        options: Options(headers: _headers),
      );

      return _parseBooking(response.data);
    } on DioException catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Booking management endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ViatorCancelQuote?> getCancelQuote(String bookingRef) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/bookings/$bookingRef/cancel-quote',
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return null;

      return ViatorCancelQuote(
        bookingRef: bookingRef,
        refundAmount: (data['refundAmount'] as num?)?.toDouble() ?? 0.0,
        currency: data['currency'] as String? ?? 'USD',
        cancellationFee: (data['cancellationFee'] as num?)?.toDouble() ?? 0.0,
        feeReason: data['feeReason'] as String?,
      );
    } on DioException catch (_) {
      return null;
    }
  }

  @override
  Future<ViatorBooking?> cancelBooking({
    required String bookingRef,
    required String reasonCode,
  }) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/bookings/$bookingRef/cancel',
        data: {'reasonCode': reasonCode},
        options: Options(headers: _headers),
      );

      return _parseBooking(response.data);
    } on DioException catch (_) {
      return null;
    }
  }

  @override
  Future<List<ViatorCancelReason>> getCancelReasons() async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/bookings/cancel-reasons',
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      final reasons = data['reasons'] as List<dynamic>? ?? [];
      return reasons
          .cast<Map<String, dynamic>>()
          .map((r) => ViatorCancelReason(
                code: r['code'] as String? ?? '',
                description: r['description'] as String? ?? '',
              ))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Destination search
  // ---------------------------------------------------------------------------

  @override
  Future<List<ViatorDestination>> searchDestinations(String query) async {
    if (_apiKey.isEmpty) return [];

    final cacheKey = 'dest:$query';
    final cached = _destinationCache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/destinations/search',
        data: {
          'searchTerm': query,
          'language': 'en',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      final destinations = (data['destinations'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map((d) => ViatorDestination(
                id: d['destId']?.toString() ?? '',
                name: d['name'] as String? ?? '',
                countryCode: d['countryCode'] as String? ?? '',
                type: d['destinationType'] as String? ?? '',
              ))
          .toList();

      await _destinationCache.put(cacheKey, destinations);
      return destinations;
    } on DioException catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  @override
  Future<List<ViatorReview>> getProductReviews(
    String productCode, {
    int page = 1,
    int limit = 10,
  }) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/products/$productCode/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
          'language': 'en',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      final reviews = data['reviews'] as List<dynamic>? ?? [];
      return reviews
          .cast<Map<String, dynamic>>()
          .map((r) => ViatorReview(
                id: r['reviewId']?.toString() ?? '',
                author: r['authorName'] as String? ?? 'Anonymous',
                rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
                text: r['text'] as String? ?? '',
                date: DateTime.tryParse(r['date']?.toString() ?? '') ??
                    DateTime.now(),
                soloTraveler: r['soloTraveler'] as bool?,
              ))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Sync endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<List<PlaceActivity>> getModifiedProducts(DateTime since) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/products/modified-since',
        data: {
          'since': since.toUtc().toIso8601String(),
          'currency': 'USD',
          'language': 'en',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      return (data['products'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(_parseProductToPlaceActivity)
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<List<PlaceActivity>> searchSupplierProducts({
    required String supplierId,
    List<String>? productCodes,
  }) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/suppliers/search/product-codes',
        data: {
          'supplierId': supplierId,
          if (productCodes != null) 'productCodes': productCodes,
          'currency': 'USD',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      return (data['products'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(_parseProductToPlaceActivity)
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, List<DateTime>>> getModifiedSchedules(DateTime since) async {
    if (_apiKey.isEmpty) return {};

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/availability/schedules/modified-since',
        data: {
          'since': since.toUtc().toIso8601String(),
          'currency': 'USD',
        },
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return {};

      final result = <String, List<DateTime>>{};
      final schedules = data['schedules'] as Map<String, dynamic>?;
      if (schedules != null) {
        for (final entry in schedules.entries) {
          final dates = (entry.value as List<dynamic>)
              .map((d) => DateTime.tryParse(d.toString()) ?? DateTime.now())
              .toList();
          result[entry.key] = dates;
        }
      }
      return result;
    } on DioException catch (_) {
      return {};
    }
  }

  @override
  Future<List<ViatorBookingQuestion>> getBookingQuestions(String productCode) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/products/$productCode/booking-questions',
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      final questions = data['questions'] as List<dynamic>? ?? [];
      return questions
          .cast<Map<String, dynamic>>()
          .map((q) => ViatorBookingQuestion(
                id: q['id'] as String? ?? '',
                question: q['question'] as String? ?? '',
                required: q['required'] as bool? ?? false,
                inputType: q['inputType'] as String? ?? 'text',
                options: (q['options'] as List<dynamic>?)
                    ?.cast<String>()
                    .toList(),
              ))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<List<ViatorBooking>> getModifiedBookings(DateTime since) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/bookings/modified-since',
        queryParameters: {'since': since.toUtc().toIso8601String()},
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data == null) return [];

      final bookings = data['bookings'] as List<dynamic>? ?? [];
      return bookings
          .cast<Map<String, dynamic>>()
          .map(_parseBooking)
          .where((b) => b != null)
          .cast<ViatorBooking>()
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<void> acknowledgeBookingChanges(List<String> bookingRefs) async {
    if (_apiKey.isEmpty || bookingRefs.isEmpty) return;

    try {
      await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/bookings/acknowledge',
        data: {'bookingRefs': bookingRefs},
        options: Options(headers: _headers),
      );
    } on DioException catch (_) {
    // intentional silent catch
    }
  }

  // ---------------------------------------------------------------------------
  // Response parsing
  // ---------------------------------------------------------------------------

  ViatorSearchResult _parseSearchResponse(Map<String, dynamic>? data) {
    if (data == null) {
      return const ViatorSearchResult(products: [], totalCount: 0, hasMore: false);
    }

    final products = (data['products'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(_parseProductToPlaceActivity)
        .toList();

    final totalCount = data['totalCount'] as int? ?? 0;
    final hasMore = (data['hasMore'] as bool?) ??
        (products.length >= 20 && totalCount > products.length);

    return ViatorSearchResult(
      products: products,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }

  PlaceActivity _parseProductToPlaceActivity(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    String? imageUrl;
    if (images.isNotEmpty) {
      final firstImage = images[0] as Map<String, dynamic>;
      final variants = firstImage['variants'] as List<dynamic>? ?? [];
      if (variants.isNotEmpty) {
        final mediumVariant = variants.cast<Map<String, dynamic>>().firstWhere(
              (v) => v['width'] == 640,
              orElse: () => variants.first as Map<String, dynamic>,
            );
        imageUrl = mediumVariant['url'] as String?;
      } else {
        imageUrl = firstImage['url'] as String?;
      }
    }

    final pricing = json['pricing'] as Map<String, dynamic>?;

    return PlaceActivity(
      id: json['productCode'] as String? ?? '',
      name: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: _mapViatorCategory(json['primaryCategory'] as String?),
      cost: (pricing?['fromPrice'] as num?)?.toDouble(),
      rating: (json['reviews'] as Map<String, dynamic>?)?['combinedNumericRating']
              as double? ??
          0.0,
      reviewCount:
          ((json['reviews'] as Map<String, dynamic>?)?['totalReviews'] as num?)
                  ?.toInt() ??
              0,
      photoUrl: imageUrl,
      bookingUrl: json['webUrl'] as String?,
    );
  }

  ViatorProductDetail? _parseProductDetail(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    final imageUrls = images
        .map((img) {
          final variants = img['variants'] as List<dynamic>? ?? [];
          return variants.isNotEmpty
              ? variants[0]['url'] as String?
              : img['url'] as String?;
        })
        .where((url) => url != null)
        .cast<String>()
        .toList();

    final pricing = json['pricing'] as Map<String, dynamic>?;
    final reviews = json['reviews'] as Map<String, dynamic>?;

    return ViatorProductDetail(
      productCode: json['productCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: imageUrls,
      price: (pricing?['fromPrice'] as num?)?.toDouble() ?? 0.0,
      currency: pricing?['currency'] as String? ?? 'USD',
      duration: json['duration'] as String? ?? '',
      category: _mapViatorCategory(json['primaryCategory'] as String?),
      rating:
          reviews?['combinedNumericRating'] as double? ?? 0.0,
      reviewCount: (reviews?['totalReviews'] as num?)?.toInt() ?? 0,
      cancellationPolicy: json['cancellationPolicy'] as String? ?? '',
      freeCancellation: json['freeCancellation'] as bool? ?? false,
      webUrl: json['webUrl'] as String?,
    );
  }

  List<ViatorAvailability> _parseAvailability(Map<String, dynamic>? data) {
    if (data == null) return [];

    final slots = data['availability'] as List<dynamic>? ?? [];
    return slots.cast<Map<String, dynamic>>().map((slot) {
      return ViatorAvailability(
        id: slot['id'] as String? ?? '',
        startTime: DateTime.tryParse(slot['startTime']?.toString() ?? '') ??
            DateTime.now(),
        endTime: DateTime.tryParse(slot['endTime']?.toString() ?? '') ??
            DateTime.now().add(const Duration(hours: 3)),
        price: (slot['price'] as num?)?.toDouble() ?? 0.0,
        currency: slot['currency'] as String? ?? 'USD',
        spotsRemaining: slot['spotsRemaining'] as int?,
        bookable: slot['bookable'] as bool? ?? false,
      );
    }).toList();
  }

  ViatorBooking? _parseBooking(Map<String, dynamic>? data) {
    if (data == null) return null;

    return ViatorBooking(
      bookingRef: data['bookingRef'] as String? ?? '',
      productCode: data['productCode'] as String? ?? '',
      productTitle: data['productTitle'] as String? ?? '',
      status: ViatorBookingStatus.fromString(
          data['status'] as String? ?? 'UNKNOWN'),
      travelDate: DateTime.tryParse(data['travelDate']?.toString() ?? '') ??
          DateTime.now(),
      travelerCount: data['travelerCount'] as int? ?? 1,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'USD',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      cancellationDeadline:
          data['cancellationDeadline'] != null
              ? DateTime.tryParse(data['cancellationDeadline'].toString())
              : null,
      confirmationUrl: data['confirmationUrl'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _mapViatorCategory(String? category) {
    if (category == null) return 'activity';
    final lower = category.toLowerCase();
    if (lower.contains('tour')) return 'tour';
    if (lower.contains('food') || lower.contains('cooking')) return 'food';
    if (lower.contains('adventure') || lower.contains('sport')) return 'adventure';
    if (lower.contains('transfer') || lower.contains('transport')) return 'transport';
    if (lower.contains('ticket') || lower.contains('attraction')) return 'attraction';
    if (lower.contains('class') || lower.contains('workshop')) return 'class';
    if (lower.contains('cruise') || lower.contains('boat')) return 'cruise';
    return 'activity';
  }
}

/// Provider for ViatorServiceImpl.
@riverpod
ViatorService viatorServiceImpl(Ref ref) {
  return ViatorServiceImpl();
}
