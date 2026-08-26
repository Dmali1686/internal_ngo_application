import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/voice_service.dart';

class DoctorFoodScheduleScreen extends StatefulWidget {
  const DoctorFoodScheduleScreen({super.key});

  @override
  State<DoctorFoodScheduleScreen> createState() =>
      _DoctorFoodScheduleScreenState();
}

class _DoctorFoodScheduleScreenState extends State<DoctorFoodScheduleScreen> {
  String _selectedDietType = 'Post-Surgery Recovery';
  final List<String> _dietTypes = [
    'Normal Diet',
    'Post-Surgery Recovery',
    'High Protein',
    'Liquid Diet',
    'Renal Diet',
    'Custom',
  ];

  final List<_FoodSlotEditor> _slots = [
    _FoodSlotEditor(
      time: '08:00 AM',
      foodItems: 'Boiled chicken (200g) + Rice (100g)',
      instructions:
          'Give boiled chicken mixed with plain rice. Ensure the multivitamin tablet is crushed and mixed into the food.',
    ),
    _FoodSlotEditor(
      time: '12:30 PM',
      foodItems: 'Curd (150g) + Glucose water (200ml)',
      instructions:
          'Serve fresh curd at room temperature. Mix two spoons of glucose powder in lukewarm water.',
    ),
  ];

  final VoiceService _voiceService = VoiceService();
  int? _activeListeningIndex;

  @override
  void dispose() {
    for (var slot in _slots) {
      slot.dispose();
    }
    super.dispose();
  }

  void _toggleListening(int index) async {
    if (_activeListeningIndex == index) {
      await _voiceService.stopListening();
      setState(() => _activeListeningIndex = null);
    } else {
      if (_activeListeningIndex != null) {
        await _voiceService.stopListening();
      }
      setState(() => _activeListeningIndex = index);
      await _voiceService.startListening(
        onResultFinalized: (text) {
          setState(() {
            _slots[index].instructionController.text = text;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        title: Text(
          'Food Schedule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Food schedule updated successfully'),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
              context.pop();
            },
            icon: const Icon(Icons.check, color: Color(0xFF34A853)),
            label: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF34A853),
                fontSize: 15.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildDietTypeSelector(),
          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feeding Slots',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _slots.add(_FoodSlotEditor(time: 'Select Time'));
                  });
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: const Text('Add Slot'),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ...List.generate(_slots.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildSlotEditorCard(index),
            );
          }),

          SizedBox(height: 16.h),
          _buildSpecialInstructionsCard(),
          SizedBox(height: 32.h),

          // Main Save Button
          ElevatedButton.icon(
            onPressed: () {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All food schedule changes saved successfully'),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
            },
            icon: Icon(Icons.save, size: 20.sp, color: Colors.white),
            label: Text(
              'Save Full Schedule',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34A853),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  Widget _buildDietTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Diet Type',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDietType,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: _dietTypes.map((String diet) {
                return DropdownMenuItem<String>(
                  value: diet,
                  child: Text(
                    diet,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15.sp,
                      color: AppColors.textMain,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedDietType = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotEditorCard(int index) {
    final slot = _slots[index];
    final isListening = _activeListeningIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        slot.time = time.format(context);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18.sp,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        slot.time,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: const Color(0xFFEF4444),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _slots.removeAt(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Items',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: slot.foodController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Boiled chicken (200g) + Rice',
                    hintStyle: GoogleFonts.nunitoSans(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  style: GoogleFonts.nunitoSans(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Worker Instructions (Dictate)',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    InkWell(
                      onTap: () => _toggleListening(index),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isListening
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          size: 18.sp,
                          color: isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: slot.instructionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Speak or type instructions for the worker...',
                    hintStyle: GoogleFonts.nunitoSans(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1.5.w,
                      ),
                    ),
                  ),
                  style: GoogleFonts.nunitoSans(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Slot details saved'),
                          backgroundColor: Color(0xFF3B82F6),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.check,
                      size: 16.sp,
                      color: const Color(0xFF3B82F6),
                    ),
                    label: Text(
                      'Save Slot',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: 13.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
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

  Widget _buildSpecialInstructionsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Overall Special Instructions',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. No spicy or oily food. Keep water available.',
              hintStyle: GoogleFonts.nunitoSans(
                color: Colors.grey[400],
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: AppColors.backgroundLightGray,
            ),
            style: GoogleFonts.nunitoSans(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Special instructions saved'),
                    backgroundColor: Color(0xFF3B82F6),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                Icons.check,
                size: 16.sp,
                color: const Color(0xFF3B82F6),
              ),
              label: Text(
                'Save Instructions',
                style: TextStyle(
                  color: const Color(0xFF3B82F6),
                  fontSize: 13.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodSlotEditor {
  String time;
  final TextEditingController foodController;
  final TextEditingController instructionController;

  _FoodSlotEditor({
    required this.time,
    String foodItems = '',
    String instructions = '',
  }) : foodController = TextEditingController(text: foodItems),
       instructionController = TextEditingController(text: instructions);

  void dispose() {
    foodController.dispose();
    instructionController.dispose();
  }
}
