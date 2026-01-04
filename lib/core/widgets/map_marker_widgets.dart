import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/map_marker.dart';

/// Widget for displaying a single map marker
///
/// Renders a customizable marker icon with optional title,
/// color, and tap handling. Supports all marker types.
class MapMarkerWidget extends StatelessWidget {
  /// The marker data to display
  final MapMarker marker;

  /// Size of the marker widget
  final double size;

  /// Optional callback when marker is tapped
  final VoidCallback? onTap;

  /// Whether to show a title label below the marker
  final bool showTitle;

  /// Custom widget to override default marker icon
  final Widget? customIcon;

  /// Whether to enable ripple effect on tap
  final bool enableRipple;

  /// Border radius for the marker container
  final double borderRadius;

  const MapMarkerWidget({
    super.key,
    required this.marker,
    this.size = 40.0,
    this.onTap,
    this.showTitle = false,
    this.customIcon,
    this.enableRipple = true,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = _getMarkerColor(context);

    Widget markerWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: marker.color != null
            ? Color(marker.color!).withOpacity(0.9)
            : markerColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: customIcon ??
          Icon(
            _getMarkerIcon(),
            color: Colors.white,
            size: size * 0.6,
          ),
    );

    if (onTap != null) {
      markerWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          enableFeedback: enableRipple,
          borderRadius: BorderRadius.circular(borderRadius),
          child: markerWidget,
        ),
      );
    }

    if (showTitle && marker.title != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          markerWidget,
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              marker.title!,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return markerWidget;
  }

  /// Get color based on marker type
  Color _getMarkerColor(BuildContext context) {
    switch (marker.type) {
      case MarkerType.trip:
        return Colors.blue;
      case MarkerType.activity:
        return Colors.orange;
      case MarkerType.photo:
        return Colors.purple;
      case MarkerType.accommodation:
        return Colors.teal;
      case MarkerType.restaurant:
        return Colors.red;
      case MarkerType.transport:
        return Colors.indigo;
      case MarkerType.poi:
        return Colors.amber;
      case MarkerType.defaultType:
        return Theme.of(context).primaryColor;
    }
  }

  /// Get icon based on marker type
  IconData _getMarkerIcon() {
    switch (marker.type) {
      case MarkerType.trip:
        return Icons.flight_takeoff;
      case MarkerType.activity:
        return Icons.hiking;
      case MarkerType.photo:
        return Icons.photo_camera;
      case MarkerType.accommodation:
        return Icons.hotel;
      case MarkerType.restaurant:
        return Icons.restaurant;
      case MarkerType.transport:
        return Icons.directions_car;
      case MarkerType.poi:
        return Icons.place;
      case MarkerType.defaultType:
        return Icons.location_on;
    }
  }

  /// Create marker widget for trip
  factory MapMarkerWidget.forTrip({
    Key? key,
    required MapMarker marker,
    double size = 40.0,
    VoidCallback? onTap,
    bool showTitle = false,
  }) {
    return MapMarkerWidget(
      key: key,
      marker: marker,
      size: size,
      onTap: onTap,
      showTitle: showTitle,
    );
  }

  /// Create marker widget for activity
  factory MapMarkerWidget.forActivity({
    Key? key,
    required MapMarker marker,
    double size = 40.0,
    VoidCallback? onTap,
    bool showTitle = false,
  }) {
    return MapMarkerWidget(
      key: key,
      marker: marker,
      size: size,
      onTap: onTap,
      showTitle: showTitle,
    );
  }

  /// Create small marker (for list items)
  factory MapMarkerWidget.small({
    Key? key,
    required MapMarker marker,
    VoidCallback? onTap,
  }) {
    return MapMarkerWidget(
      key: key,
      marker: marker,
      size: 24.0,
      onTap: onTap,
      enableRipple: false,
    );
  }

  /// Create large marker (for featured items)
  factory MapMarkerWidget.large({
    Key? key,
    required MapMarker marker,
    VoidCallback? onTap,
    bool showTitle = true,
  }) {
    return MapMarkerWidget(
      key: key,
      marker: marker,
      size: 56.0,
      onTap: onTap,
      showTitle: showTitle,
      borderRadius: 12.0,
    );
  }
}

/// Widget for displaying a cluster of map markers
///
/// Renders a circle showing the count of markers in the cluster
/// with color coding based on cluster size. Supports tap handling
/// to expand the cluster.
class MapClusterWidget extends StatefulWidget {
  /// The cluster data to display
  final MapCluster cluster;

  /// Base size of the cluster widget (will grow with cluster size)
  final double baseSize;

  /// Optional callback when cluster is tapped
  final VoidCallback? onTap;

  /// Whether to show exact count or abbreviated (e.g., 99+, 1.2k)
  final bool abbreviateCount;

  /// Custom color for the cluster circle
  final Color? color;

  /// Custom text style for the count label
  final TextStyle? textStyle;

  /// Whether to enable animation when count changes
  final bool animate;

  /// Border width around the cluster circle
  final double borderWidth;

  const MapClusterWidget({
    super.key,
    required this.cluster,
    this.baseSize = 50.0,
    this.onTap,
    this.abbreviateCount = true,
    this.color,
    this.textStyle,
    this.animate = true,
    this.borderWidth = 2.0,
  });

  @override
  State<MapClusterWidget> createState() => _MapClusterWidgetState();
}

class _MapClusterWidgetState extends State<MapClusterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _scaleController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ));
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(MapClusterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && widget.cluster.markerCount != oldWidget.cluster.markerCount) {
      _scaleController.forward(from: 0.8);
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _scaleController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clusterSize = _calculateClusterSize();
    final clusterColor = widget.color ?? _getClusterColor(context);
    final countText = _formatCount();

    Widget clusterWidget = AnimatedBuilder(
      animation: widget.animate ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: clusterSize,
        height: clusterSize,
        decoration: BoxDecoration(
          color: clusterColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            countText,
            style: widget.textStyle ??
                TextStyle(
                  color: Colors.white,
                  fontSize: clusterSize * 0.35,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      clusterWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          enableFeedback: true,
          customBorder: const CircleBorder(),
          child: clusterWidget,
        ),
      );
    }

    return clusterWidget;
  }

  /// Calculate cluster size based on marker count
  double _calculateClusterSize() {
    // Scale size logarithmically with marker count
    final count = widget.cluster.markerCount.toDouble();
    final minSize = widget.baseSize;
    final maxSize = widget.baseSize * 2.5;

    if (count <= 10) return minSize;
    if (count >= 1000) return maxSize;

    // Logarithmic scaling: size grows slower as count increases
    final scaleFactor = (log(count) / log(1000));
    return minSize + (maxSize - minSize) * scaleFactor;
  }

  /// Get color based on cluster size
  Color _getClusterColor(BuildContext context) {
    final count = widget.cluster.markerCount;

    if (count < 10) {
      return Colors.green; // Small clusters
    } else if (count < 50) {
      return Colors.orange; // Medium clusters
    } else if (count < 100) {
      return Colors.red; // Large clusters
    } else {
      return Colors.purple; // Very large clusters
    }
  }

  /// Format count for display
  String _formatCount() {
    final count = widget.cluster.markerCount;

    if (!widget.abbreviateCount || count < 1000) {
      return count.toString();
    }

    if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(count / 1000).toStringAsFixed(0)}k';
    }
  }

  /// Create cluster widget for small clusters
  factory MapClusterWidget.small({
    Key? key,
    required MapCluster cluster,
    VoidCallback? onTap,
  }) {
    return MapClusterWidget(
      key: key,
      cluster: cluster,
      baseSize: 40.0,
      onTap: onTap,
    );
  }

  /// Create cluster widget for large clusters
  factory MapClusterWidget.large({
    Key? key,
    required MapCluster cluster,
    VoidCallback? onTap,
    }) {
    return MapClusterWidget(
      key: key,
      cluster: cluster,
      baseSize: 60.0,
      onTap: onTap,
    );
  }

  /// Create cluster widget with custom color
  factory MapClusterWidget.withColor({
    Key? key,
    required MapCluster cluster,
    required Color color,
    double baseSize = 50.0,
    VoidCallback? onTap,
  }) {
    return MapClusterWidget(
      key: key,
      cluster: cluster,
      baseSize: baseSize,
      color: color,
      onTap: onTap,
    );
  }
}

/// Widget for displaying marker type icons in cluster
///
/// Shows small icons representing the types of markers
/// contained within a cluster.
class ClusterTypeIcons extends StatelessWidget {
  /// The cluster data
  final MapCluster cluster;

  /// Size of each icon
  final double iconSize;

  /// Maximum number of icons to display
  final int maxIcons;

  const ClusterTypeIcons({
    super.key,
    required this.cluster,
    this.iconSize = 16.0,
    this.maxIcons = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (cluster.markerTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final uniqueTypes = cluster.markerTypes.toSet().toList();
    final displayTypes = uniqueTypes.take(maxIcons).toList();
    final remainingCount = uniqueTypes.length - maxIcons;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayTypes.map((type) => _buildTypeIcon(type)),
        if (remainingCount > 0) ...[
          const SizedBox(width: 2),
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: iconSize * 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeIcon(MarkerType type) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Icon(
        _getIconForType(type),
        size: iconSize,
        color: _getColorForType(type),
      ),
    );
  }

  IconData _getIconForType(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return Icons.flight_takeoff;
      case MarkerType.activity:
        return Icons.hiking;
      case MarkerType.photo:
        return Icons.photo_camera;
      case MarkerType.accommodation:
        return Icons.hotel;
      case MarkerType.restaurant:
        return Icons.restaurant;
      case MarkerType.transport:
        return Icons.directions_car;
      case MarkerType.poi:
        return Icons.place;
      case MarkerType.defaultType:
        return Icons.location_on;
    }
  }

  Color _getColorForType(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return Colors.blue;
      case MarkerType.activity:
        return Colors.orange;
      case MarkerType.photo:
        return Colors.purple;
      case MarkerType.accommodation:
        return Colors.teal;
      case MarkerType.restaurant:
        return Colors.red;
      case MarkerType.transport:
        return Colors.indigo;
      case MarkerType.poi:
        return Colors.amber;
      case MarkerType.defaultType:
        return Colors.grey;
    }
  }
}

/// Widget for displaying a cluster with type indicators
///
/// Combines cluster count with type icons for more detailed
/// information about cluster contents.
class MapClusterWithTypesWidget extends StatelessWidget {
  /// The cluster data
  final MapCluster cluster;

  /// Base size for the cluster circle
  final double baseSize;

  /// Optional callback when cluster is tapped
  final VoidCallback? onTap;

  /// Whether to show type icons below the cluster
  final bool showTypeIcons;

  const MapClusterWithTypesWidget({
    super.key,
    required this.cluster,
    this.baseSize = 50.0,
    this.onTap,
    this.showTypeIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapClusterWidget(
          cluster: cluster,
          baseSize: baseSize,
          onTap: onTap,
        ),
        if (showTypeIcons && cluster.markerTypes.isNotEmpty) ...[
          const SizedBox(height: 4),
          ClusterTypeIcons(
            cluster: cluster,
            iconSize: baseSize * 0.3,
          ),
        ],
      ],
    );
  }
}
