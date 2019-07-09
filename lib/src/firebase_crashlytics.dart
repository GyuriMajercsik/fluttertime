import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Set `devMode` to true to see reports while in debug mode
/// This is only to be used for confirming that reports are being
/// submitted as expected. It is not intended to be used for everyday
/// development.
void installCrashlytics({bool devMode = false}) {
  Crashlytics.instance.enableInDevMode = devMode;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };
}
