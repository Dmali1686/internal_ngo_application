import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/logger.dart';
import 'app.dart';
import 'core/services/auth_storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if necessary
  await Firebase.initializeApp();
  AppLogger.info('App', 'Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'Starting NGO Internal Operation application...');

  // Initialize Firebase
  await Firebase.initializeApp();
  AppLogger.info('App', 'Firebase initialized successfully');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await AuthStorageService().init();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
