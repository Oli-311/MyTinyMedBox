enum MedicineUnit {
  tablet, // 片/粒
  milliliter, // 毫升
  strip, // 条/支
}

enum MedicineStatus {
  normal,
  empty,
}

class Medicine {
  final String name;
  double quantity;
  final MedicineUnit unit;
  final double dosage;
  final String effects;
  final DateTime expirationDate;

  Medicine({
    required this.name,
    required this.quantity,
    this.unit = MedicineUnit.tablet,
    this.dosage = 1.0,
    this.effects = '',
    required this.expirationDate,
  });

  // Check if medicine is empty
  bool get isEmpty => quantity <= 0;

  // Get medicine status
  MedicineStatus get status => isEmpty ? MedicineStatus.empty : MedicineStatus.normal;

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
      'unit': unit.index,
      'dosage': dosage,
      'effects': effects,
      'expirationDate': expirationDate.millisecondsSinceEpoch,
    };
  }

  // Create Medicine object from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      quantity: json['quantity'] is int ? (json['quantity'] as int).toDouble() : json['quantity'],
      unit: MedicineUnit.values[json['unit'] ?? 0],
      dosage: json['dosage'] ?? 1.0,
      effects: json['effects'] ?? '',
      expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
    );
  }
}
