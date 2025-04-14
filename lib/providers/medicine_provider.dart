import 'package:flutter/foundation.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<Medicine> _sortedMedicines = [];
  bool _isLoading = true;
  bool _hasError = false;
  MedicineSortMethod _sortMethod = MedicineSortMethod.additionOrder;
  bool _isCollapsed = false;
  DateTime _lastInteractionTime = DateTime.now();

  MedicineProvider() {
    _loadMedicines();
    _startIdleTimer();
  }

  // Getter to access the medicines list
  List<Medicine> get medicines => List.unmodifiable(_sortedMedicines);
  
  // Loading state
  bool get isLoading => _isLoading;
  
  // Error state
  bool get hasError => _hasError;

  // Collapsed state
  bool get isCollapsed => _isCollapsed;

  // Current sort method
  MedicineSortMethod get sortMethod => _sortMethod;

  // Start timer to check for idle state
  void _startIdleTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      final now = DateTime.now();
      if (now.difference(_lastInteractionTime).inSeconds >= 30 && !_manualMode) {
        if (!_isCollapsed) {
          _isCollapsed = true;
          notifyListeners();
        }
      }
      _startIdleTimer(); // Restart the timer
    });
  }

  // Flag to indicate if collapse mode is manually controlled
  bool _manualMode = false;

  // Record user interaction
  void recordInteraction() {
    _lastInteractionTime = DateTime.now();
    if (_isCollapsed && !_manualMode) {
      _isCollapsed = false;
      notifyListeners();
    }
  }

  // Toggle display mode manually
  void toggleDisplayMode() {
    _manualMode = true;
    _isCollapsed = !_isCollapsed;
    notifyListeners();
  }

  // Set display mode
  void setDisplayMode(bool collapsed) {
    if (_isCollapsed != collapsed) {
      _isCollapsed = collapsed;
      _manualMode = true;
      notifyListeners();
    }
  }

  // Reset to automatic mode
  void resetToAutoMode() {
    _manualMode = false;
    _lastInteractionTime = DateTime.now();
    _isCollapsed = false;
    notifyListeners();
  }

  // Sort medicines based on current sort method
  void _sortMedicines() {
    _sortedMedicines = List.from(_medicines);
    
    switch (_sortMethod) {
      case MedicineSortMethod.alphabetical:
        _sortedMedicines.sort((a, b) => a.name.compareTo(b.name));
        break;
      case MedicineSortMethod.additionOrder:
        _sortedMedicines.sort((a, b) => a.addedDate.compareTo(b.addedDate));
        break;
      case MedicineSortMethod.expirationTime:
        _sortedMedicines.sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));
        break;
      case MedicineSortMethod.remainingQuantity:
        _sortedMedicines.sort((a, b) {
          // Handle empty medicines (put them at the end)
          if (a.isEmpty && !b.isEmpty) return 1;
          if (!a.isEmpty && b.isEmpty) return -1;
          if (a.isEmpty && b.isEmpty) return 0;
          
          // Compare by percentage of remaining quantity
          final aPercentage = a.quantity / a.initialQuantity;
          final bPercentage = b.quantity / b.initialQuantity;
          return aPercentage.compareTo(bPercentage);
        });
        break;
    }
  }

  // Change sort method
  void setSortMethod(MedicineSortMethod method) {
    if (_sortMethod != method) {
      _sortMethod = method;
      _sortMedicines();
      notifyListeners();
    }
    recordInteraction();
  }

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
      
      _sortMedicines();
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
    _sortMedicines();
    recordInteraction();
    notifyListeners();
    await _saveMedicines();
  }

  // Remove a medicine from the list
  Future<void> removeMedicine(int index) async {
    if (index >= 0 && index < _sortedMedicines.length) {
      final medicine = _sortedMedicines[index];
      _medicines.remove(medicine);
      _sortMedicines();
      recordInteraction();
      notifyListeners();
      await _saveMedicines();
    }
  }

  // Update an existing medicine
  Future<void> updateMedicine(int index, Medicine medicine) async {
    if (index >= 0 && index < _sortedMedicines.length) {
      final oldMedicine = _sortedMedicines[index];
      final oldIndex = _medicines.indexOf(oldMedicine);
      if (oldIndex >= 0) {
        _medicines[oldIndex] = medicine;
        _sortMedicines();
        recordInteraction();
        notifyListeners();
        await _saveMedicines();
      }
    }
  }

  // Use medicine (reduce quantity by dosage)
  Future<void> useMedicine(int index) async {
    if (index >= 0 && index < _sortedMedicines.length) {
      final medicine = _sortedMedicines[index];
      
      // Only use if there's enough quantity
      if (medicine.quantity > 0) {
        medicine.use();
        recordInteraction();
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
