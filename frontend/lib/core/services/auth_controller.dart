import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:client/core/utils/debug_connection.dart';
import 'package:client/core/utils/success_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/core/services/notification_controller.dart';

class AuthController extends GetxController{
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';
  
  final _storage = GetStorage();

  final RxBool _isFisrtTime = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

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
  }

  void setFirstTimeDone(){
    _isFisrtTime.value = false;
    _storage.write('isFirstTime', false);
  }

  Future<bool> loginWithApi(String email, String password) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _login(email, password);
      
      if (result['success']) {
        final data = result['data'];
        
        // Store user data and token
        _storage.write('user', data['user']);
        _storage.write('token', data['token']);
        _storage.write('isLoggedIn', true);
        
        _isLoggedIn.value = true;
        _isLoading.value = false;
        
        // Cập nhật token và fetch notifications
        final notificationController = Get.find<NotificationController>();
        notificationController.setToken(data['token']);
        await notificationController.fetchNotifications();

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

  // Login API method
  Future<Map<String, dynamic>> _login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/dangnhap'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Xử lý các lỗi HTTP cụ thể
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {'message': 'Lỗi không xác định'};
        }

        return {
          'success': false,
          'data': errorData,
          'statusCode': response.statusCode,
          'error': _getErrorMessage(response.statusCode, errorData['message']),
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';
      
      // Kiểm tra loại lỗi cụ thể
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': 0,
      };
    }
  }

  // Helper method để tạo thông báo lỗi
  String _getErrorMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 401:
        return 'Email hoặc mật khẩu không đúng.';
      case 404:
        return 'Không tìm thấy tài khoản với email này.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  Future<bool> registerWithApi(String name, String email, String password) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _register(name, email, password);
      
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

  // Register API method
  Future<Map<String, dynamic>> _register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/dangky'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Xử lý các lỗi HTTP cụ thể
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {'message': 'Lỗi không xác định'};
        }

        return {
          'success': false,
          'data': errorData,
          'statusCode': response.statusCode,
          'error': _getRegisterErrorMessage(response.statusCode, errorData['message']),
        };
      }
    } on http.ClientException  {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';
      
      // Kiểm tra loại lỗi cụ thể
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': 0,
      };
    }
  }

  // Helper method để tạo thông báo lỗi cho đăng ký
  String _getRegisterErrorMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 409:
        return 'Email đã tồn tại. Vui lòng sử dụng email khác.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi không xác định.';
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
      final result = await _testConnection();
      return result['success'];
    } catch (e) {
      return false;
    }
  }

  // Test connection method
  Future<Map<String, dynamic>> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      return {
        'success': true,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server',
        'statusCode': 0,
      };
    }
  }

  // Get profile method
  Future<Map<String, dynamic>> _getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: getAuthHeaders(token),
      );

      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Upload avatar method
  Future<Map<String, dynamic>> _uploadAvatar(String token, List<int> imageBytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/avatar'),
      );
      
      request.headers.addAll(getAuthHeaders(token));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      return {
        'success': response.statusCode == 200,
        'data': jsonData,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
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
    final result = await _getProfile(token);
    if (result['success']) {
      // Lấy user data từ result['data']['data'] vì API trả về {success: true, data: {success: true, data: user}}
      final user = result['data']['data'] ?? result['data'];
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
    
    final result = await _uploadAvatar(token, imageBytes, fileName);
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
    
    final result = await _getProfile(token);
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