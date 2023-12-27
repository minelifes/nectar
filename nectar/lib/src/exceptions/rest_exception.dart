class RestException implements Exception {
  final int statusCode;
  final String message;

  RestException({
    required this.message,
    this.statusCode = 500,
  });

  factory RestException.badRequest({String message = "Bad request"}) =>
      RestException(message: message, statusCode: 400);
  factory RestException.unauthorized({String message = "Not authorized"}) =>
      RestException(message: message, statusCode: 401);
  factory RestException.notAllowed({String message = "Not allowed"}) =>
      RestException(message: message, statusCode: 403);
  factory RestException.notFound({String message = "Not found"}) =>
      RestException(message: message, statusCode: 404);

  @override
  String toString() => message;
}
