import 'package:flutter_web_plugins/url_strategy.dart';

/// Configures HTML5 clean path URL strategy on Flutter Web (removes '#' hash routing).
void configureAppUrlStrategy() {
  usePathUrlStrategy();
}
