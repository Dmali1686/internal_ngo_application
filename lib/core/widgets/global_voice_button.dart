import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/voice_service.dart';
import '../services/voice_command_manager.dart';
import '../theme/app_colors.dart';

/// Premium floating voice button with:
/// - Tap-to-toggle (not push-to-talk)
/// - Pulsing glow animation during listening
/// - Live transcript card with auto-fade
/// - State-based colors: idle (green) → listening (blue) → processing (orange)
/// - Haptic feedback
class GlobalVoiceButton extends StatefulWidget {
  final Widget child;
  final Function(String)? onDictate;

  const GlobalVoiceButton({super.key, required this.child, this.onDictate});

  @override
  State<GlobalVoiceButton> createState() => _GlobalVoiceButtonState();
}

class _GlobalVoiceButtonState extends State<GlobalVoiceButton>
    with TickerProviderStateMixin {
  final VoiceCommandManager _commandManager = VoiceCommandManager();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _transcriptFadeController;
  late Animation<double> _transcriptFadeAnimation;

  /// Track whether we showed transcript for auto-fade
  String _lastTranscript = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Pulsing glow animation — continuous during listening
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Transcript fade-out animation
    _transcriptFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _transcriptFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _transcriptFadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptFadeController.dispose();
    super.dispose();
  }

  /// Get the button color based on current state.
  Color _getButtonColor(VoiceService voiceService) {
    if (_isProcessing) return const Color(0xFFE65100); // Orange — processing
    if (voiceService.isListening)
      return const Color(0xFF1565C0); // Blue — listening
    return AppColors.primaryGreen; // Green — idle
  }

  /// Get the glow color based on current state.
  Color _getGlowColor(VoiceService voiceService) {
    if (_isProcessing) return const Color(0xFFE65100);
    if (voiceService.isListening) return const Color(0xFF1565C0);
    return AppColors.primaryGreen;
  }

  /// Get the icon based on state.
  IconData _getIcon(VoiceService voiceService) {
    if (_isProcessing) return Icons.pending;
    if (voiceService.isListening) return Icons.mic;
    return Icons.mic_none;
  }

  void _toggleVoice(VoiceService voiceService) {
    HapticFeedback.mediumImpact();

    if (voiceService.isListening) {
      // Stop listening
      voiceService.stopListening();
    } else {
      // Prevent Android SpeechRecognizer bug by unfocusing keyboard first
      FocusManager.instance.primaryFocus?.unfocus();
      
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        // Start listening
        _transcriptFadeController.reset();
        _pulseController.repeat(reverse: true);

        voiceService.startListening(
        onResultFinalized: (text) {
          _pulseController.stop();
          _pulseController.reset();

          if (text.isNotEmpty) {
            setState(() => _isProcessing = true);

            // Show transcript briefly then process
            Future.delayed(const Duration(milliseconds: 500), () {
              if (widget.onDictate != null) {
                widget.onDictate!(text);
              } else {
                _commandManager.processCommand(context, text);
              }
              if (mounted) {
                setState(() => _isProcessing = false);
              }

              // Auto-fade transcript after 3 seconds
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  _transcriptFadeController.forward();
                }
              });
            });
          }
        },
        onResultPartial: (text) {
          if (text != _lastTranscript) {
            setState(() {
              _lastTranscript = text;
            });
            _transcriptFadeController.reset(); // Keep visible while typing
            
            if (widget.onDictate != null && text.isNotEmpty) {
              widget.onDictate!(text);
            }
          }
        },
      );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 100.h,
          right: 20.w,
          child: Consumer<VoiceService>(
            builder: (context, voiceService, _) {
              // Sync pulse animation with listening state
              if (voiceService.isListening && !_pulseController.isAnimating) {
                _pulseController.repeat(reverse: true);
              } else if (!voiceService.isListening &&
                  !_isProcessing &&
                  _pulseController.isAnimating) {
                _pulseController.stop();
                _pulseController.reset();
              }

              final buttonColor = _getButtonColor(voiceService);
              final glowColor = _getGlowColor(voiceService);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- Transcript Card ---
                  if (voiceService.isListening &&
                      voiceService.recognizedText.isNotEmpty)
                    FadeTransition(
                      opacity:
                          _transcriptFadeAnimation.status ==
                              AnimationStatus.forward
                          ? _transcriptFadeAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: glowColor.withOpacity(0.3),
                            width: 1.5.w,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildListeningIndicator(glowColor),
                                SizedBox(width: 8.w),
                                Text(
                                  'Listening...',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: glowColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              voiceService.recognizedText,
                              style: GoogleFonts.nunitoSans(
                                color: AppColors.textMain,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Finalized transcript (not listening anymore) ---
                  if (!voiceService.isListening &&
                      _lastTranscript.isNotEmpty &&
                      _transcriptFadeController.status !=
                          AnimationStatus.completed)
                    FadeTransition(
                      opacity: _transcriptFadeAnimation,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1.5.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                _lastTranscript,
                                style: GoogleFonts.nunitoSans(
                                  color: AppColors.textMain,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Voice Button with Pulsing Glow ---
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () => _toggleVoice(voiceService),
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: glowColor.withOpacity(
                                  voiceService.isListening
                                      ? 0.2 + (_pulseAnimation.value * 0.4)
                                      : 0.25,
                                ),
                                blurRadius: voiceService.isListening
                                    ? 12 + (_pulseAnimation.value * 16)
                                    : 12,
                                spreadRadius: voiceService.isListening
                                    ? 2 + (_pulseAnimation.value * 6)
                                    : 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIcon(voiceService),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tiny animated dots indicating active listening.
  Widget _buildListeningIndicator(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final value = ((_pulseAnimation.value + delay) % 1.0);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: 4.w,
              height: 4.h + (value * 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.5 + (value * 0.5)),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        );
      },
    );
  }
}
