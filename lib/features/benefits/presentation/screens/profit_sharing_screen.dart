import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pechetech_header.dart';
import '../../data/services/finance_service.dart';

class ProfitSharingScreen extends StatefulWidget {
  const ProfitSharingScreen({super.key});

  @override
  State<ProfitSharingScreen> createState() => _ProfitSharingScreenState();
}

class _ProfitSharingScreenState extends State<ProfitSharingScreen> {
  final FinanceService _financeService = FinanceService();
  final _grossRevenueController = TextEditingController();
  final _fishermenCountController = TextEditingController();
  final _idPirogueController = TextEditingController(text: 'PIROGUE-DEMO-01');
  
  // Custom Calculation Controllers
  final _piroguePartsController = TextEditingController(text: '1.0');
  final _moteurPartsController = TextEditingController(text: '1.0');
  final _filetFractionController = TextEditingController(text: '33.33');
  
  bool _isLoading = true;
  double _totalExpenses = 0;
  String _selectedUnitType = 'PIROGUE_GLACIERE';
  Map<String, dynamic>? _distributionResult;
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _selectDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
      });
    }
  }

  Future<void> _selectDateFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateFin) {
      setState(() {
        _dateFin = picked;
      });
    }
  }

  Future<void> _fetchExpenses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final expenses = await _financeService.getUserExpenses(user.uid);
        double total = 0;
        for (var expense in expenses) {
          total += double.tryParse(expense['amount']?.toString() ?? '0') ?? 0;
        }
        setState(() {
          _totalExpenses = total;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateDistribution() async {
    final grossStr = _grossRevenueController.text;
    final fishermenStr = _fishermenCountController.text;

    if (grossStr.isEmpty || fishermenStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pirogueParts = double.tryParse(_piroguePartsController.text) ?? 1.0;
      final moteurParts = double.tryParse(_moteurPartsController.text) ?? 1.0;
      final filetPercent = double.tryParse(_filetFractionController.text) ?? 33.33;
      final filetFraction = filetPercent / 100.0;

      final requestData = {
        'grossRevenue': double.parse(grossStr),
        'totalExpenses': _totalExpenses,
        'numberOfFishermen': int.parse(fishermenStr),
        'unitType': _selectedUnitType,
        'pirogueParts': pirogueParts,
        'moteurParts': moteurParts,
        'filetFraction': filetFraction,
      };

      final result = await _financeService.calculateDistribution(requestData);
      setState(() {
        _distributionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error calculating distribution: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du calcul')),
        );
      }
    }
  }

  Future<void> _saveDistribution() async {
    if (_distributionResult == null) return;

    setState(() => _isLoading = true);

    try {
      final grossStr = _grossRevenueController.text;
      final fishermenStr = _fishermenCountController.text;

      final pirogueParts = double.tryParse(_piroguePartsController.text) ?? 1.0;
      final moteurParts = double.tryParse(_moteurPartsController.text) ?? 1.0;
      final filetPercent = double.tryParse(_filetFractionController.text) ?? 33.33;
      final filetFraction = filetPercent / 100.0;

      final saveData = {
        'grossRevenue': double.parse(grossStr),
        'totalExpenses': _totalExpenses,
        'numberOfFishermen': int.parse(fishermenStr),
        'unitType': _selectedUnitType,
        'calculationResult': _distributionResult,
        'idPirogue': _idPirogueController.text.trim().isEmpty ? 'PIROGUE-DEMO-01' : _idPirogueController.text.trim(),
        'dateDebut': _dateDebut.toIso8601String().split('T')[0],
        'dateFin': _dateFin.toIso8601String().split('T')[0],
        'pirogueParts': pirogueParts,
        'moteurParts': moteurParts,
        'filetFraction': filetFraction,
      };

      await _financeService.saveDistribution(saveData);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Répartition enregistrée avec succès dans la base de données !'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving distribution: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const PecheTechHeader(
              showBackButton: true,
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalExpensesCard(),
                        const SizedBox(height: 24),
                        _buildInputForm(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _calculateDistribution,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Calculer la répartition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        if (_distributionResult != null) ...[
                          const SizedBox(height: 32),
                          _buildResultsSection(),
                        ]
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalExpensesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Charges Communes (Déduites)', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${_totalExpenses.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.remove_circle_outline, color: Colors.red, size: 32),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenu Brut Vente (FCFA)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _grossRevenueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ex: 500000',
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Type d'unité", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUnitType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'PIROGUE_GLACIERE', child: Text('Pirogue Glacière')),
                  DropdownMenuItem(value: 'SENNE_TOURNANTE', child: Text('Senne Tournante')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUnitType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Nombre de pêcheurs', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _fishermenCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ex: 5',
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Référence de la Pirogue', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _idPirogueController,
            decoration: InputDecoration(
              hintText: 'Ex: PIROGUE-DEMO-01',
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date Début', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateDebut(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_dateDebut.day.toString().padLeft(2, '0')}/${_dateDebut.month.toString().padLeft(2, '0')}/${_dateDebut.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date Fin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateFin(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_dateFin.day.toString().padLeft(2, '0')}/${_dateFin.month.toString().padLeft(2, '0')}/${_dateFin.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
          Row(
            children: [
              const Icon(Icons.tune, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Paramétrage personnalisé des calculs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedUnitType == 'PIROGUE_GLACIERE') ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Parts Pirogue', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _piroguePartsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '1.0',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Parts Moteur', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _moteurPartsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '1.0',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else if (_selectedUnitType == 'SENNE_TOURNANTE') ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Part du Filet (%)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _filetFractionController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '33.33',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixText: '%',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Parts Moteur/Annexe', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _moteurPartsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '1.0',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final net = _distributionResult!['netRevenue'] ?? 0;
    final amort = _distributionResult!['amortizationFund'] ?? 0;
    final share = _distributionResult!['netSharePerFisherman'] ?? 0;
    final equip = _distributionResult!['equipmentShare'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RÉSULTAT DE LA RÉPARTITION', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildResultRow('Revenu Net à Partager', net, isTitle: true),
          const Divider(color: Colors.white24, height: 24),
          _buildResultRow('Part de Réserve (Amortissement)', amort),
          const SizedBox(height: 12),
          _buildResultRow('Part nette par pêcheur', share),
          if (equip > 0) ...[
            const SizedBox(height: 12),
            _buildResultRow('Part du Filet', equip),
          ],
          const Divider(color: Colors.white24, height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveDistribution,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Valider et Enregistrer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, num value, {bool isTitle = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTitle ? Colors.white : Colors.white70,
              fontSize: isTitle ? 16 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${value.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTitle ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
