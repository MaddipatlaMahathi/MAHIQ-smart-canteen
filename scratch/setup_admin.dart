import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AIzaSyCiXnMxxrp7C4ixGk9aKRTWGcHR7_dnUMo';
  final firestoreUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/smart-canteen-24611/databases/(default)/documents/admins/qJb6tbXOqLOv3Cun8SaVzmapkuB2');
  
  final fsResponse = await http.patch(
    firestoreUrl,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2ZWUwMzFlODZhM2YwZmNkOWI2ZDcwMDJiMDJiMDg2ZDJmNTVkZTQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vc21hcnQtY2FudGVlbi0yNDYxMSIsImF1ZCI6InNtYXJ0LWNhbnRlZW4tMjQ2MTEiLCJhdXRoX3RpbWUiOjE3ODUzODQ0ODUsInVzZXJfaWQiOiJxSmI2dGJYT3FMT3YzQ3VuOFNhVnptYXBrdUIyIiwic3ViIjoicUpiNnRiWE9xTE92M0N1bjhTYVZ6bWFwa3VCMiIsImlhdCI6MTc4NTM4NDQ4NSwiZXhwIjoxNzg1Mzg4MDg1LCJlbWFpbCI6ImFkbWluMkBtYWhpcS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiYWRtaW4yQG1haGlxLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.CcxdQwXNspIbVDS5ve5RaIelSjejYqNsD2ituJzwWtObiyPu7gq_glG2WZ1mcotXJ-VCdyrXPvU3WDgmCG90ohaYI6RPWBajQJOYbrUtm-nEiE7PoUvHipfq9bf0oS6XLYq4-qBlfksxm1KFJYoa5igrqWVl0rFDJq5vIMLmekYVAVgqYligLH3BmjXrLF5d5vG4so57g-H_JPySvJ_VmgT_QUY_65C73NEzOiVj3B0YUMy3lG_3H5yrMREDsydMZR8VhNxaQZwNpghJB4dwziEH5nhgCdOsv8680yEY5FpC1J86lj5-WHSBno-Dzv4A8mWBbPL-1uD6ocKBOkYsIA',
    },
    body: jsonEncode({
      'fields': {
        'name': {'stringValue': 'Admin'},
        'email': {'stringValue': 'admin2@mahiq.com'}
      }
    }),
  );
  print(fsResponse.body);

}
