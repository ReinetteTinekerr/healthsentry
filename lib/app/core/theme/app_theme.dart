import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  /// for getting light theme
  FluentThemeData get lightTheme {
    // TODO: add light theme here
    return FluentThemeData();
  }

  /// for getting dark theme
  FluentThemeData get darkTheme {
    // TODO: add dark theme here
    return FluentThemeData();
  }
}

/// for providing app theme [AppTheme]
final appThemeProvider = Provider<AppTheme>((_) => AppTheme());
