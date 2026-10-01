import 'package:cinema_app/domain/entities/actor.dart';
import 'package:cinema_app/domain/entities/movies.dart';
import 'package:cinema_app/infrastructure/models/static/static_cast.dart';
import 'package:cinema_app/infrastructure/models/static/static_movie.dart';

class StaticMapper {
  static const _noProfileImage =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png';

  /// [genres] permite sustituir los ids de género por sus nombres (detalle de película).
  static Movie movieToEntity(StaticMovie movie, {Map<int, String>? genres}) => Movie(
        adult: false,
        backdropPath: movie.backdropUrl,
        genreIds: genres == null
            ? movie.genreIds.map((id) => id.toString()).toList()
            : movie.genreIds.map((id) => genres[id]).whereType<String>().toList(),
        id: movie.id,
        originalLanguage: movie.originalLanguage,
        originalTitle: movie.originalTitle,
        overview: movie.overview,
        popularity: movie.sitelinks.toDouble(),
        posterPath: movie.posterUrl,
        releaseDate: movie.releaseDate,
        title: movie.title,
        video: false,
        voteAverage: movie.relevance,
        voteCount: movie.sitelinks,
      );

  static Actor castToEntity(StaticCast cast) => Actor(
        id: cast.id,
        name: cast.name,
        profilePath: cast.profileUrl ?? _noProfileImage,
        character: cast.character.isEmpty ? null : cast.character,
      );
}
