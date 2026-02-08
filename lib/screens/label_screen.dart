import 'package:flutter/material.dart';

import '../models/label_data.dart';
import '../services/print_service.dart';

/// Fő képernyő: adatbevitel, élő előnézet és nyomtatás.
///
/// Egyetlen képernyőn jeleníti meg a három beviteli mezőt,
/// a címke előnézetét és a nyomtatás gombot.
class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key});

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _printService = PrintService();

  /// Az aktuális címke adatok a controllerek értékei alapján.
  LabelData get _labelData => LabelData(
        name: _nameController.text,
        city: _cityController.text,
        street: _streetController.text,
      );

  @override
  void initState() {
    super.initState();
    // Élő előnézet frissítés minden szövegváltozáskor
    _nameController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _streetController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  /// Nyomtatás indítása, hiba esetén SnackBar megjelenítése.
  Future<void> _onPrint() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _printService.printLabel(_labelData);
    } catch (e) {
      if (mounted) {
        debugPrint('Nyomtatási hiba: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nyomtatási hiba: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Címkenyomtató'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tablet (>= 600px): egymás mellett, Telefon: egymás alatt
          if (constraints.maxWidth >= 600) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildForm()),
                Expanded(child: _buildPreviewAndButton()),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildForm(),
                _buildPreviewAndButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Beviteli űrlap: név, város, utca és házszám mezők.
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Név',
                hintText: 'pl. John Doe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Név megadása kötelező' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Város',
                hintText: 'pl. Hódmezővásárhely',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Város megadása kötelező' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Utca és házszám',
                hintText: 'pl. Kossuth utca 42',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Utca és házszám megadása kötelező'
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Címke előnézet és nyomtatás gomb.
  Widget _buildPreviewAndButton() {
    final data = _labelData;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Előnézet kártya
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    data.name.isEmpty ? '(Név)' : data.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: data.name.isEmpty ? Colors.grey : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.city.isEmpty ? '(Város)' : data.city,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: data.city.isEmpty ? Colors.grey : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.street.isEmpty ? '(Utca és házszám)' : data.street,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: data.street.isEmpty ? Colors.grey : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nyomtatás gomb
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: data.isValid ? _onPrint : null,
              child: const Text('Nyomtatás'),
            ),
          ),
        ],
      ),
    );
  }
}
