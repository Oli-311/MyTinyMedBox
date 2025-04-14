import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/add_medicine_card.dart';
import '../widgets/add_medicine_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的药盒'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () {
              Provider.of<MedicineProvider>(context, listen: false).reloadMedicines();
            },
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, medicineProvider, child) {
          // Show loading indicator
          if (medicineProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载中...'),
                ],
              ),
            );
          }

          // Show error message
          if (medicineProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('加载数据时出错'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      medicineProvider.reloadMedicines();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final medicines = medicineProvider.medicines;
          
          // Show empty state
          if (medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('没有药品记录'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddMedicineDialog(context),
                    child: const Text('添加药品'),
                  ),
                ],
              ),
            );
          }
          
          // Show medicine list
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0, bottom: 80.0),
            itemCount: medicines.length + 1, // +1 for the add card
            itemBuilder: (context, index) {
              // If it's the last item, show the add card
              if (index == medicines.length) {
                return AddMedicineCard(
                  onTap: () => _showAddMedicineDialog(context),
                );
              }
              
              // Otherwise, show a medicine card
              final medicine = medicines[index];
              return MedicineCard(
                medicine: medicine,
                index: index,
                onTap: () => _showMedicineDetails(context, medicine, index),
                onDelete: () => _confirmDelete(context, index),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMedicineForm(
        onSave: (medicine) async {
          await Provider.of<MedicineProvider>(context, listen: false)
              .addMedicine(medicine);
        },
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine, int index) {
    // For now, just show a snackbar with the medicine name
    // In a real app, you might want to navigate to a detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看 ${medicine.name} 详情'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    final medicine = medicineProvider.medicines[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${medicine.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await medicineProvider.removeMedicine(index);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${medicine.name} 已删除'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
