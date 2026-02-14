class Formatters {
  Formatters._();

  static String dateTime(DateTime dt) {
    final l = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }

  static String compactMoney(num amount, {String currency = 'EGP'}) {
    // Very small formatter without intl.
    final a = amount.toDouble();
    String fmt(num v) => v.toStringAsFixed(v >= 10 ? 0 : 1).replaceAll('.0', '');
    if (a >= 1000000) return '${fmt(a / 1000000)}M $currency';
    if (a >= 1000) return '${fmt(a / 1000)}K $currency';
    return '${fmt(a)} $currency';
  }

  static String money(num amount, {String currency = 'EGP'}) {
    return compactMoney(amount, currency: currency);
  }
}
