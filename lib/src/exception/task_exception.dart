class TaskException implements Exception {
  TaskException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
