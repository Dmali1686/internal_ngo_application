import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedFilter = 0;
  static const Color _primary = Color(0xFF1E293B);
  static const Color _accent = Color(0xFF0F766E);

  final List<String> _filters = [
    'All', 'Emergencies', 'Updates', 'System',
  ];

  final List<_AlertItem> _alerts = [
    _AlertItem(
      type: 'emergency',
      title: 'Critical Case Arrived',
      message:
          'Ambulance dropped off a severe trauma case. Immediate doctor attention required in ER.',
      time: 'Just now',
      isUnread: true,
      icon: Icons.warning_amber_rounded,
      accentColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEF2F2),
      typeLabel: 'Emergency',
    ),
    _AlertItem(
      type: 'update',
      title: 'Task Completed',
      message:
          'Morning rounds for Ward B have been marked as completed by Dr. Sarah.',
      time: '45 mins ago',
      isUnread: true,
      icon: Icons.task_alt_rounded,
      accentColor: Color(0xFF10B981),
      iconBg: Color(0xFFECFDF5),
      typeLabel: 'Update',
    ),
    _AlertItem(
      type: 'system',
      title: 'System Maintenance',
      message:
          'The QR management system will be down for maintenance tonight at 2:00 AM.',
      time: '2 hours ago',
      isUnread: false,
      icon: Icons.settings_rounded,
      accentColor: Color(0xFF64748B),
      iconBg: Color(0xFFF1F5F9),
      typeLabel: 'System',
    ),
    _AlertItem(
      type: 'update',
      title: 'Diet Plan Updated',
      message:
          'Special diet plan for Patient ANM-0982 (Max) has been updated.',
      time: 'Yesterday',
      isUnread: false,
      icon: Icons.restaurant_rounded,
      accentColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFFBEB),
      typeLabel: 'Update',
    ),
    _AlertItem(
      type: 'emergency',
      title: 'Rescue Request',
      message: 'New rescue request received at Sector 14. Ambulance dispatched.',
      time: 'Yesterday',
      isUnread: false,
      icon: Icons.local_shipping_rounded,
      accentColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEF2F2),
      typeLabel: 'Emergency',
    ),
    _AlertItem(
      type: 'update',
      title: 'Treatment Updated',
      message:
          'Bella\'s treatment plan has been revised. Check new medication schedule.',
      time: '2 days ago',
      isUnread: false,
      icon: Icons.medical_services_rounded,
      accentColor: Color(0xFF3B82F6),
      iconBg: Color(0xFFEFF6FF),
      typeLabel: 'Update',
    ),
  ];

  List<_AlertItem> get _filteredAlerts {
    if (_selectedFilter == 0) return _alerts;
    final typeMap = {1: 'emergency', 2: 'update', 3: 'system'};
    final type = typeMap[_selectedFilter]!;
    return _alerts.where((a) => a.type == type).toList();
  }

  int get _unreadCount => _alerts.where((a) => a.isUnread).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildFilters(),
            SizedBox(height: 8.h),
            Expanded(child: _buildAlertsList()),
          ],
        ),
      ),
    );
  }

  // ─── Header ───

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Alerts',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  if (_unreadCount > 0) ...[
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 9.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '$_unreadCount new',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                '${_alerts.length} notifications total',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() {
              for (final a in _alerts) {
                a.isUnread = false;
              }
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _accent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.done_all_rounded, size: 15.sp, color: _accent),
                  SizedBox(width: 6.w),
                  Text(
                    'Mark all read',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filters ───

  Widget _buildFilters() {
    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? _primary : Colors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _filters[i],
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Alerts List ───

  Widget _buildAlertsList() {
    final items = _filteredAlerts;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 48.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'No alerts in this category',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildAlertCard(items[i]),
    );
  }

  Widget _buildAlertCard(_AlertItem alert) {
    return GestureDetector(
      onTap: () => setState(() => alert.isUnread = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: alert.isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: alert.isUnread
                ? alert.accentColor.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.12),
            width: alert.isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: alert.isUnread
                  ? alert.accentColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4.w,
                  color: alert.isUnread
                      ? alert.accentColor
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: alert.iconBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            alert.icon,
                            color: alert.accentColor,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: alert.isUnread
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Type pill
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: alert.iconBg,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: alert.accentColor
                                              .withValues(alpha: 0.25)),
                                    ),
                                    child: Text(
                                      alert.typeLabel,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: alert.accentColor,
                                      ),
                                    ),
                                  ),
                                  if (alert.isUnread) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: BoxDecoration(
                                        color: alert.accentColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                alert.message,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                  height: 1.45,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 12.sp, color: Colors.grey.shade400),
                                  SizedBox(width: 4.w),
                                  Text(
                                    alert.time,
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: alert.isUnread
                                          ? alert.accentColor
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertItem {
  final String type;
  final String title;
  final String message;
  final String time;
  bool isUnread;
  final IconData icon;
  final Color accentColor;
  final Color iconBg;
  final String typeLabel;

  _AlertItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.icon,
    required this.accentColor,
    required this.iconBg,
    required this.typeLabel,
  });
}
