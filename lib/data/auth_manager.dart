abstract class AuthManager {
  String getAccessToken();
  Future<bool> refreshToken();
  Future<void> logout();
}