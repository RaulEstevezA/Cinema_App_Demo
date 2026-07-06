import 'package:cinema_app/domain/datasources/movies_datasources.dart';
import 'package:cinema_app/domain/entities/movies.dart';
import 'package:cinema_app/domain/repositories/movie_repositories.dart';

class MovieRepositoryImp extends MoviesRepository {

  final MoviesDataSources dataSources;

  MovieRepositoryImp(this.dataSources);


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {
    return dataSources.getNowPlaying(page: page);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    return dataSources.getPopular(page: page);
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    return dataSources.getUpcoming(page: page);
  }
  
  @override
  Future<List<Movie>> getTopRated({int page = 1}) {
    return dataSources.getTopRated(page: page);
  }
  
  @override
  Future<Movie> getMovieById(String id) {
    return dataSources.getMovieById(id);
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) {
    return dataSources.searchMovies(query);
  }

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) {
    return dataSources.getMoviesByGenre(genreId, page: page);
  }
}