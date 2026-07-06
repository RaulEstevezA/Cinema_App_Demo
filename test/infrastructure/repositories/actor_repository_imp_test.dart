import 'package:cinema_app/domain/datasources/actors_datasources.dart';
import 'package:cinema_app/domain/entities/actor.dart';
import 'package:cinema_app/infrastructure/repositories/actor_repository_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockActorsDatasources extends Mock implements ActorsDatasources {}

void main() {
  test('getActorsByMovie delegates to the datasource', () async {
    final datasources = _MockActorsDatasources();
    final repository = ActorRepositoryImp(datasources);
    final actors = [
      Actor(id: 1, name: 'Test Actor', profilePath: 'path.jpg', character: 'Hero'),
    ];

    when(() => datasources.getActorsByMovie('42')).thenAnswer((_) async => actors);

    final result = await repository.getActorsByMovie('42');

    expect(result, actors);
    verify(() => datasources.getActorsByMovie('42')).called(1);
  });
}
