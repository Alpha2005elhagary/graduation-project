abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}

extension FailureMapper on Failure {
  String toUserMessage() {
    if (this is UnauthorizedFailure) {
      return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
    }
    if (this is NetworkFailure) {
      return 'لا يوجد اتصال بالإنترنت، يرجى المحاولة لاحقًا';
    }
    if (this is ServerFailure) {
      return 'حدث خطأ في الخادم، يرجى المحاولة لاحقًا';
    }
    return message;
  }
}
