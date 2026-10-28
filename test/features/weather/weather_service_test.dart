import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pechetech_superapp/features/weather/data/models/weather_model.dart';
import 'package:pechetech_superapp/features/weather/data/weather_service.dart';

void main() {
  group('WeatherService Client-Side API Integration', () {
    test('successfully parses Open-Meteo and Marine-API JSON to return accurate WeatherModel and warning levels', () async {
      final mockForecastResponse = {
        'current': {
          'temperature_2m': 26.5,
          'wind_speed_10m': 25.0,
          'wind_direction_10m': 315, // NW
          'weather_code': 3, // Partiellement nuageux
        }
      };

      final mockMarineResponse = {
        'current': {
          'wave_height': 2.0,
          'wave_period': 7.0,
        }
      };

      final client = MockClient((request) async {
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(jsonEncode(mockForecastResponse), 200);
        } else if (request.url.host == 'marine-api.open-meteo.com') {
          return http.Response(jsonEncode(mockMarineResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      final weatherService = WeatherService(client: client);
      final weather = await weatherService.getCurrentWeather(siteId: 'yoff');

      expect(weather, isA<WeatherModel>());
      expect(weather.condition, 'moderate'); // wind_speed 25.0 > 20 or wave 2.0 > 1.5
      expect(weather.temperature, 27); // round(26.5)
      expect(weather.windDirection, 'NW');
      expect(weather.statusText, 'Partiellement nuageux');
      expect(weather.alertText, 'ALERTE MODÉRÉE');
    });

    test('resiliently falls back to safe weather defaults when server errors occur', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final weatherService = WeatherService(client: client);
      final weather = await weatherService.getCurrentWeather(siteId: 'invalid-site');

      // The service must not throw an exception; it must fallback gracefully
      expect(weather, isA<WeatherModel>());
      expect(weather.condition, 'good');
      expect(weather.temperature, 25); // Default temperature is used in catch fallback
      expect(weather.alertText, 'CONDITIONS FAVORABLES');
    });
  });
}
