class Validators {
  Validators._();

  static bool isValidEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    final re = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return re.hasMatch(v);
  }

  static String? requiredField(String value, {String label = 'Field'}) {
    if (value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? minLength(String value, int min, {String label = 'Field'}) {
    if (value.trim().length < min) return '$label must be at least $min characters.';
    return null;
  }
}
