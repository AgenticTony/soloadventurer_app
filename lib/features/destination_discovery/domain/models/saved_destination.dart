import 'package:freezed_annotation/freezed_annotation.dart';

import 'destination.dart';

part 'saved_destination.freezed.dart';
part 'saved_destination.g.dart';

/// Represents the type/location where a destination is saved
enum SaveType {
  /// Saved to user's wishlist (bucket list)
  @JsonValue('wishlist')
  wishlist,

  /// Saved to a specific trip
  @JsonValue('trip')
  trip,
}

/// Represents a destination saved by a user
///
/// This model tracks destinations that users have saved either to their
/// wishlist for future reference or to a specific trip they're planning.
/// Users can add notes to saved destinations for personal reference.
@freezed
sealed class SavedDestination with _$SavedDestination {
  factory SavedDestination({
    /// Unique identifier for this save entry
    required String id,

    /// User ID who saved this destination
    required String userId,

    /// The destination being saved
    required Destination destination,

    /// Type/location of save (wishlist or trip)
    required SaveType saveType,

    /// Trip ID if saveType is trip
    /// Null when saveType is wishlist
    String? tripId,

    /// Optional notes added by the user
    /// Users can add personal notes about why they saved this destination
    /// or specific plans for it
    String? notes,

    /// Timestamp when this destination was saved
    required DateTime createdAt,

    /// Timestamp when this save was last updated
    /// Used for tracking when notes or other fields were modified
    required DateTime updatedAt,
  }) = _SavedDestination;

  SavedDestination._();

  factory SavedDestination.fromJson(Map<String, dynamic> json) =>
      _$SavedDestinationFromJson(json);

  /// Checks if this destination is saved to wishlist
  bool get isWishlist => saveType == SaveType.wishlist;

  /// Checks if this destination is saved to a trip
  bool get isTrip => saveType == SaveType.trip;

  /// Returns true if user has added notes to this saved destination
  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;

  /// Creates a copy with updated timestamp
  /// Useful for when notes or other fields are modified
  SavedDestination withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Creates a copy with new notes and updated timestamp
  SavedDestination withNotes(String? newNotes) {
    return copyWith(
      notes: newNotes?.trim().isEmpty == true ? null : newNotes?.trim(),
      updatedAt: DateTime.now(),
    );
  }
}
