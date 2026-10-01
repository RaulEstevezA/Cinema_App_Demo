import 'dart:convert';

import 'package:cinema_app/infrastructure/models/moviedb/genre_moviedb.dart';
import 'package:cinema_app/infrastructure/models/static/static_cast.dart';
import 'package:cinema_app/infrastructure/models/static/static_movie.dart';
import 'package:flutter/services.dart';

/// Base de datos estática empaquetada como assets en `assets/data/`.
///
/// Los ficheros se generan con `dart run tool/generate_static_db.dart` a partir
/// de Wikidata, Wikimedia Commons y Wikipedia (ver `docs/DATA_ATTRIBUTION.md`).
class StaticDatabase {
  static const String basePath = 'assets/data';

  final AssetBundle bundle;

  StaticDatabase([AssetBundle? bundle]) : bundle = bundle ?? rootBundle;

  Future<Map<int, StaticMovie>>? _movies;
  Future<Map<String, List<int>>>? _lists;
  Future<List<Genre>>? _genres;

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await bundle.loadString('$basePath/$path', cache: false);
    return json.decode(raw) as Map<String, dynamic>;
  }

  /// Catálogo completo de películas indexado por id (en orden de inserción).
  Future<Map<int, StaticMovie>> movies() => _movies ??= _loadJson('movies.json').then((json) {
    final results = (json['results'] as List).map((x) => StaticMovie.fromJson(x));
    return {for (final movie in results) movie.id: movie};
  });

  /// Listados de la portada (`now_playing`, `popular`, `upcoming`, `top_rated`) como listas de ids.
  Future<Map<String, List<int>>> lists() => _lists ??= _loadJson('lists.json').then(
    (json) => json.map((key, ids) => MapEntry(key, List<int>.from(ids))),
  );

  Future<List<Genre>> genres() => _genres ??= _loadJson('genres.json').then(
    (json) => GenreMovies.fromJson(json).genres,
  );

  Future<List<StaticCast>> credits(String movieId) => _loadJson('credits/$movieId.json').then(
    (json) => (json['cast'] as List).map((x) => StaticCast.fromJson(x)).toList(),
  );
}
