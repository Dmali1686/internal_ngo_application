import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/utils/logger.dart';
import 'app.dart';
import 'core/services/auth_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'Starting NGO Internal Operation application...');
  await AuthStorageService().init();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
