import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../diet_management/providers/diet_provider.dart';

class DoctorFoodScheduleScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;
  const DoctorFoodScheduleScreen({super.key, this.patientId, this.patientName});

  @override
  State<DoctorFoodScheduleScreen> createState() =>
      _DoctorFoodScheduleScreenState();
}

class _DoctorFoodScheduleScreenState extends State<DoctorFoodScheduleScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<DietProvider>();
        provider.fetchDietHistory(widget.patientId!);
        if (provider.defaultPlans.isEmpty) {
          provider.fetchDefaultDietPlans();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        title: Text(
          'Food Schedule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        actions: [
          if (widget.patientId != null)
            TextButton.icon(
              onPressed: () {
                context.push('/assign-diet', extra: {
                  'patientId': widget.patientId,
                  'patientName': widget.patientName,
                });
              },
              icon: const Icon(Icons.add_rounded, color: Color(0xFF34A853)),
              label: Text(
                'Add Diet',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF34A853),
                  fontSize: 15.sp,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: widget.patientId == null
          ? _buildNoPatientState()
          : Consumer<DietProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.dietHistory.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                
                if (provider.dietHistory.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: provider.dietHistory.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final diet = provider.dietHistory[index];
                    return _buildDietCard(diet);
                  },
                );
              },
            ),
    );
  }

  Widget _buildDietCard(dynamic diet) {
    final bool isActive = diet.status == 'ACTIVE';
    final String source = diet.dietSource ?? 'UNKNOWN';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isActive ? AppColors.successGreen.withValues(alpha: 0.05) : Colors.grey[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle_rounded : Icons.history_rounded,
                      size: 18.sp,
                      color: isActive ? AppColors.successGreen : Colors.grey[500],
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isActive ? 'Active Diet' : 'Past Diet',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.successGreen : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: source == 'DEFAULT' 
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    source,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: source == 'DEFAULT' 
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Body (Items)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Items & Frequency',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 12.h),
                if (diet.items != null && diet.items!.isNotEmpty)
                  ...diet.items!.map<Widget>((item) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLightGray,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.restaurant, size: 14.sp, color: Colors.grey[600]),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.foodItem?.name ?? 'Unknown Food',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Qty: ${item.quantity} ${item.foodItem?.unit ?? ''} • Freq: ${item.frequency}',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 13.sp,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList()
                else
                  Text(
                    'No specific food items attached to this plan.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 64.sp,
                color: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Diets Assigned',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'This patient currently does not have any active or past diet plans assigned.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/assign-diet', extra: {
                  'patientId': widget.patientId,
                  'patientName': widget.patientName,
                });
              },
              icon: Icon(Icons.add, size: 20.sp, color: Colors.white),
              label: Text(
                'Assign Diet Now',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPatientState() {
    return Center(
      child: Text(
        'Please access this screen from a specific patient.',
        style: GoogleFonts.nunitoSans(color: Colors.grey[600]),
      ),
    );
  }
}
