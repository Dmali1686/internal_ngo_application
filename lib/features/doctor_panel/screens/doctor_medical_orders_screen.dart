import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/text_to_speech_player.dart';
import '../../../core/services/voice_service.dart';

class DoctorMedicalOrdersScreen extends StatefulWidget {
  const DoctorMedicalOrdersScreen({super.key});

  @override
  State<DoctorMedicalOrdersScreen> createState() =>
      _DoctorMedicalOrdersScreenState();
}

class _DoctorMedicalOrdersScreenState extends State<DoctorMedicalOrdersScreen> {
  final TextEditingController _noteController = TextEditingController();
  String _selectedCondition = 'Recovery';
  final List<String> _conditions = [
    'Critical',
    'Stable',
    'Recovery',
    'Ready for Release',
  ];

  final List<Map<String, String>> _medicines = [
    {
      'name': 'Doxycycline 100mg',
      'details': '1 Tab • Morning, Night • After meal',
    },
    {'name': 'Prednisolone 5mg', 'details': '1/2 Tab • Morning • After meal'},
  ];

  final Map<String, String> _vitalsFreq = {
    'Temp': 'Twice daily',
    'Heart': 'Once daily',
    'Weight': 'Weekly',
  };

  final List<Map<String, String>> _pastNotes = [
    {
      'date': 'Yesterday, 10:00 AM',
      'doctor': 'Dr. Sarah',
      'note':
          'Swelling has reduced significantly. Wound is healing well. Changed bandage. Continue current antibiotics.',
    },
    {
      'date': 'Oct 24, 02:30 PM',
      'doctor': 'Dr. Sarah',
      'note':
          'Initial assessment post-surgery. Patient is stable but weak. Starting IV fluids and antibiotics.',
    },
  ];

  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voiceService.startListening(
        onResultFinalized: (text) {
          setState(() {
            _noteController.text = text;
          });
        },
        // We handle stopping externally, so we don't need onDone here, but if we did, we'd handle it.
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
          'Medical Orders',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Save logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medical orders updated successfully'),
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
          _buildConditionSelector(),
          SizedBox(height: 20.h),
          _buildMedicalNoteInput(),
          SizedBox(height: 20.h),
          _buildMedicinesSection(),
          SizedBox(height: 20.h),
          _buildVitalsSection(),
          SizedBox(height: 24.h),
          _buildPastTimeline(),
          SizedBox(height: 32.h),

          // Main Save Button
          ElevatedButton.icon(
            onPressed: () {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All medical orders saved successfully'),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
            },
            icon: Icon(Icons.save, size: 20.sp, color: Colors.white),
            label: Text(
              'Save Full Orders',
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

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Condition',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _conditions.map((condition) {
            final isSelected = _selectedCondition == condition;
            Color getConditionColor() {
              if (condition == 'Critical') return const Color(0xFFEF4444);
              if (condition == 'Stable') return const Color(0xFF3B82F6);
              if (condition == 'Recovery') return const Color(0xFFF59E0B);
              return const Color(0xFF34A853);
            }

            final cColor = getConditionColor();

            return InkWell(
              onTap: () => setState(() => _selectedCondition = condition),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? cColor.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? cColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_circle, color: cColor, size: 16.sp),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      condition,
                      style: GoogleFonts.nunitoSans(
                        color: isSelected ? cColor : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicalNoteInput() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Medical Note',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                ),
                onPressed: _toggleListening,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter observation, diagnosis or instructions...',
              hintStyle: GoogleFonts.nunitoSans(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 1.5.w,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundLightGray,
            ),
            style: GoogleFonts.nunitoSans(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_noteController.text.trim().isNotEmpty) {
                  setState(() {
                    final now = TimeOfDay.now();
                    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
                    final minute = now.minute.toString().padLeft(2, '0');
                    final period = now.period == DayPeriod.am ? 'AM' : 'PM';

                    _pastNotes.insert(0, {
                      'date': 'Today, $hour:$minute $period',
                      'doctor': 'Dr. Sarah',
                      'note': _noteController.text.trim(),
                    });
                    _noteController.clear();
                  });
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          const Text('Medical note posted successfully'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF3B82F6),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(Icons.send, size: 16.sp, color: Colors.white),
              label: Text(
                'Post Note',
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Medicine',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                hintText: 'e.g. Doxycycline 100mg',
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage & Instructions',
                hintText: 'e.g. 1 Tab • Morning, Night • After meal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty) {
                setState(() {
                  _medicines.add({
                    'name': nameController.text,
                    'details': dosageController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34A853),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medicines prescribed',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddMedicineDialog,
                icon: Icon(Icons.add, size: 18.sp),
                label: const Text('Add'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_medicines.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'No medicines prescribed yet.',
                style: GoogleFonts.nunitoSans(color: AppColors.textMuted),
              ),
            )
          else
            ..._medicines.asMap().entries.map((entry) {
              final idx = entry.key;
              final med = entry.value;
              return _buildMedicineItem(med['name']!, med['details']!, idx);
            }),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(String name, String details, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: const Color(0xFF3B82F6), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  details,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18.sp),
            onPressed: () {
              setState(() {
                _medicines.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showEditVitalDialog(String vitalKey, String currentFreq) {
    final freqController = TextEditingController(text: currentFreq);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit $vitalKey Schedule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        content: TextField(
          controller: freqController,
          decoration: const InputDecoration(
            labelText: 'Frequency',
            hintText: 'e.g. Twice daily, Weekly, Every 4 hours',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (freqController.text.isNotEmpty) {
                setState(() {
                  _vitalsFreq[vitalKey] = freqController.text;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34A853),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
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
          Text(
            'Vitals Check (Schedule)',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildVitalBox(
                  Icons.thermostat,
                  'Temp',
                  _vitalsFreq['Temp']!,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildVitalBox(
                  Icons.monitor_heart,
                  'Heart',
                  _vitalsFreq['Heart']!,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildVitalBox(
                  Icons.scale,
                  'Weight',
                  _vitalsFreq['Weight']!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalBox(IconData icon, String label, String freq) {
    return InkWell(
      onTap: () => _showEditVitalDialog(label, freq),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFEF4444), size: 20.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              freq,
              style: GoogleFonts.nunitoSans(
                fontSize: 11.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Icon(Icons.edit, size: 12.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPastTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past Medical Notes',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 16.h),
        if (_pastNotes.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'No medical notes yet.',
                style: GoogleFonts.nunitoSans(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ..._pastNotes.map((noteMap) {
            return _buildTimelineItem(
              date: noteMap['date']!,
              doctor: noteMap['doctor']!,
              note: noteMap['note']!,
            );
          }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String doctor,
    required String note,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2.w, height: 80.h, color: Colors.grey[300]),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      Text(
                        doctor,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    note,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13.sp,
                      color: AppColors.textMain,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextToSpeechPlayer(text: note),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
