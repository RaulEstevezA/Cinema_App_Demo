import 'package:cinema_app/domain/datasources/actors_datasources.dart';
import 'package:cinema_app/domain/entities/actor.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_database.dart';
import 'package:cinema_app/infrastructure/mappers/static_mapper.dart';
import 'package:cinema_app/infrastructure/models/static/static_cast.dart';

class StaticActorsDatasource extends ActorsDatasources {
  final StaticDatabase database;

  StaticActorsDatasource(this.database);

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {
    final List<StaticCast> cast;
    try {
      cast = await database.credits(movieId);
    } catch (_) {
      // Película sin reparto en la base estática.
      return [];
    }

    return cast.map((cast) => StaticMapper.castToEntity(cast)).toList();
  }
}
