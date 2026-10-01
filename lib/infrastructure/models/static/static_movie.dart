/// Película de la base estática (`assets/data/movies.json`), generada a
/// partir de Wikidata, Wikimedia Commons y Wikipedia.
class StaticMovie {
  final int id;
  final String title;
  final String originalTitle;
  final String originalLanguage;
  final String overview;
  final String? overviewSource;
  final DateTime releaseDate;
  final List<int> genreIds;
  final String posterUrl;
  final String backdropUrl;
  final int sitelinks;
  final double relevance;

  StaticMovie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.originalLanguage,
    required this.overview,
    required this.overviewSource,
    required this.releaseDate,
    required this.genreIds,
    required this.posterUrl,
    required this.backdropUrl,
    required this.sitelinks,
    required this.relevance,
  });

  factory StaticMovie.fromJson(Map<String, dynamic> json) => StaticMovie(
        id: json["id"],
        title: json["title"] ?? '',
        originalTitle: json["original_title"] ?? '',
        originalLanguage: json["original_language"] ?? '',
        overview: json["overview"] ?? '',
        overviewSource: json["overview_source"],
        releaseDate: DateTime.tryParse(json["release_date"] ?? '') ?? DateTime(1900),
        genreIds: List<int>.from(json["genre_ids"] ?? const []),
        posterUrl: json["poster_url"] ?? '',
        backdropUrl: json["backdrop_url"] ?? json["poster_url"] ?? '',
        sitelinks: json["sitelinks"] ?? 0,
        relevance: json["relevance"]?.toDouble() ?? 0.0,
      );
}
