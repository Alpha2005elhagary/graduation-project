class SecureStorage {
  final Map<String, String> _store = {};

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    _store['access_token'] = accessToken;
    _store['refresh_token'] = refreshToken;
    if (userId != null) _store['user_id'] = userId;
  }

  Future<String?> getAccessToken() async => _store['access_token'];
  Future<String?> getRefreshToken() async => _store['refresh_token'];
  Future<String?> getUserId() async => _store['user_id'];

  Future<void> clearTokens() async {
    _store.clear();
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    _store['fingerprint_enabled'] = enabled.toString();
  }

  Future<bool> isFingerprintEnabled() async {
    return _store['fingerprint_enabled'] == 'true';
  }
}
