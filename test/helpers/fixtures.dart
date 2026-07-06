import 'package:cinema_app/domain/entities/movies.dart';

Movie buildMovie({
  int id = 1,
  String title = 'Test Movie',
  double voteAverage = 7.5,
}) => Movie(
  adult: false,
  backdropPath: 'https://image.tmdb.org/t/p/w500/backdrop.jpg',
  genreIds: const ['28'],
  id: id,
  originalLanguage: 'en',
  originalTitle: title,
  overview: 'A test overview',
  popularity: 12.3,
  posterPath: 'https://image.tmdb.org/t/p/w500/poster.jpg',
  releaseDate: DateTime(2024, 1, 1),
  title: title,
  video: false,
  voteAverage: voteAverage,
  voteCount: 100,
);
