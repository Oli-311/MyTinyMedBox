import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;
  final int index;

  const MedicineDetailScreen({
    super.key,
    required this.medicine,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medication),
            tooltip: '使用药品',
            onPressed: () => _useMedicine(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 16.0),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            _buildInfoRow('数量:', medicine.quantityString),
            _buildInfoRow('用量:', medicine.dosageString),
            if (medicine.effects.isNotEmpty)
              _buildInfoRow('功效:', medicine.effects),
            _buildInfoRow('有效期:', medicine.formattedExpirationDate),
            const SizedBox(height: 16.0),
            _buildStatusIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.0,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Widget statusWidget;
    
    if (medicine.isEmpty) {
      statusWidget = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '药品已用完，请及时购买',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (medicine.isAlmostEmpty) {
      statusWidget = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '药品即将用完，请及时购买',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (medicine.isAboutToExpire) {
      statusWidget = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '药品即将过期，请注意使用',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final days = medicine.daysUntilExpiration;
      Color statusColor = Colors.green;
      
      statusWidget = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: statusColor),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: statusColor),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '药品状态良好，${medicine.expirationStatus}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return statusWidget;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.medication),
          label: const Text('使用药品'),
          onPressed: medicine.isEmpty ? null : () => _useMedicine(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('删除药品'),
          onPressed: () => _confirmDelete(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
      ],
    );
  }

  void _useMedicine(BuildContext context) async {
    if (medicine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} 已用完，请及时购买'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await Provider.of<MedicineProvider>(context, listen: false).useMedicine(index);
    
    if (medicine.isEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} 已用完，请及时购买'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已使用 ${medicine.name} ${medicine.dosageString}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
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
              final provider = Provider.of<MedicineProvider>(context, listen: false);
              await provider.removeMedicine(index);
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home screen
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
