import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/api_service.dart';
import '../utils/debug_connection.dart';
import '../utils/success_dialog.dart';
import 'dart:convert';

class AuthController extends GetxController{
  final _storage = GetStorage();

  final RxBool _isFisrtTime = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  bool get isFirstTime => _isFisrtTime.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadInitState();
  }

  void _loadInitState(){
    _isFisrtTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
    // KHÔNG tự động logout nếu user/token null, chỉ log ra để debug
    final user = _storage.read('user');
    final token = _storage.read('token');
    print('[AuthController] _loadInitState: user=' + user.toString() + ', token=' + token.toString());
  }

  void setFirstTimeDone(){
    _isFisrtTime.value = false;
    _storage.write('isFirstTime', false);
  }

  Future<bool> loginWithApi(String email, String password) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await ApiService.login(email, password);
      
      if (result['success']) {
        final data = result['data'];
        
        // Store user data and token
        _storage.write('user', data['user']);
        _storage.write('token', data['token']);
        _storage.write('isLoggedIn', true);
        print('[AuthController] Đăng nhập thành công, userId: ' + (data['user']?['_id']?.toString() ?? 'null'));
        
        _isLoggedIn.value = true;
        _isLoading.value = false;
        
        // Hiển thị thông báo thành công
        showSuccessMessage('Đăng nhập thành công! Chào mừng bạn quay trở lại.');
        
        return true;
      } else {
        final data = result['data'];
        final statusCode = result['statusCode'];
        
        // Xử lý các trường hợp lỗi cụ thể
        if (statusCode == 400) {
          _errorMessage.value = 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
        } else if (statusCode == 404) {
          _errorMessage.value = 'Không tìm thấy tài khoản với email này.';
        } else if (statusCode == 500) {
          _errorMessage.value = 'Lỗi server. Vui lòng thử lại sau.';
        } else if (statusCode == 0) {
          _errorMessage.value = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
        } else if (data != null && data['message'] != null) {
          _errorMessage.value = data['message'];
        } else if (result['error'] != null) {
          _errorMessage.value = result['error'];
        } else {
          _errorMessage.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
        }
        
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi kết nối: $e';
      _isLoading.value = false;
      return false;
    }
  }

  Future<bool> registerWithApi(String name, String email, String password) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await ApiService.register(name, email, password);
      
      if (result['success']) {
        final data = result['data'];
        
        // Store user data and token
        _storage.write('user', data['user']);
        _storage.write('token', data['token']);
        _storage.write('isLoggedIn', true);
        
        _isLoggedIn.value = true;
        _isLoading.value = false;
        
        // Hiển thị thông báo thành công
        showSuccessMessage('Đăng ký thành công! Chào mừng bạn đến với ứng dụng.');
        
        return true;
      } else {
        final data = result['data'];
        final statusCode = result['statusCode'];
        
        // Xử lý các trường hợp lỗi cụ thể cho đăng ký
        if (statusCode == 400) {
          _errorMessage.value = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
        } else if (statusCode == 409) {
          _errorMessage.value = 'Email đã tồn tại. Vui lòng sử dụng email khác.';
        } else if (statusCode == 500) {
          _errorMessage.value = 'Lỗi server. Vui lòng thử lại sau.';
        } else if (statusCode == 0) {
          _errorMessage.value = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
        } else if (data != null && data['message'] != null) {
          _errorMessage.value = data['message'];
        } else if (result['error'] != null) {
          _errorMessage.value = result['error'];
        } else {
          _errorMessage.value = 'Đăng ký thất bại. Vui lòng thử lại.';
        }
        
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Lỗi kết nối: $e';
      _isLoading.value = false;
      return false;
    }
  }

  void login(){
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }
  
  void logout(){
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    _storage.remove('user');
    _storage.remove('token');
  }

  // Get stored user data
  Map<String, dynamic>? getCurrentUser() {
    final dynamic userRaw = _storage.read('user');
    print('[AuthController] user raw from storage: ' + userRaw.toString());
    if (userRaw == null) {
      // Nếu đã có token mà chưa có user, tự động fetch profile
      final token = getToken();
      if (token != null) {
        fetchAndUpdateProfile(); // Gọi bất đồng bộ, lần sau sẽ có user
      }
      return null;
    }
    if (userRaw is String) {
      try {
        return jsonDecode(userRaw) as Map<String, dynamic>;
      } catch (e) {
        print('[AuthController] Lỗi decode user: $e');
        return null;
      }
    }
    if (userRaw is Map<String, dynamic>) return userRaw;
    if (userRaw is Map) return Map<String, dynamic>.from(userRaw);
    return null;
  }

  // Get stored token
  String? getToken() {
    return _storage.read('token');
  }

  // Test connection to server
  Future<bool> testConnection() async {
    try {
      final result = await ApiService.testConnection();
      return result['success'];
    } catch (e) {
      return false;
    }
  }

  // Debug connection - test all possible URLs
  Future<void> debugConnection() async {
    print('🔍 Testing all possible server connections...');
    final results = await DebugConnection.testAllConnections();
    DebugConnection.printResults(results);
    
    // Find working connection
    String? workingUrl;
    results.forEach((url, result) {
      if (result['success']) {
        workingUrl = url;
      }
    });
    
    if (workingUrl != null) {
      print('✅ Found working connection: $workingUrl');
      _errorMessage.value = 'Tìm thấy kết nối: $workingUrl';
    } else {
      print('❌ No working connections found');
      _errorMessage.value = 'Không tìm thấy kết nối nào. Vui lòng kiểm tra server.';
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Set error message
  void setErrorMessage(String message) {
    _errorMessage.value = message;
  }

  // Show success message
  void showSuccessMessage(String message) {
    SuccessDialog.show(
      title: 'Thành công!',
      message: message,
      duration: const Duration(seconds: 2),
    );
  }

  // Lấy lại profile user từ server và cập nhật local storage
  Future<List<String>> fetchAndUpdateProfile() async {
    final token = getToken();
    if (token == null) return [];
    final result = await ApiService.getProfile(token);
    print('[AuthController] fetchAndUpdateProfile result: ' + result.toString());
    if (result['success']) {
      final user = result['data'];
      print('[AuthController] fetchAndUpdateProfile user: ' + user.toString());
      _storage.write('user', jsonEncode(user));
      // Chống null khi truy cập favorites
      final favorites = (user?['favorites'] as List<dynamic>?) ?? [];
      return favorites.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Upload avatar
  Future<bool> uploadAvatar(List<int> imageBytes, String fileName) async {
    final token = getToken();
    if (token == null) return false;
    
    final result = await ApiService.uploadAvatar(token, imageBytes, fileName);
    if (result['success']) {
      // Cập nhật user data với avatar mới
      final currentUser = getCurrentUser();
      if (currentUser != null) {
        currentUser['image'] = result['data']['imageUrl'];
        _storage.write('user', currentUser);
      }
      return true;
    }
    return false;
  }

  // Refresh user data from server
  Future<bool> refreshUserData() async {
    final token = getToken();
    if (token == null) return false;
    
    final result = await ApiService.getProfile(token);
    if (result['success']) {
      final user = result['data'];
      _storage.write('user', user);
      return true;
    }
    return false;
  }

  // Clear avatar cache and force refresh
  Future<void> clearAvatarCache() async {
    // This would clear any cached avatar images
    // For now, just refresh user data
    await refreshUserData();
  }

  // Set default avatar for user
  Future<void> setDefaultAvatar() async {
    final currentUser = getCurrentUser();
    if (currentUser != null && (currentUser['image'] == null || currentUser['image'].isEmpty)) {
      // Set a default avatar URL or use local asset
      currentUser['image'] = null; // Let UI handle default avatar
      _storage.write('user', currentUser);
    }
  }
}