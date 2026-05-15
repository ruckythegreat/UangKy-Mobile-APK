import 'package:flutter/material.dart';

/// `hex` format `#RRGGBB` seperti prototipe web.
Color parseHexColor(String hex, {double opacity = 1}) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) {
    final v = int.parse(h, radix: 16);
    return Color(0xFF000000 | v).withValues(alpha: opacity.clamp(0.0, 1.0));
  }
  return Colors.grey;
}
