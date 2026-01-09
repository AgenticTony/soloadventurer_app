/// Barrel file for all safety notifier providers
///
/// This file imports all the notifier files, which include their generated
/// .g.dart parts that contain the provider definitions.
library;

import 'package:soloadventurer/features/safety/presentation/notifiers/trusted_contacts_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/location_sharing_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/safety_notifier.dart';

// Export all providers - the providers are defined in the .g.dart part files
// and will be available when this file is imported.
export 'package:soloadventurer/features/safety/presentation/notifiers/trusted_contacts_notifier.dart'
    show trustedContactsNotifierProvider;
export 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart'
    show checkInNotifierProvider;
export 'package:soloadventurer/features/safety/presentation/notifiers/location_sharing_notifier.dart'
    show locationSharingNotifierProvider;
export 'package:soloadventurer/features/safety/presentation/notifiers/safety_notifier.dart'
    show safetyNotifierProvider;
