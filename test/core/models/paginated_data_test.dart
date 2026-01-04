import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer/core/models/paginated_data.dart';
import 'package:solo_adventurer/core/models/page_info.dart';

/// Sample model for testing pagination
class TestModel {
  final String id;
  final String name;

  TestModel({
    required this.id,
    required this.name,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

void main() {
  group('PaginatedData', () {
    group('Constructor', () {
      test('should create PaginatedData with items and pageInfo', () {
        final items = [
          TestModel(id: '1', name: 'Item 1'),
          TestModel(id: '2', name: 'Item 2'),
        ];

        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final paginatedData = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo,
        );

        expect(paginatedData.items, equals(items));
        expect(paginatedData.pageInfo, equals(pageInfo));
        expect(paginatedData.itemCount, equals(2));
      });

      test('should create empty PaginatedData using empty constructor', () {
        final paginatedData = PaginatedData<TestModel>.empty();

        expect(paginatedData.items, isEmpty);
        expect(paginatedData.itemCount, equals(0));
        expect(paginatedData.isEmpty, isTrue);
        expect(paginatedData.isNotEmpty, isFalse);
        expect(paginatedData.pageInfo.currentPage, equals(1));
        expect(paginatedData.pageInfo.totalItems, equals(0));
        expect(paginatedData.pageInfo.hasNextPage, isFalse);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final items = [
          TestModel(id: '1', name: 'Item 1'),
          TestModel(id: '2', name: 'Item 2'),
        ];

        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final paginatedData = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo,
        );

        final json = paginatedData.toJson((item) => item.toJson());

        expect(json['items'], isA<List>());
        expect((json['items'] as List).length, equals(2));
        expect(json['pageInfo'], isA<Map<String, dynamic>>());

        final itemsJson = json['items'] as List;
        expect(itemsJson[0]['id'], equals('1'));
        expect(itemsJson[0]['name'], equals('Item 1'));
        expect(itemsJson[1]['id'], equals('2'));
        expect(itemsJson[1]['name'], equals('Item 2'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'items': [
            {'id': '1', 'name': 'Item 1'},
            {'id': '2', 'name': 'Item 2'},
          ],
          'pageInfo': {
            'currentPage': 1,
            'itemsPerPage': 20,
            'totalItems': 100,
            'totalPages': 5,
            'hasNextPage': true,
            'hasPreviousPage': false,
            'nextCursor': null,
            'previousCursor': null,
          },
        };

        final paginatedData = PaginatedData.fromJson(
          json,
          (itemJson) => TestModel.fromJson(itemJson),
        );

        expect(paginatedData.items.length, equals(2));
        expect(paginatedData.items[0].id, equals('1'));
        expect(paginatedData.items[0].name, equals('Item 1'));
        expect(paginatedData.items[1].id, equals('2'));
        expect(paginatedData.items[1].name, equals('Item 2'));
        expect(paginatedData.pageInfo.currentPage, equals(1));
        expect(paginatedData.pageInfo.totalItems, equals(100));
        expect(paginatedData.pageInfo.hasNextPage, isTrue);
      });

      test('should handle empty items list in JSON', () {
        final json = {
          'items': <dynamic>[],
          'pageInfo': {
            'currentPage': 1,
            'itemsPerPage': 20,
            'totalItems': 0,
            'totalPages': 0,
            'hasNextPage': false,
            'hasPreviousPage': false,
            'nextCursor': null,
            'previousCursor': null,
          },
        };

        final paginatedData = PaginatedData.fromJson(
          json,
          (itemJson) => TestModel.fromJson(itemJson),
        );

        expect(paginatedData.items, isEmpty);
        expect(paginatedData.itemCount, equals(0));
        expect(paginatedData.isEmpty, isTrue);
      });
    });

    group('Getters', () {
      test('should provide access to pageInfo fields', () {
        final pageInfo = PageInfo(
          currentPage: 2,
          itemsPerPage: 15,
          totalItems: 45,
          totalPages: 3,
          hasNextPage: true,
          hasPreviousPage: true,
        );

        final paginatedData = PaginatedData<TestModel>(
          items: [TestModel(id: '1', name: 'Item 1')],
          pageInfo: pageInfo,
        );

        expect(paginatedData.currentPage, equals(2));
        expect(paginatedData.itemsPerPage, equals(15));
        expect(paginatedData.totalItems, equals(45));
        expect(paginatedData.totalPages, equals(3));
        expect(paginatedData.hasNextPage, isTrue);
        expect(paginatedData.hasPreviousPage, isTrue);
      });

      test('should return first and last items correctly', () {
        final items = [
          TestModel(id: '1', name: 'Item 1'),
          TestModel(id: '2', name: 'Item 2'),
          TestModel(id: '3', name: 'Item 3'),
        ];

        final paginatedData = PaginatedData<TestModel>(
          items: items,
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        );

        expect(paginatedData.firstOrNull?.id, equals('1'));
        expect(paginatedData.lastOrNull?.id, equals('3'));
      });

      test('should return null for first/last when empty', () {
        final paginatedData = PaginatedData<TestModel>.empty();

        expect(paginatedData.firstOrNull, isNull);
        expect(paginatedData.lastOrNull, isNull);
      });

      test('should return same item for first/last when single item', () {
        final items = [TestModel(id: '1', name: 'Item 1')];

        final paginatedData = PaginatedData<TestModel>(
          items: items,
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );

        expect(paginatedData.firstOrNull?.id, equals('1'));
        expect(paginatedData.lastOrNull?.id, equals('1'));
        expect(paginatedData.firstOrNull, equals(paginatedData.lastOrNull));
      });
    });

    group('copyWith', () {
      test('should create copy with modified items', () {
        final originalItems = [
          TestModel(id: '1', name: 'Item 1'),
        ];

        final originalPageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final original = PaginatedData<TestModel>(
          items: originalItems,
          pageInfo: originalPageInfo,
        );

        final newItems = [
          TestModel(id: '2', name: 'Item 2'),
          TestModel(id: '3', name: 'Item 3'),
        ];

        final copy = original.copyWith(items: newItems);

        expect(copy.items, equals(newItems));
        expect(copy.pageInfo, equals(originalPageInfo));
        expect(original.items, equals(originalItems)); // unchanged
      });

      test('should create copy with modified pageInfo', () {
        final originalPageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final original = PaginatedData<TestModel>(
          items: [TestModel(id: '1', name: 'Item 1')],
          pageInfo: originalPageInfo,
        );

        final newPageInfo = originalPageInfo.copyWith(currentPage: 2);

        final copy = original.copyWith(pageInfo: newPageInfo);

        expect(copy.items, equals(original.items)); // unchanged
        expect(copy.pageInfo.currentPage, equals(2));
        expect(original.pageInfo.currentPage, equals(1)); // unchanged
      });

      test('should not modify original when copying', () {
        final original = PaginatedData<TestModel>(
          items: [TestModel(id: '1', name: 'Item 1')],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        );

        original.copyWith(
          items: [TestModel(id: '2', name: 'Item 2')],
          pageInfo: original.pageInfo.copyWith(currentPage: 2),
        );

        expect(original.items[0].id, equals('1'));
        expect(original.pageInfo.currentPage, equals(1));
      });
    });

    group('Equality', () {
      test('should be equal when items and pageInfo match', () {
        final items = [
          TestModel(id: '1', name: 'Item 1'),
          TestModel(id: '2', name: 'Item 2'),
        ];

        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final paginatedData1 = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo,
        );

        final paginatedData2 = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo,
        );

        expect(paginatedData1, equals(paginatedData2));
        expect(paginatedData1.hashCode, equals(paginatedData2.hashCode));
      });

      test('should not be equal when items differ', () {
        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final paginatedData1 = PaginatedData<TestModel>(
          items: [TestModel(id: '1', name: 'Item 1')],
          pageInfo: pageInfo,
        );

        final paginatedData2 = PaginatedData<TestModel>(
          items: [TestModel(id: '2', name: 'Item 2')],
          pageInfo: pageInfo,
        );

        expect(paginatedData1, isNot(equals(paginatedData2)));
      });

      test('should not be equal when pageInfo differs', () {
        final items = [TestModel(id: '1', name: 'Item 1')];

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

        final paginatedData1 = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo1,
        );

        final paginatedData2 = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo2,
        );

        expect(paginatedData1, isNot(equals(paginatedData2)));
      });
    });

    group('toString', () {
      test('should format string correctly', () {
        final items = [
          TestModel(id: '1', name: 'Item 1'),
          TestModel(id: '2', name: 'Item 2'),
        ];

        final pageInfo = PageInfo(
          currentPage: 1,
          itemsPerPage: 20,
          totalItems: 100,
          totalPages: 5,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        final paginatedData = PaginatedData<TestModel>(
          items: items,
          pageInfo: pageInfo,
        );

        final str = paginatedData.toString();

        expect(str, contains('itemCount: 2'));
        expect(str, contains('pageInfo:'));
      });
    });

    group('Generic Type Support', () {
      test('should work with different types', () {
        // Test with String type
        final stringData = PaginatedData<String>(
          items: ['a', 'b', 'c'],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );

        expect(stringData.itemCount, equals(3));
        expect(stringData.items[0], equals('a'));

        // Test with int type
        final intData = PaginatedData<int>(
          items: [1, 2, 3, 4, 5],
          pageInfo: PageInfo(
            currentPage: 1,
            itemsPerPage: 20,
            totalItems: 5,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );

        expect(intData.itemCount, equals(5));
        expect(intData.items[2], equals(3));
      });
    });
  });
}
