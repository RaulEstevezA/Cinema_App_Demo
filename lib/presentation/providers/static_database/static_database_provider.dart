import 'package:cinema_app/infrastructure/datasources/static/static_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Base de datos estática compartida por todos los repositorios
final staticDatabaseProvider = Provider((ref) => StaticDatabase());
