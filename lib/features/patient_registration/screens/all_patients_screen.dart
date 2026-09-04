import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../core/theme/app_colors.dart';
import '../models/patient_registration_model.dart';
import '../providers/patient_list_provider.dart';

/// Full-screen patient list with search, filters, and infinite scroll.
class AllPatientsScreen extends StatefulWidget {
  final bool showBackButton;
  const AllPatientsScreen({super.key, this.showBackButton = true});

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _fadeCtrl;
  Timer? _searchDebounce;  // 400 ms debounce for search

  // Filter bottom-sheet state (local copies shown in the sheet)
  String? _sheetStatus;
  String? _sheetAnimalType;
  String? _sheetGender;

  static const List<String> _statuses = [
    'ADMITTED',
    'UNDER_TREATMENT',
    'READY_FOR_RELEASE',
    'RELEASED',
    'ADOPTED',
    'DECEASED',
  ];

  static const Map<String, String> _statusLabels = {
    'ADMITTED': 'Admitted',
    'UNDER_TREATMENT': 'Under Treatment',
    'READY_FOR_RELEASE': 'Ready for Release',
    'RELEASED': 'Released',
    'ADOPTED': 'Adopted',
    'DECEASED': 'Deceased',
  };

  // ── Animal types — MUST match backend stored values (title case) ──────────
  static const List<String> _animalTypes = [
    'Dog', 'Cat', 'Cow', 'Bird', 'Monkey', 'Other',
  ];

  static const List<String> _genders = ['MALE', 'FEMALE', 'UNKNOWN'];

  // Status → color mapping (keys are exact backend values)
  static const Map<String, Color> _statusColors = {
    'ADMITTED': Color(0xFF2563EB),
    'UNDER_TREATMENT': Color(0xFFF59E0B),
    'READY_FOR_RELEASE': Color(0xFF10B981),
    'RELEASED': Color(0xFF6366F1),
    'ADOPTED': Color(0xFF34A853),
    'DECEASED': Color(0xFF9CA3AF),
  };

  // Animal type → icon mapping — keys match backend title-case values
  static const Map<String, IconData> _animalIcons = {
    'Dog': Icons.pets,
    'Cat': Icons.cruelty_free,
    'Cow': Icons.agriculture,
    'Bird': Icons.flutter_dash,
    'Monkey': Icons.emoji_nature,
  };

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    )..forward();

    _scrollCtrl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientListProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<PatientListProvider>().loadMore();
    }
  }

  // Debounced search — waits 400 ms after the user stops typing
  void _onSearchChanged(String val) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<PatientListProvider>().setSearch(val.trim());
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    context.read<PatientListProvider>().setSearch('');
  }

  // ── Filter sheet ──────────────────────────────────────────────────────────
  void _openFilterSheet() {
    final prov = context.read<PatientListProvider>();
    _sheetStatus = prov.status;
    _sheetAnimalType = prov.animalType;
    _sheetGender = prov.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FilterSheet(
        initialStatus: _sheetStatus,
        initialAnimalType: _sheetAnimalType,
        initialGender: _sheetGender,
        statuses: _statuses,
        statusLabels: _statusLabels,
        animalTypes: _animalTypes,
        genders: _genders,
        onApply: (status, animalType, gender) async {
          Navigator.pop(ctx);
          final p = context.read<PatientListProvider>();
          await p.setStatus(status);
          await p.setAnimalType(animalType);
          await p.setGender(gender);
        },
        onClear: () async {
          Navigator.pop(ctx);
          await context.read<PatientListProvider>().clearFilters();
          _searchCtrl.clear();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PatientListProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard-transition');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: FadeTransition(
        opacity: _fadeCtrl,
        child: Column(
          children: [
            _buildHeader(prov),
            _buildSearchBar(prov),
            _buildFilterChips(prov),
            _buildCountBanner(prov),
            Expanded(child: _buildList(prov)),
          ],
        ),
      ),
    ),);
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(PatientListProvider prov) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF34A853)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      child: Row(
        children: [
          if (widget.showBackButton)
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard-transition');
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18.w),
              ),
            ),
          if (widget.showBackButton) SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Registered Animals',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (!prov.isLoading)
                Text(
                  '${prov.total} patients in total',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Filter button
          GestureDetector(
            onTap: _openFilterSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20.w),
                ),
                if (prov.hasActiveFilters)
                  Positioned(
                    right: -3.w,
                    top: -3.h,
                    child: Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBC05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(PatientListProvider prov) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          style: GoogleFonts.nunitoSans(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText:
                'Search by name, case ID, or reporter...',
            hintStyle: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppColors.primaryGreen, size: 22.w),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: _clearSearch,
                    child: Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 20.w),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    );
  }

  // ── Active filter chips ────────────────────────────────────────────────────
  Widget _buildFilterChips(PatientListProvider prov) {
    final chips = <Widget>[];

    void addChip(String label, VoidCallback onRemove) {
      chips.add(_FilterChip(label: label, onRemove: onRemove));
    }

    if (prov.status != null) {
      addChip(
        _statusLabels[prov.status!] ?? prov.status!,
        () => prov.setStatus(null),
      );
    }
    if (prov.animalType != null) {
      addChip(prov.animalType!, () => prov.setAnimalType(null));
    }
    if (prov.gender != null) {
      addChip(
        prov.gender!,
        () => prov.setGender(null),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips,
            TextButton.icon(
              onPressed: prov.clearFilters,
              icon: Icon(Icons.close, size: 14.w, color: AppColors.warningRed),
              label: Text(
                'Clear all',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  color: AppColors.warningRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Result count banner ───────────────────────────────────────────────────
  Widget _buildCountBanner(PatientListProvider prov) {
    if (prov.isLoading || prov.patients.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
      child: Row(
        children: [
          Text(
            'Showing ${prov.patients.length} of ${prov.total}',
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Patient list ──────────────────────────────────────────────────────────
  Widget _buildList(PatientListProvider prov) {
    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (prov.error != null && prov.patients.isEmpty) {
      return _buildError(prov);
    }

    if (prov.patients.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: prov.loadPatients,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: prov.patients.length + (prov.isLoadingMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == prov.patients.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            );
          }
          return _PatientCard(
            patient: prov.patients[i],
            statusColor: _statusColors[prov.patients[i].status] ??
                AppColors.primaryGreen,
            statusLabel:
                _statusLabels[prov.patients[i].status] ?? prov.patients[i].status,
            animalIcon: _animalIcons[prov.patients[i].animalType] ?? Icons.pets,
            onTap: () {
              context.push('/patient-detail',
                  extra: prov.patients[i].toMap());
            },
          );
        },
      ),
    );
  }

  Widget _buildError(PatientListProvider prov) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 56.w, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text(
            'Failed to load patients',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            prov.error ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: prov.loadPatients,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64.w, color: AppColors.textMuted),
          SizedBox(height: 14.h),
          Text(
            'No patients found',
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try adjusting your filters or search term.',
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Card
// ─────────────────────────────────────────────────────────────────────────────

class _PatientCard extends StatefulWidget {
  final PatientModel patient;
  final Color statusColor;
  final String statusLabel;
  final IconData animalIcon;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.statusColor,
    required this.statusLabel,
    required this.animalIcon,
    required this.onTap,
  });

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final displayName =
        (p.animalName != null && p.animalName!.isNotEmpty)
            ? p.animalName!
            : p.animalType;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) => _scaleCtrl.forward(),
      onTapCancel: () => _scaleCtrl.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Top row ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal avatar — front photo as DP, icon fallback
                    _AnimalAvatar(
                      imageUrl: widget.patient.frontImageUrl,
                      icon: widget.animalIcon,
                      color: widget.statusColor,
                    ),
                    SizedBox(width: 12.w),
                    // Name + case ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.tag_rounded,
                                  size: 12.w, color: AppColors.textMuted),
                              SizedBox(width: 3.w),
                              Text(
                                p.caseId,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: widget.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        widget.statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: widget.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Divider ────────────────────────────────────────────────
              Divider(height: 1.h, color: Colors.grey.withOpacity(0.10)),
              // ── Bottom metadata row ────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
                child: Row(
                  children: [
                    _MetaChip(
                      icon: Icons.pets_rounded,
                      label: p.animalType,
                    ),
                    SizedBox(width: 8.w),
                    if (p.gender != null && p.gender!.isNotEmpty)
                      _MetaChip(
                        icon: p.gender == 'MALE'
                            ? Icons.male_rounded
                            : p.gender == 'FEMALE'
                                ? Icons.female_rounded
                                : Icons.help_outline_rounded,
                        label: p.gender!,
                      ),
                    SizedBox(width: 8.w),
                    if (p.cageNumber != null && p.cageNumber!.isNotEmpty)
                      _MetaChip(
                        icon: Icons.grid_view_rounded,
                        label: 'Cage ${p.cageNumber}',
                      ),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded,
                        size: 11.w, color: AppColors.textMuted),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(p.admissionDate),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small metadata chip (icon + text)
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.w, color: AppColors.textMuted),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 10.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active filter chip pill ─────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11.sp,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14.w, color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialAnimalType;
  final String? initialGender;
  final List<String> statuses;
  final Map<String, String> statusLabels;
  final List<String> animalTypes;
  final List<String> genders;
  final void Function(String? status, String? animalType, String? gender)
      onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.initialStatus,
    required this.initialAnimalType,
    required this.initialGender,
    required this.statuses,
    required this.statusLabels,
    required this.animalTypes,
    required this.genders,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _status;
  late String? _animalType;
  late String? _gender;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _animalType = widget.initialAnimalType;
    _gender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 18.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Text(
              'Filters',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 18.h),
            // ── Status ─────────────────────────────────────────────────
            _sectionLabel('Status'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.statuses.map((s) {
                final selected = _status == s;
                return GestureDetector(
                  onTap: () => setState(
                      () => _status = selected ? null : s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryGreen
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      widget.statusLabels[s] ?? s,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            // ── Animal type ────────────────────────────────────────────
            _sectionLabel('Animal Type'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.animalTypes.map((t) {
                final selected = _animalType == t;
                return GestureDetector(
                  onTap: () => setState(
                      () => _animalType = selected ? null : t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryGreen
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            // ── Gender ─────────────────────────────────────────────────
            _sectionLabel('Gender'),
            SizedBox(height: 8.h),
            Row(
              children: widget.genders.map((g) {
                final selected = _gender == g;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _gender = selected ? null : g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryGreen
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        g,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 28.h),
            // ── Action buttons ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClear,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onApply(_status, _animalType, _gender),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animal Avatar — shows front_image from S3, falls back to icon
// ─────────────────────────────────────────────────────────────────────────────

class _AnimalAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData icon;
  final Color color;

  const _AnimalAvatar({
    required this.imageUrl,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _iconFallback(),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            : _iconFallback(),
      ),
    );
  }

  Widget _iconFallback() {
    return Icon(icon, color: color, size: 26.w);
  }
}
