abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();

  Future<void> cacheUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? image,
  });

  Future<Map<String, dynamic>?> getCachedUserProfile();

  Future<void> clearUserProfile();
}