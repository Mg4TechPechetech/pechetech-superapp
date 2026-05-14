class WeatherModel {
  final String condition;
  final int temperature;
  final int windSpeed;
  final String windDirection;
  final double waveHeight;
  final int wavePeriod;
  final String statusText;
  final String alertText;

  WeatherModel({
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.waveHeight,
    required this.wavePeriod,
    required this.statusText,
    required this.alertText,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      condition: json['condition'] ?? 'good',
      temperature: json['temperature'] ?? 24,
      windSpeed: json['wind_speed'] ?? 12,
      windDirection: json['wind_direction'] ?? 'NO',
      waveHeight: (json['wave_height'] ?? 1.2).toDouble(),
      wavePeriod: json['wave_period'] ?? 8,
      statusText: json['status_text'] ?? 'Ciel clair',
      alertText: json['alert_text'] ?? 'CONDITIONS FAVORABLES',
    );
  }
}
