import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/dashboard_module_model.dart';
import '../../../../core/providers/dashboard_modules_provider.dart';

/// Dynamic dashboard grid that renders module cards fetched from the backend.
///
/// **Fallback**: if the API is unavailable (network error, server error, etc.)
/// the provider automatically provides ALL modules so the user always sees
/// a fully functional dashboard.
///
/// States handled:
///  - [isLoading]  → animated shimmer skeleton cards
///  - loaded        → dynamic cards from API (or fallback all-cards)
class ModulesGrid extends StatelessWidget {
  const ModulesGrid({super.key});

  // ---------------------------------------------------------------------------
  // Icon + color map — client-side only, keyed by module.key from the server.
  // The server controls WHICH modules appear; Flutter controls HOW they look.
  // ---------------------------------------------------------------------------
  static final Map<String, IconData> _iconMap = {
    'patient_registration': Icons.assignment_add,
    'qr_management': Icons.qr_code_scanner,
    'patient_history': Icons.history,
    'treatment_cycle': Icons.medical_services,
    'diet_management': Icons.restaurant,
    'ambulance': Icons.local_shipping,
    'employees': Icons.people,
    'voice_notes': Icons.mic,
    'settings': Icons.settings,
    'doctor_panel': Icons.medical_information,
    'cleaning': Icons.cleaning_services,
    'tasks': Icons.task_alt,
    'alerts': Icons.notifications_active,
    'role_management': Icons.admin_panel_settings_rounded,
    'admin_analytics': Icons.analytics_rounded,
  };

  static final Map<String, Color> _colorMap = {
    'patient_registration': const Color(0xFF34A853),
    'qr_management': const Color(0xFF34A853),
    'patient_history': const Color(0xFF8B5CF6),
    'treatment_cycle': const Color(0xFF3B82F6),
    'diet_management': const Color(0xFFF59E0B),
    'ambulance': const Color(0xFFEF4444),
    'employees': const Color(0xFF14B8A6),
    'voice_notes': const Color(0xFF3B82F6),
    'settings': const Color(0xFF64748B),
    'doctor_panel': const Color(0xFF6366F1),
    'cleaning': const Color(0xFF06B6D4),
    'tasks': const Color(0xFFF97316),
    'alerts': const Color(0xFFEC4899),
    'role_management': const Color(0xFF7C3AED),
    'admin_analytics': const Color(0xFF6366F1),
  };

  IconData _resolveIcon(String key) =>
      _iconMap[key] ?? Icons.dashboard_rounded;

  Color _resolveColor(String key) =>
      _colorMap[key] ?? const Color(0xFF34A853);

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardModulesProvider>(
      builder: (context, provider, _) {
        // ── Loading state — shimmer skeletons ──────────────────────────────
        if (provider.isLoading) {
          return _buildShimmerGrid();
        }

        // ── Loaded (API or automatic fallback to all cards) ────────────────
        return _buildModuleGrid(context, provider.modules);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Grid of real module cards
  // ---------------------------------------------------------------------------
  Widget _buildModuleGrid(
    BuildContext context,
    List<DashboardModuleModel> modules,
  ) {
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
          return _ModuleCard(
            module: module,
            icon: _resolveIcon(module.key),
            color: _resolveColor(module.key),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer skeleton grid — shown while the API call is in flight
  // ---------------------------------------------------------------------------
  Widget _buildShimmerGrid() {
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
        itemCount: 9, // show 9 placeholder cards
        itemBuilder: (context, _) => const _ShimmerCard(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single module card widget
// ---------------------------------------------------------------------------
class _ModuleCard extends StatefulWidget {
  final DashboardModuleModel module;
  final IconData icon;
  final Color color;

  const _ModuleCard({
    required this.module,
    required this.icon,
    required this.color,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.module.route != null) {
          context.push(widget.module.route!);
        }
      },
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon container ─────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(widget.icon, size: 28.w, color: widget.color),
              ),
              SizedBox(height: 8.h),
              // ── Title ──────────────────────────────────────────────────
              Text(
                widget.module.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 4.h),
              // ── Subtitle ───────────────────────────────────────────────
              Text(
                widget.module.subtitle,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated shimmer placeholder card
// ---------------------------------------------------------------------------
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon area placeholder
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 10.h),
                // Title placeholder
                Container(
                  height: 10.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                // Subtitle placeholder
                Container(
                  height: 8.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
