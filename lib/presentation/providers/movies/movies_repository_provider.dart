import 'package:cinema_app/infrastructure/datasources/static/static_movies_datasource.dart';
import 'package:cinema_app/infrastructure/repositories/movie_repository_imp.dart';
import 'package:cinema_app/presentation/providers/static_database/static_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repositorio inmutable
final movieRepositoryProvider = Provider((ref) {
  return MovieRepositoryImp(StaticMoviesDatasource(ref.watch(staticDatabaseProvider)));
});
