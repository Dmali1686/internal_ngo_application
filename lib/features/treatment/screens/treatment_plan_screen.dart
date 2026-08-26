import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/text_to_speech_player.dart';

class TreatmentPlanScreen extends StatelessWidget {
  const TreatmentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Treatment Plan'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              _buildPatientHeader(),
              SizedBox(height: 24.h),
              _buildDiagnosisSection(),
              SizedBox(height: 24.h),
              _buildSuggestedCycle(),
            ],
          ),

          // Bottom Action Area
          Positioned(
            bottom: 0.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/treatment-timeline'),
                  icon: const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Assign Treatment',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bella',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.healing,
                            size: 14.sp,
                            color: Colors.orange[700],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Recovery',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '#PT-2938 • Golden Retriever',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Diagnosis',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search conditions...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildDiagnosisChip('Maggot Wound', false),
              _buildDiagnosisChip('Fracture', false),
              _buildDiagnosisChip('Tick Fever', true),
              _buildDiagnosisChip('Viral Infection', false),
              _buildDiagnosisChip('Skin Disease', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green[50] : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.green[700] : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedCycle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Cycle: Tick Fever',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green[700]),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildCycleTimelineItem(
            icon: Icons.medication,
            color: Colors.blue,
            title: 'Medicines',
            desc:
                'Doxycycline 100mg orally twice a day, Prednisolone 5mg once a day for anti-inflammatory support. Ensure the medication is administered right after meals to avoid any gastric irritation.',
          ),
          _buildCycleTimelineItem(
            icon: Icons.science,
            color: Colors.purple,
            title: 'Lab Tests',
            desc:
                'Weekly Complete Blood Count (CBC) and liver function panel to monitor the response to Doxycycline. Please ensure blood is drawn early in the morning before feeding.',
          ),
          _buildCycleTimelineItem(
            icon: Icons.restaurant,
            color: Colors.orange,
            title: 'Diet',
            desc: 'High Protein / Recovery',
            isLast: true,
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.green[700]),
                  SizedBox(width: 8.w),
                  Text(
                    'Est. Recovery',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Text(
                '21 Days',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleTimelineItem({
    required IconData icon,
    required MaterialColor color,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color[700], size: 16.sp),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 30.h,
                color: Colors.green.withOpacity(0.2),
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              TextToSpeechPlayer(text: desc),
              if (!isLast) SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}
