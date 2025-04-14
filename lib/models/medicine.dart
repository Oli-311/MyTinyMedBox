enum MedicineUnit {
  tablet, // 片/粒
  milliliter, // 毫升
  strip, // 条/支
}

enum MedicineStatus {
  normal,
  empty,
  almostEmpty,
  aboutToExpire,
}

enum MedicineSortMethod {
  alphabetical,
  additionOrder,
  expirationTime,
  remainingQuantity,
}

class Medicine {
  final String name;
  double quantity;
  final double initialQuantity; // Store initial quantity for comparison
  final MedicineUnit unit;
  final double dosage;
  final String effects;
  final DateTime expirationDate;
  final DateTime addedDate; // Store when the medicine was added

  Medicine({
    required this.name,
    required this.quantity,
    double? initialQuantity,
    this.unit = MedicineUnit.tablet,
    this.dosage = 1.0,
    this.effects = '',
    required this.expirationDate,
    DateTime? addedDate,
  }) : 
    this.initialQuantity = initialQuantity ?? quantity,
    this.addedDate = addedDate ?? DateTime.now();

  // Check if medicine is empty
  bool get isEmpty => quantity <= 0;

  // Check if medicine is almost empty (less than 10% of initial quantity)
  bool get isAlmostEmpty => quantity > 0 && quantity < (initialQuantity / 10);

  // Check if medicine is about to expire (less than 10 days)
  bool get isAboutToExpire => daysUntilExpiration >= 0 && daysUntilExpiration < 10;

  // Get medicine status
  MedicineStatus get status {
    if (isEmpty) return MedicineStatus.empty;
    if (isAlmostEmpty) return MedicineStatus.almostEmpty;
    if (isAboutToExpire) return MedicineStatus.aboutToExpire;
    return MedicineStatus.normal;
  }

  // Use medicine (reduce quantity by dosage)
  void use() {
    quantity = (quantity - dosage).clamp(0, double.infinity);
  }

  // Create a copy of this medicine with updated properties
  Medicine copyWith({
    String? name,
    double? quantity,
    MedicineUnit? unit,
    double? dosage,
    String? effects,
    DateTime? expirationDate,
  }) {
    return Medicine(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      dosage: dosage ?? this.dosage,
      effects: effects ?? this.effects,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  // Calculate remaining days until expiration
  int get daysUntilExpiration {
    final now = DateTime.now();
    return expirationDate.difference(now).inDays;
  }

  // Format the expiration date as a string
  String get formattedExpirationDate {
    return '${expirationDate.year}年${expirationDate.month}月${expirationDate.day}日';
  }

  // Get a status string based on days until expiration
  String get expirationStatus {
    final days = daysUntilExpiration;
    if (days < 0) {
      return '已过期';
    } else if (days < 30) {
      return '即将过期 (剩余 $days 天)';
    } else {
      return '剩余 $days 天';
    }
  }

  // Get the unit string based on the unit enum
  String get unitString {
    switch (unit) {
      case MedicineUnit.tablet:
        return '片/粒';
      case MedicineUnit.milliliter:
        return '毫升';
      case MedicineUnit.strip:
        return '条/支';
    }
  }

  // Get the dosage string based on the unit
  String get dosageString {
    final dosageValue = dosage % 1 == 0 ? dosage.toInt().toString() : dosage.toString();
    switch (unit) {
      case MedicineUnit.tablet:
        return '$dosageValue 片/粒';
      case MedicineUnit.milliliter:
        return '$dosageValue 毫升';
      case MedicineUnit.strip:
        return '$dosageValue 条/支';
    }
  }

  // Get the quantity string with unit
  String get quantityString {
    final quantityValue = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
    return '$quantityValue ${unitString}';
  }

  // Convert Medicine object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'initialQuantity': initialQuantity,
      'unit': unit.index,
      'dosage': dosage,
      'effects': effects,
      'expirationDate': expirationDate.millisecondsSinceEpoch,
      'addedDate': addedDate.millisecondsSinceEpoch,
    };
  }

  // Create Medicine object from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] is int 
        ? (json['quantity'] as int).toDouble() 
        : json['quantity'] as double;
    
    return Medicine(
      name: json['name'],
      quantity: quantity,
      initialQuantity: json['initialQuantity'] ?? quantity,
      unit: MedicineUnit.values[json['unit'] ?? 0],
      dosage: json['dosage'] ?? 1.0,
      effects: json['effects'] ?? '',
      expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
      addedDate: json['addedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['addedDate']) 
          : DateTime.now(),
    );
  }
}
