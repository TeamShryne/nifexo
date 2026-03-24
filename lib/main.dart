import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService().init();
  runApp(const NifexoApp());
}
