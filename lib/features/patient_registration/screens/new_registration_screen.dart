import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/registration_provider.dart';
import '../services/registration_voice_assistant.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/services/voice_language_provider.dart';
import '../widgets/steps/step_1_reporter_details.dart';
import '../widgets/steps/step_2_rescue_location.dart';
import '../widgets/steps/step_3_animal_details.dart';
import '../widgets/steps/step_6_review_submit.dart';
import '../../../core/widgets/global_voice_button.dart';
import '../models/patient_registration_model.dart';
import '../services/patient_api_service.dart';

class NewRegistrationScreen extends StatefulWidget {
  const NewRegistrationScreen({super.key});

  @override
  State<NewRegistrationScreen> createState() => _NewRegistrationScreenState();
}

class _NewRegistrationScreenState extends State<NewRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    // Stop any ongoing voice interactions when the screen is closed.
    if (mounted) {
      context.read<VoiceService>().abortVoice();
    }
    super.dispose();
  }

  final List<String> _stepTitles = [
    'Reporter Details',
    'Rescue Location',
    'Animal Details',
    'Review & Submit',
  ];

  final List<Widget> _steps = [
    const Step1ReporterDetails(),
    const Step2RescueLocation(),
    const Step3AnimalDetails(),
    const Step6ReviewSubmit(),
  ];

  void _nextStep([bool continueVoiceFlow = false]) {
    if (_currentStep < _steps.length - 1) {
      int targetStep = _currentStep + 1;
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (continueVoiceFlow) {
              _startVoiceForStep(targetStep);
            }
          });
    }
  }

  void _startVoiceForStep(int stepIndex) {
    if (!mounted) return;
    final voiceService = context.read<VoiceService>();
    final formProvider = context.read<RegistrationProvider>();
    final languageProvider = context.read<VoiceLanguageProvider>();
    final assistant = RegistrationVoiceAssistant(
      voiceService,
      formProvider,
      languageProvider,
    );

    switch (stepIndex) {
      case 0:
        assistant.startStep1();
        break;
      case 1:
        assistant.startStep2();
        break;
      case 2:
        assistant.startStep3();
        break;
      case 3:
        assistant.startStep6Readback();
        break;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().onNextStepRequested = _nextStep;
    });
  }

  Future<void> _submitRegistration() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<RegistrationProvider>();

    final request = PatientRegistrationRequest(
      animalTypeId: provider.animalTypeId ?? 1,
      breedId: provider.breedId,
      colorId: provider.colorId,
      animalName: provider.animalNameController.text.isNotEmpty
          ? provider.animalNameController.text
          : null,
      age: provider.age != 'Unknown' ? provider.age : null,
      weight: double.tryParse(provider.weightController.text),
      gender: provider.gender != 'Unknown' ? provider.gender : null,
      reporterName: provider.reporterNameController.text.isNotEmpty
          ? provider.reporterNameController.text
          : null,
      reporterMobile: provider.mobileNumberController.text.isNotEmpty
          ? provider.mobileNumberController.text
          : null,
      reporterType: 'Citizen',
      address: provider.addressController.text.isNotEmpty
          ? provider.addressController.text
          : null,
      landmark: provider.landmarkController.text.isNotEmpty
          ? provider.landmarkController.text
          : null,
      description: provider.symptomsController.text.isNotEmpty
          ? provider.symptomsController.text
          : null,
      transportType: 'Ambulance',
      rescuePriority: provider.priority.toLowerCase(),
    );

    final apiService = PatientApiService();
    final response = await apiService.registerPatient(request: request);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rescue Registration Successful!')),
      );
      context.go('/registration-success');
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(
            response.errorMessage ??
                'An error occurred while registering the patient.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalVoiceButton(
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Rescue Registration',
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFF1B1C1C),
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Save Draft',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF006E1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: _steps,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: const Color(0xFFFBF9F9),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 4',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006E1C),
                ),
              ),
              Text(
                _stepTitles[_currentStep],
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            height: 4.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: _currentStep + 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF006E1C),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                Expanded(flex: 4 - (_currentStep + 1), child: const SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: const BorderSide(color: Color(0xFF006E1C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006E1C),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 3
                  ? _isSubmitting
                        ? null
                        : _submitRegistration
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006E1C),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 3 ? 'Submit Rescue' : 'Next Step',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_currentStep < 3) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
