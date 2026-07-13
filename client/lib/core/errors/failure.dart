sealed class Failure {
  final String message;
  const Failure({required this.message});
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure({required super.message, this.statusCode});
}

class ServerFailure extends Failure {
  final String? code;
  const ServerFailure({required super.message, this.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
