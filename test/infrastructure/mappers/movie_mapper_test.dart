import 'package:cinema_app/infrastructure/mappers/movie_mapper.dart';
import 'package:cinema_app/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinema_app/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:flutter_test/flutter_test.dart';

MovieMovieDB _buildMovieMovieDB({
  String backdropPath = '/backdrop.jpg',
  String posterPath = '/poster.jpg',
  double voteAverage = 7.456,
  List<int> genreIds = const [28, 12],
}) => MovieMovieDB(
  adult: false,
  backdropPath: backdropPath,
  genreIds: genreIds,
  id: 1,
  title: 'Test Movie',
  originalLanguage: 'en',
  originalTitle: 'Original Test Movie',
  overview: 'overview',
  popularity: 10.0,
  posterPath: posterPath,
  releaseDate: DateTime(2024, 5, 10),
  softcore: false,
  video: false,
  voteAverage: voteAverage,
  voteCount: 50,
);

MovieDetails _buildMovieDetails({
  String backdropPath = '/backdrop.jpg',
  String posterPath = '/poster.jpg',
  double voteAverage = 8.256,
  List<Genre> genres = const [],
}) => MovieDetails(
  adult: false,
  backdropPath: backdropPath,
  belongsToCollection: null,
  budget: 0,
  genres: genres,
  homepage: '',
  id: 2,
  imdbId: 'tt123',
  originCountry: const ['US'],
  originalLanguage: 'en',
  originalTitle: 'Original Detail Movie',
  overview: 'overview detail',
  popularity: 20.0,
  posterPath: posterPath,
  productionCompanies: const [],
  productionCountries: const [],
  releaseDate: DateTime(2023, 3, 1),
  revenue: 0,
  runtime: 120,
  softcore: false,
  spokenLanguages: const [],
  status: 'Released',
  tagline: '',
  title: 'Detail Movie',
  video: false,
  voteAverage: voteAverage,
  voteCount: 30,
);

void main() {
  group('MovieMapper.movieDBToEntity', () {
    test('builds full TMDB image URLs when paths are present', () {
      final movie = MovieMapper.movieDBToEntity(_buildMovieMovieDB());

      expect(movie.backdropPath, 'https://image.tmdb.org/t/p/w500/backdrop.jpg');
      expect(movie.posterPath, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('falls back to a placeholder image when paths are empty', () {
      final movie = MovieMapper.movieDBToEntity(
        _buildMovieMovieDB(backdropPath: '', posterPath: ''),
      );

      expect(movie.backdropPath, contains('gstatic.com'));
      expect(movie.posterPath, contains('gstatic.com'));
    });

    test('converts numeric genreIds to a list of strings', () {
      final movie = MovieMapper.movieDBToEntity(
        _buildMovieMovieDB(genreIds: [28, 12]),
      );

      expect(movie.genreIds, ['28', '12']);
    });

    test('rounds voteAverage to a single decimal', () {
      final movie = MovieMapper.movieDBToEntity(
        _buildMovieMovieDB(voteAverage: 7.456),
      );

      expect(movie.voteAverage, 7.5);
    });
  });

  group('MovieMapper.movieDetailsToEntity', () {
    test('builds full TMDB image URLs when paths are present', () {
      final movie = MovieMapper.movieDetailsToEntity(_buildMovieDetails());

      expect(movie.backdropPath, 'https://image.tmdb.org/t/p/w500/backdrop.jpg');
      expect(movie.posterPath, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('falls back to a placeholder image when paths are empty', () {
      final movie = MovieMapper.movieDetailsToEntity(
        _buildMovieDetails(backdropPath: '', posterPath: ''),
      );

      expect(movie.backdropPath, contains('gstatic.com'));
      expect(movie.posterPath, contains('gstatic.com'));
    });

    test('maps genre names instead of ids', () {
      final movie = MovieMapper.movieDetailsToEntity(
        _buildMovieDetails(genres: [Genre(id: 28, name: 'Action')]),
      );

      expect(movie.genreIds, ['Action']);
    });

    test('rounds voteAverage to a single decimal', () {
      final movie = MovieMapper.movieDetailsToEntity(
        _buildMovieDetails(voteAverage: 8.256),
      );

      expect(movie.voteAverage, 8.3);
    });
  });
}
