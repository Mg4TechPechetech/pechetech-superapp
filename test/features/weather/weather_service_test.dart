import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pechetech_superapp/features/weather/data/models/weather_model.dart';
import 'package:pechetech_superapp/features/weather/data/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('returns WeatherModel if the http call completes successfully', () async {
      final mockResponse = {
        'condition': 'moderate',
        'temperature': 26,
        'wind_speed': 25,
        'wind_direction': 'NO',
        'wave_height': 2.0,
        'wave_period': 7,
        'status_text': 'Mer agitée',
        'alert_text': 'ALERTE MODÉRÉE'
      };

      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/weather/current') {
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      final weatherService = WeatherService(client: client);
      final weather = await weatherService.getCurrentWeather(siteId: 'yoff');

      expect(weather, isA<WeatherModel>());
      expect(weather.condition, 'moderate');
      expect(weather.temperature, 26);
    });

    test('throws an exception if the http call completes with an error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final weatherService = WeatherService(client: client);
      expect(weatherService.getCurrentWeather(siteId: 'yoff'), throwsException);
    });
  });
}

