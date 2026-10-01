# Cinema App · Demo web

> [!IMPORTANT]
> **Este no es el repositorio principal de Cinema App.**
> Aquí solo está la **versión de demostración web** que se publica en mi web.
> El proyecto completo (código fuente, la versión original con la API de TMDB e instrucciones para descargar y ejecutar la app) está en:
>
> **➡️ [RaulEstevezA/Cinema_App](https://github.com/RaulEstevezA/Cinema_App)**

**▶️ Demo en vivo:** [raulesteveza.github.io/demos/Cinema_App](https://raulesteveza.github.io/demos/Cinema_App/)

<p align="center">
  <a href="https://raulesteveza.github.io/demos/Cinema_App/">
    <img src="docs/images/web_demo.png" alt="Demo web de Cinema App dentro de un marco de móvil" width="720">
  </a>
</p>

## Para qué sirve este repositorio

Cinema App es una app móvil Flutter que obtiene las películas de la API de The Movie Database (TMDB). Para enseñarla en mi web sin depender de una API ni de una clave, este repositorio contiene una copia adaptada que:

1. **No usa ninguna API.** Las películas vienen de una base de datos estática incluida en la propia app, generada a partir de fuentes con licencia libre.
2. **Funciona en el navegador**, publicada en GitHub Pages dentro de la sección de demos de mi web.
3. **Se despliega sola**: cada push a `main` compila la app y la publica con GitHub Actions.

La arquitectura es la misma que en el repositorio principal (Clean Architecture, Riverpod, go_router, Drift). Gracias a la separación entre dominio e infraestructura, cambiar el origen de los datos solo ha requerido nuevos datasources: la interfaz y la lógica de la app no saben de dónde vienen las películas.

## Diferencias con la app original

| | App original ([Cinema_App](https://github.com/RaulEstevezA/Cinema_App)) | Esta demo |
|---|---|---|
| Datos | API de TMDB en tiempo real | Base estática en `assets/data/` (80 películas) |
| API key | Necesaria (`.env`) | No hace falta |
| Secciones de la portada | En cines, Próximamente, Populares, Mejor valoradas | Destacadas, Cine mudo, Edad de oro, Clásicos modernos |
| Valoración (estrellas) | Nota media de usuarios de TMDB | Índice de relevancia 0-10 (en cuántas Wikipedias aparece la película) |
| Búsqueda | Todo el catálogo de TMDB | Títulos de la base estática, sin distinguir acentos |
| Favoritos | SQLite en el dispositivo | SQLite en el dispositivo; en web, en el navegador (IndexedDB) |
| Plataforma principal | Android / iOS | Web (también funciona en móvil) |

## Origen de los datos

La base estática se genera con [`tool/generate_static_db.dart`](tool/generate_static_db.dart), solo a partir de fuentes que permiten su reutilización:

| Fuente | Qué aporta | Licencia |
|---|---|---|
| [Wikidata](https://www.wikidata.org) | Títulos, fechas, géneros, reparto y relevancia | CC0 (dominio público) |
| [Wikimedia Commons](https://commons.wikimedia.org) | Pósters, fotogramas y fotos de actores | Cada imagen con su licencia libre (dominio público, CC BY, CC BY-SA…) |
| [Wikipedia en español](https://es.wikipedia.org) | Sinopsis | CC BY-SA 4.0 |

El autor y la licencia de cada imagen y texto están en [`docs/DATA_ATTRIBUTION.md`](docs/DATA_ATTRIBUTION.md) y en [`assets/data/attributions.json`](assets/data/attributions.json), y la demo los muestra en el botón «Créditos».

No se usan datos de TMDB ni de IMDb: sus condiciones no permiten publicarlos como base estática.

### Regenerar los datos

```bash
dart run tool/generate_static_db.dart                 # 20 películas por sección
dart run tool/generate_static_db.dart --per-section=30 --cast=12
```

No necesita ninguna clave. Sobrescribe `assets/data/` y `docs/DATA_ATTRIBUTION.md`. Como Wikidata cambia con el tiempo, cada ejecución puede dar resultados ligeramente distintos.

## Estructura relevante

Solo lo que cambia respecto al repositorio principal:

```
assets/data/                  Base de datos estática (JSON)
  movies.json                 Catálogo de películas
  lists.json                  Películas de cada sección de la portada
  genres.json                 Géneros
  credits/{id}.json           Reparto de cada película
  attributions.json           Autor y licencia de imágenes y textos
lib/infrastructure/
  datasources/static/         Datasources que leen la base estática
  models/static/              Modelos del formato JSON propio
  mappers/static_mapper.dart  Conversión a las entidades del dominio
tool/generate_static_db.dart  Generador de la base estática
web/sqlite3.wasm              SQLite para la web (favoritos)
web/drift_worker.js           Worker de Drift para la web
showcase/index.html           Página de presentación con el marco de móvil
.github/workflows/            Compilación y despliegue automático
```

## Ejecutar en local

```bash
flutter pub get
flutter run -d chrome
```

Para verlo exactamente como queda publicado (página con el marco de móvil y la app en `app/`):

```bash
flutter build web --release --base-href /demos/Cinema_App/app/

mkdir -p /tmp/site/demos/Cinema_App
cp -R showcase/. /tmp/site/demos/Cinema_App/
cp -R build/web /tmp/site/demos/Cinema_App/app
cd /tmp/site && python3 -m http.server 8000
# Abrir http://localhost:8000/demos/Cinema_App/
```

## Despliegue

El workflow [`deploy-demo.yml`](.github/workflows/deploy-demo.yml) se ejecuta en cada push a `main` (y manualmente desde Actions):

1. Ejecuta `flutter analyze` y `flutter test`.
2. Compila la app para web con la ruta `/demos/Cinema_App/app/`.
3. Copia `showcase/` y la app compilada en `demos/Cinema_App/` del repositorio [RaulEstevezA.github.io](https://github.com/RaulEstevezA/RaulEstevezA.github.io), que GitHub Pages publica.

Necesita el secreto de Actions `PORTFOLIO_DEPLOY_TOKEN`: un token *fine-grained* con permiso **Contents: Read and write** solo sobre `RaulEstevezA.github.io`.

La carpeta `demos/Cinema_App/` de la web se sustituye entera en cada despliegue, así que no debe editarse a mano.

## Créditos

Proyecto basado en el curso **«Flutter de Cero a Experto»** de Fernando Herrera, con desarrollo propio posterior. Los detalles están en el [repositorio principal](https://github.com/RaulEstevezA/Cinema_App).

## Desarrollador

**Raul Estevez**

- [Web personal](https://raulesteveza.github.io/)
- [LinkedIn](https://www.linkedin.com/in/raulesteveza/)

[Volver al README principal](./README.md)
