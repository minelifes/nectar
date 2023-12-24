class OrmException implements Exception {
  final String error;

  OrmException(this.error);

  @override
  String toString() => 'OrmException: $error';
}
