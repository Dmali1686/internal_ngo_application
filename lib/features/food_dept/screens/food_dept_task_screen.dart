import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/voice_service.dart';
import '../models/food_dept_models.dart';
import '../providers/food_dept_provider.dart';

/// Food Department Feeding Schedule screen.
///
/// Rendered for employees with position codes FOD-HOD-001 / FOD-COOK-001.
/// Can be opened both as a full-page route AND embedded inside another widget.
class FoodDeptTaskScreen extends StatefulWidget {
  const FoodDeptTaskScreen({super.key});

  @override
  State<FoodDeptTaskScreen> createState() => _FoodDeptTaskScreenState();
}

class _FoodDeptTaskScreenState extends State<FoodDeptTaskScreen>
    with TickerProviderStateMixin {
  // ─── Colour palette ───────────────────────────────────────────────────────
  static const Color _pageBg      = Color(0xFFF4F6F9);
  static const Color _primary     = Color(0xFF1B4332);
  static const Color _accent      = Color(0xFF2D6A4F);
  static const Color _green       = Color(0xFF10B981);
  static const Color _textMain    = Color(0xFF1E293B);
  static const Color _textSub     = Color(0xFF64748B);

  // Animation
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodDeptProvider>().fetchTodaySchedule();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Date picker
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickDate(FoodDeptProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      provider.fetchScheduleForDate(picked);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      // ── App Bar ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feeding Schedule',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Food Department',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<FoodDeptProvider>(
            builder: (_, provider, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker chip
                GestureDetector(
                  onTap: () => _pickDate(provider),
                  child: Container(
                    margin: EdgeInsets.only(right: 6.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13.sp, color: Colors.white),
                        SizedBox(width: 5.w),
                        Text(
                          provider.isToday
                              ? 'Today'
                              : _shortDate(provider.selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Refresh
                IconButton(
                  icon: provider.isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 22.sp),
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.isToday
                          ? provider.fetchTodaySchedule()
                          : provider.fetchScheduleForDate(
                              provider.selectedDate),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Consumer<FoodDeptProvider>(
        builder: (context, provider, _) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ── Summary bar ───────────────────────────────────────────
                _SummaryBar(provider: provider),

                // ── Slot filter ───────────────────────────────────────────
                _SlotFilterBar(provider: provider),

                // ── Content ───────────────────────────────────────────────
                Expanded(child: _buildBody(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FoodDeptProvider provider) {
    final schedule = provider.schedule;

    if (provider.isLoading && schedule == null) {
      return _buildLoading();
    }
    if (provider.errorMessage != null && schedule == null) {
      return _buildError(provider);
    }
    if (schedule == null || schedule.schedule.isEmpty) {
      return _buildEmpty();
    }

    // ── History mode ─────────────────────────────────────────────
    if (provider.showHistory) {
      return _buildHistoryList(context, provider);
    }

    // ── Normal pending list ───────────────────────────────────────
    final patients = provider.filteredPatients;
    if (patients.isEmpty) return _buildEmpty();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 100.h),
      itemCount: patients.length + 1, // +1 header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.pets_rounded,
                      size: 14.sp, color: _primary),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${patients.length} Animal${patients.length != 1 ? 's' : ''} scheduled',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
              ],
            ),
          );
        }
        final patient = patients[index - 1];
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: _PatientCard(
            patient: patient,
            visibleSlots: provider.visibleSlotsFor(patient),
            provider: provider,
            onComplete: (task) =>
                _handleComplete(context, provider, task),
          ),
        );
      },
    );
  }

  // ── History list view ─────────────────────────────────────────
  Widget _buildHistoryList(BuildContext context, FoodDeptProvider provider) {
    final history = provider.completedHistory;
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 52.sp,
                color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            SizedBox(height: 12.h),
            Text('No completed tasks yet',
                style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
            SizedBox(height: 4.h),
            Text('Tasks you complete will appear here.',
                style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp, color: _textSub),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 100.h),
      itemCount: history.length + 1, // +1 header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      size: 14.sp,
                      color: const Color(0xFF10B981)),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${history.length} task${history.length != 1 ? 's' : ''} completed today',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
              ],
            ),
          );
        }
        final entry = history[index - 1];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _HistoryCard(entry: entry),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Complete task
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleComplete(
    BuildContext ctx,
    FoodDeptProvider provider,
    FeedingTask task,
  ) async {
    String? notes;

    final confirmed = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _CompleteTaskSheet(
        task: task,
        onNotesChanged: (v) => notes = v,
      ),
    );

    if (confirmed != true) return;
    if (!ctx.mounted) return;

    final ok = await provider.completeTask(task.id,
        notes: notes?.isEmpty == true ? null : notes);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '✅ Feeding task completed!' : '❌ Failed — please retry.',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: ok ? _green : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading / Error / Empty
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accent)),
            SizedBox(height: 16.h),
            Text('Loading feeding schedule…',
                style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    color: _textSub,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _buildError(FoodDeptProvider provider) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52.sp,
                color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
            SizedBox(height: 12.h),
            Text('Could not load schedule',
                style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
            SizedBox(height: 4.h),
            Text('Tap to retry',
                style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp, color: _textSub)),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: provider.fetchTodaySchedule,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_food_rounded,
                size: 52.sp,
                color: _accent.withValues(alpha: 0.3)),
            SizedBox(height: 12.h),
            Text('No feeding tasks',
                style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
            SizedBox(height: 4.h),
            Text('No tasks scheduled for this date / slot.',
                style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp, color: _textSub),
                textAlign: TextAlign.center),
          ],
        ),
      );

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary bar (Animals / Pending / Done)
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final FoodDeptProvider provider;

  const _SummaryBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final s = provider.schedule;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B4332),
        borderRadius: BorderRadius.vertical(bottom: Radius.zero),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.pets_rounded,
            value: s?.totalAnimals.toString() ?? '—',
            label: 'Animals',
            color: const Color(0xFF60A5FA),
          ),
          SizedBox(width: 10.w),
          _StatChip(
            icon: Icons.pending_actions_rounded,
            value: s?.pendingTasks.toString() ?? '—',
            label: 'Pending',
            color: const Color(0xFFFBBF24),
          ),
          SizedBox(width: 10.w),
          _StatChip(
            icon: Icons.check_circle_rounded,
            value: s?.completedTasks.toString() ?? '—',
            label: 'Completed',
            color: const Color(0xFF34D399),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14.sp, color: color),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot filter pill bar
// ─────────────────────────────────────────────────────────────────────────────

class _SlotFilterBar extends StatelessWidget {
  final FoodDeptProvider provider;

  const _SlotFilterBar({required this.provider});

  static const _filters = [
    (slot: null,         label: 'All',       icon: Icons.list_alt_rounded),
    (slot: 'MORNING',   label: 'Morning',   icon: Icons.wb_sunny_rounded),
    (slot: 'AFTERNOON', label: 'Afternoon', icon: Icons.wb_cloudy_rounded),
    (slot: 'EVENING',   label: 'Evening',   icon: Icons.nights_stay_rounded),
  ];

  static const Color _historyColor = Color(0xFF10B981); // green

  @override
  Widget build(BuildContext context) {
    final isHistory = provider.showHistory;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(top: 10.h, bottom: 16.h),
      child: SizedBox(
        height: 36.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            // ── All / Morning / Afternoon / Evening pills ───
            ..._filters.map((f) {
              // A slot pill is active only when NOT in history mode
              final selected = !isHistory && provider.selectedSlot == f.slot;
              const color = Color(0xFF2D6A4F);
              return GestureDetector(
                onTap: () => provider.setSlotFilter(f.slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? color : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.icon,
                        size: 13.sp,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        f.label,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ── History pill (last) ─────────────────────────────
            GestureDetector(
              onTap: provider.toggleHistory,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isHistory
                      ? _historyColor
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: isHistory
                      ? [
                          BoxShadow(
                            color: _historyColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 13.sp,
                      color: isHistory
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'History',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isHistory
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final PatientSchedule patient;
  final List<SlotSchedule> visibleSlots;
  final FoodDeptProvider provider;
  final void Function(FeedingTask) onComplete;

  const _PatientCard({
    required this.patient,
    required this.visibleSlots,
    required this.provider,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient header ──────────────────────────────────────────
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B4332).withValues(alpha: 0.06),
                    const Color(0xFF2D6A4F).withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Emoji avatar
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        patient.animalEmoji,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              patient.caseId,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11.sp,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (patient.cageNumber != null &&
                                patient.cageNumber!.isNotEmpty) ...[
                              Text(
                                '  ·  ',
                                style: GoogleFonts.nunitoSans(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B)),
                              ),
                              Icon(Icons.grid_view_rounded,
                                  size: 10.sp,
                                  color: const Color(0xFF64748B)),
                              SizedBox(width: 3.w),
                              Text(
                                'Cage ${patient.cageNumber}',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: const Color(0xFF2D6A4F)
                              .withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      patient.animalType.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D6A4F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Slots ───────────────────────────────────────────────────
            ...visibleSlots.map((slot) =>
                _SlotSection(slot: slot, provider: provider,
                    onComplete: onComplete)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot section
// ─────────────────────────────────────────────────────────────────────────────

class _SlotSection extends StatelessWidget {
  final SlotSchedule slot;
  final FoodDeptProvider provider;
  final void Function(FeedingTask) onComplete;

  const _SlotSection({
    required this.slot,
    required this.provider,
    required this.onComplete,
  });

  Color get _slotColor {
    return const Color(0xFF64748B);
  }

  IconData get _slotIcon {
    switch (slot.slot) {
      case 'MORNING':   return Icons.wb_sunny_rounded;
      case 'AFTERNOON': return Icons.wb_cloudy_rounded;
      case 'EVENING':   return Icons.nights_stay_rounded;
      default:          return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _slotColor;
    final pending = slot.items.where((t) => t.isPending).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slot header
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
          child: Row(
            children: [
              Icon(_slotIcon, size: 13.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                slot.slot,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (pending > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: const Color(0xFF64748B)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$pending pending',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Task items
        ...slot.items.asMap().entries.map((entry) {
          final isLast = entry.key == slot.items.length - 1;
          return _FeedingItemRow(
            task: entry.value,
            isLast: isLast,
            isBeingCompleted: provider.isCompleting(entry.value.id),
            onComplete: () => onComplete(entry.value),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual feeding item row
// ─────────────────────────────────────────────────────────────────────────────

class _FeedingItemRow extends StatelessWidget {
  final FeedingTask task;
  final bool isLast;
  final bool isBeingCompleted;
  final VoidCallback onComplete;

  const _FeedingItemRow({
    required this.task,
    required this.isLast,
    required this.isBeingCompleted,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return Container(
      padding: EdgeInsets.fromLTRB(
          14.w, 12.h, 14.w, isLast ? 14.h : 10.h),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.grey.shade50
            : Colors.white,
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status dot
          Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF2D6A4F)
                  : Colors.grey.shade400,
            ),
          ),
          SizedBox(width: 12.w),

          // Food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.foodItemName,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? const Color(0xFF64748B)
                        : const Color(0xFF1E293B),
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D6A4F)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${task.quantity} ${task.unit}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D6A4F),
                        ),
                      ),
                    ),
                    if (task.instructions != null &&
                        task.instructions!.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          task.instructions!,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isDone && task.completedByName != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 11.sp,
                          color: const Color(0xFF2D6A4F)),
                      SizedBox(width: 4.w),
                      Text(
                        'Done by ${task.completedByName}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.sp,
                          color: const Color(0xFF2D6A4F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Action
          if (!isDone)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isBeingCompleted
                  ? SizedBox(
                      key: const ValueKey('spin'),
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF2D6A4F)),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('btn'),
                      onTap: onComplete,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1B4332),
                              Color(0xFF2D6A4F),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D6A4F)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Complete',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: 11.sp,
                      color: const Color(0xFF10B981)),
                  SizedBox(width: 3.w),
                  Text(
                    'Done',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History card — one completed task row (used by the History filter view)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final CompletedEntry entry;

  static const Color _green    = Color(0xFF10B981);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub  = Color(0xFF64748B);
  static const Color _accent   = Color(0xFF2D6A4F);

  const _HistoryCard({required this.entry});

  Color _slotColor(String slot) {
    switch (slot) {
      case 'MORNING':   return const Color(0xFFF59E0B);
      case 'AFTERNOON': return const Color(0xFF3B82F6);
      case 'EVENING':   return const Color(0xFF8B5CF6);
      default:          return _textSub;
    }
  }

  IconData _slotIcon(String slot) {
    switch (slot) {
      case 'MORNING':   return Icons.wb_sunny_rounded;
      case 'AFTERNOON': return Icons.wb_cloudy_rounded;
      case 'EVENING':   return Icons.nights_stay_rounded;
      default:          return Icons.schedule_rounded;
    }
  }

  String _slotLabel(String slot) {
    switch (slot) {
      case 'MORNING':   return 'Morning';
      case 'AFTERNOON': return 'Afternoon';
      case 'EVENING':   return 'Evening';
      default:          return slot;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m  = dt.minute.toString().padLeft(2, '0');
      return '$h:${m} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final task    = entry.task;
    final patient = entry.patient;
    final sc      = _slotColor(entry.slot);
    final time    = _formatTime(task.completedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Green done dot
          Container(
            width: 9.w,
            height: 9.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF10B981),
            ),
          ),
          SizedBox(width: 12.w),

          // Main info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animal + slot badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_slotIcon(entry.slot),
                              size: 9.sp, color: sc),
                          SizedBox(width: 3.w),
                          Text(
                            _slotLabel(entry.slot),
                            style: GoogleFonts.nunitoSans(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: sc,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Food name with strikethrough
                Text(
                  task.foodItemName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _textSub,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _textSub.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 3.h),

                // Quantity · done-by · time
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        '${task.quantity} ${task.unit}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                    ),
                    if (task.completedByName != null) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.person_rounded,
                          size: 10.sp, color: _green),
                      SizedBox(width: 2.w),
                      Text(
                        task.completedByName!,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ],
                    if (time.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.access_time_rounded,
                          size: 10.sp, color: _textSub),
                      SizedBox(width: 2.w),
                      Text(time,
                          style: GoogleFonts.nunitoSans(
                              fontSize: 10.sp, color: _textSub)),
                    ],
                  ],
                ),

                // Notes (optional)
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.notes_rounded,
                          size: 10.sp, color: _textSub),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          task.notes!,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10.sp,
                            color: _textSub,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Done badge
          SizedBox(width: 10.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 10.sp, color: _green),
                SizedBox(width: 3.w),
                Text(
                  'Done',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Complete-Task bottom sheet (with Speech-to-Text notes)
// ─────────────────────────────────────────────────────────────────────────────

class _CompleteTaskSheet extends StatefulWidget {
  final FeedingTask task;
  final void Function(String?) onNotesChanged;

  const _CompleteTaskSheet({
    required this.task,
    required this.onNotesChanged,
  });

  @override
  State<_CompleteTaskSheet> createState() => _CompleteTaskSheetState();
}

class _CompleteTaskSheetState extends State<_CompleteTaskSheet> {
  static const Color _accent   = Color(0xFF2D6A4F);
  static const Color _primary  = Color(0xFF1B4332);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub  = Color(0xFF64748B);
  static const Color _red      = Color(0xFFEF4444);

  final TextEditingController _notesCtrl = TextEditingController();
  late final VoiceService _voice;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voice = context.read<VoiceService>();
  }

  @override
  void dispose() {
    // Always stop mic when sheet closes (e.g. swipe-dismiss).
    if (_isListening) {
      _voice.stopListening();
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── toggle dictation ───────────────────────────────────────────────────

  Future<void> _toggleMic() async {
    if (_isListening) {
      // Stop — finalize whatever was recognized so far.
      await _voice.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voice.startListening(
        localeId: 'mr_IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onResultPartial: (text) {
          // Show live transcription in the field as the user speaks.
          if (mounted) {
            setState(() {
              _notesCtrl.text = text;
              _notesCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: text.length),
              );
            });
            widget.onNotesChanged(text.trim().isEmpty ? null : text.trim());
          }
        },
        onResultFinalized: (text) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _notesCtrl.text = text;
              _notesCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: text.length),
              );
            });
            widget.onNotesChanged(text.trim().isEmpty ? null : text.trim());
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // ── Title ────────────────────────────────────────────────────
            Text(
              'Mark as Completed',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.task.foodItemName,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: _textSub,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 18.h),

            // ── Notes label + mic toggle ─────────────────────────────────
            Row(
              children: [
                Text(
                  'Notes',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _textMain,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(optional)',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    color: _textSub,
                  ),
                ),
                const Spacer(),
                // Live listening badge when active
                if (_isListening) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: _red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 7.w,
                          height: 7.w,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Listening…',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: _red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                // Mic toggle button
                GestureDetector(
                  onTap: _toggleMic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? _red.withValues(alpha: 0.12)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isListening
                            ? _red.withValues(alpha: 0.4)
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isListening
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      size: 18.sp,
                      color: _isListening ? _red : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // ── Notes text field ─────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _isListening
                      ? _red.withValues(alpha: 0.5)
                      : Colors.grey.shade300,
                  width: _isListening ? 1.8 : 1.2,
                ),
                color: _isListening
                    ? _red.withValues(alpha: 0.03)
                    : const Color(0xFFFBF9F9),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                onChanged: (v) => widget.onNotesChanged(
                    v.trim().isEmpty ? null : v.trim()),
                style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp, color: _textMain),
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Speak now… (tap 🎤 to stop)'
                      : 'e.g. "Animal ate well" — or tap 🎤 to speak',
                  hintStyle: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: _isListening
                        ? _red.withValues(alpha: 0.5)
                        : _textSub,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  // Mic shortcut inside the field (right side)
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening
                          ? Icons.stop_circle_rounded
                          : Icons.mic_none_rounded,
                      color: _isListening ? _red : _textSub,
                      size: 20.sp,
                    ),
                    onPressed: _toggleMic,
                    tooltip: _isListening ? 'Stop dictation' : 'Dictate note',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Confirm button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  elevation: 2,
                  shadowColor: _primary.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  if (_isListening) _voice.stopListening();
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Confirm Completion',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // ── Cancel ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (_isListening) _voice.stopListening();
                  Navigator.pop(context, false);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    color: _textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
