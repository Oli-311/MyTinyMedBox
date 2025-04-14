import 'package:flutter/foundation.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  bool _hasError = false;

  MedicineProvider() {
    _loadMedicines();
  }

  // Getter to access the medicines list
  List<Medicine> get medicines => List.unmodifiable(_medicines);
  
  // Loading state
  bool get isLoading => _isLoading;
  
  // Error state
  bool get hasError => _hasError;

  // Load medicines from storage
  Future<void> _loadMedicines() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final loadedMedicines = await StorageService.loadMedicines();
      
      // If no saved medicines, use sample data
      if (loadedMedicines.isEmpty) {
        _medicines = _getSampleMedicines();
      } else {
        _medicines = loadedMedicines;
      }
      
      _isLoading = false;
      _hasError = false;
      notifyListeners();
      
      // Save sample data if we're using it for the first time
      if (loadedMedicines.isEmpty) {
        await _saveMedicines();
      }
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      notifyListeners();
      print('Error loading medicines: $e');
    }
  }

  // Save medicines to storage
  Future<void> _saveMedicines() async {
    try {
      await StorageService.saveMedicines(_medicines);
    } catch (e) {
      print('Error saving medicines: $e');
    }
  }

  // Get sample medicines for first launch
  List<Medicine> _getSampleMedicines() {
    return [
      Medicine(
        name: '阿司匹林',
        quantity: 30,
        unit: MedicineUnit.tablet,
        dosage: 1,
        effects: '解热镇痛，抗炎，抗血小板聚集',
        expirationDate: DateTime.now().add(const Duration(days: 180)),
      ),
      Medicine(
        name: '布洛芬',
        quantity: 20,
        unit: MedicineUnit.tablet,
        dosage: 0.5,
        effects: '解热镇痛，抗炎',
        expirationDate: DateTime.now().add(const Duration(days: 90)),
      ),
      Medicine(
        name: '维生素C',
        quantity: 60,
        unit: MedicineUnit.tablet,
        dosage: 1,
        effects: '补充维生素C，增强免疫力',
        expirationDate: DateTime.now().add(const Duration(days: 365)),
      ),
      Medicine(
        name: '感冒糖浆',
        quantity: 100,
        unit: MedicineUnit.milliliter,
        dosage: 10,
        effects: '缓解感冒症状',
        expirationDate: DateTime.now().add(const Duration(days: 120)),
      ),
      Medicine(
        name: '创可贴',
        quantity: 5,
        unit: MedicineUnit.strip,
        dosage: 1,
        effects: '保护伤口，防止感染',
        expirationDate: DateTime.now().add(const Duration(days: 730)),
      ),
    ];
  }

  // Add a new medicine to the list
  Future<void> addMedicine(Medicine medicine) async {
    _medicines.add(medicine);
    notifyListeners();
    await _saveMedicines();
  }

  // Remove a medicine from the list
  Future<void> removeMedicine(int index) async {
    if (index >= 0 && index < _medicines.length) {
      _medicines.removeAt(index);
      notifyListeners();
      await _saveMedicines();
    }
  }

  // Update an existing medicine
  Future<void> updateMedicine(int index, Medicine medicine) async {
    if (index >= 0 && index < _medicines.length) {
      _medicines[index] = medicine;
      notifyListeners();
      await _saveMedicines();
    }
  }

  // Use medicine (reduce quantity by dosage)
  Future<void> useMedicine(int index) async {
    if (index >= 0 && index < _medicines.length) {
      final medicine = _medicines[index];
      
      // Only use if there's enough quantity
      if (medicine.quantity > 0) {
        medicine.use();
        notifyListeners();
        await _saveMedicines();
      }
    }
  }

  // Reload medicines from storage
  Future<void> reloadMedicines() async {
    await _loadMedicines();
  }
}
