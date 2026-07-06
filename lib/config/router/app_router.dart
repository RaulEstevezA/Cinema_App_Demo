import 'package:cinema_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';
import 'package:cinema_app/presentation/views/views.dart';

final appRouter = GoRouter(
  
  initialLocation: '/',
  routes: [

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => HomeView(),
              routes: [
                GoRoute(
                  path: 'movie/:id',
                  builder: (context, state) {
                    final movieId = state.pathParameters['id'] ?? 'no-id';
                    return MovieScreen(movieId : movieId);
                  },
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => CategoriesView(),
              routes: [
                GoRoute(
                  path: 'genre/:id',
                  builder: (context, state) {
                    final genreId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    final genreName = state.extra as String? ?? '';
                    return MoviesByGenreScreen(genreId: genreId, genreName: genreName);
                  },
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => FavoritesView(),
            ),
          ],
        ),
      ],
    )

    // GoRoute(
    //   path: '/',
    //   name: HomeScreen.name,
    //   builder: (context, state) => HomeScreen(childView: HomeView(),),

    //   routes: [
    //     GoRoute(
    //       path: '/movie/:id',
    //       name: MovieScreen.name,
    //       builder: (context, state) {
    //         final movieId = state.pathParameters['id'] ?? 'no-id';
    //         return MovieScreen(movieId : movieId);
    //       },
    //     ),


    //   ]
    // ),
  ]
);