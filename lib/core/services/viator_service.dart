import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

import 'viator_service_impl.dart' show viatorServiceImplProvider;

part 'viator_service.g.dart';

/// Service for accessing Viator Transactional API.
///
/// Provides bookable tours, experiences, and day trips with full
/// in-app booking support (hold → pay → confirm).
///
/// Covers: guided tours, day trips, cooking classes, adventure experiences,
/// skip-the-line tickets.
abstract class ViatorService {
  /// Search for bookable products by destination.
  ///
  /// [destinationId] is the Viator destination ID (e.g., "737" for Paris).
  /// [filter] narrows results by category, price, etc.
  /// Returns a list of Viator products mapped to [PlaceActivity].
  Future<ViatorSearchResult> searchProducts({
    required String destinationId,
    ViatorSearchFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Get detailed information about a specific product.
  ///
  /// [productCode] is the Viator product code.
  Future<ViatorProductDetail?> getProductDetails(String productCode);

  /// Check real-time availability for a product on a specific date.
  ///
  /// [productCode] is the Viator product code.
  /// [date] is the travel date.
  /// Returns available time slots with pricing.
  Future<List<ViatorAvailability>> checkAvailability({
    required String productCode,
    required DateTime date,
  });

  /// Get bulk availability schedules for calendar view.
  ///
  /// [productCodes] is the list of product codes to check.
  /// [startDate] and [endDate] define the date range.
  Future<Map<String, List<DateTime>>> getAvailabilitySchedules({
    required List<String> productCodes,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Hold availability during checkout.
  ///
  /// Returns a [ViatorBookingHold] with the hold reference and expiry.
  Future<ViatorBookingHold?> holdBooking({
    required String productCode,
    required ViatorAvailability availability,
    required int travelerCount,
  });

  /// Complete a booking after payment.
  ///
  /// [holdToken] is from a previous [holdBooking] call.
  /// [travelerDetails] contains names and required info per traveler.
  Future<ViatorBooking?> bookBooking({
    required String holdToken,
    required List<ViatorTravelerDetail> travelerDetails,
  });

  /// Get booking status.
  ///
  /// [bookingRef] is the booking reference returned from [bookBooking].
  Future<ViatorBooking?> getBookingStatus(String bookingRef);

  /// Get a cancel quote showing refund amount before confirming.
  ///
  /// [bookingRef] is the booking to cancel.
  Future<ViatorCancelQuote?> getCancelQuote(String bookingRef);

  /// Cancel a booking.
  ///
  /// [bookingRef] is the booking to cancel.
  /// [reasonCode] is from [ViatorCancelReason].
  /// Returns the updated booking with cancellation details.
  Future<ViatorBooking?> cancelBooking({
    required String bookingRef,
    required String reasonCode,
  });

  /// Get available cancel reasons.
  Future<List<ViatorCancelReason>> getCancelReasons();

  /// Search for Viator destinations matching a text query.
  Future<List<ViatorDestination>> searchDestinations(String query);

  /// Get reviews for a product.
  ///
  /// [productCode] is the Viator product code.
  Future<List<ViatorReview>> getProductReviews(
    String productCode, {
    int page = 1,
    int limit = 10,
  });

  /// Get products modified since a given timestamp.
  ///
  /// Used for incremental sync to keep local data fresh.
  Future<List<PlaceActivity>> getModifiedProducts(DateTime since);

  /// Search for supplier products by code.
  ///
  /// [supplierId] is the Viator supplier ID.
  /// [productCodes] is the list of product codes to look up.
  Future<List<PlaceActivity>> searchSupplierProducts({
    required String supplierId,
    List<String>? productCodes,
  });

  /// Get availability schedule changes since a given timestamp.
  ///
  /// Used for incremental sync of schedule data.
  Future<Map<String, List<DateTime>>> getModifiedSchedules(DateTime since);

  /// Get booking questions required for a product.
  ///
  /// Returns a list of questions the traveler must answer during booking.
  Future<List<ViatorBookingQuestion>> getBookingQuestions(String productCode);

  /// Get bookings modified since a given timestamp.
  ///
  /// Used for syncing booking status changes.
  Future<List<ViatorBooking>> getModifiedBookings(DateTime since);

  /// Acknowledge booking changes have been processed.
  Future<void> acknowledgeBookingChanges(List<String> bookingRefs);
}

/// Result of a product search with pagination info.
class ViatorSearchResult {
  /// Products found.
  final List<PlaceActivity> products;

  /// Total matching products (for pagination).
  final int totalCount;

  /// Whether more results are available.
  final bool hasMore;

  const ViatorSearchResult({
    required this.products,
    required this.totalCount,
    required this.hasMore,
  });
}

/// Filter for Viator product searches.
class ViatorSearchFilter {
  /// Text search query.
  final String? query;

  /// Category filter (e.g., "tours", "activities", "attractions").
  final String? category;

  /// Minimum price in USD.
  final double? minPrice;

  /// Maximum price in USD.
  final double? maxPrice;

  /// Minimum rating (1-5).
  final double? minRating;

  /// Sort order.
  final ViatorSortOrder sortOrder;

  const ViatorSearchFilter({
    this.query,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sortOrder = ViatorSortOrder.relevance,
  });
}

/// Sort order for Viator product searches.
enum ViatorSortOrder {
  relevance,
  priceAsc,
  priceDesc,
  rating,
  popularity,
}

/// Detailed product information from Viator.
class ViatorProductDetail {
  /// Viator product code.
  final String productCode;

  /// Display title.
  final String title;

  /// Full description.
  final String description;

  /// List of image URLs.
  final List<String> imageUrls;

  /// Starting price in USD.
  final double price;

  /// Currency code.
  final String currency;

  /// Duration description (e.g., "3 hours", "Full day").
  final String duration;

  /// Category name.
  final String category;

  /// Average rating (0-5).
  final double rating;

  /// Number of reviews.
  final int reviewCount;

  /// Cancellation policy description.
  final String cancellationPolicy;

  /// Whether free cancellation is available.
  final bool freeCancellation;

  /// URL for more info on Viator.
  final String? webUrl;

  /// Booking questions required for this product.
  final List<ViatorBookingQuestion> bookingQuestions;

  const ViatorProductDetail({
    required this.productCode,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.price,
    this.currency = 'USD',
    required this.duration,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.cancellationPolicy,
    required this.freeCancellation,
    this.webUrl,
    this.bookingQuestions = const [],
  });

  /// Convert to PlaceActivity for unified display.
  PlaceActivity toPlaceActivity() {
    return PlaceActivity(
      id: productCode,
      name: title,
      description: description,
      category: category,
      cost: price,
      rating: rating,
      reviewCount: reviewCount,
      bookingUrl: webUrl,
      photoUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
    );
  }
}

/// Available time slot for a product on a specific date.
class ViatorAvailability {
  /// Unique identifier for this availability slot.
  final String id;

  /// Start time.
  final DateTime startTime;

  /// End time.
  final DateTime endTime;

  /// Price per traveler in USD.
  final double price;

  /// Currency code.
  final String currency;

  /// Number of spots remaining (null = unlimited).
  final int? spotsRemaining;

  /// Whether this slot is still bookable.
  final bool bookable;

  const ViatorAvailability({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.currency = 'USD',
    this.spotsRemaining,
    required this.bookable,
  });
}

/// Hold token for checkout flow.
class ViatorBookingHold {
  /// Hold reference/token.
  final String holdToken;

  /// When this hold expires.
  final DateTime expiresAt;

  /// Held price per traveler.
  final double pricePerTraveler;

  /// Total held price.
  final double totalPrice;

  /// Currency code.
  final String currency;

  const ViatorBookingHold({
    required this.holdToken,
    required this.expiresAt,
    required this.pricePerTraveler,
    required this.totalPrice,
    this.currency = 'USD',
  });
}

/// Completed booking details.
class ViatorBooking {
  /// Booking reference number.
  final String bookingRef;

  /// Product code.
  final String productCode;

  /// Product title.
  final String productTitle;

  /// Booking status.
  final ViatorBookingStatus status;

  /// Travel date.
  final DateTime travelDate;

  /// Number of travelers.
  final int travelerCount;

  /// Total price paid.
  final double totalPrice;

  /// Currency code.
  final String currency;

  /// Date the booking was created.
  final DateTime createdAt;

  /// Cancellation deadline (if free cancellation applies).
  final DateTime? cancellationDeadline;

  /// Confirmation PDF URL.
  final String? confirmationUrl;

  const ViatorBooking({
    required this.bookingRef,
    required this.productCode,
    required this.productTitle,
    required this.status,
    required this.travelDate,
    required this.travelerCount,
    required this.totalPrice,
    this.currency = 'USD',
    required this.createdAt,
    this.cancellationDeadline,
    this.confirmationUrl,
  });
}

/// Booking status.
enum ViatorBookingStatus {
  pending,
  confirmed,
  cancelled,
  expired,
  unknown;

  static ViatorBookingStatus fromString(String value) {
    return switch (value.toUpperCase()) {
      'PENDING' => pending,
      'CONFIRMED' => confirmed,
      'CANCELLED' => cancelled,
      'EXPIRED' => expired,
      _ => unknown,
    };
  }
}

/// Traveler detail for booking.
class ViatorTravelerDetail {
  /// First name.
  final String firstName;

  /// Last name.
  final String lastName;

  /// Email address.
  final String email;

  /// Phone number (with country code).
  final String? phone;

  /// Answers to booking questions.
  final Map<String, String> questionAnswers;

  const ViatorTravelerDetail({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.questionAnswers = const {},
  });
}

/// Cancel quote showing refund details.
class ViatorCancelQuote {
  /// Booking reference.
  final String bookingRef;

  /// Refund amount.
  final double refundAmount;

  /// Currency code.
  final String currency;

  /// Cancellation fee.
  final double cancellationFee;

  /// Reason for the fee amount.
  final String? feeReason;

  const ViatorCancelQuote({
    required this.bookingRef,
    required this.refundAmount,
    this.currency = 'USD',
    required this.cancellationFee,
    this.feeReason,
  });
}

/// Cancel reason option.
class ViatorCancelReason {
  /// Reason code.
  final String code;

  /// Human-readable reason.
  final String description;

  const ViatorCancelReason({
    required this.code,
    required this.description,
  });
}

/// Viator destination.
class ViatorDestination {
  /// Destination ID.
  final String id;

  /// Destination name.
  final String name;

  /// Country code.
  final String countryCode;

  /// Destination type (e.g., "CITY", "REGION").
  final String type;

  const ViatorDestination({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.type,
  });
}

/// Product review.
class ViatorReview {
  /// Review ID.
  final String id;

  /// Author name.
  final String author;

  /// Rating (1-5).
  final double rating;

  /// Review text.
  final String text;

  /// Date of the review.
  final DateTime date;

  /// Whether the reviewer was a solo traveler.
  final bool? soloTraveler;

  const ViatorReview({
    required this.id,
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
    this.soloTraveler,
  });
}

/// Booking question required by a product.
class ViatorBookingQuestion {
  /// Question ID.
  final String id;

  /// The question text.
  final String question;

  /// Whether this question is required.
  final bool required;

  /// Input type (e.g., "text", "date", "select").
  final String inputType;

  /// Options for "select" type questions.
  final List<String>? options;

  const ViatorBookingQuestion({
    required this.id,
    required this.question,
    required this.required,
    this.inputType = 'text',
    this.options,
  });
}

/// Provider for the ViatorService implementation.
@Riverpod(keepAlive: true)
ViatorService viatorService(Ref ref) {
  return ref.watch(viatorServiceImplProvider);
}
