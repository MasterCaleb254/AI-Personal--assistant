/// Native platform channel failures
class NativeFailure implements Exception {
  final String message;
  final String? code;
  final String? platform;
  final String? method;

  const NativeFailure(
    this.message, {
    this.code,
    this.platform,
    this.method,
  });

  factory NativeFailure.fromPlatformException(PlatformException e) {
    return NativeFailure(
      e.message ?? 'Native operation failed',
      code: e.code,
      platform: Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown',
      method: e.methodName,
    );
  }

  @override
  String toString() {
    return 'NativeFailure: $message'
      '${code != null ? ' ($code)' : ''}'
      '${platform != null ? ' | Platform: $platform' : ''}'
      '${method != null ? ' | Method: $method' : ''}';
  }
}