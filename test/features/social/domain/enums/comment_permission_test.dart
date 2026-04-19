import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';

void main() {
  group('CommentPermission', () {
    test('has exactly 3 values', () {
      expect(CommentPermission.values, hasLength(3));
    });

    group('fromString', () {
      test('returns nobody for "nobody"', () {
        expect(CommentPermission.fromString('nobody'), CommentPermission.nobody);
      });

      test('returns followers for "followers"', () {
        expect(CommentPermission.fromString('followers'), CommentPermission.followers);
      });

      test('returns everyone for "everyone"', () {
        expect(CommentPermission.fromString('everyone'), CommentPermission.everyone);
      });

      test('handles uppercase input', () {
        expect(CommentPermission.fromString('NOBODY'), CommentPermission.nobody);
        expect(CommentPermission.fromString('Followers'), CommentPermission.followers);
        expect(CommentPermission.fromString('EVERYONE'), CommentPermission.everyone);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => CommentPermission.fromString('unknown'), throwsArgumentError);
      });

      test('throws ArgumentError for empty string', () {
        expect(() => CommentPermission.fromString(''), throwsArgumentError);
      });
    });

    group('value extension', () {
      test('round-trips through value and fromString', () {
        for (final permission in CommentPermission.values) {
          expect(CommentPermission.fromString(permission.value), permission);
        }
      });

      test('nobody has value "nobody"', () {
        expect(CommentPermission.nobody.value, 'nobody');
      });

      test('followers has value "followers"', () {
        expect(CommentPermission.followers.value, 'followers');
      });

      test('everyone has value "everyone"', () {
        expect(CommentPermission.everyone.value, 'everyone');
      });
    });
  });
}
