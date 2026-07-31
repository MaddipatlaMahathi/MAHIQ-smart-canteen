import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../../services/firestore_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Meals', 'Snacks', 'Juice'];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentCanteenId = cartProvider.selectedCanteen?.canteenId ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.itemCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat ? AppColors.primaryBlue : Colors.black,
                      fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Menu Grid
          Expanded(
            child: StreamBuilder<List<MenuItemModel>>(
              stream: _firestoreService.getMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading menu'));
                }

                final allItems = snapshot.data ?? [];
                // Filter by canteen and availability
                var displayedItems = allItems.where((i) {
                  bool matchesCanteen = (i.canteenId == currentCanteenId || i.canteenId == 'all');
                  bool matchesCategory = _selectedCategory == 'All' || i.category.toLowerCase() == _selectedCategory.toLowerCase();
                  return matchesCanteen && matchesCategory && i.isAvailable;
                }).toList();
                
                if (displayedItems.isEmpty) {
                  return const Center(
                    child: Text('No menu items available for this canteen yet.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final item = displayedItems[index];
                    return AnimatedCard(
                      onTap: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.itemName} added to cart!'), duration: const Duration(seconds: 1)),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                image: item.imageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(item.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.imageUrl.isEmpty ? const Icon(Icons.fastfood, color: Colors.grey) : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${item.price.toStringAsFixed(0)}',
                                      style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
