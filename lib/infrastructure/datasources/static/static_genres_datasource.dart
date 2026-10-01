import 'package:cinema_app/domain/datasources/genres_datasource.dart';
import 'package:cinema_app/domain/entities/genres.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_database.dart';
import 'package:cinema_app/infrastructure/mappers/genre_mappers.dart';

class StaticGenresDatasource extends GenresDatasource {
  final StaticDatabase database;

  StaticGenresDatasource(this.database);

  @override
  Future<List<Genres>> getGenre() async {
    final genres = await database.genres();
    return genres.map((genre) => GenreMapper.genresDBToEntity(genre)).toList();
  }
}
