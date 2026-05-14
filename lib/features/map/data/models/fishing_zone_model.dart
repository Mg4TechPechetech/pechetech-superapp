class FishingZoneModel {
  final String idPrediction;
  final String dateValidite;
  final double scoreProbabilite;
  final String especeCible;

  FishingZoneModel({
    required this.idPrediction,
    required this.dateValidite,
    required this.scoreProbabilite,
    required this.especeCible,
  });

  factory FishingZoneModel.fromJson(Map<String, dynamic> json) {
    return FishingZoneModel(
      idPrediction: json['id_prediction'] ?? '',
      dateValidite: json['date_validite'] ?? '',
      scoreProbabilite: (json['score_probabilite'] ?? 0.0).toDouble(),
      especeCible: json['espece_cible'] ?? 'Inconnue',
    );
  }
}
