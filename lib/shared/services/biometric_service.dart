class BiometricService {
  Future<bool> isAvailable() async => false;

  Future<bool> authenticate({String reason = 'قم بتأكيد هويتك'}) async => false;
}
