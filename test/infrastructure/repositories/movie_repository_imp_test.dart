import 'package:cinema_app/domain/datasources/movies_datasources.dart';
import 'package:cinema_app/infrastructure/repositories/movie_repository_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockMoviesDataSources extends Mock implements MoviesDataSources {}

void main() {
  late _MockMoviesDataSources dataSources;
  late MovieRepositoryImp repository;

  setUp(() {
    dataSources = _MockMoviesDataSources();
    repository = MovieRepositoryImp(dataSources);
  });

  test('getNowPlaying delegates to the datasource with the given page', () async {
    final movies = [buildMovie(id: 1)];
    when(() => dataSources.getNowPlaying(page: 2)).thenAnswer((_) async => movies);

    final result = await repository.getNowPlaying(page: 2);

    expect(result, movies);
    verify(() => dataSources.getNowPlaying(page: 2)).called(1);
  });

  test('getPopular delegates to the datasource', () async {
    final movies = [buildMovie(id: 2)];
    when(() => dataSources.getPopular(page: 1)).thenAnswer((_) async => movies);

    final result = await repository.getPopular();

    expect(result, movies);
  });

  test('getUpcoming delegates to the datasource', () async {
    final movies = [buildMovie(id: 3)];
    when(() => dataSources.getUpcoming(page: 1)).thenAnswer((_) async => movies);

    final result = await repository.getUpcoming();

    expect(result, movies);
  });

  test('getTopRated delegates to the datasource', () async {
    final movies = [buildMovie(id: 4)];
    when(() => dataSources.getTopRated(page: 1)).thenAnswer((_) async => movies);

    final result = await repository.getTopRated();

    expect(result, movies);
  });

  test('getMovieById delegates to the datasource', () async {
    final movie = buildMovie(id: 5);
    when(() => dataSources.getMovieById('5')).thenAnswer((_) async => movie);

    final result = await repository.getMovieById('5');

    expect(result, movie);
  });

  test('searchMovies delegates to the datasource', () async {
    final movies = [buildMovie(id: 6)];
    when(() => dataSources.searchMovies('matrix')).thenAnswer((_) async => movies);

    final result = await repository.searchMovies('matrix');

    expect(result, movies);
  });

  test('getMoviesByGenre delegates to the datasource with genreId and page', () async {
    final movies = [buildMovie(id: 7)];
    when(() => dataSources.getMoviesByGenre(28, page: 3)).thenAnswer((_) async => movies);

    final result = await repository.getMoviesByGenre(28, page: 3);

    expect(result, movies);
    verify(() => dataSources.getMoviesByGenre(28, page: 3)).called(1);
  });
}
