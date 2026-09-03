import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/diet_models.dart';
import '../providers/diet_provider.dart';
import '../../../core/services/voice_service.dart';

/// Screen for adding an ADDITIONAL diet to a patient.
/// Calls `POST /api/v1/patients/{id}/diet/additional`.
///
/// Food items are sourced from existing DefaultDietPlan items (Option A).
class AssignDietScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;

  const AssignDietScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<AssignDietScreen> createState() => _AssignDietScreenState();
}

class _AssignDietScreenState extends State<AssignDietScreen> {
  final _formKey = GlobalKey<FormState>();

  // Date controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Voice Service
  final VoiceService _voiceService = VoiceService();
  bool _isListeningDesc = false;

  // Diet item rows
  final List<_DietItemRow> _itemRows = [];

  @override
  void initState() {
    super.initState();
    // Default start date = today
    _startDate = DateTime.now();
    _startDateController.text = _formatDate(_startDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure default plans are loaded (for food item picker)
      final provider = context.read<DietProvider>();
      if (provider.defaultPlans.isEmpty && !provider.isLoading) {
        provider.fetchDefaultDietPlans();
      }
      // Add one empty row to start
      setState(() => _itemRows.add(_DietItemRow()));
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _toggleListeningDesc() async {
    if (_isListeningDesc) {
      await _voiceService.stopListening();
      if (mounted) setState(() => _isListeningDesc = false);
    } else {
      setState(() => _isListeningDesc = true);
      await _voiceService.startListening(
        onResultFinalized: (text) {
          if (mounted) {
            setState(() {
              _descriptionController.text = text;
            });
          }
        },
      );
    }
  }

  // ─────────────────────── Build ───────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: Consumer<DietProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                    children: [
                      _buildInfoBanner(),
                      SizedBox(height: 20.h),
                      _buildDateSection(),
                      SizedBox(height: 20.h),
                      _buildDescriptionSection(),
                      SizedBox(height: 20.h),
                      _buildFoodItemsSection(provider),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
                _buildSubmitBar(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────── App Bar ───────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF065F46),
      foregroundColor: Colors.white,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Additional Diet',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (widget.patientName != null)
            Text(
              widget.patientName!,
              style: GoogleFonts.nunitoSans(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────── Info Banner ───────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded,
                size: 16.sp, color: const Color(0xFF3B82F6)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'This will add a supplementary diet without replacing the patient\'s existing DEFAULT diet plan. Both will remain active.',
              style: GoogleFonts.nunitoSans(
                fontSize: 12.sp,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Date Section ───────────────────────

  Widget _buildDateSection() {
    return _buildCard(
      title: 'Diet Duration',
      icon: Icons.date_range_rounded,
      iconColor: const Color(0xFF065F46),
      child: Column(
        children: [
          _buildDateField(
            label: 'Start Date *',
            controller: _startDateController,
            onTap: () => _pickDate(isStart: true),
          ),
          SizedBox(height: 14.h),
          _buildDateField(
            label: 'End Date (optional)',
            controller: _endDateController,
            onTap: () => _pickDate(isStart: false),
            suffixIcon: _endDate != null
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 16.sp, color: AppColors.textMuted),
                    onPressed: () {
                      setState(() {
                        _endDate = null;
                        _endDateController.clear();
                      });
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Description Section ───────────────────────

  Widget _buildDescriptionSection() {
    return _buildCard(
      title: 'Diet Note (optional)',
      icon: Icons.sticky_note_2_outlined,
      iconColor: const Color(0xFF8B5CF6),
      action: IconButton(
        icon: Icon(
          _isListeningDesc ? Icons.mic : Icons.mic_none,
          color: _isListeningDesc
              ? const Color(0xFFEF4444)
              : const Color(0xFF8B5CF6),
        ),
        onPressed: _toggleListeningDesc,
        tooltip: 'Use Speech to Text',
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        style: GoogleFonts.nunitoSans(
            fontSize: 13.sp, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText:
              'e.g. Patient needs soft food due to teeth extraction…',
          hintStyle: GoogleFonts.nunitoSans(
              fontSize: 12.sp, color: AppColors.textMuted),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 40.h),
            child: Icon(Icons.notes_rounded,
                size: 16.sp, color: const Color(0xFF8B5CF6)),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.nunitoSans(
          fontSize: 14.sp,
          color: AppColors.textMain,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunitoSans(
            fontSize: 12.sp, color: AppColors.textMuted),
        prefixIcon: Icon(Icons.calendar_today_rounded,
            size: 16.sp, color: const Color(0xFF065F46)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF065F46), width: 1.5),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: (v) {
        if (label.contains('*') && (v == null || v.isEmpty)) {
          return 'Start date is required';
        }
        return null;
      },
    );
  }

  // ─────────────────────── Food Items Section ───────────────────────

  Widget _buildFoodItemsSection(DietProvider provider) {
    return _buildCard(
      title: 'Food Items',
      icon: Icons.lunch_dining_rounded,
      iconColor: const Color(0xFF3B82F6),
      child: Column(
        children: [
          if (provider.isLoading && provider.defaultPlans.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const CircularProgressIndicator(
                  color: Color(0xFF065F46)),
            )
          else ...[
            ...List.generate(_itemRows.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildItemRow(i, provider),
              );
            }),
            // Add Item button
            InkWell(
              onTap: () => setState(() => _itemRows.add(_DietItemRow())),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: const Color(0xFF3B82F6).withOpacity(0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 16.sp, color: const Color(0xFF3B82F6)),
                    SizedBox(width: 6.w),
                    Text(
                      'Add Another Item',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, DietProvider provider) {
    final row = _itemRows[index];
    final foodItems = provider.availableFoodItems;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Food Item ${index + 1}',
                style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain),
              ),
              const Spacer(),
              if (_itemRows.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: const Color(0xFFEF4444)),
                  onPressed: () =>
                      setState(() => _itemRows.removeAt(index)),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                      minWidth: 28.w, minHeight: 28.h),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          // Food item dropdown
          DropdownButtonFormField<String>(
            value: row.selectedFoodItemId,
            isExpanded: true,
            style: GoogleFonts.nunitoSans(
                fontSize: 13.sp, color: AppColors.textMain),
            decoration: _inputDecoration('Food Item *', Icons.fastfood_rounded),
            items: foodItems.isEmpty
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Text('No items available — load default plans',
                          style: GoogleFonts.nunitoSans(
                              fontSize: 12.sp,
                              color: AppColors.textMuted)),
                    )
                  ]
                : foodItems
                    .map((f) => DropdownMenuItem<String>(
                          value: f.id,
                          child: Text(
                            '${f.name}${f.unit != null ? ' (${f.unit})' : ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
            onChanged: (val) =>
                setState(() => row.selectedFoodItemId = val),
            validator: (v) =>
                v == null ? 'Please select a food item' : null,
          ),
          SizedBox(height: 10.h),

          // Quantity + Slot row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp, color: AppColors.textMain),
                  decoration:
                      _inputDecoration('Qty *', Icons.scale_rounded),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: row.selectedSlot,
                  isExpanded: true,
                  style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp, color: AppColors.textMain),
                  decoration: _inputDecoration(
                      'Slot *', Icons.wb_sunny_rounded),
                  items: DietSlot.all
                      .map((s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              '${DietSlot.emoji(s)} ${DietSlot.label(s)}',
                            ),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => row.selectedSlot = val),
                  validator: (v) =>
                      v == null ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Instructions
          TextFormField(
            controller: row.instructionController,
            maxLines: 2,
            style: GoogleFonts.nunitoSans(
                fontSize: 13.sp, color: AppColors.textMain),
            decoration: _inputDecoration(
              'Instructions (optional)',
              Icons.notes_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  row.isListening ? Icons.mic : Icons.mic_none,
                  color: row.isListening
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                ),
                onPressed: () async {
                  if (row.isListening) {
                    await _voiceService.stopListening();
                    if (mounted) setState(() => row.isListening = false);
                  } else {
                    setState(() => row.isListening = true);
                    await _voiceService.startListening(
                      onResultFinalized: (text) {
                        if (mounted) {
                          setState(() {
                            row.instructionController.text = text;
                          });
                        }
                      },
                    );
                  }
                },
                tooltip: 'Use Speech to Text',
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.nunitoSans(fontSize: 11.sp, color: AppColors.textMuted),
      prefixIcon:
          Icon(icon, size: 16.sp, color: const Color(0xFF065F46)),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: Color(0xFF065F46), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide:
            const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }

  // ─────────────────────── Submit Bar ───────────────────────

  Widget _buildSubmitBar(DietProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed:
                provider.isSubmitting ? null : () => _submit(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF065F46),
              disabledBackgroundColor:
                  const Color(0xFF065F46).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
            child: provider.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Submit Additional Diet',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Card Wrapper ───────────────────────

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: iconColor),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                if (action != null) action,
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE2E8F0)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: child,
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Actions ───────────────────────

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF065F46),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  Future<void> _submit(DietProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) return;

    // Validate each row has a food item and slot
    for (final row in _itemRows) {
      if (row.selectedFoodItemId == null) {
        _showSnack('Please select a food item for all rows', isError: true);
        return;
      }
      if (row.selectedSlot == null) {
        _showSnack('Please select a meal slot for all items', isError: true);
        return;
      }
    }

    final items = _itemRows.map((row) {
      return AdditionalDietItemRequest(
        foodItemId: row.selectedFoodItemId!,
        quantity: double.parse(row.quantityController.text.trim()),
        slot: row.selectedSlot!,
        instructions: row.instructionController.text.trim(),
      );
    }).toList();

    final request = CreateAdditionalDietRequest(
      startDate: _startDate!.toIso8601String().substring(0, 10),
      endDate: _endDate != null
          ? _endDate!.toIso8601String().substring(0, 10)
          : null,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      items: items,
    );

    final success =
        await provider.addAdditionalDiet(widget.patientId, request);

    if (!mounted) return;

    if (success) {
      _showSnack('Additional diet added successfully!');
      context.pop();
    } else {
      _showSnack(
          provider.error ?? 'Failed to add diet. Please try again.',
          isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunitoSans(color: Colors.white)),
      backgroundColor:
          isError ? const Color(0xFFEF4444) : const Color(0xFF34A853),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ));
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

// ─────────────────────── Data row model ───────────────────────

class _DietItemRow {
  String? selectedFoodItemId;
  String? selectedSlot = DietSlot.morning;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  bool isListening = false;

  void dispose() {
    quantityController.dispose();
    instructionController.dispose();
  }
}
