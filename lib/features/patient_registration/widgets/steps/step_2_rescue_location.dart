import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_voice_assistant.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/voice_language_provider.dart';

class Step2RescueLocation extends StatefulWidget {
  const Step2RescueLocation({super.key});

  @override
  State<Step2RescueLocation> createState() => _Step2RescueLocationState();
}

class _Step2RescueLocationState extends State<Step2RescueLocation> {
  final MapController _mapController = MapController();
  bool _isFetchingLocation = false;
  bool _isAutoFilling = false;
  LatLng _mapCenter = const LatLng(19.0760, 72.8777); // Default to Mumbai

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<RegistrationProvider>().mapLocation;
      if (loc != null) {
        setState(() => _mapCenter = loc);
        _mapController.move(loc, 15.0);
      } else {
        context.read<RegistrationProvider>().updateMapLocation(_mapCenter);
      }
    });
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLoc = LatLng(position.latitude, position.longitude);

      setState(() {
        _mapCenter = newLoc;
      });
      _mapController.move(newLoc, 15.0);

      context.read<RegistrationProvider>().updateMapLocation(newLoc);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _autoFillFromMap() async {
    setState(() => _isAutoFilling = true);
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        _mapCenter.latitude,
        _mapCenter.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final formProvider = context.read<RegistrationProvider>();

        final street = place.street ?? place.name ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? place.administrativeArea ?? '';

        // Clean up formatting
        String finalAddress = street;
        if (finalAddress.contains(subLocality)) {
          finalAddress = finalAddress.replaceAll(subLocality, '').trim();
        }
        if (finalAddress.isEmpty &&
            place.subThoroughfare != null &&
            place.thoroughfare != null) {
          finalAddress = '${place.subThoroughfare} ${place.thoroughfare}';
        }

        formProvider.addressController.text = finalAddress.trim();
        formProvider.areaController.text = subLocality;
        formProvider.cityController.text = locality;
        formProvider.pincodeController.text = place.postalCode ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address auto-filled successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting address: $e')));
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildMapSection(),
          SizedBox(height: 24.h),
          _buildLocationForm(context),
          SizedBox(height: 24.h),
          _buildPrioritySection(context),
          SizedBox(height: 24.h),
          _buildMediaSection(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pinpoint the Animal',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            Row(
              children: [
                Icon(Icons.gps_fixed, color: Colors.grey.shade600, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  'Lat: ${_mapCenter.latitude.toStringAsFixed(4)}, Lng: ${_mapCenter.longitude.toStringAsFixed(4)}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 250.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: 15.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && position.center != null) {
                        setState(() {
                          _mapCenter = position.center!;
                        });
                        context.read<RegistrationProvider>().updateMapLocation(
                          position.center!,
                        );
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ngoerp.ngo_erp',
                    ),
                  ],
                ),
                // Center Map Marker
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 32.h,
                    ), // Offset to put point on center
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF006E1C),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ),
                        Container(
                          width: 4.w,
                          height: 16.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFF006E1C),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: _isFetchingLocation ? null : _fetchCurrentLocation,
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006E1C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isFetchingLocation
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 24.w,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    final voiceService = context.watch<VoiceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location Details',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            Row(
              children: [
                if (!_isAutoFilling)
                  TextButton.icon(
                    onPressed: _autoFillFromMap,
                    icon: Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFF006E1C),
                      size: 16.w,
                    ),
                    label: Text(
                      'Auto-fill',
                      style: GoogleFonts.nunitoSans(
                        color: const Color(0xFF006E1C),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF006E1C),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    voiceService.isListening ? Icons.mic : Icons.mic_none,
                    color: voiceService.isListening
                        ? Colors.red
                        : const Color(0xFF006E1C),
                  ),
                  onPressed: () {
                    if (voiceService.isVoiceModeActive) {
                      voiceService.abortVoice();
                    } else {
                      final assistant = RegistrationVoiceAssistant(
                        voiceService,
                        formProvider,
                        context.read<VoiceLanguageProvider>(),
                      );
                      assistant.startStep2();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          'Animal Address / Detailed Location',
          'Example: Near the blue dumpster...',
          formProvider.addressController,
          focusNode: formProvider.addressFocus,
          maxLines: 3,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'address',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Landmark',
          'e.g. Next to Star Coffee',
          formProvider.landmarkController,
          focusNode: formProvider.landmarkFocus,
          icon: Icons.store,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'landmark',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          'Area / Locality',
          'e.g. Upper West Side',
          formProvider.areaController,
          focusNode: formProvider.areaFocus,
          icon: Icons.map,
          readOnly: voiceService.isVoiceModeActive,
          fieldKey: 'area',
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'City',
                'New York',
                formProvider.cityController,
                focusNode: formProvider.cityFocus,
                readOnly: voiceService.isVoiceModeActive,
                fieldKey: 'city',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                'Pin Code',
                '10023',
                formProvider.pincodeController,
                focusNode: formProvider.pincodeFocus,
                readOnly: voiceService.isVoiceModeActive,
                fieldKey: 'pincode',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    FocusNode? focusNode,
    int maxLines = 1,
    IconData? icon,
    bool readOnly = false,
    String? fieldKey,
  }) {
    return Builder(
      builder: (context) {
        final formProvider = context.watch<RegistrationProvider>();
        final voiceService = context.watch<VoiceService>();
        bool isActiveVoiceField =
            voiceService.isVoiceModeActive &&
            formProvider.activeVoiceField == fieldKey &&
            fieldKey != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ),
            voiceService.isVoiceModeActive
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: isActiveVoiceField
                          ? Border.all(
                              color: const Color(0xFF006E1C),
                              width: 2.w,
                            )
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.grey.shade400, size: 20.w),
                          SizedBox(width: 12.w),
                        ],
                        Expanded(
                          child: Text(
                            controller.text.isEmpty ? hint : controller.text,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              color: controller.text.isEmpty
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1B1C1C),
                            ),
                            maxLines: maxLines,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  )
                : TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: maxLines,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      color: const Color(0xFF1B1C1C),
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.nunitoSans(
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: icon != null
                          ? Icon(icon, color: Colors.grey.shade400, size: 20.w)
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFFBF9F9),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Color(0xFF006E1C),
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildPrioritySection(BuildContext context) {
    final formProvider = context.watch<RegistrationProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rescue Priority',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1C1C),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildPriorityButton(
                'Normal',
                const Color(0xFF006E1C),
                const Color(0xFF94F990),
                formProvider,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPriorityButton(
                'Emergency',
                const Color(0xFFFFA726),
                const Color(0xFFFFF3E0),
                formProvider,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPriorityButton(
                'Critical',
                const Color(0xFFBA1A1A),
                const Color(0xFFFFEBEE),
                formProvider,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Critical priority notifies the nearest vet clinic immediately.',
          style: GoogleFonts.nunitoSans(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(
    String label,
    Color color,
    Color bgColor,
    RegistrationProvider provider,
  ) {
    bool isSelected = provider.priority == label;
    return GestureDetector(
      onTap: () {
        provider.updatePriority(label);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9F9),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 2.w,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Location Photos',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Help rescuers find the spot',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9F9),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 2.w,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58CAFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic, color: Colors.white, size: 24.w),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Voice Note',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Describe surroundings',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
