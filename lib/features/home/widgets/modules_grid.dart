import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ModulesGrid extends StatelessWidget {
  const ModulesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Patient Registration',
        'subtitle': 'Register new\nanimal patient',
        'icon': Icons.assignment_add,
        'color': const Color(0xFF34A853),
        'route': '/registration-dashboard',
      },
      {
        'title': 'QR Management',
        'subtitle': 'Generate, scan &\nmanage QR codes',
        'icon': Icons.qr_code_scanner,
        'color': const Color(0xFF34A853),
        'route': '/qr-scanner',
      },
      {
        'title': 'Patient History',
        'subtitle': 'View complete\ntreatment history',
        'icon': Icons.history,
        'color': const Color(0xFF8B5CF6),
        'route': '/animal-overview',
      },
      {
        'title': 'Treatment Cycle',
        'subtitle': 'Manage treatment\nand recovery',
        'icon': Icons.medical_services,
        'color': const Color(0xFF3B82F6),
        'route': '/treatment-dashboard',
      },
      {
        'title': 'Diet Management',
        'subtitle': 'Disease-based\ndiet plans',
        'icon': Icons.restaurant,
        'color': const Color(0xFFF59E0B),
        'route': '/diet-dashboard',
      },
      {
        'title': 'Ambulance',
        'subtitle': 'Rescue requests &\nnotifications',
        'icon': Icons.local_shipping,
        'color': const Color(0xFFEF4444),
        'route': '/ambulance-dashboard',
      },
      {
        'title': 'Employees',
        'subtitle': 'Manage staff &\nroles',
        'icon': Icons.people,
        'color': const Color(0xFF14B8A6),
        'route': '/employee-dashboard',
      },
      {
        'title': 'Voice Notes',
        'subtitle': 'Add voice notes\n& updates',
        'icon': Icons.mic,
        'color': const Color(0xFF3B82F6),
        'route': '/voice-notes-dashboard',
      },
      {
        'title': 'Settings',
        'subtitle': 'App settings &\npreferences',
        'icon': Icons.settings,
        'color': const Color(0xFF64748B),
        'route': null,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.72,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return GestureDetector(
            onTap: () {
              if (module['route'] != null) {
                context.push(module['route'] as String);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: (module['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      module['icon'] as IconData,
                      size: 28.w,
                      color: module['color'] as Color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    module['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    module['subtitle'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
