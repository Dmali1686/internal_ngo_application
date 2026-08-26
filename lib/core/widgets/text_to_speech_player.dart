import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';

class TextToSpeechPlayer extends StatefulWidget {
  final String text;
  final String? languageCode;

  const TextToSpeechPlayer({super.key, required this.text, this.languageCode});

  @override
  State<TextToSpeechPlayer> createState() => _TextToSpeechPlayerState();
}

class _TextToSpeechPlayerState extends State<TextToSpeechPlayer> {
  bool _isThisWidgetSpeaking = false;
  VoiceService? _voiceService;

  @override
  void dispose() {
    if (_isThisWidgetSpeaking) {
      _voiceService?.stopSpeaking();
    }
    super.dispose();
  }

  void _toggleSpeech(VoiceService voiceService) async {
    _voiceService = voiceService;

    if (_isThisWidgetSpeaking) {
      setState(() {
        _isThisWidgetSpeaking = false;
      });
      await voiceService.stopSpeaking();
    } else {
      if (voiceService.isSpeaking) {
        await voiceService.stopSpeaking(); // stop any other speech first
      }

      if (!mounted) return;
      setState(() {
        _isThisWidgetSpeaking = true;
      });

      try {
        await voiceService.speak(
          widget.text,
          languageCode: widget.languageCode ?? 'en-IN',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error playing audio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted && _isThisWidgetSpeaking) {
          setState(() {
            _isThisWidgetSpeaking = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = context.watch<VoiceService>();
    _voiceService = voiceService;

    return GestureDetector(
      onTap: () => _toggleSpeech(voiceService),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _isThisWidgetSpeaking
              ? Colors.red.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: _isThisWidgetSpeaking
                ? Colors.red.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isThisWidgetSpeaking)
              Icon(Icons.stop_circle, size: 16.w, color: Colors.red[700])
            else
              Icon(
                Icons.play_arrow_rounded,
                size: 16.w,
                color: Colors.grey[700],
              ),
            SizedBox(width: 4.w),
            Text(
              _isThisWidgetSpeaking ? 'Stop' : 'Listen',
              style: TextStyle(
                fontSize: 12.sp,
                color: _isThisWidgetSpeaking
                    ? Colors.red[700]
                    : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
