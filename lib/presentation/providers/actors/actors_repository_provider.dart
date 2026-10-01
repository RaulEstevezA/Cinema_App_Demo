// Repositorio inmutable
import 'package:cinema_app/infrastructure/datasources/static/static_actors_datasource.dart';
import 'package:cinema_app/infrastructure/repositories/actor_repository_imp.dart';
import 'package:cinema_app/presentation/providers/static_database/static_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorsRepositoryProvider = Provider((ref) {
  return ActorRepositoryImp(StaticActorsDatasource(ref.watch(staticDatabaseProvider)));
});
