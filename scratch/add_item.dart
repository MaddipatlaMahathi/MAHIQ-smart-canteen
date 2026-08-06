import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AIzaSyCiXnMxxrp7C4ixGk9aKRTWGcHR7_dnUMo';
  final authUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
  
  final authResponse = await http.post(
    authUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'admin2@mahiq.com',
      'password': 'Admin123',
      'returnSecureToken': true,
    }),
  );
  
  final idToken = jsonDecode(authResponse.body)['idToken'];
  if (idToken == null) {
    print('Failed to authenticate');
    return;
  }
  print('Successfully authenticated.');

  final List<Map<String, dynamic>> menuItems = [
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
    {'name': 'Cold Drink', 'price': 40, 'category': 'Drinks', 'rating': 4.1, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Coca-Cola-Glass.jpg/500px-Coca-Cola-Glass.jpg'},
    {'name': 'Coffee', 'price': 30, 'category': 'Drinks', 'rating': 4.7, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/500px-A_small_cup_of_coffee.JPG'},
    {'name': 'Tea', 'price': 20, 'category': 'Drinks', 'rating': 4.4, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Cup_of_tea.jpg/500px-Cup_of_tea.jpg'},
    {'name': 'Milkshake', 'price': 80, 'category': 'Drinks', 'rating': 4.8, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Chocolate_milkshake.jpg/500px-Chocolate_milkshake.jpg'},
    {'name': 'Fresh Juice', 'price': 50, 'category': 'Drinks', 'rating': 4.4, 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Orangejuice.jpg/500px-Orangejuice.jpg'},
  ];

  print('Starting to seed menu items...');

  int count = 0;
  for (var item in menuItems) {
    final docId = 'item_${DateTime.now().millisecondsSinceEpoch}_$count';
    final firestoreUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/smart-canteen-24611/databases/(default)/documents/menu_items/$docId');
    
    final fsResponse = await http.patch(
      firestoreUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'fields': {
          'canteenId': {'stringValue': 'all'}, // Global scope!
          'itemName': {'stringValue': item['name']},
          'price': {'doubleValue': item['price'].toDouble()},
          'description': {'stringValue': item['category']}, // Use category as description for now
          'imageUrl': {'stringValue': item['image']},
          'isAvailable': {'booleanValue': true}
        }
      }),
    );
    
    if (fsResponse.statusCode == 200) {
      count++;
    } else {
      print('Failed to add ${item['name']}: ${fsResponse.body}');
    }
  }

  print('Successfully restored $count menu items to all canteens!');
}
