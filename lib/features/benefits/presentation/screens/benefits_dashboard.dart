import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/services/finance_service.dart';
import 'expense_capture_screen.dart';

class BenefitsDashboard extends StatefulWidget {
  const BenefitsDashboard({super.key});

  @override
  State<BenefitsDashboard> createState() => _BenefitsDashboardState();
}

class _BenefitsDashboardState extends State<BenefitsDashboard> {
  final FinanceService _financeService = FinanceService();
  Map<String, dynamic>? _solvabilityData;
  List<dynamic> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ⚡ Bolt: Parallelize independent async requests using Dart 3 records to improve load time
        final (solvabilityData, expensesData) = await (
          _financeService.getSolvabilityScore(user.uid),
          _financeService.getUserExpenses(user.uid),
        ).wait;

        setState(() {
          _solvabilityData = solvabilityData['data'];
          _expenses = expensesData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading benefits data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSolvabilityCard(),
            const SizedBox(height: 25),
            _buildActionGrid(),
            const SizedBox(height: 25),
            _buildRecentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSolvabilityCard() {
    final score = _solvabilityData?['score'] ?? 0;
    final level = _solvabilityData?['level'] ?? 'INCONNU';

    Color levelColor;
    switch (level) {
      case 'EXCELLENT':
        levelColor = Colors.green;
        break;
      case 'BON':
        levelColor = Colors.lightGreen;
        break;
      case 'MOYEN':
        levelColor = Colors.orange;
        break;
      case 'RISQUE ÉLEVÉ':
        levelColor = Colors.red;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SCORE DE SOLVABILITÉ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Text(
              'NIVEAU : $level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Ce score est calculé sur la base de vos dépenses payées. Un score élevé facilite l\'accès au micro-crédit.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GESTION FINANCIÈRE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildActionItem(
              'Nouvelle Dépense',
              Icons.add_a_photo,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseCaptureScreen(),
                ),
              ),
            ),
            const SizedBox(width: 15),
            _buildActionItem(
              'Mes Crédits',
              Icons.account_balance_wallet,
              () {}, // To be implemented in Module 3
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.border.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DÉPENSES RÉCENTES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        if (_expenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.border.withOpacity(0.5)),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_outlined, color: Colors.grey, size: 40),
                SizedBox(height: 10),
                Text(
                  'Aucune dépense récente numérisée.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ..._expenses
              .take(5)
              .map((expense) => _buildExpenseItem(expense))
              .toList(),
      ],
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final status = expense['status'] ?? 'EN_ATTENTE';
    final amount = expense['totalAmount'] ?? 0;
    final supplier = expense['supplierName'] ?? 'Inconnu';
    final date = expense['createdAt'] != null
        ? DateTime.parse(expense['createdAt'])
        : DateTime.now();

    Color statusColor = status.toString().startsWith('PAYE')
        ? Colors.green
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amount FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status.toString().replaceAll('_', ' '),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
