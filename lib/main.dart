import 'package:cinema_app/config/router/app_router.dart';
import 'package:cinema_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  // await db
  //     .into(db.favoriteMovies)
  //     .insert(
  //       FavoriteMoviesCompanion.insert(
  //         movieId: 1, 
  //         backdropPatch: 'backdropPatch.png', 
  //         originalTitle: 'My firsth movie', 
  //         posterPatch: 'posterpath.png', 
  //         tile: 'Mi primera pelicula')
  //     );

  // final deleteQuery = db.delete(db.favoriteMovies);

  // await deleteQuery.go();
  
  // final moviesQuery = await db.select(db.favoriteMovies).get();
  // print('movies $moviesQuery');

  await initializeDateFormatting('es');
  runApp(const ProviderScope(child:  MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
