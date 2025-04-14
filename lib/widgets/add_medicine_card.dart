import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

class AddMedicineCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddMedicineCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    final bool isCollapsed = medicineProvider.isCollapsed;
    
    if (isCollapsed) {
      return const SizedBox.shrink(); // Don't show add card when collapsed
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          medicineProvider.recordInteraction();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12.0),
              Text(
                '添加新药品',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
