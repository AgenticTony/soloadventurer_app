import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';

void main() {
  group('CommentPermission enforcement', () {
    /// Simulates whether a viewer is allowed to comment based on permission.
    bool canComment({
      required CommentPermission permission,
      required String viewerType, // 'self', 'follower', 'community', 'stranger'
    }) {
      switch (permission) {
        case CommentPermission.nobody:
          return false; // Nobody can comment
        case CommentPermission.followers:
          return viewerType == 'follower' || viewerType == 'self';
        case CommentPermission.everyone:
          return true; // Everyone can comment
      }
    }

    test('CommentPermission.nobody blocks all comment attempts', () {
      // No viewer type should be able to comment
      for (final viewer in ['self', 'follower', 'community', 'stranger']) {
        expect(
          canComment(permission: CommentPermission.nobody, viewerType: viewer),
          isFalse,
          reason: 'Nobody permission should block $viewer',
        );
      }
    });

    test('CommentPermission.everyone allows all comment attempts', () {
      // All viewer types should be able to comment
      for (final viewer in ['self', 'follower', 'community', 'stranger']) {
        expect(
          canComment(
              permission: CommentPermission.everyone, viewerType: viewer),
          isTrue,
          reason: 'Everyone permission should allow $viewer',
        );
      }
    });

    test('CommentPermission.followers allows only followers and self', () {
      expect(
        canComment(
            permission: CommentPermission.followers, viewerType: 'follower'),
        isTrue,
      );
      expect(
        canComment(
            permission: CommentPermission.followers, viewerType: 'self'),
        isTrue,
      );

      // Non-followers and strangers should be blocked
      expect(
        canComment(
            permission: CommentPermission.followers, viewerType: 'stranger'),
        isFalse,
      );
      expect(
        canComment(
            permission: CommentPermission.followers, viewerType: 'community'),
        isFalse,
      );
    });

    test('CommentPermission.fromString parses valid values', () {
      expect(
          CommentPermission.fromString('nobody'), CommentPermission.nobody);
      expect(CommentPermission.fromString('followers'),
          CommentPermission.followers);
      expect(CommentPermission.fromString('everyone'),
          CommentPermission.everyone);
    });

    test('CommentPermission.fromString throws on invalid value', () {
      expect(
        () => CommentPermission.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('CommentPermission extension value round-trips correctly', () {
      for (final permission in CommentPermission.values) {
        expect(CommentPermission.fromString(permission.value), permission);
      }
    });

    test('CommentPermission has exactly 3 values', () {
      expect(CommentPermission.values.length, 3);
      expect(CommentPermission.values,
          contains(CommentPermission.nobody));
      expect(CommentPermission.values,
          contains(CommentPermission.followers));
      expect(CommentPermission.values,
          contains(CommentPermission.everyone));
    });
  });
}
