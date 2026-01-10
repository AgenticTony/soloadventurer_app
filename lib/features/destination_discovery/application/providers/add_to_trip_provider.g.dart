// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_to_trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the travel operation repository from the travel feature

@ProviderFor(travelOperationRepository)
final travelOperationRepositoryProvider = TravelOperationRepositoryProvider._();

/// Provider for the travel operation repository from the travel feature

final class TravelOperationRepositoryProvider extends $FunctionalProvider<
    TravelOperationRepository,
    TravelOperationRepository,
    TravelOperationRepository> with $Provider<TravelOperationRepository> {
  /// Provider for the travel operation repository from the travel feature
  TravelOperationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'travelOperationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$travelOperationRepositoryHash();

  @$internal
  @override
  $ProviderElement<TravelOperationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TravelOperationRepository create(Ref ref) {
    return travelOperationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TravelOperationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TravelOperationRepository>(value),
    );
  }
}

String _$travelOperationRepositoryHash() =>
    r'dfca59a02c9c282e20a251781dfcb3ed65ca1294';

/// Provider for managing add to trip operations
///
/// This provider manages the state of adding a destination from the
/// destination discovery feature to a trip in the travel feature.
///
/// Usage:
/// ```dart
/// final addToTripState = ref.watch(addToTripProvider);
/// final addToTripNotifier = ref.read(addToTripProvider.notifier);
///
/// // Add destination to existing trip
/// await addToTripNotifier.addToExistingTrip(
///   destination: destination,
///   tripId: tripId,
///   tripName: 'Japan Adventure',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Add destination to new trip
/// await addToTripNotifier.addToNewTrip(
///   destination: destination,
///   tripTitle: 'Summer Adventure',
///   tripDescription: 'Exploring new places',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Check if operation is loading
/// if (addToTripState.isLoading) {
///   // Show loading indicator
/// }
///
/// // Check if operation was successful
/// if (addToTripState.isSuccess) {
///   final tripId = addToTripState.tripId;
///   final tripName = addToTripState.tripName;
///   // Show success message
/// }
///
/// // Check for errors
/// if (addToTripState.hasError) {
///   final error = addToTripState.errorMessage;
///   // Show error message
/// }
/// ```

@ProviderFor(AddToTripNotifier)
final addToTripProvider = AddToTripNotifierProvider._();

/// Provider for managing add to trip operations
///
/// This provider manages the state of adding a destination from the
/// destination discovery feature to a trip in the travel feature.
///
/// Usage:
/// ```dart
/// final addToTripState = ref.watch(addToTripProvider);
/// final addToTripNotifier = ref.read(addToTripProvider.notifier);
///
/// // Add destination to existing trip
/// await addToTripNotifier.addToExistingTrip(
///   destination: destination,
///   tripId: tripId,
///   tripName: 'Japan Adventure',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Add destination to new trip
/// await addToTripNotifier.addToNewTrip(
///   destination: destination,
///   tripTitle: 'Summer Adventure',
///   tripDescription: 'Exploring new places',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Check if operation is loading
/// if (addToTripState.isLoading) {
///   // Show loading indicator
/// }
///
/// // Check if operation was successful
/// if (addToTripState.isSuccess) {
///   final tripId = addToTripState.tripId;
///   final tripName = addToTripState.tripName;
///   // Show success message
/// }
///
/// // Check for errors
/// if (addToTripState.hasError) {
///   final error = addToTripState.errorMessage;
///   // Show error message
/// }
/// ```
final class AddToTripNotifierProvider
    extends $NotifierProvider<AddToTripNotifier, AddToTripState> {
  /// Provider for managing add to trip operations
  ///
  /// This provider manages the state of adding a destination from the
  /// destination discovery feature to a trip in the travel feature.
  ///
  /// Usage:
  /// ```dart
  /// final addToTripState = ref.watch(addToTripProvider);
  /// final addToTripNotifier = ref.read(addToTripProvider.notifier);
  ///
  /// // Add destination to existing trip
  /// await addToTripNotifier.addToExistingTrip(
  ///   destination: destination,
  ///   tripId: tripId,
  ///   tripName: 'Japan Adventure',
  ///   startDate: startDate,
  ///   endDate: endDate,
  ///   notes: notes,
  /// );
  ///
  /// // Add destination to new trip
  /// await addToTripNotifier.addToNewTrip(
  ///   destination: destination,
  ///   tripTitle: 'Summer Adventure',
  ///   tripDescription: 'Exploring new places',
  ///   startDate: startDate,
  ///   endDate: endDate,
  ///   notes: notes,
  /// );
  ///
  /// // Check if operation is loading
  /// if (addToTripState.isLoading) {
  ///   // Show loading indicator
  /// }
  ///
  /// // Check if operation was successful
  /// if (addToTripState.isSuccess) {
  ///   final tripId = addToTripState.tripId;
  ///   final tripName = addToTripState.tripName;
  ///   // Show success message
  /// }
  ///
  /// // Check for errors
  /// if (addToTripState.hasError) {
  ///   final error = addToTripState.errorMessage;
  ///   // Show error message
  /// }
  /// ```
  AddToTripNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addToTripProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addToTripNotifierHash();

  @$internal
  @override
  AddToTripNotifier create() => AddToTripNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddToTripState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddToTripState>(value),
    );
  }
}

String _$addToTripNotifierHash() => r'967153d1eac717efbf123c3ac2b652d455285117';

/// Provider for managing add to trip operations
///
/// This provider manages the state of adding a destination from the
/// destination discovery feature to a trip in the travel feature.
///
/// Usage:
/// ```dart
/// final addToTripState = ref.watch(addToTripProvider);
/// final addToTripNotifier = ref.read(addToTripProvider.notifier);
///
/// // Add destination to existing trip
/// await addToTripNotifier.addToExistingTrip(
///   destination: destination,
///   tripId: tripId,
///   tripName: 'Japan Adventure',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Add destination to new trip
/// await addToTripNotifier.addToNewTrip(
///   destination: destination,
///   tripTitle: 'Summer Adventure',
///   tripDescription: 'Exploring new places',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Check if operation is loading
/// if (addToTripState.isLoading) {
///   // Show loading indicator
/// }
///
/// // Check if operation was successful
/// if (addToTripState.isSuccess) {
///   final tripId = addToTripState.tripId;
///   final tripName = addToTripState.tripName;
///   // Show success message
/// }
///
/// // Check for errors
/// if (addToTripState.hasError) {
///   final error = addToTripState.errorMessage;
///   // Show error message
/// }
/// ```

abstract class _$AddToTripNotifier extends $Notifier<AddToTripState> {
  AddToTripState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddToTripState, AddToTripState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AddToTripState, AddToTripState>,
        AddToTripState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
