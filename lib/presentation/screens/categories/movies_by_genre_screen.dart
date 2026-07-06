import 'package:cinema_app/presentation/providers/providers.dart';
import 'package:cinema_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoviesByGenreScreen extends ConsumerStatefulWidget {
  final int genreId;
  final String genreName;

  const MoviesByGenreScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  ConsumerState<MoviesByGenreScreen> createState() =>
      _MoviesByGenreScreenState();
}

class _MoviesByGenreScreenState extends ConsumerState<MoviesByGenreScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    ref.read(moviesByGenreProvider(widget.genreId).notifier).loadNextPage();

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels + 200 >=
        scrollController.position.maxScrollExtent) {
      ref.read(moviesByGenreProvider(widget.genreId).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesByGenreProvider(widget.genreId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.genreName)),
      body: ListView.builder(
        controller: scrollController,
        itemCount: movies.length,
        itemBuilder: (context, index) => MovieVerticalListview(
          movie: movies[index],
          onMovieSelected: (BuildContext context, movie) {
            context.push('/movie/${movie.id}');
          },
        ),
      ),
    );
  }
}
