import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

class AdminCanteenManagementScreen extends StatefulWidget {
  const AdminCanteenManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminCanteenManagementScreen> createState() => _AdminCanteenManagementScreenState();
}

class _AdminCanteenManagementScreenState extends State<AdminCanteenManagementScreen> {
  final List<String> _canteens = [
    'Main Block Canteen',
    'Engineering Café',
    'Central Food Court',
    'Library Café',
    'Science Block Canteen',
    'Sports Complex Canteen',
    'Hostel Mess',
  ];

  void _showAddEditDialog([int? index]) {
    final controller = TextEditingController(text: index != null ? _canteens[index] : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Canteen' : 'Edit Canteen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Canteen Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _canteens.add(controller.text);
                    } else {
                      _canteens[index] = controller.text;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCanteen(int index) {
    setState(() {
      _canteens.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _canteens.length,
        itemBuilder: (context, index) {
          return AnimatedCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.storefront, color: Colors.white),
              ),
              title: Text(_canteens[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                    onPressed: () => _showAddEditDialog(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.errorRed),
                    onPressed: () => _deleteCanteen(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
