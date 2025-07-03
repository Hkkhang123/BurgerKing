import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Đăng nhập Google qua Firebase và gửi idToken về backend
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('googleUser: ' + googleUser.toString());
      if (googleUser == null) {
        return {'success': false, 'message': 'Đăng nhập Google bị hủy'};
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('googleAuth: ' + googleAuth.toString());
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();
      print('idToken (from Firebase): ' + (idToken ?? 'null'));
      if (idToken == null) {
        return {'success': false, 'message': 'Không lấy được idToken từ Firebase'};
      }
      // Gửi idToken lên backend
      final response = await http.post(
        Uri.parse('https://burgerking-j92p.onrender.com/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Lỗi backend: ${response.body}'};
      }
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }
} 