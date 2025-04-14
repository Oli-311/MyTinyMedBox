import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.index,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = medicine.isEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      color: isEmpty ? Colors.red.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isEmpty 
            ? BorderSide(color: Colors.red.shade200, width: 1.0)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onDoubleTap: () => _useMedicine(context),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isEmpty ? Colors.red : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (!isEmpty)
                        Tooltip(
                          message: '双击使用药品',
                          child: IconButton(
                            icon: const Icon(Icons.medication, color: Colors.blue),
                            onPressed: () => _useMedicine(context),
                            tooltip: '使用药品',
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: '删除',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              _buildInfoRow('数量:', medicine.quantityString, isEmpty),
              _buildInfoRow('用量:', medicine.dosageString, isEmpty),
              if (medicine.effects.isNotEmpty)
                _buildInfoRow('功效:', medicine.effects, isEmpty),
              _buildInfoRow('有效期:', medicine.formattedExpirationDate, isEmpty),
              if (isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '药品已用完，请及时购买',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildExpirationStatus(),
            ],
          ),
        ),
      ),
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

  Widget _buildInfoRow(String label, String value, [bool isEmpty = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.0,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isEmpty && label == '数量:' ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationStatus() {
    final days = medicine.daysUntilExpiration;
    Color statusColor;
    
    if (days < 0) {
      statusColor = Colors.red;
    } else if (days < 30) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        medicine.expirationStatus,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
