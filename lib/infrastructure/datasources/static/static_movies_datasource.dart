import 'package:cinema_app/domain/datasources/movies_datasources.dart';
import 'package:cinema_app/domain/entities/movies.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_database.dart';
import 'package:cinema_app/infrastructure/mappers/static_mapper.dart';
import 'package:cinema_app/infrastructure/models/static/static_movie.dart';

class StaticMoviesDatasource extends MoviesDataSources {
  static const int pageSize = 20;

  final StaticDatabase database;

  StaticMoviesDatasource(this.database);

  List<Movie> _toEntities(Iterable<StaticMovie> movies) => movies
      .where((movie) => movie.posterUrl.isNotEmpty)
      .map((movie) => StaticMapper.movieToEntity(movie))
      .toList();

  List<T> _page<T>(List<T> items, int page) =>
      items.skip((page - 1) * pageSize).take(pageSize).toList();

  Future<List<Movie>> _getList(String name, int page) async {
    final movies = await database.movies();
    final ids = (await database.lists())[name] ?? const <int>[];

    final listMovies = _page(ids, page)
        .map((id) => movies[id])
        .whereType<StaticMovie>();

    return _toEntities(listMovies);
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) => _getList('now_playing', page);

  @override
  Future<List<Movie>> getPopular({int page = 1}) => _getList('popular', page);

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) => _getList('upcoming', page);

  @override
  Future<List<Movie>> getTopRated({int page = 1}) => _getList('top_rated', page);

  @override
  Future<Movie> getMovieById(String id) async {
    final movie = (await database.movies())[int.tryParse(id)];
    if (movie == null) throw Exception('Movie with id: $id not found');

    // Igual que el detalle de TMDB: en el detalle los géneros van por nombre.
    final genres = {
      for (final genre in await database.genres()) genre.id: genre.name,
    };

    return StaticMapper.movieToEntity(movie, genres: genres);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final normalizedQuery = _normalize(query.trim());
    if (normalizedQuery.isEmpty) return [];

    final movies = (await database.movies()).values
        .where((movie) =>
            _normalize(movie.title).contains(normalizedQuery) ||
            _normalize(movie.originalTitle).contains(normalizedQuery))
        .toList()
      ..sort((a, b) => b.sitelinks.compareTo(a.sitelinks));

    return _toEntities(movies.take(pageSize));
  }

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final movies = (await database.movies()).values
        .where((movie) => movie.genreIds.contains(genreId))
        .toList()
      ..sort((a, b) => b.sitelinks.compareTo(a.sitelinks));

    return _toEntities(_page(movies, page));
  }

  static const _accents = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    'ñ': 'n', 'ç': 'c',
  };

  static String _normalize(String text) => text
      .toLowerCase()
      .split('')
      .map((char) => _accents[char] ?? char)
      .join();
}
