# Cinema App

Cinema App is a Flutter movie discovery application powered by [The Movie Database (TMDB)](https://www.themoviedb.org). It includes movie listings, search, details, cast information, genre browsing and local favorites stored with SQLite.

- 🇬🇧 **English version:**  
  [Full functional app overview (English)](./README_en.md)

- 🇪🇸 **Versión en español:**  
  [Resumen completo de la app funcional (Español)](./README_es.md)

<p align="center">
  <img src="docs/images/home_view.png" alt="Cinema App home screen" width="180">
</p>

## Project Summary

This project was built as part of Fernando Herrera's **"Flutter de Cero a Experto"** course. The course-guided section ends at commit `239f87d`; everything after that point was developed independently, including genre/category browsing, movies by genre, the custom app icon and tab transition animations.

The app follows a Clean Architecture approach with a clear separation between domain, infrastructure and presentation layers. A key part of the project is its API integration and data mapping flow: TMDB responses are consumed through dedicated datasources, converted from remote DTOs into domain entities and then exposed to the UI through repositories and Riverpod providers. Favorite movies are persisted locally using Drift over SQLite.

## Main Technologies

| Technology | Purpose |
|---|---|
| Flutter / Dart | Cross-platform application framework |
| Riverpod | State management |
| Go Router | Declarative navigation with tabs and nested routes |
| Dio | HTTP client for TMDB API calls |
| Custom mappers | Conversion from TMDB DTOs to app domain entities |
| Drift / SQLite | Local persistence for favorite movies |
| flutter_dotenv | Environment variable loading |
| animate_do | UI animations |
| card_swiper | Featured movies carousel |
| flutter_staggered_grid | Masonry layout for favorites |

## Features

- Home screen with now playing, upcoming, popular and top rated movies.
- Movie detail screen with backdrop, poster, overview, genres, cast and favorite toggle.
- Debounced movie search.
- Local favorites with infinite pagination.
- Genre/category list and movies filtered by genre.
- Remote and local pagination.
- Cached movie details and cast data.
- Dedicated API integration and mapping layer for movies, actors and genres.
- Custom app icon for Android and iOS.

## Setup

1. Copy `.env.template` to `.env`.
2. Add your TMDB API key:

```env
THE_MOVIEDB_KEY=your_tmdb_api_key
```

3. Install dependencies:

```bash
flutter pub get
```

4. Regenerate Drift code if the database schema changes:

```bash
dart run build_runner build
```

5. Run the app:

```bash
flutter run
```

## Developer

**Raul Estevez**

- [Personal Website](https://raulesteveza.github.io/)
- [LinkedIn Profile](https://www.linkedin.com/in/raulesteveza/)
