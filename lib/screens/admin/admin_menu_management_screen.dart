import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../providers/admin_order_provider.dart';
import '../../models/menu_item_model.dart';

class AdminMenuManagementScreen extends StatefulWidget {
  const AdminMenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminMenuManagementScreen> createState() => _AdminMenuManagementScreenState();
}

class _AdminMenuManagementScreenState extends State<AdminMenuManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _toggleAvailability(MenuItemModel item) async {
    await _firestoreService.updateMenuItem(item.itemId, {'isAvailable': !item.isAvailable});
  }

  void _deleteItem(String itemId) async {
    await _firestoreService.deleteMenuItem(itemId);
  }

  void _restoreDefaults(String canteenId) async {
    final List<Map<String, dynamic>> defaultItems = [
      {'name': '1 Rupee Test Item', 'price': 1, 'category': 'Snacks', 'rating': 5.0, 'image': 'https://via.placeholder.com/150/EEEEEE/909090?text=1+Rupee'},
      {'name': 'Chicken Biryani', 'price': 150, 'category': 'Meals', 'rating': 4.8, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Hyderabadi_Dum_Biryani.jpg/500px-Hyderabadi_Dum_Biryani.jpg'},
      {'name': 'Veg Biryani', 'price': 120, 'category': 'Meals', 'rating': 4.5, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Veg_Biryani.jpg/500px-Veg_Biryani.jpg'},
      {'name': 'Paneer Butter Masala', 'price': 140, 'category': 'Meals', 'rating': 4.6, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Shahi_panner.jpg/500px-Shahi_panner.jpg'},
      {'name': 'Mutton Curry', 'price': 200, 'category': 'Meals', 'rating': 4.7, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Mutton_Curry_-_Kolkata_2012-10-18_0733.JPG/500px-Mutton_Curry_-_Kolkata_2012-10-18_0733.JPG'},
      {'name': 'Burger', 'price': 80, 'category': 'Snacks', 'rating': 4.2, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/RedDot_Burger.jpg/500px-RedDot_Burger.jpg'},
      {'name': 'Pizza', 'price': 120, 'category': 'Snacks', 'rating': 4.6, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg/500px-Eq_it-na_pizza-margherita_sep2005_sml.jpg'},
      {'name': 'Sandwich', 'price': 60, 'category': 'Snacks', 'rating': 4.0, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Turkey_sandwich.jpg/500px-Turkey_sandwich.jpg'},
      {'name': 'Pasta', 'price': 100, 'category': 'Snacks', 'rating': 4.3, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Recipe_for_making_Pasta.jpg/500px-Recipe_for_making_Pasta.jpg'},
      {'name': 'French Fries', 'price': 60, 'category': 'Snacks', 'rating': 4.3, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/French_Fries.jpg/500px-French_Fries.jpg'},
      {'name': 'Samosa', 'price': 15, 'category': 'Snacks', 'rating': 4.5, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Samosachutney.jpg/500px-Samosachutney.jpg'},
      {'name': 'Garlic Bread', 'price': 90, 'category': 'Snacks', 'rating': 4.2, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Garlic_Bread.jpg/500px-Garlic_Bread.jpg'},
      {'name': 'Cold Drink', 'price': 40, 'category': 'Juice', 'rating': 4.1, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Coca-Cola-Glass.jpg/500px-Coca-Cola-Glass.jpg'},
      {'name': 'Coffee', 'price': 30, 'category': 'Juice', 'rating': 4.7, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/500px-A_small_cup_of_coffee.JPG'},
      {'name': 'Tea', 'price': 20, 'category': 'Juice', 'rating': 4.4, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Cup_of_tea.jpg/500px-Cup_of_tea.jpg'},
      {'name': 'Milkshake', 'price': 80, 'category': 'Juice', 'rating': 4.8, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Chocolate_milkshake.jpg/500px-Chocolate_milkshake.jpg'},
      {'name': 'Fresh Juice', 'price': 50, 'category': 'Juice', 'rating': 4.4, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Orangejuice.jpg/500px-Orangejuice.jpg'},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // First, delete ALL existing menu items to prevent duplicates
      final existingItems = await FirebaseFirestore.instance
          .collection('menu_items')
          .get();
          
      for (var doc in existingItems.docs) {
        await doc.reference.delete();
      }

      // Then, add the default items
      for (var item in defaultItems) {
        final newItem = MenuItemModel(
        itemId: FirebaseFirestore.instance.collection('menu_items').doc().id,
        canteenId: canteenId,
        itemName: item['name'],
        price: (item['price'] as int).toDouble(),
        category: item['category'],
        imageUrl: item['image'],
        isAvailable: true,
      );
      await _firestoreService.addMenuItem(newItem);
    }
    
    if (mounted) {
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default items restored successfully!')),
      );
    }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring menu: $e')),
        );
      }
    }
  }

  void _showAddEditDialog(String canteenId, [MenuItemModel? item]) {
    final nameController = TextEditingController(text: item?.itemName);
    final priceController = TextEditingController(text: item?.price.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add New Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                controller: nameController,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number,
                controller: priceController,
              ),
              // Optional: Add category dropdown here, but for simplicity, default to 'Meals'
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                
                if (name.isNotEmpty && price > 0) {
                  if (item == null) {
                    final newItem = MenuItemModel(
                      itemId: FirebaseFirestore.instance.collection('menu_items').doc().id,
                      canteenId: canteenId,
                      itemName: name,
                      category: item?.category ?? 'Meals', // Default if new
                      price: price,
                      imageUrl: 'https://via.placeholder.com/150', // placeholder
                      isAvailable: true,
                    );
                    await _firestoreService.addMenuItem(newItem);
                  } else {
                    await _firestoreService.updateMenuItem(item.itemId, {
                      'itemName': name,
                      'price': price,
                    });
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item saved successfully')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canteenId = Provider.of<AdminOrderProvider>(context, listen: false).canteenId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            tooltip: 'Restore Default Menu',
            icon: const Icon(Icons.restore),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restore Default Menu?'),
                  content: const Text('This will add all the original demo items back to your canteen menu. Proceed?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _restoreDefaults(canteenId);
                      },
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Add New Item',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(canteenId),
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _firestoreService.getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading menu'));
          }

          final allItems = snapshot.data ?? [];
          final displayedItems = canteenId == 'all' 
              ? allItems 
              : allItems.where((i) => i.canteenId == canteenId || i.canteenId == 'all').toList();

          if (displayedItems.isEmpty) {
            return const Center(child: Text('No menu items found. Add some!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayedItems.length,
            itemBuilder: (context, index) {
              final item = displayedItems[index];
              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: item.imageUrl.isNotEmpty 
                          ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover) 
                          : null,
                    ),
                    child: item.imageUrl.isEmpty ? const Icon(Icons.fastfood, color: Colors.grey) : null,
                  ),
                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('₹${item.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isAvailable,
                        onChanged: (val) => _toggleAvailability(item),
                        activeThumbColor: AppColors.primaryBlue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                        onPressed: () => _showAddEditDialog(canteenId, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.errorRed),
                        onPressed: () => _deleteItem(item.itemId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
