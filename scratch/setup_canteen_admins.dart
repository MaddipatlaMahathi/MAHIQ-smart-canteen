import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AIzaSyCiXnMxxrp7C4ixGk9aKRTWGcHR7_dnUMo';
  final signUpUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
  final signInUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');

  // Get Admin Token
  final adminLoginResponse = await http.post(
    signInUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'admin2@mahiq.com',
      'password': 'Admin123',
      'returnSecureToken': true,
    }),
  );
  final idToken = jsonDecode(adminLoginResponse.body)['idToken'];

  final canteens = [
    {'id': 'c1', 'name': 'Main Block Canteen', 'email': 'mainblock@mahiq.com'},
    {'id': 'c2', 'name': 'Engineering Café', 'email': 'engineering@mahiq.com'},
    {'id': 'c3', 'name': 'Central Food Court', 'email': 'central@mahiq.com'},
    {'id': 'c4', 'name': 'Library Café', 'email': 'library@mahiq.com'},
    {'id': 'c5', 'name': 'Science Block Canteen', 'email': 'science@mahiq.com'},
    {'id': 'c6', 'name': 'Sports Complex Canteen', 'email': 'sports@mahiq.com'},
    {'id': 'c7', 'name': 'Hostel Mess', 'email': 'hostel@mahiq.com'},
  ];

  for (var canteen in canteens) {
    try {
      var authResponse = await http.post(
        signUpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': canteen['email'],
          'password': 'Admin123',
          'returnSecureToken': true,
        }),
      );

      var responseData = jsonDecode(authResponse.body);
      String? uid;
      
      if (authResponse.statusCode != 200) {
        if (responseData['error']['message'] == 'EMAIL_EXISTS') {
           final loginRes = await http.post(
             signInUrl,
             headers: {'Content-Type': 'application/json'},
             body: jsonEncode({
               'email': canteen['email'],
               'password': 'Admin123',
               'returnSecureToken': true,
             }),
           );
           uid = jsonDecode(loginRes.body)['localId'];
           print('Account already exists for ${canteen['email']}, UID: $uid');
        } else {
           print('Failed to create ${canteen['email']}: ${responseData['error']['message']}');
           continue;
        }
      } else {
         uid = responseData['localId'];
         print('Successfully created auth account for ${canteen['email']} with UID: $uid');
      }

      // 2. Add to Firestore 'admins' collection
      final firestoreUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/smart-canteen-24611/databases/(default)/documents/admins/$uid');
      
      final firestoreResponse = await http.patch(
        firestoreUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'fields': {
            'name': {'stringValue': canteen['name']},
            'canteenId': {'stringValue': canteen['id']},
          }
        }),
      );

      if (firestoreResponse.statusCode == 200) {
        print('Successfully added ${canteen['email']} to admins collection.');
      } else {
        print('Failed to add ${canteen['email']} to Firestore: ${firestoreResponse.body}');
      }
    } catch (e) {
      print('Error processing ${canteen['email']}: $e');
    }
  }
}
