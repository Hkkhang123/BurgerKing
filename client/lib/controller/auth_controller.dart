import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/api_service.dart';
import '../utils/debug_connection.dart';
import '../utils/success_dialog.dart';

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
    
    // Load stored user data and token if user is logged in
    if (_isLoggedIn.value) {
      final user = _storage.read('user');
      final token = _storage.read('token');
      if (user == null || token == null) {
        // If user data or token is missing, logout
        logout();
      }
    }
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
    return _storage.read('user');
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
    if (result['success']) {
      final user = result['data'];
      _storage.write('user', user);
      return (user['favorites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    }
    return [];
  }
}