/// Authentication failures
class AuthFailure extends Failure {
  final String provider;
  final String? userId;

  const AuthFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    this.provider = 'Unknown',
    this.userId,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'provider': provider,
            'user_id': userId,
          },
        );

  factory AuthFailure.fromFirebase(dynamic error) {
    String message = 'Authentication failed';
    String? code;
    
    if (error is FirebaseAuthException) {
      code = error.code;
      switch (error.code) {
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'User account disabled';
          break;
        case 'operation-not-allowed':
          message = 'Sign-in method not allowed';
          break;
        case 'too-many-requests':
          message = 'Too many requests, try again later';
          break;
      }
    }
    
    return AuthFailure(
      message,
      code: code,
      provider: 'Firebase',
    );
  }
}