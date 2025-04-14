import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _medicinesKey = 'medicines';

  // Save list of medicines to SharedPreferences
  static Future<bool> saveMedicines(List<Medicine> medicines) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicinesJson = medicines.map((medicine) => medicine.toJson()).toList();
      final medicinesJsonString = jsonEncode(medicinesJson);
      
      return await prefs.setString(_medicinesKey, medicinesJsonString);
    } catch (e) {
      print('Error saving medicines: $e');
      return false;
    }
  }

  // Load list of medicines from SharedPreferences
  static Future<List<Medicine>> loadMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicinesJsonString = prefs.getString(_medicinesKey);
      
      if (medicinesJsonString == null || medicinesJsonString.isEmpty) {
        return [];
      }
      
      final medicinesJson = jsonDecode(medicinesJsonString) as List;
      return medicinesJson
          .map((json) => Medicine.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading medicines: $e');
      return [];
    }
  }

  // Clear all saved medicines
  static Future<bool> clearMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_medicinesKey);
    } catch (e) {
      print('Error clearing medicines: $e');
      return false;
    }
  }
}
