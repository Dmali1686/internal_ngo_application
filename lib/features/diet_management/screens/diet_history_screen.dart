import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/diet_models.dart';
import '../providers/diet_provider.dart';

class DietHistoryScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;
  final String? animalType;

  const DietHistoryScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.animalType,
  });

  @override
  State<DietHistoryScreen> createState() => _DietHistoryScreenState();
}

class _DietHistoryScreenState extends State<DietHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load both: history and default plans (for food item picker)
      final provider = context.read<DietProvider>();
      provider.fetchDietHistory(widget.patientId);
      provider.fetchDefaultDietPlans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<DietProvider>(
        builder: (context, provider, _) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
              _buildSliverAppBar(provider),
            ],
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveDietTab(provider),
                      _buildAllHistoryTab(provider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAddDietFab(),
    );
  }

  // ─────────────────────── App Bar ───────────────────────

  Widget _buildSliverAppBar(DietProvider provider) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF065F46),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (!provider.isLoading)
          Container(
            margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu_rounded,
                    size: 14.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  '${provider.activeDiets.length} Active',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF065F46), Color(0xFF1E293B)],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -40.w,
              top: -30.h,
              child: Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              left: -20.w,
              bottom: 20.h,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 60.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.restaurant_menu_rounded,
                            size: 16.sp, color: Colors.white),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Diet Management',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.patientName ?? 'Patient',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (widget.animalType != null)
                    Text(
                      widget.animalType!,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── Tab Bar ───────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF065F46),
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: const Color(0xFF065F46),
        indicatorWeight: 3,
        labelStyle:
            GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Active Diets'),
          Tab(text: 'Full History'),
        ],
      ),
    );
  }

  // ─────────────────────── Tab: Active Diets ───────────────────────

  Widget _buildActiveDietTab(DietProvider provider) {
    if (provider.isLoading) return _buildLoader();
    if (provider.error != null) return _buildError(provider);
    if (provider.activeDiets.isEmpty) return _buildEmpty('No active diets found.');

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
      itemCount: provider.activeDiets.length,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (context, i) {
        final diet = provider.activeDiets[i];
        return _buildDietCard(diet, isHighlighted: true);
      },
    );
  }

  // ─────────────────────── Tab: Full History ───────────────────────

  Widget _buildAllHistoryTab(DietProvider provider) {
    if (provider.isLoading) return _buildLoader();
    if (provider.error != null) return _buildError(provider);
    if (provider.dietHistory.isEmpty)
      return _buildEmpty('No diet history available.');

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
      itemCount: provider.dietHistory.length,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (context, i) {
        final diet = provider.dietHistory[i];
        return _buildDietCard(diet, isHighlighted: false);
      },
    );
  }

  // ─────────────────────── Diet Card ───────────────────────

  Widget _buildDietCard(PatientDiet diet, {required bool isHighlighted}) {
    final isActive = diet.isActive;
    final isDefault = diet.isDefault;
    final isAdditional = diet.isAdditional;

    // Color scheme by source
    final sourceColor = isDefault
        ? const Color(0xFF065F46)
        : isAdditional
            ? const Color(0xFF3B82F6)
            : const Color(0xFF8B5CF6);

    final sourceLabel = isDefault
        ? 'DEFAULT'
        : isAdditional
            ? 'ADDITIONAL'
            : diet.dietSource ?? 'UNKNOWN';

    final statusColor = isActive
        ? const Color(0xFF34A853)
        : diet.status?.toUpperCase() == 'CANCELLED'
            ? const Color(0xFFEF4444)
            : const Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isActive
            ? Border.all(
                color: sourceColor.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isActive
                ? sourceColor.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bar ──
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: sourceColor.withOpacity(0.06),
                border: Border(
                  bottom: BorderSide(
                      color: sourceColor.withOpacity(0.12), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: sourceColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      sourceLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: sourceColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          diet.status ?? '',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (diet.startDate != null)
                    Text(
                      _formatDate(diet.startDate!),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            // ── Food items list ──
            if (diet.items.isEmpty)
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Text(
                  'No food items recorded.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: diet.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < diet.items.length - 1 ? 10.h : 0),
                      child: _buildFoodItemRow(item, sourceColor),
                    );
                  }).toList(),
                ),
              ),

            // ── Footer: date range ──
            if (diet.endDate != null)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(
                        color: const Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 13.sp, color: AppColors.textMuted),
                    SizedBox(width: 6.w),
                    Text(
                      'Until ${_formatDate(diet.endDate!)}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemRow(PatientDietItem item, Color accentColor) {
    final name = item.foodItem?.name ?? 'Food Item';
    final unit = item.foodItem?.unit ?? '';
    final qty = item.quantity;
    final freq = DietFrequency.label(item.frequency ?? '');

    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.lunch_dining_rounded,
            size: 16.sp,
            color: accentColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$qty${unit.isNotEmpty ? ' $unit' : ''} • $freq',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                ),
              ),
              if (item.instructions != null &&
                  item.instructions!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  item.instructions!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    color: const Color(0xFF3B82F6),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────── FAB ───────────────────────

  Widget _buildAddDietFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        context.push(
          '/assign-diet',
          extra: {
            'patientId': widget.patientId,
            'patientName': widget.patientName,
          },
        );
      },
      backgroundColor: const Color(0xFF065F46),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Add Diet',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  // ─────────────────────── States ───────────────────────

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF065F46)),
    );
  }

  Widget _buildError(DietProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.sp, color: const Color(0xFFEF4444)),
            SizedBox(height: 16.h),
            Text(
              'Failed to load diet data',
              style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.error ?? '',
              style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                provider.fetchDietHistory(widget.patientId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant_menu_rounded,
                  size: 40.sp, color: const Color(0xFF065F46).withOpacity(0.5)),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap + Add Diet to get started.',
              style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── Helpers ───────────────────────

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
    }
  }
}
