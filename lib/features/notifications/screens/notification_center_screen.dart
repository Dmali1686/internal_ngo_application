import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

import 'package:go_router/go_router.dart';

/// Full-page notification center — opened from the bell icon.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  static const Color _primary = Color(0xFF1E293B);
  static const Color _accent = Color(0xFF0F766E);
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().fetchInbox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 12.h),
            _buildFilterChips(context),
            SizedBox(height: 8.h),
            Expanded(child: _buildNotificationsList(context)),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final unread = provider.unreadCount;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 16.w, 0),
      child: Row(
        children: [
          // Back button
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20.sp,
                color: _primary,
              ),
            ),
          ),
          // Title + badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (unread > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '$unread new',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Mark all read
          GestureDetector(
            onTap: () => provider.markAllRead(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all_rounded, size: 14.sp, color: _accent),
                  SizedBox(width: 4.w),
                  Text(
                    'Mark read',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
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

  // ─── Filter Chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final selected = provider.selectedFilter;

    final filters = <MapEntry<NotificationType?, String>>[
      const MapEntry(null, 'All'),
      const MapEntry(NotificationType.emergency, '🚨 Emergency'),
      const MapEntry(NotificationType.departmentTask, '📋 Dept Task'),
      const MapEntry(NotificationType.assignedTask, '✅ Assigned'),
      const MapEntry(NotificationType.general, '🔔 General'),
    ];

    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final entry = filters[i];
          final isSelected = selected == entry.key;
          return GestureDetector(
            onTap: () => provider.setFilter(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? _primary
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: isSelected
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
                entry.value,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Notifications List (date-grouped) ─────────────────────────────────────

  Widget _buildNotificationsList(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final grouped = provider.groupedNotifications;

    if (grouped.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => provider.fetchInbox(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
        itemCount: grouped.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == grouped.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            );
          }
          
          final label = grouped.keys.elementAt(index);
          final items = grouped[label]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) SizedBox(height: 10.h),
              // Day label
              Padding(
                padding: EdgeInsets.only(bottom: 10.h, left: 4.w),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              ...items.map(
                (n) => _NotificationCard(notification: n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'All caught up!',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'No notifications in this category.',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual notification card
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Icon(Icons.delete_rounded, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (_) {
        context.read<NotificationProvider>().removeNotification(n.id);
      },
      child: GestureDetector(
        onTap: () {
          context.read<NotificationProvider>().markAsRead(n.id);
          if (n.link != null && n.link!.isNotEmpty) {
            GoRouter.of(context).push(n.link!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: n.isRead
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: n.isRead
                  ? Colors.grey.withValues(alpha: 0.12)
                  : n.accentColor.withValues(alpha: 0.3),
              width: n.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: n.isRead
                    ? Colors.black.withValues(alpha: 0.03)
                    : n.accentColor.withValues(alpha: 0.08),
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
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? Colors.grey.withValues(alpha: 0.2)
                          : n.accentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        bottomLeft: Radius.circular(18.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type icon
                          _buildIcon(n),
                          SizedBox(width: 12.w),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: n.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w700,
                                          color: const Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildTypePill(n),
                                    if (!n.isRead) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: n.accentColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                // Message
                                Text(
                                  n.message,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 12.sp,
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                // Time
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 12.sp,
                                        color: Colors.grey.shade400),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _timeAgo(n.createdAt),
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: n.isRead
                                            ? Colors.grey.shade400
                                            : n.accentColor,
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
      ),
    );
  }

  Widget _buildIcon(NotificationModel n) {
    if (n.type == NotificationType.emergency && !n.isRead) {
      // Animated pulsing container for unread emergencies
      return _PulsingIcon(notification: n);
    }
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: n.iconBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(n.icon, color: n.accentColor, size: 22.sp),
    );
  }

  Widget _buildTypePill(NotificationModel n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: n.iconBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: n.accentColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        n.typeLabel,
        style: GoogleFonts.nunitoSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: n.accentColor,
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing icon for emergency cards
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingIcon extends StatefulWidget {
  final NotificationModel notification;
  const _PulsingIcon({required this.notification});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: n.iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: n.accentColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(n.icon, color: n.accentColor, size: 22.sp),
          ),
        );
      },
    );
  }
}
