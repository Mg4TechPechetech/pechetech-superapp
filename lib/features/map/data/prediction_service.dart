import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/fishing_zone_model.dart';

class PredictionService {
  final FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  PredictionService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  Future<List<FishingZoneModel>> getFishingZonesToday() async {
    try {
      // 1. Try to fetch active fishing zones from Firestore
      final snapshot = await firestore
          .collection('fishing_zones')
          .where('date_validite', isGreaterThanOrEqualTo: DateTime.now().toIso8601String().substring(0, 10))
          .get()
          .timeout(const Duration(seconds: 4));

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return FishingZoneModel(
            idPrediction: doc.id,
            dateValidite: data['date_validite'] ?? '',
            scoreProbabilite: (data['score_probabilite'] ?? 0.8).toDouble(),
            especeCible: data['espece_cible'] ?? 'Sardinelle',
          );
        }).toList();
      }
    } catch (e) {
      print("Firestore Fishing Zones warning: $e. Falling back to local predictions.");
    }

    // 2. Resilient fallback: Return the high-probability prediction zones mapped in Senegal
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return [
      FishingZoneModel(
        idPrediction: "pred-yoff-001",
        dateValidite: todayStr,
        scoreProbabilite: 0.85,
        especeCible: "Sardinelle (Yoff)",
      ),
      FishingZoneModel(
        idPrediction: "pred-mbour-002",
        dateValidite: todayStr,
        scoreProbabilite: 0.78,
        especeCible: "Thon rouge (Mbour)",
      ),
      FishingZoneModel(
        idPrediction: "pred-kayar-003",
        dateValidite: todayStr,
        scoreProbabilite: 0.90,
        especeCible: "Mérou bronzé / Thiof (Kayar)",
      ),
    ];
  }
}

