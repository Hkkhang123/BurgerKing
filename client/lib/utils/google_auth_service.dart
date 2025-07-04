import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

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

  static Future<Map<String, dynamic>> signInWithGoogleAndSave() async {
    final result = await signInWithGoogle();
    print('[GoogleAuthService] Kết quả từ backend: ' + result.toString());
    if (result['success']) {
      final data = result['data'];
      final user = data['user'];
      final token = data['token'];
      final storage = GetStorage();
      print('[GoogleAuthService] Lưu token vào storage: ' + token.toString());
      await storage.write('token', token);
      await storage.write('isLoggedIn', true);
      print('[GoogleAuthService] isLoggedIn sau lưu: ' + storage.read('isLoggedIn').toString());
      print('[GoogleAuthService] Các key trong storage sau lưu: ' + storage.getKeys().toString());
      // Cập nhật trạng thái đăng nhập cho AuthController
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());
      authController.login();
      // Lấy lại profile mới nhất từ backend (nếu muốn)
      await authController.fetchAndUpdateProfile();
    }
    return result;
  }
} 