import 'package:cinema_app/infrastructure/mappers/actor_mapper.dart';
import 'package:cinema_app/infrastructure/models/moviedb/credits_response.dart';
import 'package:flutter_test/flutter_test.dart';

Cast _buildCast({String? profilePath, String? character}) => Cast(
  adult: false,
  gender: 2,
  id: 1,
  knownForDepartment: 'Acting',
  name: 'Test Actor',
  originalName: 'Test Actor',
  popularity: 5.0,
  profilePath: profilePath,
  creditId: 'credit-1',
  character: character,
);

void main() {
  group('ActorMapper.castToEntity', () {
    test('builds a full TMDB image URL when profilePath is present', () {
      final actor = ActorMapper.castToEntity(_buildCast(profilePath: '/actor.jpg'));

      expect(actor.profilePath, 'https://image.tmdb.org/t/p/w500/actor.jpg');
    });

    test('falls back to a placeholder avatar when profilePath is null', () {
      final actor = ActorMapper.castToEntity(_buildCast(profilePath: null));

      expect(actor.profilePath, contains('pixabay.com'));
    });

    test('maps id, name and character as-is', () {
      final actor = ActorMapper.castToEntity(
        _buildCast(profilePath: '/actor.jpg', character: 'Hero'),
      );

      expect(actor.id, 1);
      expect(actor.name, 'Test Actor');
      expect(actor.character, 'Hero');
    });
  });
}
