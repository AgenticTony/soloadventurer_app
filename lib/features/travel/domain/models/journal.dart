import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal.freezed.dart';
part 'journal.g.dart';

/// Journal domain entity representing a travel journal entry
///
/// This entity represents a single journal entry associated with a trip.
/// Journals can contain text, images, location data, mood, and tags.
@freezed
sealed class Journal with _$Journal {
  const factory Journal({
    /// Unique identifier for the journal
    required String id,

    /// ID of the trip this journal belongs to
    required String tripId,

    /// ID of the user who created the journal
    required String userId,

    /// Title of the journal entry
    required String title,

    /// Main content of the journal
    required String content,

    /// Date the journal entry was written (optional, defaults to createdAt)
    DateTime? entryDate,

    /// Mood or emotional state associated with the entry
    String? mood,

    /// Location where the journal was written
    String? location,

    /// List of image URLs attached to the journal
    List<String>? imageUrls,

    /// List of tags for categorizing the journal
    List<String>? tags,

    /// Timestamp when the journal was created
    required DateTime createdAt,

    /// Timestamp when the journal was last updated
    required DateTime updatedAt,
  }) = _Journal;

  /// Creates a Journal from JSON
  factory Journal.fromJson(Map<String, dynamic> json) =>
      _$JournalFromJson(json);
}
