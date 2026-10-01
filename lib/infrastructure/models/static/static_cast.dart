/// Reparto de una película de la base estática (`assets/data/credits/{id}.json`).
class StaticCast {
  final int id;
  final String name;
  final String character;
  final String? profileUrl;

  StaticCast({
    required this.id,
    required this.name,
    required this.character,
    required this.profileUrl,
  });

  factory StaticCast.fromJson(Map<String, dynamic> json) => StaticCast(
        id: json["id"],
        name: json["name"] ?? '',
        character: json["character"] ?? '',
        profileUrl: json["profile_url"],
      );
}
