import 'package:cinema_app/presentation/providers/movies/movies_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('MoviesNotifier', () {
    test('requests page 1 on the first call and stores the result', () async {
      final calledPages = <int>[];
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          calledPages.add(page);
          return [buildMovie(id: page)];
        },
      );

      await notifier.loadNextPage();

      expect(calledPages, [1]);
      expect(notifier.state.map((m) => m.id), [1]);
    });

    test('increments the page and accumulates movies across calls', () async {
      final calledPages = <int>[];
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          calledPages.add(page);
          return [buildMovie(id: page)];
        },
      );

      await notifier.loadNextPage();
      await notifier.loadNextPage();

      expect(calledPages, [1, 2]);
      expect(notifier.state.map((m) => m.id), [1, 2]);
    });

    test('ignores a concurrent call while one is already in flight', () async {
      var callCount = 0;
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          callCount++;
          return [buildMovie(id: page)];
        },
      );

      final first = notifier.loadNextPage();
      final second = notifier.loadNextPage();
      await Future.wait([first, second]);

      expect(callCount, 1);
      expect(notifier.state.length, 1);
    });
  });
}
