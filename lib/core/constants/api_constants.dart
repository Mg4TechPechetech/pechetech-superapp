class ApiConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// Clé OCR.space, fournie au build : `--dart-define=OCR_SPACE_API_KEY=...`.
  /// Vide par défaut : l'application utilise alors le repli local de lecture de reçus.
  static const String ocrSpaceApiKey = String.fromEnvironment(
    'OCR_SPACE_API_KEY',
    defaultValue: '',
  );
}
