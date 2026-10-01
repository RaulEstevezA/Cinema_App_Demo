// Genera la base de datos estática de la app en `assets/data/` a partir de
// fuentes con licencia libre:
//
//   - Wikidata (CC0): títulos, fechas, géneros, reparto y relevancia.
//   - Wikimedia Commons: pósters y fotos (cada imagen con su licencia libre;
//     autor y licencia se guardan en `attributions.json`).
//   - Wikipedia en español (CC BY-SA 4.0): sinopsis.
//
// Uso:
//   dart run tool/generate_static_db.dart [--per-section=20] [--cast=10]
//
// No necesita ninguna clave. Se respeta la política de uso de la API de
// Wikimedia (User-Agent identificativo, peticiones secuenciales y reintentos).

import 'dart:convert';
import 'dart:io';

const _outputDir = 'assets/data';
const _attributionDoc = 'docs/DATA_ATTRIBUTION.md';
const _userAgent = 'CinemaAppDemo/0.1 (https://raulesteveza.github.io/demos/Cinema_App; static demo data generator)';
const _minSitelinks = 25;
const _minMoviesPerGenre = 3;

/// Valores de "género" en Wikidata que no son géneros cinematográficos.
const _excludedGenres = {'Analepsis en el cine'};

/// Secciones de la portada: clave de `lists.json` y años [desde, hasta).
/// `now_playing` (Destacadas) toma las más relevantes de cualquier época; el
/// resto se reparte por épocas sin repetir películas.
const _sections = {
  'now_playing': (0, 9999),
  'upcoming': (0, 1930),
  'popular': (1930, 1960),
  'top_rated': (1960, 9999),
};

Future<void> main(List<String> args) async {
  final options = {
    'per-section': '20',
    'cast': '10',
    for (final arg in args.where((a) => a.startsWith('--') && a.contains('=')))
      arg.substring(2, arg.indexOf('=')): arg.substring(arg.indexOf('=') + 1),
  };
  final perSection = int.parse(options['per-section']!);
  final castLimit = int.parse(options['cast']!);

  final client = _Client();

  try {
    // 1. Candidatas: películas con póster en Commons y artículos en bastantes Wikipedias.
    stdout.writeln('Buscando películas en Wikidata...');
    final candidates = await client.sparql('''
      SELECT ?film ?links WHERE {
        ?film wdt:P31 wd:Q11424; wdt:P3383 ?poster; wikibase:sitelinks ?links.
        FILTER(?links >= $_minSitelinks)
      }
      GROUP BY ?film ?links
      ORDER BY DESC(?links)
    ''');
    final sitelinks = {
      for (final row in candidates) _qid(row['film']['value']): int.parse(row['links']['value']),
    };

    final filmEntities = await client.entities(sitelinks.keys, props: 'labels|descriptions|claims|sitelinks');

    // 2. Selección por secciones.
    final films = filmEntities.values
        .where((entity) => _label(entity) != null && _releaseDate(entity) != null && _firstFile(entity, 'P3383') != null)
        .toList()
      ..sort((a, b) => sitelinks[b['id']]!.compareTo(sitelinks[a['id']]!));

    final lists = <String, List<int>>{};
    final selected = <String>{};
    for (final MapEntry(key: section, value: (from, to)) in _sections.entries) {
      final ids = films
          .where((film) => !selected.contains(film['id']))
          .where((film) {
            final year = _releaseDate(film)!.year;
            return year >= from && year < to;
          })
          .take(perSection)
          .map((film) => film['id'] as String)
          .toList();
      selected.addAll(ids);
      lists[section] = ids.map(_numericId).toList();
      stdout.writeln('  $section: ${ids.length} películas');
    }
    final selectedFilms = films.where((film) => selected.contains(film['id'])).toList();

    // 3. Géneros, reparto y personajes.
    stdout.writeln('Géneros y reparto...');
    // Los géneros se agrupan por nombre (Wikidata tiene varios elementos para
    // un mismo género) y solo se conservan los que tienen suficientes películas.
    final genreEntities = await client.entities(
      {for (final film in selectedFilms) ..._itemValues(film, 'P136')},
      props: 'labels',
    );
    final genreNameByQid = {
      for (final MapEntry(key: qid, value: entity) in genreEntities.entries)
        if (_genreName(_label(entity) ?? '') case final name when name.isNotEmpty && !_excludedGenres.contains(name))
          qid: name,
    };
    final filmsByGenre = <String, Set<String>>{};
    for (final film in selectedFilms) {
      for (final qid in _itemValues(film, 'P136')) {
        if (genreNameByQid[qid] case final name?) filmsByGenre.putIfAbsent(name, () => {}).add(film['id']);
      }
    }
    final genreIdByName = <String, int>{};
    for (final qid in genreNameByQid.keys.toList()..sort((a, b) => _numericId(a).compareTo(_numericId(b)))) {
      final name = genreNameByQid[qid]!;
      if (filmsByGenre[name] != null && filmsByGenre[name]!.length >= _minMoviesPerGenre) {
        genreIdByName.putIfAbsent(name, () => _numericId(qid));
      }
    }

    final castByFilm = {
      for (final film in selectedFilms)
        film['id'] as String: _claims(film, 'P161').take(castLimit).toList(),
    };
    final actorIds = {
      for (final cast in castByFilm.values)
        for (final claim in cast) ?_itemId(claim['mainsnak']),
    };
    final characterIds = {
      for (final cast in castByFilm.values)
        for (final claim in cast)
          for (final qualifier in (claim['qualifiers']?['P453'] as List? ?? const []))
            ?_itemId(qualifier),
    };

    final actorEntities = await client.entities(actorIds, props: 'labels|claims');
    final characterEntities = await client.entities(characterIds, props: 'labels');

    // 4. Imágenes en Commons: URL de miniatura, autor y licencia.
    stdout.writeln('Licencias de imágenes en Commons...');
    final posterFiles = {for (final film in selectedFilms) _firstFile(film, 'P3383')!};
    final backdropFiles = {for (final film in selectedFilms) ?_firstFile(film, 'P18')};
    final profileFiles = {for (final actor in actorEntities.values) ?_firstFile(actor, 'P18')};
    final images = {
      ...await client.commonsImages({...posterFiles, ...backdropFiles}, width: 500),
      ...await client.commonsImages(profileFiles.difference({...posterFiles, ...backdropFiles}), width: 330),
    };

    // 5. Sinopsis desde Wikipedia en español.
    stdout.writeln('Sinopsis en Wikipedia...');
    final overviews = <String, ({String text, String url})>{};
    for (final film in selectedFilms) {
      final article = film['sitelinks']?['eswiki']?['title'] as String?;
      if (article == null) continue;
      final text = await client.wikipediaIntro(article);
      if (text != null && text.isNotEmpty) {
        overviews[film['id']] = (
          text: text,
          url: 'https://es.wikipedia.org/wiki/${Uri.encodeComponent(article.replaceAll(' ', '_'))}',
        );
      }
    }

    // 6. Construcción de los ficheros.
    final maxLinks = sitelinks[selectedFilms.first['id']]!;
    final usedImages = <String, Set<String>>{};
    String? imageUrl(String? file, String usedBy) {
      final image = images[file];
      if (image == null) return null;
      usedImages.putIfAbsent(file!, () => {}).add(usedBy);
      return image.thumbUrl;
    }

    final movies = selectedFilms.map((film) {
      final id = film['id'] as String;
      final title = _label(film)!;
      final originalTitle = _monolingual(film, 'P1476');
      final links = sitelinks[id]!;
      final posterUrl = imageUrl(_firstFile(film, 'P3383'), title);

      return {
        'id': _numericId(id),
        'wikidata_id': id,
        'title': title,
        'original_title': originalTitle?.text ?? title,
        'original_language': originalTitle?.language ?? '',
        'overview': overviews[id]?.text ?? _description(film) ?? '',
        'overview_source': overviews[id]?.url,
        'release_date': _formatDate(_releaseDate(film)!),
        'genre_ids': {
          for (final qid in _itemValues(film, 'P136')) ?genreIdByName[genreNameByQid[qid]],
        }.toList(),
        'poster_url': posterUrl,
        'backdrop_url': imageUrl(_firstFile(film, 'P18'), title) ?? posterUrl,
        'sitelinks': links,
        // Índice de relevancia 0-10 según el número de Wikipedias con artículo
        // (Wikidata no tiene valoraciones de usuarios).
        'relevance': double.parse((10 * links / maxLinks).toStringAsFixed(1)),
      };
    }).where((movie) => movie['poster_url'] != null).toList();

    final genres = [
      for (final MapEntry(key: name, value: id) in genreIdByName.entries) {'id': id, 'name': name},
    ]..sort((a, b) => _sortKey(a['name'] as String).compareTo(_sortKey(b['name'] as String)));

    final credits = <int, Map<String, dynamic>>{};
    for (final film in selectedFilms) {
      final title = _label(film)!;
      credits[_numericId(film['id'])] = {
        'id': _numericId(film['id']),
        'cast': [
          for (final claim in castByFilm[film['id']]!)
            if (actorEntities[_itemId(claim['mainsnak'])] case final actor?)
              if (_label(actor) case final name?)
                {
                  'id': _numericId(actor['id']),
                  'name': name,
                  'character': [
                    for (final qualifier in (claim['qualifiers']?['P453'] as List? ?? const []))
                      ?_label(characterEntities[_itemId(qualifier)]),
                  ].join(' / '),
                  'profile_url': imageUrl(_firstFile(actor, 'P18'), '$name ($title)'),
                },
        ],
      };
    }

    final attributions = {
      'data': {
        'source': 'Wikidata',
        'license': 'CC0 1.0',
        'license_url': 'https://creativecommons.org/publicdomain/zero/1.0/',
      },
      'texts': [
        for (final movie in movies)
          if (movie['overview_source'] != null)
            {
              'movie_id': movie['id'],
              'title': movie['title'],
              'source_url': movie['overview_source'],
              'license': 'CC BY-SA 4.0',
              'license_url': 'https://creativecommons.org/licenses/by-sa/4.0/',
            },
      ],
      'images': [
        for (final MapEntry(key: file, value: usedBy) in usedImages.entries)
          {
            'file': file,
            'source_url': images[file]!.pageUrl,
            'artist': images[file]!.artist,
            'license': images[file]!.license,
            'license_url': images[file]!.licenseUrl,
            'used_by': usedBy.toList()..sort(),
          },
      ],
    };

    // Escritura: se regenera todo para no dejar ficheros huérfanos.
    final creditsDir = Directory('$_outputDir/credits');
    if (creditsDir.existsSync()) creditsDir.deleteSync(recursive: true);
    creditsDir.createSync(recursive: true);

    _writeJson('$_outputDir/genres.json', {'genres': genres});
    _writeJson('$_outputDir/movies.json', {'results': movies});
    _writeJson('$_outputDir/lists.json', lists);
    _writeJson('$_outputDir/attributions.json', attributions);
    for (final entry in credits.entries) {
      _writeJson('${creditsDir.path}/${entry.key}.json', entry.value);
    }
    File(_attributionDoc).writeAsStringSync(_attributionMarkdown(attributions));

    stdout.writeln('Listo: ${movies.length} películas, ${genres.length} géneros, '
        '${usedImages.length} imágenes en $_outputDir/');
  } finally {
    client.close();
  }
}

// --- Lectura de entidades de Wikidata ---------------------------------------

String _qid(String uri) => uri.substring(uri.lastIndexOf('/') + 1);

int _numericId(String qid) => int.parse(qid.substring(1));

List<Map<String, dynamic>> _claims(Map<String, dynamic> entity, String property) =>
    ((entity['claims']?[property] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .where((claim) => claim['rank'] != 'deprecated')
        .toList();

String? _itemId(Map<String, dynamic> snak) => snak['datavalue']?['value']?['id'] as String?;

List<String> _itemValues(Map<String, dynamic> entity, String property) =>
    [for (final claim in _claims(entity, property)) ?_itemId(claim['mainsnak'])];

String? _firstFile(Map<String, dynamic> entity, String property) {
  for (final claim in _claims(entity, property)) {
    final value = claim['mainsnak']['datavalue']?['value'];
    if (value is String) return value;
  }
  return null;
}

String? _label(Map<String, dynamic>? entity) =>
    entity?['labels']?['es']?['value'] ?? entity?['labels']?['en']?['value'];

String? _description(Map<String, dynamic> entity) {
  final description = entity['descriptions']?['es']?['value'] as String?;
  if (description == null) return null;
  return '${description[0].toUpperCase()}${description.substring(1)}.';
}

({String text, String language})? _monolingual(Map<String, dynamic> entity, String property) {
  for (final claim in _claims(entity, property)) {
    final value = claim['mainsnak']['datavalue']?['value'];
    if (value is Map) return (text: value['text'] as String, language: value['language'] as String);
  }
  return null;
}

DateTime? _releaseDate(Map<String, dynamic> entity) {
  final dates = [
    for (final claim in _claims(entity, 'P577'))
      if (claim['mainsnak']['datavalue']?['value']?['time'] case final String time)
        // Formato "+1927-01-10T00:00:00Z"; con precisión de año viene como -00-00.
        DateTime.tryParse(time.substring(1, 11).replaceAll('-00', '-01')),
  ].whereType<DateTime>().toList()
    ..sort();
  return dates.firstOrNull;
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// "película de terror" -> "Terror"
String _genreName(String label) {
  final name = label.replaceFirst(RegExp(r'^(película|cine|filme)s?( de)? ', caseSensitive: false), '').trim();
  return name.isEmpty ? '' : '${name[0].toUpperCase()}${name.substring(1)}';
}

// --- Atribuciones -------------------------------------------------------------

String _attributionMarkdown(Map<String, dynamic> attributions) {
  final buffer = StringBuffer()
    ..writeln('# Atribución de datos e imágenes')
    ..writeln()
    ..writeln('Fichero generado por `tool/generate_static_db.dart`. No editar a mano.')
    ..writeln()
    ..writeln('- **Datos de películas:** [Wikidata](https://www.wikidata.org), [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).')
    ..writeln('- **Sinopsis:** extractos de [Wikipedia en español](https://es.wikipedia.org), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Enlace al artículo original de cada una abajo.')
    ..writeln('- **Imágenes:** [Wikimedia Commons](https://commons.wikimedia.org), cada una con la licencia indicada.')
    ..writeln()
    ..writeln('## Sinopsis')
    ..writeln();
  for (final text in attributions['texts'] as List) {
    buffer.writeln('- ${text['title']}: <${text['source_url']}> (${text['license']})');
  }
  buffer
    ..writeln()
    ..writeln('## Imágenes')
    ..writeln()
    ..writeln('| Imagen | Autor | Licencia | Usada en |')
    ..writeln('|---|---|---|---|');
  String cell(Object? value) => '${value ?? ''}'.replaceAll('|', r'\|').replaceAll('\n', ' ');
  for (final image in attributions['images'] as List) {
    final license = image['license_url'] != null
        ? '[${cell(image['license'])}](${image['license_url']})'
        : cell(image['license']);
    buffer.writeln('| [${cell(image['file'])}](${image['source_url']}) | ${cell(image['artist'])} | $license | ${cell((image['used_by'] as List).join(', '))} |');
  }
  return buffer.toString();
}

void _writeJson(String path, Object data) =>
    File(path).writeAsStringSync(json.encode(data));

// --- Cliente HTTP de Wikimedia --------------------------------------------------

typedef _CommonsImage = ({String thumbUrl, String pageUrl, String artist, String license, String? licenseUrl});

class _Client {
  final HttpClient _http = HttpClient()..userAgent = _userAgent;

  Future<dynamic> _getJson(Uri uri) async {
    for (var attempt = 1; ; attempt++) {
      final request = await _http.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json, application/sparql-results+json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) return json.decode(body);

      // Límite de peticiones o error transitorio: reintentar con espera.
      if ((response.statusCode == 429 || response.statusCode >= 500) && attempt < 5) {
        await Future.delayed(Duration(seconds: attempt * 5));
        continue;
      }
      throw HttpException('${response.statusCode} en ${uri.host}${uri.path}: $body');
    }
  }

  Future<List<dynamic>> sparql(String query) async {
    final response = await _getJson(Uri.https('query.wikidata.org', '/sparql', {'query': query, 'format': 'json'}));
    return response['results']['bindings'] as List;
  }

  /// Entidades de Wikidata por id (Q...), en lotes de 50.
  Future<Map<String, Map<String, dynamic>>> entities(Iterable<String> ids, {required String props}) async {
    final result = <String, Map<String, dynamic>>{};
    final all = ids.toList();
    for (var i = 0; i < all.length; i += 50) {
      final response = await _getJson(Uri.https('www.wikidata.org', '/w/api.php', {
        'action': 'wbgetentities',
        'ids': all.skip(i).take(50).join('|'),
        'props': props,
        'languages': 'es|en',
        'sitefilter': 'eswiki',
        'format': 'json',
      }));
      for (final entity in (response['entities'] as Map).values) {
        if (entity['missing'] == null) result[entity['id']] = entity;
      }
    }
    return result;
  }

  /// Miniatura, autor y licencia de ficheros de Commons, en lotes de 50.
  Future<Map<String, _CommonsImage>> commonsImages(Iterable<String> files, {required int width}) async {
    final result = <String, _CommonsImage>{};
    final all = files.toList();
    for (var i = 0; i < all.length; i += 50) {
      final batch = all.skip(i).take(50).toList();
      final response = await _getJson(Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'titles': batch.map((file) => 'File:$file').join('|'),
        'prop': 'imageinfo',
        'iiprop': 'url|extmetadata',
        'iiurlwidth': '$width',
        'iiextmetadatafilter': 'Artist|LicenseShortName|LicenseUrl',
        'format': 'json',
        'formatversion': '2',
      }));
      final query = response['query'];
      final normalized = {
        for (final entry in (query['normalized'] as List? ?? const [])) entry['to']: entry['from'],
      };
      for (final page in (query['pages'] as List)) {
        final info = (page['imageinfo'] as List?)?.firstOrNull;
        if (info == null) continue;
        final title = normalized[page['title']] ?? page['title'];
        final metadata = info['extmetadata'] is Map ? info['extmetadata'] as Map : const {};
        result[(title as String).substring('File:'.length)] = (
          thumbUrl: (info['thumburl'] ?? info['url'] as String).split('?').first,
          pageUrl: info['descriptionurl'],
          artist: _stripHtml(metadata['Artist']?['value'] ?? 'Desconocido'),
          license: _stripHtml(metadata['LicenseShortName']?['value'] ?? 'Ver página de Commons'),
          licenseUrl: metadata['LicenseUrl']?['value'],
        );
      }
    }
    return result;
  }

  /// Introducción en texto plano de un artículo de Wikipedia en español,
  /// recortada a ~3 frases.
  Future<String?> wikipediaIntro(String article) async {
    final response = await _getJson(Uri.https('es.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'prop': 'extracts',
      'exintro': '1',
      'explaintext': '1',
      'exsentences': '3',
      'redirects': '1',
      'titles': article,
      'format': 'json',
      'formatversion': '2',
    }));
    final pages = response['query']?['pages'] as List?;
    return (pages?.firstOrNull?['extract'] as String?)?.replaceAll(RegExp(r'\n+'), '\n\n').trim();
  }

  void close() => _http.close();
}

/// Clave de ordenación alfabética que ignora acentos ("Bélico" antes que "Biográfico").
String _sortKey(String text) => text.toLowerCase()
    .replaceAll(RegExp('[áàäâ]'), 'a')
    .replaceAll(RegExp('[éèëê]'), 'e')
    .replaceAll(RegExp('[íìïî]'), 'i')
    .replaceAll(RegExp('[óòöô]'), 'o')
    .replaceAll(RegExp('[úùüû]'), 'u')
    .replaceAll('ñ', 'n~');

String _stripHtml(String html) => html
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .replaceAll('&nbsp;', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    // Commons a veces repite el texto ("Unknown authorUnknown author").
    .replaceAllMapped(RegExp(r'^(.+?)\s?\1$'), (match) => match[1]!);
