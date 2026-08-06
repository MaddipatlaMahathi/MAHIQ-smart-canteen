import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  final url = Uri.parse('https://firestore.googleapis.com/v1/projects/smart-canteen-24611/databases/(default)/documents/orders');
  final res = await http.get(url);
  print(res.body);
}
