/// Re-export of sync manager provider from app/providers
///
/// This file maintains backward compatibility for imports while
/// the actual provider is now defined in app/providers/offline_service_providers.dart
library;
export 'package:soloadventurer/app/providers/offline_service_providers.dart'
    show syncManagerProvider;
