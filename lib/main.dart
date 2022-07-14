import 'package:drift_sqlite/src/app.dart';
import 'package:drift_sqlite/src/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(observers: [Logger()], child: const App()));
}
