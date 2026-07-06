import 'package:cinema_app/domain/datasources/genres_datasource.dart';
import 'package:cinema_app/domain/entities/genres.dart';
import 'package:cinema_app/infrastructure/repositories/genre_repository_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGenresDatasource extends Mock implements GenresDatasource {}

void main() {
  test('getGenre delegates to the datasource', () async {
    final datasource = _MockGenresDatasource();
    final repository = GenreRepositoryImp(datasource: datasource);
    final genres = [Genres(id: 28, genre: 'Acción')];

    when(() => datasource.getGenre()).thenAnswer((_) async => genres);

    final result = await repository.getGenre();

    expect(result, genres);
    verify(() => datasource.getGenre()).called(1);
  });
}
