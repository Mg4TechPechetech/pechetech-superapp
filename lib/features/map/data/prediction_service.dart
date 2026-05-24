import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import 'models/fishing_zone_model.dart';

class PredictionService {
  final String baseUrl;
  final http.Client httpClient;

  PredictionService({
    String? baseUrl,
    http.Client? client,
  }) : baseUrl = baseUrl ?? '${ApiConstants.apiBaseUrl}/predictions',
       httpClient = client ?? http.Client();

  Future<List<FishingZoneModel>> getFishingZonesToday() async {
    try {
      final response = await httpClient.get(Uri.parse('$baseUrl/zones/today'));
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        return List<FishingZoneModel>.from(l.map((model) => FishingZoneModel.fromJson(model)));
      } else {
        throw Exception('Failed to load fishing zones');
      }
    } catch (e) {
      throw Exception('Failed to fetch fishing zones data: $e');
    }
  }
}
