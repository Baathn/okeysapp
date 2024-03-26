class AppUser {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;

  AppUser({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'role': role,
      };

  static AppUser fromJson(Map<String, dynamic> json, String id) => AppUser(
        id: id,
        email: json['email'],
        nom: json['nom'],
        prenom: json['prenom'],
        role: json['role'] ?? 'user',
      );
}