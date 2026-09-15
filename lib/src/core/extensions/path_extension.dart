extension Path on String {
  String get p => startsWith('/') ? this : '/$this';
}
