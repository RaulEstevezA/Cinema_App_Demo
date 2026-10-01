

import 'package:cinema_app/domain/entities/genres.dart';
import 'package:cinema_app/infrastructure/datasources/static/static_genres_datasource.dart';
import 'package:cinema_app/infrastructure/repositories/genre_repository_imp.dart';
import 'package:cinema_app/presentation/providers/static_database/static_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final genresRepositoryProvider = Provider<GenreRepositoryImp>((ref) {
  return GenreRepositoryImp(datasource: StaticGenresDatasource(ref.watch(staticDatabaseProvider)));
});

final genresProvider = FutureProvider<List<Genres>>((ref) {
  final genresRepository = ref.watch(genresRepositoryProvider);
  return genresRepository.getGenre();
});