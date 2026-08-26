import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/utils/logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'Starting NGO Internal Operation application...');
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
