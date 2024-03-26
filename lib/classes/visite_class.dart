class Visite {
  String id;
  String userId;
  String agentId;
  String annonceId;
  DateTime datevisiteId;

  Visite({
    required this.id,
    required this.userId,
    required this.agentId,
    required this.annonceId,
    required this.datevisiteId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'agentId': agentId,
        'annonceId': annonceId,
        'datevisiteId': datevisiteId,
      };

  static Visite fromJson(Map<String, dynamic> json, String id) => Visite(
        id: id,
        userId: json['userId'],
        agentId: json['agentId'],
        annonceId: json['annonceId'],
        datevisiteId: json['datevisiteId'],
      );
}
