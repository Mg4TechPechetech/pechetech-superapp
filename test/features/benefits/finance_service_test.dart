import 'package:flutter_test/flutter_test.dart';
import 'package:pechetech_superapp/features/benefits/data/services/finance_service.dart';

void main() {
  group('FinanceService Client-Side Math Calculations', () {
    late FinanceService financeService;

    setUp(() {
      // Initialize service with null firestore/storage.
      // We will only call calculateDistribution which runs pure, networkless Dart math!
      financeService = FinanceService(firestore: null, storage: null);
    });

    test('Pirogue Glacière - Standard Profit Sharing Calculation', () async {
      final requestData = {
        'grossRevenue': 500000.0,
        'totalExpenses': 100000.0,
        'numberOfFishermen': 4,
        'unitType': 'PIROGUE_GLACIERE',
        'pirogueParts': 1.0,
        'moteurParts': 1.0,
      };

      final result = await financeService.calculateDistribution(requestData);

      // netRevenue = 500000.0 - 100000.0 = 400000.0
      // totalParts = 4 (fishermen) + 1 (pirogue) + 1 (moteur) = 6 parts
      // valuePerPart = 400000.0 / 6 = 66666.6666...
      // netSharePerFisherman = 66666.6666...
      // amortizationFund = valuePerPart * (pirogue + moteur) = 66666.6666 * 2 = 133333.3333...

      expect(result['netRevenue'], closeTo(400000.0, 0.01));
      expect(result['netSharePerFisherman'], closeTo(66666.67, 0.01));
      expect(result['amortizationFund'], closeTo(133333.33, 0.01));
      expect(result['equipmentShare'], closeTo(0.0, 0.01));
    });

    test('Senne Tournante - Standard Profit Sharing Calculation', () async {
      final requestData = {
        'grossRevenue': 1200000.0,
        'totalExpenses': 300000.0,
        'numberOfFishermen': 10,
        'unitType': 'SENNE_TOURNANTE',
        'moteurParts': 2.0,
        'filetFraction': 0.3333, // 1/3 for filet
      };

      final result = await financeService.calculateDistribution(requestData);

      // netRevenue = 1200000.0 - 300000.0 = 900000.0
      // equipmentShare (filet) = 900000.0 * 0.3333 = 299970.0
      // remaining = 900000.0 - 299970.0 = 600030.0
      // totalParts = 10 (fishermen) + 2 (moteur) = 12 parts
      // valuePerPartRemaining = 600030.0 / 12 = 50002.5
      // netSharePerFisherman = 50002.5
      // amortizationFund = 50002.5 * 2 = 100005.0

      expect(result['netRevenue'], closeTo(900000.0, 0.01));
      expect(result['equipmentShare'], closeTo(299970.0, 0.01));
      expect(result['netSharePerFisherman'], closeTo(50002.5, 0.01));
      expect(result['amortizationFund'], closeTo(100005.0, 0.01));
    });

    test('Zero or Negative Net Revenue Handling', () async {
      final requestData = {
        'grossRevenue': 50000.0,
        'totalExpenses': 60000.0, // deficit
        'numberOfFishermen': 3,
        'unitType': 'PIROGUE_GLACIERE',
        'pirogueParts': 1.0,
        'moteurParts': 1.0,
      };

      final result = await financeService.calculateDistribution(requestData);

      expect(result['netRevenue'], closeTo(-10000.0, 0.01));
      expect(result['netSharePerFisherman'], closeTo(0.0, 0.01));
      expect(result['amortizationFund'], closeTo(0.0, 0.01));
      expect(result['equipmentShare'], closeTo(0.0, 0.01));
    });
  });

  group('FinanceService OCR Receipt Parser', () {
    late FinanceService financeService;

    setUp(() {
      financeService = FinanceService(firestore: null, storage: null);
    });

    test('Parses Total Carburant Receipt successfully', () {
      final rawText = """
      STATION TOTAL YOFF
      DAKAR, SENEGAL
      TEL: 33 820 00 00
      ---
      CARBURANT: GAZOLE
      QUANTITE: 50 L
      PRIX/L: 750 FCFA
      TOTAL: 37500 FCFA
      MERCI DE VOTRE VISITE!
      """;

      final result = financeService.parseReceiptText(rawText, "mock_download_url");

      expect(result['supplier_name'], equals('Station Total - Dakar'));
      expect(result['category'], equals('CARBURANT'));
      expect(result['total_amount'], equals(37500.0));
      expect(result['currency'], equals('FCFA'));
      expect(result['confidence_score'], equals(0.95));
      expect(result['audit_image_url'], equals('mock_download_url'));
    });

    test('Parses Ice Receipt from Hann successfully', () {
      final rawText = """
      PECHERIE DE HANN - GLACE EN BLOC
      Date: 25/05/2026
      Description: 10 Blocs de Glace
      Montant: 12000 F
      Payé comptant
      """;

      final result = financeService.parseReceiptText(rawText, null);

      expect(result['supplier_name'], equals('Pêcherie Hann Glace'));
      expect(result['category'], equals('GLACE'));
      expect(result['total_amount'], equals(12000.0));
      expect(result['currency'], equals('FCFA'));
    });

    test('Parses Bait Receipt from Mbour successfully', () {
      final rawText = """
      LES APPATS DU LARGE
      PORT DE MBOUR
      HAUT DE GAMME
      CLIENT: COOPERATIVE
      HAMEÇONS & LEURRES
      TOTAL A PAYER: 65000 FCFA
      """;

      final result = financeService.parseReceiptText(rawText, "url_here");

      expect(result['supplier_name'], equals('Appâts du Large - Mbour'));
      expect(result['category'], equals('APPATS'));
      expect(result['total_amount'], equals(65000.0));
    });
  });
}

