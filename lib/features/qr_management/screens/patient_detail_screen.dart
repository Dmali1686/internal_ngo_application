import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/utils/logger.dart';
import '../../patient_registration/services/patient_api_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  const PatientDetailScreen({super.key, this.patient = const {}});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _patientData = {};
  bool _isLoading = false;
  final PatientApiService _apiService = PatientApiService();

  /// Returns true if the current user's role should see the Doctor Panel.
  /// Covers: Doctor (isDoctor flag), Admin, Super Admin, Medical HOD.
  bool get _canAccessDoctorPanel {
    final auth = AuthStorageService();
    // Doctor flag (set from name or backend role auto-detection)
    if (auth.isDoctor) return true;
    // Login-selected role check (Admin / Super Admin)
    final loginRole = auth.role?.toLowerCase() ?? '';
    if (loginRole == 'admin' ||
        loginRole == 'super admin' ||
        loginRole == 'superadmin') return true;
    // Backend position title check — covers Medical HOD, Veterinarian etc.
    // (set from /auth/me profile after login, covers employees with privileged positions)
    final position = auth.positionTitle?.toLowerCase() ?? '';
    return position.contains('hod') ||
        position.contains('medical') ||
        position.contains('doctor') ||
        position.contains('dr.') ||
        position.contains('veterinar') ||
        position.contains('admin') ||
        position.contains('head of department');
  }

  @override
  void initState() {
    super.initState();
    _patientData = Map.from(widget.patient);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    // Safely extract patient UUID — may be stored as 'id' or 'patient_id'
    final rawId = _patientData['id'] ?? _patientData['patient_id'];
    final patientId = rawId?.toString().trim() ?? '';
    if (patientId.isEmpty) {
      AppLogger.error('PatientDetailScreen', 'No patient ID found in patientData: $_patientData');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getPatientById(patientId);
      if (response.success && response.data != null) {
        print('========== PATIENT DETAILS RESPONSE FROM BACKEND ==========');
        print(response.data);
        print('=========================================================');
        // Backend may wrap data in a 'data' key
        final raw = response.data;
        final Map<String, dynamic> fetched =
            (raw is Map<String, dynamic> && raw.containsKey('data') && raw['data'] is Map<String, dynamic>)
                ? raw['data'] as Map<String, dynamic>
                : (raw is Map<String, dynamic> ? raw : _patientData);
        setState(() {
          _patientData = fetched;
        });
      }
    } catch (e) {
      AppLogger.error('PatientDetailScreen', 'Error fetching patient: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar with gradient header
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF2E8B57),
            leading: Padding(
              padding: EdgeInsets.all(8.w),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_2, color: Colors.white),
                    onPressed: () => _showQrModal(context),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B6B3A),
                      Color(0xFF2E8B57),
                      Color(0xFF34A853),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
                    child: Column(
                      children: [
                        // Patient avatar & core info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar with status ring
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5.w,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40.r,
                                backgroundImage: const NetworkImage(
                                  'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _patientData['animal_name']?.isNotEmpty == true 
                                              ? _patientData['animal_name'] 
                                              : (_patientData['animal_type'] ?? 'Unknown'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (_isLoading)
                                        Padding(
                                          padding: EdgeInsets.only(left: 10.w),
                                          child: SizedBox(
                                            width: 16.w,
                                            height: 16.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: 10.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.healing,
                                              size: 13.sp,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              (_patientData['status']?.toString().toUpperCase() ?? 'ADMITTED'),
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${_patientData['animal_type'] ?? 'Unknown Type'}  •  ${_patientData['gender'] ?? 'Unknown'}  •  ${_patientData['age'] ?? 'Unknown Age'}',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 13.sp,
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Quick info chips
                        Row(
                          children: [
                            _buildChip(Icons.tag, _patientData['case_id']?.toString() ?? 'No Case ID'),
                            SizedBox(width: 10.w),
                            _buildChip(Icons.meeting_room, _patientData['cage_number']?.toString() ?? 'Unassigned'),
                            SizedBox(width: 10.w),
                            _buildChip(Icons.calendar_today, _getDaysAdmitted(_patientData['admission_date'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Status Banner
                      _buildStatusBanner(),
                      SizedBox(height: 16.h),

                      // Doctor Panel Button - Visible for Doctors, Admins, Super Admins & Medical HOD
                      if (_canAccessDoctorPanel) ...[
                        InkWell(
                          onTap: () => context.push('/doctor-panel', extra: _patientData),
                          borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF3B82F6),
                                const Color(0xFF2563EB),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Doctor Panel',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Manage treatment, diet & tasks',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 13.sp,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.8),
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ],
                      SizedBox(height: 24.h),

                      // Section Title
                      Text(
                        'Update Modules',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap a module to view or add updates',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Module Cards Grid
                      _buildModuleCard(
                        icon: Icons.medical_services_outlined,
                        title: 'Medical Updates',
                        subtitle: 'Treatments, medicines & vitals',
                        color: const Color(0xFF3B82F6),
                        latestUpdate: 'Post-op checkup completed',
                        time: 'Today, 09:30 AM',
                        badge: '2 Pending',
                        badgeColor: const Color(0xFFEF4444),
                        onTap: () => context.push('/treatment-timeline'),
                      ),
                      SizedBox(height: 12.h),

                      _buildModuleCard(
                        icon: Icons.restaurant_outlined,
                        title: 'Food Updates',
                        subtitle: 'Diet plans, feeding log & nutrition',
                        color: const Color(0xFFF59E0B),
                        latestUpdate: 'Morning feed: 200g chicken & rice',
                        time: 'Today, 08:00 AM',
                        badge: 'On Schedule',
                        badgeColor: const Color(0xFF34A853),
                        onTap: () {
                          final patientId = _patientData['id']?.toString() ?? _patientData['patient_id']?.toString() ?? '';
                          final patientName = _patientData['animal_name']?.toString();
                          final animalType = _patientData['animal_type']?.toString();
                          
                          context.push(
                            '/diet-history',
                            extra: {
                              'patientId': patientId,
                              'patientName': patientName,
                              'animalType': animalType,
                            },
                          );
                        },
                      ),
                      SizedBox(height: 12.h),

                      _buildModuleCard(
                        icon: Icons.history_outlined,
                        title: 'Patient History',
                        subtitle: 'Recovery timeline & past records',
                        color: const Color(0xFF8B5CF6),
                        latestUpdate: 'Orthopedic surgery — successful',
                        time: 'Yesterday, 14:00 PM',
                        badge: '5 Records',
                        badgeColor: const Color(0xFF8B5CF6),
                        onTap: () => context.push(
                          '/animal-overview',
                          extra: Map<String, dynamic>.from(_patientData),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Recent Activity Timeline
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      _buildActivityItem(
                        icon: Icons.medical_services,
                        color: const Color(0xFF3B82F6),
                        title: 'Post-Op Checkup',
                        subtitle: 'Wound healing well. Temperature normal.',
                        time: 'Today, 09:30 AM',
                        isFirst: true,
                      ),
                      _buildActivityItem(
                        icon: Icons.restaurant,
                        color: const Color(0xFFF59E0B),
                        title: 'Morning Feed',
                        subtitle: 'Ate 200g chicken & rice. Appetite good.',
                        time: 'Today, 08:00 AM',
                      ),
                      _buildActivityItem(
                        icon: Icons.cleaning_services,
                        color: const Color(0xFF14B8A6),
                        title: 'Cage Cleaning',
                        subtitle:
                            'Full cage disinfection. Fresh bedding placed.',
                        time: 'Today, 07:15 AM',
                      ),
                      _buildActivityItem(
                        icon: Icons.healing,
                        color: const Color(0xFF8B5CF6),
                        title: 'Recovery Update',
                        subtitle:
                            'Patient responding well. Mobility improving.',
                        time: 'Yesterday, 18:00 PM',
                        isLast: true,
                      ),

                      SizedBox(height: 80.h), // bottom spacing
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Quick Action FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionSheet(context),
        backgroundColor: const Color(0xFF2E8B57),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Quick Update',
          style: GoogleFonts.nunitoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── Widgets ────────────────────────────

  String _getDaysAdmitted(String? admissionDate) {
    if (admissionDate == null || admissionDate.isEmpty) return 'Day 1';
    try {
      final date = DateTime.parse(admissionDate);
      final difference = DateTime.now().difference(date).inDays;
      return 'Day ${difference + 1}';
    } catch (e) {
      return 'Day 1';
    }
  }

  Widget _buildChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: Colors.white70),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF34A853).withOpacity(0.08),
            const Color(0xFF34A853).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF34A853).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF34A853).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 22.sp,
              color: const Color(0xFF2E8B57),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient is Stable',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B6B3A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Last checked by Dr. Sarah — Today, 09:30 AM',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: const Color(0xFF34A853), size: 28.sp),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String latestUpdate,
    required String time,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, size: 24.sp, color: color),
                ),
                SizedBox(width: 14.w),
                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Latest update row
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGray,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.update, size: 16.sp, color: AppColors.textMuted),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      latestUpdate,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    time,
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

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 36.w,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(width: 2.w, color: Colors.grey[300]),
                  ),
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 3.w,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2.w, color: Colors.grey[300]),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Content card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(icon, size: 16.sp, color: color),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                      height: 1.4,
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

  // ──────────────────────────── Modals ────────────────────────────

  void _showQrModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'Bella\'s QR',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to access patient record',
              style: GoogleFonts.nunitoSans(color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2.w),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.qr_code_2,
                size: 100.w,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Quick Update',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select a category to add an update',
              style: GoogleFonts.nunitoSans(
                fontSize: 13.sp,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildQuickAction(
                  icon: Icons.medical_services_outlined,
                  label: 'Medical',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/treatment-timeline');
                  },
                ),
                SizedBox(width: 12.w),
                _buildQuickAction(
                  icon: Icons.restaurant_outlined,
                  label: 'Food',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/diet-dashboard');
                  },
                ),
                SizedBox(width: 12.w),
                _buildQuickAction(
                  icon: Icons.cleaning_services_outlined,
                  label: 'Cleaning',
                  color: const Color(0xFF14B8A6),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/cleaning-dashboard');
                  },
                ),
                SizedBox(width: 12.w),
                _buildQuickAction(
                  icon: Icons.note_add_outlined,
                  label: 'Note',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/record-voice-note');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24.sp, color: color),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
