import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

JavascriptRuntime getJSRunTime() {
  return getJavascriptRuntime();
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

Color primaryDarkColor() {
  return const Color(0xFF1B1E38);
}

Color secondaryDarkColor() {
  return const Color(0xFF32385F);
}