import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/department_org_model.dart';
import '../providers/department_org_provider.dart';

/// Full-screen Team Members / Org-chart view for a department.
///
/// Launched from [DepartmentDetailScreen] when the user taps "View All".
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => DepartmentOrgScreen(
///       departmentId: department.id,
///       departmentName: department.name,
///       accentColor: color,
///     ),
///   ),
/// );
/// ```
class DepartmentOrgScreen extends StatefulWidget {
  final String departmentId;
  final String departmentName;
  final Color accentColor;

  const DepartmentOrgScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
    required this.accentColor,
  });

  @override
  State<DepartmentOrgScreen> createState() => _DepartmentOrgScreenState();
}

class _DepartmentOrgScreenState extends State<DepartmentOrgScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Trigger load after first frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentOrgProvider>().load(widget.departmentId);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepartmentOrgProvider>();

    // Start fade-in once data arrives
    if (provider.hasData && _fadeCtrl.status == AnimationStatus.dismissed) {
      _fadeCtrl.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar ───────────────────────────────────────────────
          _buildAppBar(context),

          // ── Search bar ───────────────────────────────────────────────────
          if (provider.hasData)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: _buildSearchBar(),
              ),
            ),

          // ── Body ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildBody(provider),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130.h,
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.w,
            color: AppColors.textMain,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Members',
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            Text(
              widget.departmentName,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accentColor.withOpacity(0.08),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer<DepartmentOrgProvider>(
          builder: (_, p, __) => IconButton(
            onPressed: p.isLoading
                ? null
                : () => p.refresh(widget.departmentId),
            icon: Icon(
              Icons.refresh_rounded,
              size: 20.w,
              color: p.isLoading ? AppColors.textMuted : widget.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
        style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: 'Search by name or position…',
          hintStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.w,
            color: AppColors.textMuted,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.w,
                    color: AppColors.textMuted,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
        ),
      ),
    );
  }

  // ── Body router ───────────────────────────────────────────────────────────

  Widget _buildBody(DepartmentOrgProvider provider) {
    if (provider.isLoading) return _buildLoader();
    if (provider.error != null) return _buildError(provider);
    if (!provider.hasData) return const SizedBox.shrink();

    final data = provider.data!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        child: _buildContent(data),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.only(top: 80.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: widget.accentColor,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading team…',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(DepartmentOrgProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 36.w,
              color: AppColors.dangerRed,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Unable to load team',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            onPressed: () => provider.refresh(widget.departmentId),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Try Again',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent(DepartmentOrganizationResponse data) {
    final filtered = _searchQuery.isEmpty
        ? data.allMembers
        : data.allMembers.where((e) {
            return e.fullName.toLowerCase().contains(_searchQuery) ||
                e.positionName.toLowerCase().contains(_searchQuery) ||
                e.email.toLowerCase().contains(_searchQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary strip ─────────────────────────────────────────────────
        _buildSummaryStrip(data),
        SizedBox(height: 24.h),

        // ── HOD Card (only when no filter applied) ───────────────────────
        if (data.hod != null && _searchQuery.isEmpty) ...[
          _sectionLabel('Head of Department'),
          SizedBox(height: 10.h),
          _HodCard(hod: data.hod!, accent: widget.accentColor),
          SizedBox(height: 24.h),
        ],

        // ── Team Members list ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel(
              _searchQuery.isEmpty ? 'All Members' : 'Search Results',
            ),
            if (filtered.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${filtered.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),

        if (filtered.isEmpty)
          _buildEmptySearch()
        else
          ...filtered.asMap().entries.map((entry) {
            final index = entry.key;
            final employee = entry.value;
            final isHod = data.hod != null && employee.userId == data.hod!.userId;
            return _MemberCard(
              employee: employee,
              isHod: isHod,
              accent: widget.accentColor,
              index: index,
            );
          }),
      ],
    );
  }

  // ── Summary strip ─────────────────────────────────────────────────────────

  Widget _buildSummaryStrip(DepartmentOrganizationResponse data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.accentColor, widget.accentColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.28),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StripStat(
            icon: Icons.people_rounded,
            label: 'Total',
            value: '${data.totalEmployees}',
          ),
          _StripDivider(),
          _StripStat(
            icon: Icons.star_rounded,
            label: 'HOD',
            value: data.hod != null ? '1' : '—',
          ),
          _StripDivider(),
          _StripStat(
            icon: Icons.group_rounded,
            label: 'Members',
            value: '${data.employees.length}',
          ),
          _StripDivider(),
          _StripStat(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Other',
            value: '${data.remainingEmployees.length}',
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 40.w, color: AppColors.textMuted),
            SizedBox(height: 12.h),
            Text(
              'No members found for "$_searchQuery"',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOD Card
// ─────────────────────────────────────────────────────────────────────────────

class _HodCard extends StatelessWidget {
  final OrgEmployee hod;
  final Color accent;
  const _HodCard({required this.hod, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.10),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with HOD crown badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.30),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    hod.initials,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -6.h,
                right: -4.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 10.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hod.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'HOD',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  hod.positionName,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        size: 12.w, color: AppColors.textMuted),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        hod.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hod.tags.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _TagRow(tags: hod.tags, accent: accent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member Card
// ─────────────────────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final OrgEmployee employee;
  final bool isHod;
  final Color accent;
  final int index;

  const _MemberCard({
    required this.employee,
    required this.isHod,
    required this.accent,
    required this.index,
  });

  /// Light pastel colours for avatar backgrounds when not HOD
  Color get _avatarBg {
    const palette = [
      Color(0xFFDDEAFF),
      Color(0xFFDCFCE7),
      Color(0xFFFEF3C7),
      Color(0xFFFCE7F3),
      Color(0xFFEDE9FE),
      Color(0xFFFFEDD5),
    ];
    return palette[index % palette.length];
  }

  Color get _avatarFg {
    const palette = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: isHod ? accent.withOpacity(0.12) : _avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                employee.initials,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isHod ? accent : _avatarFg,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        employee.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    if (isHod) ...[
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          'HOD',
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  employee.positionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                if (employee.tags.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  _TagRow(tags: employee.tags, accent: accent, compact: true),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Employee code badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  employee.employeeCode.isNotEmpty
                      ? employee.employeeCode
                      : '—',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Icon(Icons.chevron_right_rounded,
                  size: 18.w, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag Row
// ─────────────────────────────────────────────────────────────────────────────

class _TagRow extends StatelessWidget {
  final List<String> tags;
  final Color accent;
  final bool compact;

  const _TagRow({
    required this.tags,
    required this.accent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayed = compact ? tags.take(2).toList() : tags;
    return Wrap(
      spacing: 5.w,
      runSpacing: 4.h,
      children: [
        ...displayed.map(
          (tag) => Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ),
        if (compact && tags.length > 2)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '+${tags.length - 2}',
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary strip helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StripStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StripStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: Colors.white.withOpacity(0.85)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}

class _StripDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withOpacity(0.20),
    );
  }
}
