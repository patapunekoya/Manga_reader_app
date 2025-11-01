// lib/debug/tool_mangadex_test.dart
import 'package:dio/dio.dart';

Future<void> testFetchTrending() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.mangadex.org',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'manga_reader_app/1.0 (flutter test)',
      },
    ),
  );

  print('=== CALLING MANGADEX /manga (trending) ===');

  try {
    final resp = await dio.get(
      '/manga',
      queryParameters: {
        'limit': 5,
        'offset': 0,
        'includes[]': ['cover_art', 'author'],
        'contentRating[]': ['safe', 'suggestive'],
        'order[followedCount]': 'desc',
      },
    );

    print('STATUS: ${resp.statusCode}');
    final data = resp.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List && list.isNotEmpty) {
        print('Got ${list.length} manga(s).');

        final first = list.first;
        print('--- first manga ---');

        // id
        print('id: ${first['id']}');

        // title (attributes.title.en maybe)
        final attrs = first['attributes'];
        if (attrs is Map<String, dynamic>) {
          final titleMap = attrs['title'];
          if (titleMap is Map<String, dynamic>) {
            print('title.en: ${titleMap['en']}');
          }
          print('status: ${attrs['status']}');
        }

        // relationships -> cover_art
        final rel = first['relationships'];
        if (rel is List) {
          for (final r in rel) {
            if (r is Map &&
                r['type'] == 'cover_art' &&
                r['attributes'] is Map<String, dynamic>) {
              final fileName = r['attributes']['fileName'];
              final mangaId = first['id'];
              final coverUrl =
                  'https://uploads.mangadex.org/covers/$mangaId/$fileName.256.jpg';

              print('cover fileName: $fileName');
              print('cover url: $coverUrl');
              break;
            }
          }
        }
      } else {
        print('No manga data returned (list empty).');
      }
    } else {
      print('Unexpected resp.data type: ${data.runtimeType}');
      print(data);
    }
  } catch (e, st) {
    print('ERROR when calling MangaDex: $e');
    print(st);
  }
}
