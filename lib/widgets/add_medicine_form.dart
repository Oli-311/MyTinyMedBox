import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class AddMedicineForm extends StatefulWidget {
  final Function(Medicine) onSave;

  const AddMedicineForm({
    super.key,
    required this.onSave,
  });

  @override
  State<AddMedicineForm> createState() => _AddMedicineFormState();
}

class _AddMedicineFormState extends State<AddMedicineForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dosageController = TextEditingController();
  final _effectsController = TextEditingController();
  final _expirationDateController = TextEditingController();
  
  DateTime? _selectedDate;
  MedicineUnit _selectedUnit = MedicineUnit.tablet;

  @override
  void initState() {
    super.initState();
    // Set default values
    _selectedDate = DateTime.now().add(const Duration(days: 365));
    _expirationDateController.text = _formatDate(_selectedDate!);
    _dosageController.text = _getDefaultDosage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _dosageController.dispose();
    _effectsController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _getDefaultDosage() {
    switch (_selectedUnit) {
      case MedicineUnit.tablet:
      case MedicineUnit.strip:
        return '1';
      case MedicineUnit.milliliter:
        return '10';
    }
  }

  String _getUnitLabel() {
    switch (_selectedUnit) {
      case MedicineUnit.tablet:
        return '片/粒';
      case MedicineUnit.milliliter:
        return '毫升';
      case MedicineUnit.strip:
        return '条/支';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: '选择药品有效期',
      cancelText: '取消',
      confirmText: '确定',
      locale: const Locale('zh'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _expirationDateController.text = _formatDate(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final medicine = Medicine(
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        dosage: double.parse(_dosageController.text),
        effects: _effectsController.text,
        expirationDate: _selectedDate!,
      );
      
      // Record interaction before saving
      Provider.of<MedicineProvider>(context, listen: false).recordInteraction();
      
      widget.onSave(medicine);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新药品'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '药品名称',
                  hintText: '请输入药品名称',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入药品名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Unit selection
              DropdownButtonFormField<MedicineUnit>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: '单位',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: MedicineUnit.tablet,
                    child: const Text('片/粒'),
                  ),
                  DropdownMenuItem(
                    value: MedicineUnit.milliliter,
                    child: const Text('毫升'),
                  ),
                  DropdownMenuItem(
                    value: MedicineUnit.strip,
                    child: const Text('条/支'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUnit = value;
                      _dosageController.text = _getDefaultDosage();
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              
              // Quantity input
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: '数量',
                  hintText: '请输入药品数量',
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: _getUnitLabel(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入药品数量';
                  }
                  try {
                    final quantity = double.parse(value);
                    if (quantity <= 0) {
                      return '请输入大于0的数量';
                    }
                  } catch (e) {
                    return '请输入有效的数字';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Dosage input
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: '每次用量',
                  hintText: '请输入每次用量',
                  prefixIcon: const Icon(Icons.medical_services),
                  suffixText: _getUnitLabel(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用量';
                  }
                  try {
                    final dosage = double.parse(value);
                    if (dosage <= 0) {
                      return '请输入大于0的用量';
                    }
                  } catch (e) {
                    return '请输入有效的数字';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              TextFormField(
                controller: _effectsController,
                decoration: const InputDecoration(
                  labelText: '功效 (选填)',
                  hintText: '请输入药品功效（可选）',
                  prefixIcon: Icon(Icons.healing),
                ),
                maxLines: 2,
                // No validation required for this field
                validator: (value) => null,
              ),
              const SizedBox(height: 16.0),
              
              TextFormField(
                controller: _expirationDateController,
                decoration: const InputDecoration(
                  labelText: '有效期',
                  hintText: '请选择有效期',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择有效期';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
