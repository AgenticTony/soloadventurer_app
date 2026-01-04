import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/routes/destination_discovery_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Home screen of the app
class HomeScreen extends ConsumerWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoloAdventurer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                ref.read(authNavigationProvider.notifier).navigateToProfile(),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              debugPrint('Logout button pressed');
              await ref.read(authNotifierProvider.notifier).signOut();
              debugPrint('Sign out completed');

              if (context.mounted) {
                ref
                    .read(authNavigationProvider.notifier)
                    .navigateToLogin(context);
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(context, theme),

            // Discover Destinations Hero Card
            _buildDiscoverHeroCard(context, theme),

            // Recommended for You Section
            _buildRecommendedSection(context, theme),

            // Curated Collections Section
            _buildCuratedCollectionsSection(context, theme),

            // Quick Links Section
            _buildQuickLinksSection(context, theme),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// Builds the welcome section
  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover your next solo adventure',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Discover Destinations hero card
  Widget _buildDiscoverHeroCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, DestinationDiscoveryRoutes.discovery);
          },
          child: Stack(
            children: [
              // Background image with gradient overlay
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.travel_explore,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content overlay
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.explore,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover Destinations',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore safe and exciting places perfect for solo travelers',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Safety badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Safety Ratings',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Recommended for You section
  Widget _buildRecommendedSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended for You',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.recommendations,
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),

        // Horizontal scrolling recommendations
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildQuickActionCard(
                context,
                theme,
                icon: Icons.person,
                title: 'Personalized',
                subtitle: 'Based on your preferences',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.recommendations,
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                theme,
                icon: Icons.trending_up,
                title: 'Trending',
                subtitle: 'Popular this week',
                color: theme.colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.discovery,
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                theme,
                icon: Icons.diamond,
                title: 'Hidden Gems',
                subtitle: 'Unique discoveries',
                color: Colors.amber,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.curatedLists,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the Curated Collections section
  Widget _buildCuratedCollectionsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curated Collections',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.curatedLists,
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),

        // Collection cards
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCollectionCard(
                context,
                theme,
                title: 'Popular Solo Spots',
                subtitle: '12 destinations',
                icon: Icons.trending_up,
                color: const Color(0xFF6B4EFF),
                imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.curatedLists,
                  );
                },
              ),
              _buildCollectionCard(
                context,
                theme,
                title: 'Hidden Gems',
                subtitle: '8 destinations',
                icon: Icons.diamond,
                color: Colors.amber,
                imageUrl: 'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?w=400',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.curatedLists,
                  );
                },
              ),
              _buildCollectionCard(
                context,
                theme,
                title: 'Budget Friendly',
                subtitle: '15 destinations',
                icon: Icons.attach_money,
                color: Colors.green,
                imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.curatedLists,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the Quick Links section
  Widget _buildQuickLinksSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickAccessCard(
                context,
                theme,
                title: 'Saved\nDestinations',
                icon: Icons.bookmark,
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.savedDestinations,
                  );
                },
              ),
              _buildQuickAccessCard(
                context,
                theme,
                title: 'Browse\nAll',
                icon: Icons.search,
                color: theme.colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DestinationDiscoveryRoutes.discovery,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a quick action card
  Widget _buildQuickActionCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a collection card
  Widget _buildCollectionCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: 200,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a quick access card
  Widget _buildQuickAccessCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
