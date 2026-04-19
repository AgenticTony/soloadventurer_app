import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/viator_service.dart';
import 'package:soloadventurer/core/services/viator_service_impl.dart';

/// A fake [Dio] that returns canned responses for Viator API endpoints.
class FakeViatorDio implements Dio {
  final Map<String, Map<String, dynamic>> _getResponses;
  final Map<String, Map<String, dynamic>> _postResponses;
  int requestCount = 0;
  final List<String> requestPaths = [];

  FakeViatorDio({
    Map<String, Map<String, dynamic>>? getResponses,
    Map<String, Map<String, dynamic>>? postResponses,
  })  : _getResponses = getResponses ?? {},
        _postResponses = postResponses ?? {};

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    requestCount++;
    requestPaths.add(path);

    final responseData = _getResponses[path];
    if (responseData == null) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        message: 'No fake GET response for $path',
      );
    }

    return Response<T>(
      data: responseData as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    requestCount++;
    requestPaths.add(path);

    final responseData = _postResponses[path];
    if (responseData == null) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        message: 'No fake POST response for $path',
      );
    }

    return Response<T>(
      data: responseData as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  const testApiKey = 'test_viator_key_12345';
  const baseUrl = 'https://api.viator.com/v1';

  const searchProductsResponse = {
    'products': [
      {
        'productCode': '5010SYDNEY',
        'title': 'Sydney Opera House Guided Tour',
        'description': 'Explore the iconic Opera House with an expert guide.',
        'images': [
          {
            'variants': [
              {'url': 'https://example.com/opera.jpg', 'width': 640}
            ],
          },
        ],
        'pricing': {'fromPrice': 42.0, 'currency': 'USD'},
        'duration': '1 hour 30 minutes',
        'primaryCategory': 'Tours & Sightseeing',
        'reviews': {
          'combinedNumericRating': 4.8,
          'totalReviews': 5432,
        },
        'cancellationPolicy': 'Full refund up to 24 hours before.',
        'freeCancellation': true,
        'webUrl': 'https://www.viator.com/tours/5010SYDNEY',
      },
      {
        'productCode': '5015PARIS_EIFFEL',
        'title': 'Eiffel Tower Skip-the-Line Ticket',
        'description': 'Skip the line and go straight to the top.',
        'images': [],
        'pricing': {'fromPrice': 65.0, 'currency': 'USD'},
        'duration': '2 hours',
        'primaryCategory': 'Tickets & Passes',
        'reviews': {
          'combinedNumericRating': 4.5,
          'totalReviews': 2310,
        },
      },
    ],
    'totalCount': 2,
    'hasMore': false,
  };

  const availabilityResponse = {
    'availability': [
      {
        'id': 'avail_001',
        'startTime': '2026-05-15T09:00:00',
        'endTime': '2026-05-15T10:30:00',
        'price': 42.0,
        'currency': 'USD',
        'spotsRemaining': 12,
        'bookable': true,
      },
      {
        'id': 'avail_002',
        'startTime': '2026-05-15T14:00:00',
        'endTime': '2026-05-15T15:30:00',
        'price': 42.0,
        'currency': 'USD',
        'spotsRemaining': 5,
        'bookable': true,
      },
    ],
  };

  const holdResponse = {
    'holdToken': 'hold_abc123',
    'expiresAt': '2026-05-15T12:00:00Z',
    'pricePerTraveler': 42.0,
    'totalPrice': 84.0,
    'currency': 'USD',
  };

  const bookResponse = {
    'bookingRef': 'BR-12345-678',
    'productCode': '5010SYDNEY',
    'productTitle': 'Sydney Opera House Guided Tour',
    'status': 'CONFIRMED',
    'travelDate': '2026-05-15',
    'travelerCount': 2,
    'totalPrice': 84.0,
    'currency': 'USD',
    'createdAt': '2026-04-10T10:00:00Z',
    'cancellationDeadline': '2026-05-14T09:00:00Z',
  };

  const cancelQuoteResponse = {
    'refundAmount': 75.6,
    'cancellationFee': 8.4,
    'currency': 'USD',
    'feeReason': 'Cancellation within 48 hours incurs 10% fee.',
  };

  const cancelReasonsResponse = {
    'reasons': [
      {'code': 'CHANGE_OF_PLANS', 'description': 'I changed my plans'},
      {'code': 'FOUND_CHEAPER', 'description': 'I found a better price'},
      {'code': 'WEATHER', 'description': 'Bad weather'},
    ],
  };

  const destinationsResponse = {
    'destinations': [
      {
        'destId': '737',
        'name': 'Paris',
        'countryCode': 'FR',
        'destinationType': 'CITY',
      },
    ],
  };

  const reviewsResponse = {
    'reviews': [
      {
        'reviewId': 'rev_001',
        'authorName': 'Jane D.',
        'rating': 5.0,
        'text': 'Amazing tour! Great for solo travelers.',
        'date': '2026-03-20',
        'soloTraveler': true,
      },
    ],
  };

  ViatorServiceImpl createService(FakeViatorDio dio) {
    return ViatorServiceImpl(dio: dio, apiKey: testApiKey);
  }

  group('ViatorServiceImpl', () {
    test('searchProducts returns parsed products', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/products/bulk': searchProductsResponse},
      );
      final service = createService(dio);

      final result = await service.searchProducts(destinationId: '737');

      expect(result.products, hasLength(2));
      expect(result.products[0].name, 'Sydney Opera House Guided Tour');
      expect(result.products[0].cost, 42.0);
      expect(result.products[0].rating, 4.8);
      expect(result.products[0].reviewCount, 5432);
      expect(result.products[0].id, '5010SYDNEY');
      expect(result.totalCount, 2);
      expect(result.hasMore, false);
    });

    test('searchProducts returns empty when API key not configured', () async {
      final service = ViatorServiceImpl(
        dio: FakeViatorDio(),
        apiKey: '',
      );

      final result = await service.searchProducts(destinationId: '737');
      expect(result.products, isEmpty);
    });

    test('searchProducts caches results and avoids duplicate calls', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/products/bulk': searchProductsResponse},
      );
      final service = createService(dio);

      // First call.
      await service.searchProducts(destinationId: '737');
      expect(dio.requestCount, 1);

      // Second call with same params should hit cache.
      await service.searchProducts(destinationId: '737');
      expect(dio.requestCount, 1);
    });

    test('checkAvailability returns parsed availability slots', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/availability/check': availabilityResponse},
      );
      final service = createService(dio);

      final slots = await service.checkAvailability(
        productCode: '5010SYDNEY',
        date: DateTime(2026, 5, 15),
      );

      expect(slots, hasLength(2));
      expect(slots[0].price, 42.0);
      expect(slots[0].bookable, true);
      expect(slots[0].spotsRemaining, 12);
    });

    test('holdBooking returns hold token', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/bookings/cart/hold': holdResponse},
      );
      final service = createService(dio);

      final hold = await service.holdBooking(
        productCode: '5010SYDNEY',
        availability: ViatorAvailability(
          id: 'avail_001',
          startTime: _testDate,
          endTime: _testDate,
          price: 42.0,
          bookable: true,
        ),
        travelerCount: 2,
      );

      expect(hold, isNotNull);
      expect(hold!.holdToken, 'hold_abc123');
      expect(hold.totalPrice, 84.0);
    });

    test('bookBooking returns confirmed booking', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/bookings/cart/book': bookResponse},
      );
      final service = createService(dio);

      final booking = await service.bookBooking(
        holdToken: 'hold_abc123',
        travelerDetails: const [
          ViatorTravelerDetail(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
          ),
        ],
      );

      expect(booking, isNotNull);
      expect(booking!.bookingRef, 'BR-12345-678');
      expect(booking.status, ViatorBookingStatus.confirmed);
      expect(booking.totalPrice, 84.0);
      expect(booking.travelerCount, 2);
    });

    test('getCancelQuote returns refund details', () async {
      final dio = FakeViatorDio(
        getResponses: {'$baseUrl/bookings/BR-12345-678/cancel-quote': cancelQuoteResponse},
      );
      final service = createService(dio);

      final quote = await service.getCancelQuote('BR-12345-678');

      expect(quote, isNotNull);
      expect(quote!.refundAmount, 75.6);
      expect(quote.cancellationFee, 8.4);
    });

    test('getCancelReasons returns reason list', () async {
      final dio = FakeViatorDio(
        getResponses: {'$baseUrl/bookings/cancel-reasons': cancelReasonsResponse},
      );
      final service = createService(dio);

      final reasons = await service.getCancelReasons();

      expect(reasons, hasLength(3));
      expect(reasons[0].code, 'CHANGE_OF_PLANS');
      expect(reasons[0].description, 'I changed my plans');
    });

    test('searchDestinations returns parsed destinations', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/destinations/search': destinationsResponse},
      );
      final service = createService(dio);

      final destinations = await service.searchDestinations('Paris');

      expect(destinations, hasLength(1));
      expect(destinations[0].id, '737');
      expect(destinations[0].name, 'Paris');
      expect(destinations[0].countryCode, 'FR');
    });

    test('getProductReviews returns parsed reviews', () async {
      final dio = FakeViatorDio(
        getResponses: {'$baseUrl/products/5010SYDNEY/reviews': reviewsResponse},
      );
      final service = createService(dio);

      final reviews = await service.getProductReviews('5010SYDNEY');

      expect(reviews, hasLength(1));
      expect(reviews[0].author, 'Jane D.');
      expect(reviews[0].rating, 5.0);
      expect(reviews[0].soloTraveler, true);
    });

    test('handles API errors gracefully', () async {
      final dio = FakeViatorDio(); // No responses configured.
      final service = createService(dio);

      // All methods should return empty/null rather than throw.
      final result = await service.searchProducts(destinationId: '737');
      expect(result.products, isEmpty);

      final availability = await service.checkAvailability(
        productCode: 'nonexistent',
        date: DateTime.now(),
      );
      expect(availability, isEmpty);

      final hold = await service.holdBooking(
        productCode: 'nonexistent',
        availability: ViatorAvailability(
          id: 'avail_001',
          startTime: _testDate,
          endTime: _testDate,
          price: 42.0,
          bookable: true,
        ),
        travelerCount: 1,
      );
      expect(hold, isNull);
    });

    test('gracefully handles missing API key', () async {
      final service = ViatorServiceImpl(
        dio: FakeViatorDio(),
        apiKey: '',
      );

      // All methods should return empty/null without crashing.
      expect(
        (await service.searchProducts(destinationId: '737')).products,
        isEmpty,
      );
      expect(
        await service.checkAvailability(
          productCode: 'test',
          date: DateTime.now(),
        ),
        isEmpty,
      );
      expect(
        await service.holdBooking(
          productCode: 'test',
          availability: ViatorAvailability(
            id: 'a',
            startTime: _testDate,
            endTime: _testDate,
            price: 10,
            bookable: true,
          ),
          travelerCount: 1,
        ),
        isNull,
      );
      expect(await service.getProductDetails('test'), isNull);
      expect(await service.searchDestinations('Paris'), isEmpty);
      expect(await service.getProductReviews('test'), isEmpty);
      expect(await service.getCancelReasons(), isEmpty);
    });
  });

  group('Viator Booking Flow', () {
    test('hold → book flow completes successfully', () async {
      // Step 1: Hold
      final holdDio = FakeViatorDio(
        postResponses: {'$baseUrl/bookings/cart/hold': holdResponse},
      );
      final service = createService(holdDio);

      final hold = await service.holdBooking(
        productCode: '5010SYDNEY',
        availability: ViatorAvailability(
          id: 'avail_001',
          startTime: _testDate,
          endTime: _testDate,
          price: 42.0,
          bookable: true,
        ),
        travelerCount: 2,
      );

      expect(hold, isNotNull);
      expect(hold!.holdToken, 'hold_abc123');
      expect(hold.totalPrice, 84.0);

      // Step 2: Book using the hold token
      final bookDio = FakeViatorDio(
        postResponses: {'$baseUrl/bookings/cart/book': bookResponse},
      );
      final bookService = createService(bookDio);

      final booking = await bookService.bookBooking(
        holdToken: hold.holdToken,
        travelerDetails: const [
          ViatorTravelerDetail(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
          ),
          ViatorTravelerDetail(
            firstName: 'Jane',
            lastName: 'Doe',
            email: 'jane@example.com',
          ),
        ],
      );

      expect(booking, isNotNull);
      expect(booking!.bookingRef, 'BR-12345-678');
      expect(booking.status, ViatorBookingStatus.confirmed);
    });

    test('availability check returns correct date slots', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/availability/check': availabilityResponse},
      );
      final service = createService(dio);

      final slots = await service.checkAvailability(
        productCode: '5010SYDNEY',
        date: DateTime(2026, 5, 15),
      );

      expect(slots, hasLength(2));

      // Morning slot
      expect(slots[0].startTime.hour, 9);
      expect(slots[0].endTime.hour, 10);
      expect(slots[0].price, 42.0);
      expect(slots[0].bookable, isTrue);
      expect(slots[0].spotsRemaining, 12);

      // Afternoon slot
      expect(slots[1].startTime.hour, 14);
      expect(slots[1].endTime.hour, 15);
      expect(slots[1].spotsRemaining, 5);
    });

    test('cancel booking returns refund quote then confirms cancellation', () async {
      // Step 1: Get cancel quote
      final quoteDio = FakeViatorDio(
        getResponses: {'$baseUrl/bookings/BR-12345-678/cancel-quote': cancelQuoteResponse},
      );
      final service = createService(quoteDio);

      final quote = await service.getCancelQuote('BR-12345-678');
      expect(quote, isNotNull);
      expect(quote!.refundAmount, 75.6);
      expect(quote.cancellationFee, 8.4);
      expect(quote.feeReason, isNotNull);

      // Step 2: Cancel with reason
      final cancelBookResponse = {
        'bookingRef': 'BR-12345-678',
        'productCode': '5010SYDNEY',
        'productTitle': 'Sydney Opera House Guided Tour',
        'status': 'CANCELLED',
        'travelDate': '2026-05-15',
        'travelerCount': 2,
        'totalPrice': 84.0,
        'currency': 'USD',
        'createdAt': '2026-04-10T10:00:00Z',
      };
      final cancelDio = FakeViatorDio(
        postResponses: {'$baseUrl/bookings/BR-12345-678/cancel': cancelBookResponse},
      );
      final cancelService = createService(cancelDio);

      final cancelled = await cancelService.cancelBooking(
        bookingRef: 'BR-12345-678',
        reasonCode: 'CHANGE_OF_PLANS',
      );

      expect(cancelled, isNotNull);
      expect(cancelled!.status, ViatorBookingStatus.cancelled);
    });
  });

  group('Viator Sync Endpoints', () {
    test('getModifiedProducts returns updated products', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/products/modified-since': searchProductsResponse},
      );
      final service = createService(dio);

      final products = await service.getModifiedProducts(
        DateTime(2026, 4, 1),
      );

      expect(products, isNotEmpty);
      expect(products[0].id, '5010SYDNEY');
    });

    test('searchSupplierProducts returns products by supplier', () async {
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/suppliers/search/product-codes': searchProductsResponse},
      );
      final service = createService(dio);

      final products = await service.searchSupplierProducts(
        supplierId: 'supplier_123',
      );

      expect(products, isNotEmpty);
    });

    test('getBookingQuestions returns required questions', () async {
      final questionsResponse = {
        'questions': [
          {
            'id': 'q_height',
            'question': 'What is your height? (for safety equipment)',
            'required': true,
            'inputType': 'text',
          },
          {
            'id': 'q_weight',
            'question': 'What is your weight? (for safety equipment)',
            'required': true,
            'inputType': 'select',
            'options': ['Under 50kg', '50-80kg', '80-100kg', 'Over 100kg'],
          },
        ],
      };
      final dio = FakeViatorDio(
        getResponses: {'$baseUrl/products/5010SYDNEY/booking-questions': questionsResponse},
      );
      final service = createService(dio);

      final questions = await service.getBookingQuestions('5010SYDNEY');

      expect(questions, hasLength(2));
      expect(questions[0].id, 'q_height');
      expect(questions[0].required, isTrue);
      expect(questions[1].inputType, 'select');
      expect(questions[1].options, hasLength(4));
    });

    test('getModifiedBookings returns changed bookings', () async {
      final modifiedBookingsResponse = {
        'bookings': [bookResponse],
      };
      final dio = FakeViatorDio(
        getResponses: {'$baseUrl/bookings/modified-since': modifiedBookingsResponse},
      );
      final service = createService(dio);

      final bookings = await service.getModifiedBookings(DateTime(2026, 4, 1));

      expect(bookings, hasLength(1));
      expect(bookings[0].bookingRef, 'BR-12345-678');
    });

    test('getModifiedSchedules returns schedule changes', () async {
      final schedulesResponse = {
        'schedules': {
          '5010SYDNEY': ['2026-05-15', '2026-05-16', '2026-05-17'],
        },
      };
      final dio = FakeViatorDio(
        postResponses: {'$baseUrl/availability/schedules/modified-since': schedulesResponse},
      );
      final service = createService(dio);

      final schedules = await service.getModifiedSchedules(DateTime(2026, 4, 1));

      expect(schedules, hasLength(1));
      expect(schedules['5010SYDNEY'], hasLength(3));
    });
  });
}

// Test date for use in test methods (DateTime cannot be const).
final _testDate = DateTime(2026, 5, 15, 9, 0, 0);
