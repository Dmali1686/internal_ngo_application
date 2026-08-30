import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/logger.dart';

import 'package:provider/provider.dart';
import 'features/patient_registration/providers/registration_provider.dart';
import 'features/patient_registration/providers/patient_list_provider.dart';
import 'core/services/voice_service.dart';
import 'core/services/voice_language_provider.dart';
import 'core/providers/master_data_provider.dart';
import 'core/providers/dashboard_modules_provider.dart';
import 'features/super_admin/providers/super_admin_provider.dart';
import 'features/tasks/providers/task_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.lifecycle('MyApp', 'build');

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => VoiceLanguageProvider()),
            ChangeNotifierProvider(create: (_) => VoiceService()),
            ChangeNotifierProvider(create: (_) => RegistrationProvider()),
            ChangeNotifierProvider(
              create: (_) => MasterDataProvider()..loadMasterData(),
            ),
            ChangeNotifierProvider(
              create: (_) => DashboardModulesProvider()..loadModules(),
            ),
            ChangeNotifierProvider(
              create: (_) => SuperAdminProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => TaskProvider()..fetchAllTasks()..fetchAssignedTasks()..fetchMyTasks(),
            ),
            ChangeNotifierProvider(
              create: (_) => PatientListProvider(),
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appTitle,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
