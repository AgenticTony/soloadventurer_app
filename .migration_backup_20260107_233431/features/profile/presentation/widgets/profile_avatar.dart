import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;
  final String? initials;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.size = 80,
    this.onTap,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar;
    if (avatarUrl != null) {
      avatar = CachedNetworkImage(
        imageUrl: avatarUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.errorContainer,
          ),
          child: Icon(
            Icons.error_outline,
            size: size * 0.5,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      );
    } else {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: initials != null
              ? Text(
                  initials!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: avatar,
      ),
    );
  }
}
