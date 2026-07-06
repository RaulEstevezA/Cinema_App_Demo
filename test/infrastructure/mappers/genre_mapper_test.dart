import 'package:cinema_app/infrastructure/mappers/genre_mappers.dart';
import 'package:cinema_app/infrastructure/models/moviedb/genre_moviedb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GenreMapper.genresDBToEntity maps id and name to the Genres entity', () {
    final genre = GenreMapper.genresDBToEntity(Genre(id: 28, name: 'Acción'));

    expect(genre.id, 28);
    expect(genre.genre, 'Acción');
  });
}
