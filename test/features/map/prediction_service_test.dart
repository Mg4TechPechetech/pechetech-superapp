import 'package:flutter_test/flutter_test.dart';
import 'package:pechetech_superapp/features/map/data/models/fishing_zone_model.dart';
import 'package:pechetech_superapp/features/map/data/prediction_service.dart';

void main() {
  group('PredictionService Resilient Architecture', () {
    test('returns high-probability local fallback fishing zones when Firestore is uninitialized or fails', () async {
      // Create a prediction service with a null firestore instance, mimicking network/offline status
      final predictionService = PredictionService(firestore: null);
      
      final zones = await predictionService.getFishingZonesToday();

      expect(zones, isA<List<FishingZoneModel>>());
      expect(zones.length, 3);
      
      expect(zones[0].idPrediction, 'pred-yoff-001');
      expect(zones[0].especeCible, 'Sardinelle (Yoff)');
      expect(zones[0].scoreProbabilite, 0.85);

      expect(zones[1].idPrediction, 'pred-mbour-002');
      expect(zones[1].especeCible, 'Thon rouge (Mbour)');
      expect(zones[1].scoreProbabilite, 0.78);

      expect(zones[2].idPrediction, 'pred-kayar-003');
      expect(zones[2].especeCible, 'Mérou bronzé / Thiof (Kayar)');
      expect(zones[2].scoreProbabilite, 0.90);
    });
  });
}
