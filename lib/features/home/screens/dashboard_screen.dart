import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/voice_language_provider.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tasks/screens/tasks_dashboard_screen.dart';
import '../../super_admin/screens/super_admin_dashboard_screen.dart';
import '../../super_admin/providers/super_admin_provider.dart';

// Extracted Widgets
import '../widgets/home_header.dart';
import '../widgets/stat_cards.dart';
import '../widgets/modules_grid.dart';
import '../widgets/my_tasks_widget.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/view_all_animals_card.dart';
import '../widgets/employee_departments_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLanguageDialog();
    });
  }

  void _checkAndShowLanguageDialog() {
    final langProvider = context.read<VoiceLanguageProvider>();
    if (!langProvider.hasSelectedLanguage) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Voice Language',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 24.h),
                Consumer<VoiceLanguageProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: VoiceLanguage.values.map((lang) {
                        final isSelected = provider.language == lang;
                        return GestureDetector(
                          onTap: () {
                            provider.setLanguage(lang);
                            provider.markLanguageSelected();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.backgroundLightGray,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              VoiceLanguageProvider.getDisplayName(lang),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMain,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = context.watch<SuperAdminProvider>().isSuperAdmin;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: isSuperAdmin 
          ? const SuperAdminDashboardScreen()
          : Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              const TasksDashboardScreen(),
              const AlertsScreen(),
              const ProfileScreen(),
            ],
          ),
          // Floating "View All Animals" card — only visible on Home tab
          if (_currentIndex == 0)
            Positioned(
              bottom: 8.h, // small gap above the BottomAppBar
              left: 0,
              right: 0,
              child: const ViewAllAnimalsCard(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-registration'),
        backgroundColor: const Color(0xFF2E8B57),
        shape: const CircleBorder(),
        elevation: 2,
        child: Icon(Icons.add, color: Colors.white, size: 28.w),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    ),
    );
  }

  Widget _buildHomeTab() {
    final isEmployee =
        context.watch<SuperAdminProvider>().isEmployee;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Full-screen background image — always covers the full height
          Positioned.fill(
            child:
                Image.asset('assets/images/backgound.png', fit: BoxFit.cover),
          ),
          // Semi-transparent overlay
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0))),
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  onProfileTap: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
                // Stat cards are visible for all roles
                const StatCards(),
                SizedBox(height: 20.h),
                // Module grid is hidden for employees
                if (!isEmployee) const ModulesGrid(),
                if (!isEmployee) SizedBox(height: 20.h),
                if (isEmployee) const EmployeeDepartmentsGrid(),
                if (isEmployee) SizedBox(height: 20.h),
                // My Tasks section is only for non-employee roles.
                // Employees see their tasks inside the department cards above.
                if (!isEmployee) MyTasksWidget(
                  onViewAll: () => setState(() => _currentIndex = 1),
                ),
                SizedBox(height: 160.h), // Space for bottom nav + floating card
              ],
            ),
          ),
        ],
      ),
    );
  }
}
