import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:universal_io/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pechetech_header.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../../../notifications/presentation/notifications_screen.dart';
import '../../../fuel_subsidies/presentation/fuel_path_screen.dart';
import '../../data/services/finance_service.dart';

class ExpenseCaptureScreen extends StatefulWidget {
  const ExpenseCaptureScreen({super.key});

  @override
  State<ExpenseCaptureScreen> createState() => _ExpenseCaptureScreenState();
}

class _ExpenseCaptureScreenState extends State<ExpenseCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  CroppedFile? _imageFile;
  Uint8List? _webImageBytes;
  bool _isLoading = false;

  // Form Controllers
  final _amountController = TextEditingController();
  final _supplierController = TextEditingController();
  String _selectedCategory = 'AUTRE';
  double _aiConfidence = 0.0;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer le reçu',
            toolbarColor: AppTheme.primaryGreen,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Recadrer le reçu',
            aspectRatioLockEnabled: false,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.page,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );

      if (croppedFile != null) {
        if (kIsWeb) {
          final bytes = await croppedFile.readAsBytes();
          setState(() {
            _imageFile = croppedFile;
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _imageFile = croppedFile;
          });
        }
        _processImage();
      }
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Sur le Web, on envoie les bytes. Sur Mobile, le XFile lui-même ou son chemin.
      final input = kIsWeb ? _webImageBytes : _imageFile;
      final result = await FinanceService().extractReceiptData(input);
      setState(() {
        final amount = result['total_amount'];
        _amountController.text = (amount == null || amount == 0) ? 'NULL' : amount.toString();
        
        final supplier = result['supplier_name'];
        _supplierController.text = (supplier == null || supplier.toString().isEmpty) ? 'NULL' : supplier;
        
        _selectedCategory = result['category'] ?? 'AUTRE';
        _aiConfidence = (result['confidence_score'] ?? 0.0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'analyse : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<int>(
          stream: NotificationService().getUnreadCount(FirebaseAuth.instance.currentUser?.uid),
          builder: (context, snapshot) {
            return Column(
              children: [
                PecheTechHeader(
                  showBackButton: true,
                  notificationCount: snapshot.data ?? 0,
                  onFuelTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FuelPathScreen()),
                  ),
                  onNotificationsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ),
                ),
                Expanded(
                  child: _imageFile == null ? _buildInitialState() : _buildValidationState(),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: AppTheme.primaryGreen.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            'Numérisez vos reçus',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Prenez en photo vos reçus (glace, essence, appâts) pour les enregistrer automatiquement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Prendre une photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choisir depuis la galerie'),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationState() {
    return Column(
      children: [
        // Top: Image Viewer
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(bottom: BorderSide(color: AppTheme.primaryGreen, width: 2)),
          ),
          child: Stack(
            children: [
              Center(
                child: kIsWeb
                    ? (_webImageBytes != null 
                        ? Image.memory(_webImageBytes!, fit: BoxFit.contain)
                        : const SizedBox())
                    : Image.file(File(_imageFile!.path), fit: BoxFit.contain),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        
        // Bottom: Validation Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VÉRIFICATION DES DONNÉES',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 20),
                _buildField('Fournisseur', _supplierController, Icons.store),
                const SizedBox(height: 15),
                _buildField('Montant Total (FCFA)', _amountController, Icons.payments, keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                _buildCategoryDropdown(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('VALIDER ET PAYER', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _imageFile = null),
                    child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        prefixIcon: Icon(Icons.category, color: AppTheme.primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['CARBURANT', 'GLACE', 'APPATS', 'VIVRES', 'ENTRETIEN', 'AUTRE']
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
    );
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _amountController.text == 'NULL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le montant manuellement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_supplierController.text.isEmpty || _supplierController.text == 'NULL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le nom du fournisseur manuellement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final expenseData = {
        'userId': user.uid,
        'supplierName': _supplierController.text,
        'totalAmount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'fishingCampaignId': 'CAMP-2026-001', // Placeholder ou à récupérer
        'aiConfidenceScore': _aiConfidence,
        'status': 'EN_ATTENTE',
      };

      await FinanceService().createExpense(expenseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépense enregistrée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
