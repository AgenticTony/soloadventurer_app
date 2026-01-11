import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/check_in.dart';

part 'check_in_data.freezed.dart';
part 'check_in_data.g.dart';

/// Data class for check-in state
@freezed
sealed class CheckInData with _$CheckInData {
  const factory CheckInData({
    @Default([]) List<CheckIn> checkIns,
    @Default([]) List<CheckIn> upcomingCheckIns,
    CheckIn? selectedCheckIn,
  }) = _CheckInData;

  factory CheckInData.fromJson(Map<String, dynamic> json) =>
      _$CheckInDataFromJson(json);

  // Private constructor for freezed
  const CheckInData._();
}

/// Extension on [CheckInData] for computed properties
extension CheckInDataExtension on CheckInData {
  /// Whether there are any upcoming check-ins
  bool get hasUpcomingCheckIns => upcomingCheckIns.isNotEmpty;

  /// Count of check-ins due within the next hour
  int get dueSoonCount => upcomingCheckIns.where((checkIn) {
        final deadline = checkIn.deadline;
        if (deadline == null) return false;
        return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
      }).length;

  /// Count of missed check-ins
  int get missedCount => checkIns
      .where((checkIn) => checkIn.status == CheckInStatus.missed)
      .length;

  /// Next check-in (if any)
  CheckIn? get nextCheckIn {
    if (upcomingCheckIns.isEmpty) return null;
    final sorted = List<CheckIn>.from(upcomingCheckIns);
    sorted.sort((a, b) {
      final aTime = a.scheduledTime ?? a.deadline ?? DateTime.now();
      final bTime = b.scheduledTime ?? b.deadline ?? DateTime.now();
      return aTime.compareTo(bTime);
    });
    return sorted.first;
  }
}
