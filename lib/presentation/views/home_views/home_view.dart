import 'package:cinema_app/presentation/providers/providers.dart';
import 'package:cinema_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {

  @override
  void initState() {
    super.initState();

    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(upcomingMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {

    final initialLoading = ref.watch(initialLoadingProvider);

    if (initialLoading) return const FullScreenLoader();

    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final slideShoeMovies = ref.watch(moviesSlideshowProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    

    if (slideShoeMovies.isEmpty) return CircularProgressIndicator();
    

    return CustomScrollView(

      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),


        SliverToBoxAdapter(
          child: Column(
            children: [
              // const CustomAppbar(),

              MoviesSlideshow(movies: slideShoeMovies),

              MovieHorizontalListview(
                movies: nowPlayingMovies,
                title: 'Destacadas',
                loadNextPage: () => ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
              ),

              MovieHorizontalListview(
                movies: upcomingMovies,
                title: 'Cine mudo',
                // subTitle: "lunes 20",
                loadNextPage: () => ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
              ),

              MovieHorizontalListview(
                movies: popularMovies,
                title: 'Edad de oro',
                // subTitle: "lunes 20",
                loadNextPage: () => ref.read(popularMoviesProvider.notifier).loadNextPage(),
              ),

              MovieHorizontalListview(
                movies: topRatedMovies,
                title: 'Clásicos modernos',
                // subTitle: "lunes 20",
                loadNextPage: () => ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
              ),

              const SizedBox(height: 20),
          
          
            ],
          ),
        ),
      ],
    );
  }
}