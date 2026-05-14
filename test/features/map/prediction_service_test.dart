import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pechetech_superapp/features/map/data/models/fishing_zone_model.dart';
import 'package:pechetech_superapp/features/map/data/prediction_service.dart';

void main() {
  group('PredictionService', () {
    test('returns list of FishingZoneModel if http call succeeds', () async {
      final mockResponse = [
        {
          "id_prediction": "pred_001",
          "date_validite": "2026-05-11",
          "polygone_geojson": {},
          "score_probabilite": 0.85,
          "espece_cible": "Thunnus albacares"
        },
        {
          "id_prediction": "pred_002",
          "date_validite": "2026-05-11",
          "polygone_geojson": {},
          "score_probabilite": 0.92,
          "espece_cible": "Sardina pilchardus"
        }
      ];

      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/predictions/zones/today') {
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      final predictionService = PredictionService(client: client);
      final zones = await predictionService.getFishingZonesToday();

      expect(zones, isA<List<FishingZoneModel>>());
      expect(zones.length, 2);
      expect(zones[0].scoreProbabilite, 0.85);
      expect(zones[1].idPrediction, 'pred_002');
    });

    test('throws exception on http error', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final predictionService = PredictionService(client: client);
      expect(predictionService.getFishingZonesToday(), throwsException);
    });
  });
}
