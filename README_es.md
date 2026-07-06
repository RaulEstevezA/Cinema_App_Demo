# Cinema App - Resumen completo del proyecto

<p align="center">
  <a href="https://youtube.com/shorts/67coTqVxwA4">
    <img src="docs/images/home_view.png" alt="Demo en video de Cinema App" width="150">
  </a>
</p>

<p align="center">
  <a href="https://youtube.com/shorts/67coTqVxwA4">Ver la demo en YouTube</a>
</p>

## Estado del Proyecto

**Snapshot actualizado:** `2026-07-06`  
**Rama:** `main`  
**Último commit documentado:** `07897fe` - "Refactor code structure for improved readability and maintainability"  
**Estado:** aplicación terminada, con todas las pantallas y flujos principales implementados.

El commit `239f87d` marca el final de la parte del proyecto acompañada por el curso. Todo lo posterior, incluyendo géneros/categorías, navegación por género, icono de la app y animaciones, es desarrollo propio.

## Descripción General

Cinema App, con marca interna en la interfaz como **Cinemapedia**, es una aplicación Flutter de descubrimiento de películas que consume [The Movie Database (TMDB)](https://www.themoviedb.org). Usa Clean Architecture, Riverpod como gestor de estado y Drift con SQLite para persistir favoritos localmente.

Una parte técnica central de la app es el uso de APIs externas y el mapeo de la información remota hacia entidades estables del dominio. Las respuestas de TMDB se reciben como DTOs, se transforman mediante mappers dedicados y se exponen a la capa de presentación a través de repositorios, evitando que la UI dependa directamente de la forma de las respuestas de la API.

## Tecnologías y Dependencias

**SDK:** Dart `^3.11.4` / Flutter

| Paquete | Versión | Uso |
|---|---:|---|
| flutter_riverpod | ^3.3.1 | Gestión de estado |
| go_router | ^17.2.3 | Navegación con `StatefulShellRoute` |
| dio | ^5.9.2 | Cliente HTTP para llamadas a la API |
| drift | ^2.34.0 | ORM SQLite y persistencia local |
| drift_flutter | ^0.3.0 | Adaptador Flutter para Drift |
| drift_dev | ^2.34.0 | Generación de código Drift |
| flutter_staggered_grid | ^0.1.2 | `MasonryGridView` / `SliverMasonryGrid` |
| path_provider | ^2.1.6 | Localización de directorios del sistema |
| animate_do | ^5.1.0 | Animaciones como `FadeIn`, `FadeInRight` y `SpinPerfect` |
| card_swiper | ^3.0.1 | Carrusel de películas destacadas |
| flutter_dotenv | ^6.0.1 | Variables de entorno desde `.env` |
| intl | ^0.20.2 | Formateo de fechas en español |
| flutter_lints | ^6.0.0 | Reglas de linting |
| flutter_launcher_icons | ^0.14.4 | Generación del icono de Android/iOS |
| mocktail | ^1.0.5 | Mocks para tests unitarios |

## Fuente de Datos

- **API:** The Movie Database (TMDB) - https://www.themoviedb.org
- **Base URL:** `https://api.themoviedb.org/3`
- **Autenticación:** API key mediante el query param `api_key`, almacenada en `.env` como `THE_MOVIEDB_KEY`
- **Idioma:** `language=es-ES` en todas las llamadas
- **CDN de imágenes:** `https://image.tmdb.org/t/p/w500{path}`

La app no envía respuestas crudas de la API directamente a la UI. Cada respuesta se parsea en modelos de infraestructura y se convierte en entidades de dominio como `Movie`, `Actor` y `Genres`. Así, los nombres de campos propios de la API, los valores nulos y la normalización de rutas de imágenes quedan contenidos dentro de la capa de infraestructura.

### Endpoints Utilizados

| Endpoint | Propósito |
|---|---|
| `/movie/now_playing` | Películas en cartelera |
| `/movie/popular` | Películas populares |
| `/movie/upcoming` | Próximos estrenos |
| `/movie/top_rated` | Películas mejor valoradas |
| `/movie/{id}` | Detalle completo de una película |
| `/search/movie` | Búsqueda de películas |
| `/movie/{id}/credits` | Reparto y equipo |
| `/genre/movie/list` | Listado de géneros de películas |
| `/discover/movie?with_genres=` | Películas filtradas por género, con paginación |

## Arquitectura

El proyecto usa Clean Architecture dividida en capas de dominio, infraestructura y presentación:

```text
lib/
├── config/
│   ├── constants/        # Variables de entorno y acceso a la API key
│   ├── database/         # AppDatabase de Drift y esquema FavoriteMovies
│   ├── helpers/          # HumanFormats
│   ├── router/           # Go Router con StatefulShellRoute de 3 tabs
│   └── theme/            # Material Design 3, color primario #2862F5
├── domain/
│   ├── datasources/      # Contratos de películas, actores, almacenamiento y géneros
│   ├── entities/         # Movie, Actor y Genres
│   └── repositories/     # Interfaces de repositorio
├── infrastructure/
│   ├── datasources/      # Datasources de TMDB, Drift y géneros
│   ├── mappers/          # MovieMapper, ActorMapper y GenreMapper
│   ├── models/           # DTOs de TMDB
│   └── repositories/     # Implementaciones de repositorios
└── presentation/
    ├── providers/        # Providers de Riverpod para películas, storage y géneros
    ├── screens/          # HomeScreen, MovieScreen y MoviesByGenreScreen
    ├── views/            # HomeView, FavoritesView y CategoriesView
    ├── widgets/          # Widgets de películas y componentes compartidos
    └── delegate/         # SearchMovieDelegate
```

### Integración con APIs y Mapeo de Datos

El flujo de API y mapeo es una de las partes más importantes del proyecto:

- Los datasources llaman a los endpoints de TMDB con Dio y configuración de API key mediante variables de entorno.
- Los modelos de infraestructura representan la forma real de las respuestas remotas de TMDB.
- Los mappers convierten esos modelos en entidades de dominio propias de la app.
- Los repositorios exponen métodos limpios al resto de la aplicación sin filtrar detalles de la API.
- Los providers de Riverpod consumen los repositorios y entregan a la UI estado listo para renderizar.

Este patrón se utiliza para películas, detalle de película, actores/reparto y géneros. También facilita la paginación, la caché y futuros cambios de API, porque el contrato remoto queda aislado de la capa de presentación.

La imagen fuente del icono está en `assets/icon/icon.png` (`1254x1254`) y la configuración de `flutter_launcher_icons` vive en `pubspec.yaml`. Los assets generados apuntan a Android e iOS.

## Base de Datos Local

**Archivo:** `lib/config/database/favorite_database.dart`  
**Nombre del archivo de BD:** `my_database`, almacenado mediante `getApplicationSupportDirectory`.

### `FavoriteMovies`

| Columna | Tipo | Notas |
|---|---|---|
| id | INTEGER | Primary key autoincremental |
| movie_id | INTEGER | ID de TMDB |
| backdrop_path | TEXT | Ruta del backdrop |
| original_title | TEXT | Título original |
| poster_path | TEXT | Ruta del poster |
| title | TEXT | Título localizado |
| vote_average | REAL | Valor por defecto `0.0` |

El código de acceso a base de datos se genera con `drift_dev` en `favorite_database.g.dart`.

## Entidades del Dominio

| Entidad | Campos |
|---|---|
| Movie | `id`, `title`, `originalTitle`, `originalLanguage`, `overview`, `popularity`, `releaseDate`, `voteAverage`, `voteCount`, `posterPath`, `backdropPath`, `genreIds`, `adult`, `video` |
| Actor | `id`, `name`, `profilePath`, `character` |
| Genres | `id`, `genre` |

## Features Implementados

### 1. Pantalla Principal

<p align="center">
  <img src="docs/images/home_view.png" alt="Vista principal" width="150">
</p>

`HomeScreen` es el scaffold externo. Contiene el `StatefulNavigationShell` de Go Router y la navegación inferior personalizada. `HomeView` usa un `SliverAppBar` con el app bar propio, el texto de marca Cinemapedia y el icono de búsqueda.

La pantalla incluye un slideshow autoreproducible con las 6 primeras películas en cartelera, además de cuatro listas horizontales con paginación infinita:

| Lista | Provider |
|---|---|
| En Cines | `nowPlayingMoviesProvider` |
| Próximamente | `upcomingMoviesProvider` |
| Populares | `popularMoviesProvider` |
| Mejor valoradas | `topRatedMoviesProvider` |

Durante la carga inicial se muestra `FullScreenLoader`, con mensajes rotativos cada 1,5 segundos.

### 2. Detalle de Película

<p align="center">
  <img src="docs/images/movie_detail.png" alt="Detalle de película" width="150">
</p>

**Ruta:** `/movie/:id`

La pantalla de detalle usa un `SliverAppBar` expandido con el backdrop de la película y un degradado semitransparente. Muestra poster, título, overview, chips de géneros, botón para alternar favorito y una lista horizontal del reparto con foto, nombre y personaje.

El botón de favorito está conectado a `toggleFavoriteMovies` y `isFavoriteMovieProvider`. El provider de estado de favorito usa `.autoDispose` para liberar memoria al salir del detalle. La interfaz también utiliza animaciones `FadeIn` y `FadeInRight`.

### 3. Búsqueda

<p align="center">
  <img src="docs/images/serach_results.png" alt="Resultados de búsqueda" width="150">
</p>

La búsqueda usa el `SearchDelegate` nativo de Flutter, abierto desde el icono del app bar. Incluye:

- Debouncing de 500 ms con `Timer`.
- `StreamController` para resultados asíncronos.
- Indicador de carga `SpinPerfect` mientras se busca.
- Resultados con poster, título, overview limitado a 100 caracteres y valoración.

### 4. Favoritos

<p align="center">
  <img src="docs/images/favorites_view.png" alt="Vista de favoritos" width="150">
</p>

`FavoritesView` es un `ConsumerStatefulWidget`. Carga la primera página en `initState`, muestra un estado vacío con icono `favorite_border` cuando no hay favoritos y renderiza los datos mediante `MoviesMasonry`.

`MoviesMasonry` es un `StatefulWidget` construido con `CustomScrollView`, una sección superior de padding colapsable y un `SliverMasonryGrid.count` de 3 columnas. Su listener de scroll se registra con `addPostFrameCallback` para evitar cargas prematuras cuando `maxScrollExtent == 0` en el primer frame.

También comprueba en `didUpdateWidget` si el contenido llena la pantalla. Si no la llena, solicita la siguiente página hasta que haya overflow o no queden más resultados. El scroll infinito se dispara cuando `pixels + 200 >= maxScrollExtent`, con guards `isLoading` e `isLastPage` para evitar cargas duplicadas.

### 5. Paginación Infinita

La paginación remota se gestiona desde `MovieHorizontalListview`, que detecta el final del scroll horizontal y llama al `loadNextPage()` de cada provider.

La paginación local de favoritos se gestiona con `StorageMoviesNotifier.loadNextpage()`, usando `limit: 10` y `offset: page * 10`. Los resultados se acumulan en un `Map<int, Movie>` para deduplicar películas por ID.

### 6. Caché de Datos Remotos

- `movieInfoProvider` cachea detalles de películas por ID en un `Map<String, Movie>`.
- `actorsByMovieProvider` cachea repartos por movie ID en un `Map<String, List<Actor>>`.

### 7. Categorías y Géneros

<p align="center">
  <img src="docs/images/genres_list_view.png" alt="Listado de géneros" width="150">
</p>

<p align="center">
  <img src="docs/images/movie_by_genre.png" alt="Películas por género" width="150">
</p>

Los géneros se cargan con `AllGenresDatasource` mediante `/genre/movie/list`, se parsean con el modelo `GenreMovies` / `Genre` y se mapean a la entidad `Genres` mediante `GenreMapper`.

La configuración de providers incluye `genresRepositoryProvider`, que construye `GenreRepositoryImp`, y `genresProvider`, un `FutureProvider<List<Genres>>` que solicita el listado una sola vez porque los géneros no necesitan paginación.

`CategoriesView` es un `ConsumerWidget` que renderiza un `ListView.builder` vertical con una `Card` ancha por cada género. Cada tarjeta usa texto grande en negrita, el color primario del tema y animación `FadeInRight`.

Al tocar un género se navega con `context.push('/categories/genre/:id', extra: genre.genre)` hacia `MoviesByGenreScreen`.

Las películas por género se obtienen mediante `getMoviesByGenre(genreId, {page})`, añadido al contrato de datasource de películas, implementado en `MoviedbDatasource` a través de `/discover/movie?with_genres=`, expuesto por `MovieRepositoryImp` y gestionado por `moviesByGenreProvider`.

`MoviesByGenreScreen` es un `ConsumerStatefulWidget`. Renderiza un `ListView.builder` vertical de filas `MovieVerticalListview` con poster, título, overview truncado y valoración. Soporta paginación infinita con un `ScrollController`, usando el mismo umbral `pixels + 200 >= maxScrollExtent`, y abre `/movie/:id` al tocar una fila.

### 8. Animaciones de Transición Entre Tabs

`HomeScreen` pasó de `StatelessWidget` a `StatefulWidget`. En `didUpdateWidget`, cuando cambia `navigationShell.currentIndex`, el shell hace un fade-out instantáneo con `Duration.zero` y vuelve a aparecer durante 200 ms mediante `AnimatedOpacity` y `addPostFrameCallback`.

### 9. Icono de la App

<p align="center">
  <img src="docs/images/icon_view.png" alt="Icono de la app" width="150">
</p>

La imagen fuente es `assets/icon/icon.png` (`1254x1254`). El icono está configurado con `flutter_launcher_icons` en `pubspec.yaml` y se genera con:

```bash
dart run flutter_launcher_icons
```

El comando sobrescribe los assets `mipmap-*/ic_launcher.png` de Android y el `AppIcon.appiconset` de iOS.

## Gestión de Estado

| Provider | Tipo | Propósito |
|---|---|---|
| movieRepositoryProvider | Provider | Singleton del repositorio de películas |
| nowPlayingMoviesProvider | StateNotifierProvider | Lista "En Cines" con paginación |
| popularMoviesProvider | StateNotifierProvider | Lista "Populares" con paginación |
| upcomingMoviesProvider | StateNotifierProvider | Lista "Próximos estrenos" con paginación |
| topRatedMoviesProvider | StateNotifierProvider | Lista "Mejor valoradas" con paginación |
| moviesSlideshowProvider | Provider | Primeras 6 películas de "En Cines" |
| initialLoadingProvider | Provider | Booleano que es true mientras alguna lista principal está vacía |
| movieInfoProvider | StateNotifierProvider | Detalles cacheados de películas por ID |
| actorsRepositoryProvider | Provider | Singleton del repositorio de actores |
| actorsByMovieProvider | StateNotifierProvider | Actores cacheados por movie ID |
| searchQueryProvider | StateProvider<String> | Query actual de búsqueda |
| searchedMoviesProvider | StateNotifierProvider | Resultados de búsqueda |
| localStorageRepositoryProvider | Provider | Singleton del repositorio local con Drift |
| favoriteMoviesProvider | StateNotifierProvider | Favoritos paginados como `Map<int, Movie>` |
| isFavoriteMovieProvider | FutureProvider.family<bool, int> | Consulta si una película es favorita |
| genresRepositoryProvider | Provider | Singleton del repositorio de géneros |
| genresProvider | FutureProvider<List<Genres>> | Listado completo de géneros, cargado una vez |
| moviesByGenreProvider | StateNotifierProvider.family<MoviesNotifier, List<Movie>, int> | Películas filtradas por `genreId`, con paginación |

## Navegación

La navegación usa `StatefulShellRoute.indexedStack` con 3 branches. `HomeScreen` actúa como shell externo.

| Ruta | Tab | Widget |
|---|---|---|
| `/` | 0 - Inicio | `HomeView` |
| `/categories` | 1 - Categorías | `CategoriesView` |
| `/favorites` | 2 - Favoritos | `FavoritesView` |
| `/movie/:id` | Anidada bajo branch 0 | `MovieScreen` |
| `/categories/genre/:id` | Anidada bajo branch 1 | `MoviesByGenreScreen`, recibe `genreName` mediante `extra` |

## Setup

1. Copia `.env.template` a `.env`.
2. Añade tu API key de TMDB:

```env
THE_MOVIEDB_KEY=tu_api_key_de_tmdb
```

3. Instala dependencias:

```bash
flutter pub get
```

4. Regenera el código de base de datos si cambia el schema de Drift:

```bash
dart run build_runner build
```

5. Ejecuta la app:

```bash
flutter run
```

## README Principal

[Enlace al README.md principal](./README.md)
