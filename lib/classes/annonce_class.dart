class Annonce {
  String id;
  String titre;
  String departement;
  String ville;
  String codeDepartement;
  String codeVille;
  String description;
  String imageUrl;
  double prix;
  double m2;
  bool jardin;
  bool garage;
  bool fibreOptique;

  Annonce({
    required this.id,
    required this.titre,
    required this.departement,
    required this.ville,
    required this.codeDepartement,
    required this.codeVille,
    required this.description,
    required this.imageUrl,
    required this.prix,
    required this.m2,
    required this.jardin,
    required this.garage,
    required this.fibreOptique,
  });

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'description': description,
        'departement': departement,
        'ville': ville,
        'codeDepartement': codeDepartement,
        'codeVille': codeVille,
        'imageUrl': imageUrl,
        'prix': prix,
        'm2': m2,
        'jardin': jardin,
        'garage': garage,
        'fibreOptique': fibreOptique,
      };

  static Annonce fromJson(Map<String, dynamic> json, String id) => Annonce(
        id: id,
        titre: json['titre'],
        departement: json['departement'],
        ville: json['ville'],
        codeDepartement: json['codeDepartement'],
        codeVille: json['codeVille'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        prix: json['prix'].toDouble(),
        m2: json['m2'].toDouble(),
        jardin: json['jardin'],
        garage: json['garage'],
        fibreOptique: json['fibreOptique'],
      );
}