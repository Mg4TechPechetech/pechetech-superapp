import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/weather_model.dart';

class WeatherService {
  final String baseUrl;
  final http.Client httpClient;

  // Assuming Gateway runs on localhost:8080 in dev
  WeatherService({
    this.baseUrl = 'http://localhost:8080/api/v1/weather',
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  Future<WeatherModel> getCurrentWeather({String siteId = 'yoff'}) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/current?site_id=$siteId'),
      );
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
