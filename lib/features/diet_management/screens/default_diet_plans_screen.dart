import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/diet_models.dart';
import '../providers/diet_provider.dart';

/// Admin panel screen for viewing and creating default diet plan rules.
///
/// APIs:
///   GET  /api/v1/diet/default-plans
///   POST /api/v1/diet/default-plans
class DefaultDietPlansScreen extends StatefulWidget {
  const DefaultDietPlansScreen({super.key});

  @override
  State<DefaultDietPlansScreen> createState() =>
      _DefaultDietPlansScreenState();
}

class _DefaultDietPlansScreenState extends State<DefaultDietPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DietProvider>().fetchDefaultDietPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<DietProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(provider),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0F4C81)),
                  ),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                    child: _buildError(provider))
              else if (provider.defaultPlans.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildPlanCard(
                              provider.defaultPlans[i], i),
                        );
                      },
                      childCount: provider.defaultPlans.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ─────────────────────── App Bar ───────────────────────

  Widget _buildSliverAppBar(DietProvider provider) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F4C81),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
                Icon(Icons.rule_rounded, size: 14.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  '${provider.defaultPlans.length} Rules',
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
                  colors: [Color(0xFF0F4C81), Color(0xFF1E293B)],
                ),
              ),
            ),
            Positioned(
              right: -40.w,
              top: -20.h,
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
              left: 16.w,
              bottom: 55.h,
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
                        child: Icon(Icons.rule_folder_rounded,
                            size: 16.sp, color: Colors.white),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Default Diet Plans',
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
                    'Auto-assignment rules by animal type & weight',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.6),
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

  // ─────────────────────── Plan Card ───────────────────────

  Widget _buildPlanCard(DefaultDietPlan plan, int index) {
    final animalColors = {
      'DOG': const Color(0xFF3B82F6),
      'CAT': const Color(0xFF8B5CF6),
      'COW': const Color(0xFF065F46),
      'BUFFALO': const Color(0xFF0F4C81),
    };
    final color = animalColors[plan.animalType?.toUpperCase()] ??
        const Color(0xFF0F4C81);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
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
            // ── Header ──
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                border: Border(
                  bottom:
                      BorderSide(color: color.withOpacity(0.12), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      plan.animalType ?? 'UNKNOWN',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      plan.condition ?? '',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Priority ${plan.priority ?? index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Weight/Age/Temp range ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  if (plan.minWeight != null && plan.maxWeight != null)
                    _buildRangeChip(
                      Icons.scale_rounded,
                      '${plan.minWeight}–${plan.maxWeight} kg',
                      const Color(0xFF3B82F6),
                    ),
                  if (plan.minAgeMonths != null && plan.maxAgeMonths != null)
                    _buildRangeChip(
                      Icons.cake_rounded,
                      '${plan.minAgeMonths}–${plan.maxAgeMonths} mo',
                      const Color(0xFF8B5CF6),
                    ),
                  if (plan.minTemperature != null &&
                      plan.maxTemperature != null)
                    _buildRangeChip(
                      Icons.thermostat_rounded,
                      '${plan.minTemperature}–${plan.maxTemperature}°C',
                      const Color(0xFFEF4444),
                    ),
                ],
              ),
            ),

            // ── Food items ──
            if (plan.items.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Food Items (${plan.items.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...plan.items.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: i < plan.items.length - 1 ? 8.h : 0),
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.lunch_dining_rounded,
                                  size: 14.sp, color: color),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.foodItem?.name ?? 'Food Item',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}${item.foodItem?.unit != null ? ' ${item.foodItem!.unit}' : ''} • ${DietSlot.emoji(item.slot ?? '')} ${DietSlot.label(item.slot ?? '')}',
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
                      );
                    }),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'No food items configured.',
                  style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp, color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── FAB ───────────────────────

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreatePlanSheet(),
      backgroundColor: const Color(0xFF0F4C81),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'New Rule',
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  // ─────────────────────── Create Plan Bottom Sheet ───────────────────────

  void _showCreatePlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<DietProvider>(),
        child: const _CreatePlanSheet(),
      ),
    );
  }

  // ─────────────────────── States ───────────────────────

  Widget _buildError(DietProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48.sp, color: const Color(0xFFEF4444)),
            SizedBox(height: 16.h),
            Text('Failed to load plans',
                style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain)),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => provider.fetchDefaultDietPlans(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C81).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.rule_folder_rounded,
                  size: 40.sp,
                  color: const Color(0xFF0F4C81).withOpacity(0.4)),
            ),
            SizedBox(height: 16.h),
            Text('No default plans configured',
                style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain)),
            SizedBox(height: 8.h),
            Text('Tap + New Rule to create one.',
                style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Create Plan Sheet ───────────────────────

class _CreatePlanSheet extends StatefulWidget {
  const _CreatePlanSheet();

  @override
  State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _formKey = GlobalKey<FormState>();

  String _animalType = 'DOG';
  String _condition = 'NORMAL';
  final _minWeightCtrl = TextEditingController();
  final _maxWeightCtrl = TextEditingController();
  final _minAgeCtrl = TextEditingController();
  final _maxAgeCtrl = TextEditingController();
  final _minTempCtrl = TextEditingController();
  final _maxTempCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: '1');

  final List<_FoodItemRow> _foodRows = [_FoodItemRow()];

  final List<String> _animalTypes = ['DOG', 'CAT', 'COW', 'BUFFALO', 'OTHER'];
  final List<String> _conditions = ['NORMAL', 'FEVER', 'INJURY', 'RECOVERY'];

  @override
  void dispose() {
    _minWeightCtrl.dispose();
    _maxWeightCtrl.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _minTempCtrl.dispose();
    _maxTempCtrl.dispose();
    _priorityCtrl.dispose();
    for (final r in _foodRows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create Default Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: scrollCtrl,
                        padding: EdgeInsets.all(20.w),
                        children: [
                          _sheetRow(
                            'Animal Type *',
                            DropdownButtonFormField<String>(
                              value: _animalType,
                              items: _animalTypes
                                  .map((t) => DropdownMenuItem(
                                      value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _animalType = v!),
                              decoration: _sd('Animal Type'),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _sheetRow(
                            'Condition *',
                            DropdownButtonFormField<String>(
                              value: _condition,
                              items: _conditions
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _condition = v!),
                              decoration: _sd('Condition'),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(children: [
                            Expanded(
                                child: _tf('Min Weight (kg)',
                                    _minWeightCtrl)),
                            SizedBox(width: 10.w),
                            Expanded(
                                child: _tf('Max Weight (kg)',
                                    _maxWeightCtrl)),
                          ]),
                          SizedBox(height: 10.h),
                          Row(children: [
                            Expanded(
                                child:
                                    _tf('Min Age (mo)', _minAgeCtrl)),
                            SizedBox(width: 10.w),
                            Expanded(
                                child:
                                    _tf('Max Age (mo)', _maxAgeCtrl)),
                          ]),
                          SizedBox(height: 10.h),
                          Row(children: [
                            Expanded(
                                child: _tf('Min Temp (°C)', _minTempCtrl)),
                            SizedBox(width: 10.w),
                            Expanded(
                                child: _tf('Max Temp (°C)', _maxTempCtrl)),
                          ]),
                          SizedBox(height: 10.h),
                          _tf('Priority *', _priorityCtrl,
                              required: true),
                          SizedBox(height: 20.h),
                          Text(
                            'Food Items',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ..._foodRows
                              .asMap()
                              .entries
                              .map((e) => Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 10.h),
                                    child: _buildFoodRow(
                                        e.key, e.value),
                                  )),
                          TextButton.icon(
                            onPressed: () => setState(
                                () => _foodRows.add(_FoodItemRow())),
                            icon: const Icon(Icons.add_rounded,
                                color: Color(0xFF0F4C81)),
                            label: Text('Add item',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF0F4C81))),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: provider.isSubmitting
                                  ? null
                                  : () => _submit(provider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0F4C81),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14.r)),
                              ),
                              child: provider.isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Create Plan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFoodRow(int index, _FoodItemRow row) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Item ${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F4C81))),
              const Spacer(),
              if (_foodRows.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _foodRows.removeAt(index)),
                  child: Icon(Icons.close_rounded,
                      size: 16.sp, color: const Color(0xFFEF4444)),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          _tf('Food Item ID (UUID) *', row.foodItemIdCtrl,
              required: true),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _tf('Qty *', row.qtyCtrl, required: true)),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: row.slot,
                  items: DietSlot.all
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            '${DietSlot.emoji(s)} ${DietSlot.label(s)}',
                            style: TextStyle(fontSize: 12.sp),
                          )))
                      .toList(),
                  onChanged: (v) => setState(() => row.slot = v!),
                  decoration: _sd('Slot'),
                  style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: AppColors.textMain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetRow(String label, Widget child) {
    return child;
  }

  Widget _tf(String label, TextEditingController ctrl,
      {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.nunitoSans(
          fontSize: 13.sp, color: AppColors.textMain),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _sd(label),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }

  InputDecoration _sd(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
            fontSize: 11.sp, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:
              const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      );

  Future<void> _submit(DietProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final items = _foodRows.map((r) {
      return DefaultDietPlanItemRequest(
        foodItemId: r.foodItemIdCtrl.text.trim(),
        quantity: double.tryParse(r.qtyCtrl.text.trim()) ?? 0,
        slot: r.slot,
      );
    }).toList();

    final request = CreateDefaultDietPlanRequest(
      animalType: _animalType,
      condition: _condition,
      minWeight: double.tryParse(_minWeightCtrl.text),
      maxWeight: double.tryParse(_maxWeightCtrl.text),
      minAgeMonths: int.tryParse(_minAgeCtrl.text),
      maxAgeMonths: int.tryParse(_maxAgeCtrl.text),
      minTemperature: double.tryParse(_minTempCtrl.text),
      maxTemperature: double.tryParse(_maxTempCtrl.text),
      priority: int.tryParse(_priorityCtrl.text.trim()) ?? 1,
      items: items,
    );

    final success = await provider.createDefaultDietPlan(request);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Default plan created!',
            style: GoogleFonts.nunitoSans(color: Colors.white)),
        backgroundColor: const Color(0xFF34A853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Failed to create plan',
            style: GoogleFonts.nunitoSans(color: Colors.white)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
      ));
    }
  }
}

class _FoodItemRow {
  final foodItemIdCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  String slot = DietSlot.morning;

  void dispose() {
    foodItemIdCtrl.dispose();
    qtyCtrl.dispose();
  }
}
