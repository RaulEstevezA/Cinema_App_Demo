import 'package:cinema_app/domain/entities/movies.dart';
import 'package:cinema_app/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinema_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/legacy.dart';


final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref){
  final fetchMoreMovies = ref.watch( movieRepositoryProvider).getNowPlaying;

 return MoviesNotifier(
  fetchMoreMovies: fetchMoreMovies
 );
});


final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref){
  final fetchMoreMovies = ref.watch( movieRepositoryProvider).getPopular;

 return MoviesNotifier(
  fetchMoreMovies: fetchMoreMovies
 );
});


final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref){
  final fetchMoreMovies = ref.watch( movieRepositoryProvider).getUpcoming;

 return MoviesNotifier(
  fetchMoreMovies: fetchMoreMovies
 );
});


final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref){
  final fetchMoreMovies = ref.watch( movieRepositoryProvider).getTopRated;

 return MoviesNotifier(
  fetchMoreMovies: fetchMoreMovies
 );
});

final moviesByGenreProvider = StateNotifierProvider.family<MoviesNotifier, List<Movie>, int>((ref, genreId){
  final movieRepository = ref.watch(movieRepositoryProvider);

 return MoviesNotifier(
  fetchMoreMovies: ({int page = 1}) => movieRepository.getMoviesByGenre(genreId, page: page),
 );
});

typedef MovieCallback = Future<List<Movie>> Function({ int page });


class MoviesNotifier extends StateNotifier<List<Movie>> {
  bool isLoading = false;

  int currentPage = 0;
  MovieCallback fetchMoreMovies;

  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super ([]);

  Future<void> loadNextPage() async{
    if(isLoading) return;

    isLoading = true;

    try {
      currentPage++;

      final List<Movie> movies = await fetchMoreMovies (page: currentPage);
      state = [...state, ...movies];
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      isLoading = false;
    }
  }
}
