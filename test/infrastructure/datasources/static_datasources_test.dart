import 'dart:convert';

import 'package:cinema_app/infrastructure/datasources/static/static_actors_datasource.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_database.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_genres_datasource.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_movies_datasource.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  final Map<String, Object> files;

  _MemoryAssetBundle(this.files);

  @override
  Future<ByteData> load(String key) async {
    final file = files[key];
    if (file == null) throw Exception('Unable to load asset: $key');
    final bytes = utf8.encode(json.encode(file));
    return ByteData.sublistView(bytes);
  }
}

Map<String, dynamic> _movie(int id, String title, List<int> genreIds, int sitelinks) => {
  'id': id,
  'wikidata_id': 'Q$id',
  'title': title,
  'original_title': title,
  'original_language': 'es',
  'overview': 'Resumen $id',
  'overview_source': 'https://es.wikipedia.org/wiki/Pelicula_$id',
  'release_date': '1924-01-0$id',
  'genre_ids': genreIds,
  'poster_url': 'https://upload.wikimedia.org/poster$id.jpg',
  'backdrop_url': 'https://upload.wikimedia.org/backdrop$id.jpg',
  'sitelinks': sitelinks,
  'relevance': 7.3,
};

void main() {
  late StaticDatabase database;

  setUp(() {
    database = StaticDatabase(_MemoryAssetBundle({
      'assets/data/genres.json': {
        'genres': [
          {'id': 28, 'name': 'Acción'},
          {'id': 35, 'name': 'Comedia'},
        ],
      },
      'assets/data/movies.json': {
        'results': [
          _movie(1, 'El Camión', [28], 10),
          _movie(2, 'Risas', [35], 50),
          _movie(3, 'Acción total', [28, 35], 30),
          {..._movie(4, 'Sin póster', [28], 99), 'poster_url': ''},
        ],
      },
      'assets/data/lists.json': {
        'now_playing': [3, 1],
        'popular': List.generate(25, (i) => i % 2 == 0 ? 1 : 2),
        'upcoming': [],
        'top_rated': [2, 999],
      },
      'assets/data/credits/1.json': {
        'id': 1,
        'cast': [
          {'id': 10, 'name': 'Actor Uno', 'character': 'Héroe', 'profile_url': 'https://upload.wikimedia.org/actor.jpg'},
          {'id': 11, 'name': 'Actor Dos', 'character': '', 'profile_url': null},
        ],
      },
    }));
  });

  group('StaticMoviesDatasource', () {
    test('returns list movies in order with image urls and relevance', () async {
      final movies = await StaticMoviesDatasource(database).getNowPlaying();

      expect(movies.map((m) => m.id), [3, 1]);
      expect(movies.first.posterPath, 'https://upload.wikimedia.org/poster3.jpg');
      expect(movies.first.backdropPath, 'https://upload.wikimedia.org/backdrop3.jpg');
      expect(movies.first.voteAverage, 7.3);
      expect(movies.first.popularity, 30);
      expect(movies.first.genreIds, ['28', '35']);
    });

    test('paginates lists and returns empty past the end', () async {
      final datasource = StaticMoviesDatasource(database);

      expect(await datasource.getPopular(page: 1), hasLength(20));
      expect(await datasource.getPopular(page: 2), hasLength(5));
      expect(await datasource.getPopular(page: 3), isEmpty);
      expect(await datasource.getUpcoming(), isEmpty);
    });

    test('skips ids missing from the catalog', () async {
      final movies = await StaticMoviesDatasource(database).getTopRated();

      expect(movies.map((m) => m.id), [2]);
    });

    test('getMovieById resolves genre names', () async {
      final movie = await StaticMoviesDatasource(database).getMovieById('3');

      expect(movie.title, 'Acción total');
      expect(movie.genreIds, ['Acción', 'Comedia']);
    });

    test('getMovieById throws for unknown ids', () {
      expect(StaticMoviesDatasource(database).getMovieById('999'), throwsException);
    });

    test('search ignores case and accents and sorts by popularity', () async {
      final datasource = StaticMoviesDatasource(database);

      expect((await datasource.searchMovies('ACCION')).map((m) => m.id), [3]);
      expect((await datasource.searchMovies('camion')).map((m) => m.id), [1]);
      expect((await datasource.searchMovies('i')).map((m) => m.id), [2, 3, 1]);
      expect(await datasource.searchMovies('  '), isEmpty);
    });

    test('filters by genre sorted by popularity, skipping movies without poster', () async {
      final movies = await StaticMoviesDatasource(database).getMoviesByGenre(28);

      expect(movies.map((m) => m.id), [3, 1]);
    });
  });

  test('StaticGenresDatasource maps genres', () async {
    final genres = await StaticGenresDatasource(database).getGenre();

    expect(genres.map((g) => g.genre), ['Acción', 'Comedia']);
  });

  group('StaticActorsDatasource', () {
    test('maps cast from credits file', () async {
      final actors = await StaticActorsDatasource(database).getActorsByMovie('1');

      expect(actors.map((a) => a.name), ['Actor Uno', 'Actor Dos']);
      expect(actors.first.profilePath, 'https://upload.wikimedia.org/actor.jpg');
      expect(actors.first.character, 'Héroe');
    });

    test('uses a placeholder photo and null character when missing', () async {
      final actors = await StaticActorsDatasource(database).getActorsByMovie('1');

      expect(actors.last.profilePath, startsWith('https://'));
      expect(actors.last.character, isNull);
    });

    test('returns empty list when the movie has no credits file', () async {
      expect(await StaticActorsDatasource(database).getActorsByMovie('2'), isEmpty);
    });
  });
}
