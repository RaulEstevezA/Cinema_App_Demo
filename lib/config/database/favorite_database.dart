import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'favorite_database.g.dart';

// class TodoItems extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().withLength(min: 6, max: 32)();
//   TextColumn get content => text().named('body')();
//   DateTimeColumn get createdAt => dateTime().nullable()();
// }

class FavoriteMovies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get movieId => integer().named('movie_id')();
  TextColumn get backdropPath => text().named('backdrop_path')();
  TextColumn get originalTitle => text().named('original_title')();
  TextColumn get posterPath => text().named('poster_pad')();
  TextColumn get title => text()();
  RealColumn get voteAverage => real().named('vote_average').withDefault(const Constant(0.0))();
}

@DriftDatabase(tables: [FavoriteMovies])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      // Nombre propio: en web todas las demos de raulesteveza.github.io
      // comparten el almacenamiento del navegador (IndexedDB es por dominio).
      name: 'cinema_app_demo',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // En web se usan `web/sqlite3.wasm` (sqlite3 3.3.3) y `web/drift_worker.js`
      // (drift 2.34.0); al actualizar esos paquetes hay que descargar las
      // versiones correspondientes: https://drift.simonbinder.eu/platforms/web/
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}

final db = AppDatabase();
