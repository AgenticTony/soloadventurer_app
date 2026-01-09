import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer/core/models/page_info.dart';

void main() {
  group('PageInfo', () {
    group('Constructor', () {
      test('should create PageInfo with all required fields', () {
        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        expect(pageInfo.currentPage, equals(1));
        expect(pageInfo.itemsPerPage, equals(20));
        expect(pageInfo.totalItems, equals(100));
        expect(pageInfo.totalPages, equals(5));
        expect(pageInfo.hasNextPage, isTrue);
        expect(pageInfo.hasPreviousPage, isFalse);
      });

      test('should create PageInfo with optional cursor fields', () {
        final pageInfo = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: true,
          nextCursor: 'cursor3',
          previousCursor: 'cursor1',
        );

        expect(pageInfo.nextCursor, equals('cursor3'));
        expect(pageInfo.previousCursor, equals('cursor1'));
      });

      test('should create PageInfo with null totals', () {
        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        expect(pageInfo.totalItems, isNull);
        expect(pageInfo.totalPages, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final pageInfo = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
          nextCursor: 'abc123',
          previousCursor: 'xyz789',
        );

        final json = pageInfo.toJson();

        expect(json['currentPage'], equals(2));
        expect(json['itemsPerPage'], equals(20));
        expect(json['totalItems'], equals(100));
        expect(json['totalPages'], equals(5));
        expect(json['hasNextPage'], isTrue);
        expect(json['hasPreviousPage'], isTrue);
        expect(json['nextCursor'], equals('abc123'));
        expect(json['previousCursor'], equals('xyz789'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'currentPage': 3,
          'itemsPerPage': 15,
          'totalItems': 45,
          'totalPages': 3,
          'hasNextPage': false,
          'hasPreviousPage': true,
          'nextCursor': null,
          'previousCursor': 'def456',
        };

        final pageInfo = PageInfo.fromJson(json);

        expect(pageInfo.currentPage, equals(3));
        expect(pageInfo.itemsPerPage, equals(15));
        expect(pageInfo.totalItems, equals(45));
        expect(pageInfo.totalPages, equals(3));
        expect(pageInfo.hasNextPage, isFalse);
        expect(pageInfo.hasPreviousPage, isTrue);
        expect(pageInfo.nextCursor, isNull);
        expect(pageInfo.previousCursor, equals('def456'));
      });

      test('should handle null values in JSON', () {
        final json = {
          'currentPage': 1,
          'itemsPerPage': 20,
          'totalItems': null,
          'totalPages': null,
          'hasNextPage': true,
          'hasPreviousPage': false,
          'nextCursor': null,
          'previousCursor': null,
        };

        final pageInfo = PageInfo.fromJson(json);

        expect(pageInfo.totalItems, isNull);
        expect(pageInfo.totalPages, isNull);
        expect(pageInfo.nextCursor, isNull);
        expect(pageInfo.previousCursor, isNull);
      });
    });

    group('Getters', () {
      test('should calculate offset correctly', () {
        final pageInfo1 = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );
        expect(pageInfo1.offset, equals(0));

        final pageInfo2 = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: true,
        );
        expect(pageInfo2.offset, equals(20));

        final pageInfo3 = PageInfo(
          currentPage: 3,
          itemsPerPage: 15,
          hasNextPage: false,
          hasPreviousPage: true,
        );
        expect(pageInfo3.offset, equals(30));
      });

      test('should identify first page correctly', () {
        final firstPage = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );
        expect(firstPage.isFirstPage, isTrue);

        final secondPage = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: true,
        );
        expect(secondPage.isFirstPage, isFalse);
      });

      test('should identify last page correctly when totalPages is known', () {
        final middlePage = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
        );
        expect(middlePage.isLastPage, isFalse);

        final lastPage = PageInfo(
          currentPage: 5,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: false,
          hasPreviousPage: true,
        );
        expect(lastPage.isLastPage, isTrue);
      });

      test('should return false for isLastPage when totalPages is null', () {
        final pageInfo = PageInfo(
          currentPage: 5,
          itemsPerPage: 20,
          hasNextPage: false,
          hasPreviousPage: true,
        );
        expect(pageInfo.isLastPage, isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
        );

        final copy = original.copyWith(
          currentPage: 3,
          hasNextPage: false,
        );

        expect(copy.currentPage, equals(3));
        expect(copy.itemsPerPage, equals(20)); // unchanged
        expect(copy.totalItems, equals(100)); // unchanged
        expect(copy.totalPages, equals(5)); // unchanged
        expect(copy.hasNextPage, isFalse);
        expect(copy.hasPreviousPage, isTrue); // unchanged
      });

      test('should not modify original when copying', () {
        final original = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: true,
        );

        original.copyWith(currentPage: 3);

        expect(original.currentPage, equals(2));
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final pageInfo1 = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
          nextCursor: 'abc',
          previousCursor: 'xyz',
        );

        final pageInfo2 = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
          nextCursor: 'abc',
          previousCursor: 'xyz',
        );

        expect(pageInfo1, equals(pageInfo2));
        expect(pageInfo1.hashCode, equals(pageInfo2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final pageInfo1 = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final pageInfo2 = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: true,
        );

        expect(pageInfo1, isNot(equals(pageInfo2)));
      });

      test('should handle null values in equality', () {
        final pageInfo1 = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: null,
          totalPages: null,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final pageInfo2 = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        expect(pageInfo1, equals(pageInfo2));
      });
    });

    group('toString', () {
      test('should format string correctly', () {
        final pageInfo = PageInfo(
          currentPage: 2,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: true,
          nextCursor: 'abc',
          previousCursor: 'xyz',
        );

        final str = pageInfo.toString();

        expect(str, contains('currentPage: 2'));
        expect(str, contains('itemsPerPage: 20'));
        expect(str, contains('totalItems: 100'));
        expect(str, contains('totalPages: 5'));
        expect(str, contains('hasNextPage: true'));
        expect(str, contains('hasPreviousPage: true'));
        expect(str, contains('nextCursor: abc'));
        expect(str, contains('previousCursor: xyz'));
      });

      test('should show "unknown" for null totals', () {
        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final str = pageInfo.toString();

        expect(str, contains('totalItems: unknown'));
        expect(str, contains('totalPages: unknown'));
      });

      test('should show "none" for null cursors', () {
        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final str = pageInfo.toString();

        expect(str, contains('nextCursor: none'));
        expect(str, contains('previousCursor: none'));
      });
    });
  });
}
