import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Step4TransportDetails extends StatelessWidget {
  const Step4TransportDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildAssignmentDetails(),
          SizedBox(height: 24.h),
          _buildQRScanSection(),
          SizedBox(height: 24.h),
          _buildLogisticsTimeline(),
          SizedBox(height: 24.h),
          _buildRescueTeamSection(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildAssignmentDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: const Color(0xFF006E1C),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Assignment Details',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF0288D1),
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Assigned',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transported By',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'City Rescue Fleet A',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Number',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'AMB-1092-TX',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1599566150163-29194dcaad36',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Name',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Robert \'Rob\' Jenkins',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006E1C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.call, color: Colors.white, size: 20.w),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFF006E1C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: const Color(0xFF006E1C),
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Verify Load',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003C0B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Scan QR code on the transport cage or vehicle dashboard to confirm pick-up.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: const Color(0xFF005313),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003C0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            icon: Icon(Icons.photo_camera, size: 20.w),
            label: Text(
              'Launch Scanner',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsTimeline() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Color(0xFF0288D1),
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Logistics Timeline',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CAGE NUMBER',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'C-142',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006E1C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildTimelineItem('Pickup Time', '14:32', 'pm', true),
              ),
              Expanded(
                child: _buildTimelineItem('Est. Arrival', '15:15', 'pm', false),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTimelineItem(
            'Assigned Branch',
            'East Side Medical Center',
            '',
            false,
            icon: Icons.open_in_new,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    String value,
    String suffix,
    bool isPrimary, {
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isPrimary
                    ? const Color(0xFF006E1C)
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF5F3F3), width: 2.w),
              ),
            ),
            Container(
              width: 2.w,
              height: 32.h,
              color: isPrimary ? const Color(0xFF006E1C) : Colors.grey.shade300,
            ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    Text(
                      ' $suffix',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (icon != null) ...[
                    SizedBox(width: 4.w),
                    Icon(icon, color: const Color(0xFF006E1C), size: 16.w),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRescueTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.groups, color: Colors.grey.shade600, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              'RESCUE TEAM MEMBERS',
              style: GoogleFonts.nunitoSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildTeamMemberChip('SR', 'Sarah Reed (Lead)', Colors.blue),
            _buildTeamMemberChip('MT', 'Marcus Thorne', Colors.orange),
            _buildTeamMemberChip('JL', 'Jenny Liang', Colors.purple),
            _buildAddMemberChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamMemberChip(
    String initials,
    String name,
    MaterialColor color,
  ) {
    return Container(
      padding: EdgeInsets.only(left: 4.w, right: 12.w, top: 4.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E8E7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: color.shade100,
            child: Text(
              initials,
              style: GoogleFonts.nunitoSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            name,
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              color: const Color(0xFF1B1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFF006E1C),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add, color: const Color(0xFF006E1C), size: 16.w),
          SizedBox(width: 4.w),
          Text(
            'Add Member',
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              color: const Color(0xFF006E1C),
            ),
          ),
        ],
      ),
    );
  }
}
