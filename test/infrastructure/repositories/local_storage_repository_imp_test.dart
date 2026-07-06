import 'package:cinema_app/domain/datasources/local_storage_datasource.dart';
import 'package:cinema_app/infrastructure/repositories/local_storage_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockLocalStorageDatasource extends Mock implements LocalStorageDatasource {}

void main() {
  late _MockLocalStorageDatasource datasource;
  late LocalStorageRepositoryImp repository;

  setUp(() {
    datasource = _MockLocalStorageDatasource();
    repository = LocalStorageRepositoryImp(datasource);
  });

  test('isFavoriteMovie delegates to the datasource', () async {
    when(() => datasource.isFavoriteMovie(1)).thenAnswer((_) async => true);

    final result = await repository.isFavoriteMovie(1);

    expect(result, true);
  });

  test('loadFavoriteMovies delegates limit and offset to the datasource', () async {
    final movies = [buildMovie(id: 1)];
    when(() => datasource.loadFavoriteMovies(limit: 10, offset: 20))
        .thenAnswer((_) async => movies);

    final result = await repository.loadFavoriteMovies(limit: 10, offset: 20);

    expect(result, movies);
  });

  test('toggleFavoriteMovie delegates to the datasource', () async {
    final movie = buildMovie(id: 1);
    when(() => datasource.toggleFavoriteMovie(movie)).thenAnswer((_) async {});

    await repository.toggleFavoriteMovie(movie);

    verify(() => datasource.toggleFavoriteMovie(movie)).called(1);
  });
}
