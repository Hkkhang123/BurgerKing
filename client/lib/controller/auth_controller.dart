import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
class AuthController extends GetxController{
  final _storage = GetStorage();

  final RxBool _isFisrtTime = true.obs;
  final RxBool _isLoggedIn = false.obs;

  bool get isFirstTime => _isFisrtTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

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
  void login(){
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }
  void logout(){
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
  }
}