import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import 'models/weather_model.dart';

class WeatherService {
  final String baseUrl;
  final http.Client httpClient;

  WeatherService({
    String? baseUrl,
    http.Client? client,
  }) : baseUrl = baseUrl ?? '${ApiConstants.apiBaseUrl}/weather',
       httpClient = client ?? http.Client();

  Future<WeatherModel> getCurrentWeather({String siteId = 'yoff'}) async {
    try {
      final response = await httpClient.get(Uri.parse('$baseUrl/current?site_id=$siteId'));
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }
}
