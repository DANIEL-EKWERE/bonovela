import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bonovela/core/api/api_client.dart';
import 'package:bonovela/core/models/feed_section.dart';
import 'package:bonovela/core/repository/api_book_repository.dart';

Map<String, dynamic> _book(int id, {bool short = false}) => {
  'id': id,
  'title': 'Book $id',
  'author': 'Ada',
  'genre': 'Romance',
  'tags': ['CEO'],
  'is_short': short,
  'updated_at': '2026-11-01T10:00:00Z',
};

void main() {
  late List<Uri> requests;

  ApiBookRepository repo(Object? Function(Uri uri) respond, {int status = 200}) {
    requests = [];
    final client = MockClient((req) async {
      requests.add(req.url);
      return http.Response(jsonEncode(respond(req.url)), status);
    });
    return ApiBookRepository(ApiClient(baseUrl: 'https://api.test/', client: client));
  }

  test('discover tab sections keep the server layout', () async {
    final feed = await repo(
      (_) => [
        {'title': 'Love on Top', 'layout': 'cover_grid', 'books': [_book(1), _book(2)]},
        {'title': 'Best Romance', 'layout': 'something_new', 'books': [_book(3)]},
      ],
    ).getDiscoverFeed('LGBTQ+');
    expect(requests.single.toString(), 'https://api.test/api/books/discover/?tab=LGBTQ%2B');
    expect(feed.map((s) => s.layout), [FeedLayout.coverGrid, FeedLayout.coverRow]); // unknown → cover row
    expect(feed.first.books.map((b) => b.id), ['1', '2']);
  });

  test('short collections parse categories and shelves', () async {
    final collections = await repo(
      (_) => [
        {
          'title': 'Love at First Sight',
          'sections': [
            {'title': 'Hearts in Bloom', 'layout': 'cover_row', 'books': [_book(7, short: true)]},
          ],
        },
        {'title': 'Empty', 'sections': []},
      ],
    ).getShortCollections();
    expect(collections.map((c) => c.title), ['Love at First Sight']);
    expect(collections.single.sections.single.books.single.isShort, isTrue);
  });

  test('book lists follow pagination', () async {
    final books = await repo(
      (uri) => uri.queryParameters['page'] == '1'
          ? {'next': 'page2', 'results': [_book(1)]}
          : {'next': null, 'results': [_book(2)]},
    ).getBooks(genre: 'Mafia');
    expect(books.map((b) => b.id), ['1', '2']);
    expect(requests.first.queryParameters, {'short': '0', 'genre': 'Mafia', 'page': '1'});
  });

  test('unlocking without coins returns null', () async {
    final chapter = await repo((_) => {'detail': 'Not enough coins.'}, status: 402).unlockChapter('5', 11);
    expect(chapter, isNull);
  });
}
