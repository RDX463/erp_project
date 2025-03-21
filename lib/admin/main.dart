import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = SurfaceAndroidWebView(); // Initialize WebView
  runApp(const MyApp());
}
