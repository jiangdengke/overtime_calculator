import 'local_storage_service.dart';

/// 简单的本地登录状态管理。
///
/// 仅用于控制界面中“云同步”相关入口，无真实鉴权。
/// 若接入后端，请用真实鉴权（如 Firebase Auth）替换。
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  String? _email;
  String? get email => _email;
  bool get isLoggedIn => _email != null && _email!.isNotEmpty;

  Future<void> load() async {
    _email = await LocalStorageService().loadUserEmail();
  }

  Future<void> signInWithEmail(String email) async {
    _email = email;
    await LocalStorageService().saveUserEmail(email);
  }

  Future<void> signOut() async {
    _email = null;
    await LocalStorageService().saveUserEmail(null);
  }
}
