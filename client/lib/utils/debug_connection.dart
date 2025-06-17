import 'package:http/http.dart' as http;

class DebugConnection {
  static const List<String> testUrls = [
    'http://10.0.2.2:5000/',
    'http://10.0.2.2:3000/',
    'http://localhost:5000/',
    'http://localhost:3000/',
    'http://127.0.0.1:5000/',
    'http://127.0.0.1:3000/',
  ];

  static Future<Map<String, dynamic>> testAllConnections() async {
    Map<String, dynamic> results = {};
    
    for (String url in testUrls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        
        results[url] = {
          'success': true,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      } catch (e) {
        results[url] = {
          'success': false,
          'error': e.toString(),
        };
      }
    }
    
    return results;
  }

  static void printResults(Map<String, dynamic> results) {
    print('=== DEBUG CONNECTION RESULTS ===');
    results.forEach((url, result) {
      print('URL: $url');
      if (result['success']) {
        print('✅ SUCCESS - Status: ${result['statusCode']}');
        print('Response: ${result['body']}');
      } else {
        print('❌ FAILED - Error: ${result['error']}');
      }
      print('---');
    });
  }
} 