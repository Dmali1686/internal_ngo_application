import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/text_to_speech_player.dart';

class AnimalOverviewScreen extends StatelessWidget {
  const AnimalOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Patient History'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              _buildPatientHeader(context),
              SizedBox(height: 24.h),
              _buildExpansionTile(
                title: 'Basic Information',
                icon: Icons.pets,
                initiallyExpanded: true,
                content: _buildBasicInfo(),
              ),
              SizedBox(height: 12.h),
              _buildExpansionTile(
                title: 'Rescue Information',
                icon: Icons.volunteer_activism,
                content: _buildRescueInfo(),
              ),
              SizedBox(height: 12.h),
              _buildExpansionTile(
                title: 'Medical Timeline',
                icon: Icons.timeline,
                content: _buildMedicalTimeline(),
              ),
              SizedBox(height: 12.h),
              _buildExpansionTile(
                title: 'Laboratory Reports',
                icon: Icons.science,
                content: _buildLabReports(),
              ),
            ],
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => _showQrModal(context),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/treatment-history'),
                        icon: const Icon(Icons.medical_services, size: 18),
                        label: const Text('Treatments'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: const Text('Bella\'s ID', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to access patient record instantly.',
              style: TextStyle(color: Colors.grey[600]),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
                    ),
                  ),
                  Positioned(
                    bottom: 0.h,
                    right: 0.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Bella',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.healing,
                                size: 14.sp,
                                color: Colors.blue[700],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Recovery',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          '#PT-2938',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.meeting_room,
                  'Location',
                  'Ward A, Cage 04',
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  Icons.medical_services,
                  'Doctor',
                  'Dr. Sarah',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: Colors.grey[700]),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: Colors.green[700]),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          children: [Padding(padding: EdgeInsets.all(16.w), child: content)],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Row(
      children: [
        Expanded(child: _buildDataPoint('Breed', 'Golden Retriever')),
        Expanded(child: _buildDataPoint('Age', '2 Years')),
        Expanded(child: _buildDataPoint('Weight', '24.5 kg')),
        Expanded(child: _buildDataPoint('Sex', 'Female (Spayed)')),
      ],
    );
  }

  Widget _buildRescueInfo() {
    return Column(
      children: [
        _buildIconDataPoint(
          Icons.calendar_today,
          'Date Rescued',
          'Oct 24, 2023',
        ),
        SizedBox(height: 12.h),
        _buildIconDataPoint(
          Icons.location_on,
          'Location',
          'Central Park, Near West Gate',
        ),
        SizedBox(height: 12.h),
        _buildIconDataPoint(Icons.person, 'Reporter', 'Sarah Jenkins'),
      ],
    );
  }

  Widget _buildMedicalTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          time: 'Today, 09:30 AM',
          title: 'Post-Op Checkup',
          desc:
              'शस्त्रक्रियेची जखम खूप चांगल्या प्रकारे बरी होत आहे. रुग्णाचे तापमान सामान्य आहे आणि सर्व लक्षणे पूर्णपणे स्थिर आहेत. रुग्ण उपचारांना चांगला प्रतिसाद देत आहे आणि सकाळी त्याने व्यवस्थित अन्न खाल्ले. आपण पुढील तीन दिवस औषधांचा हाच कोर्स सुरू ठेवणार आहोत.',
          isLatest: true,
        ),
        _buildTimelineItem(
          time: 'Yesterday, 14:00 PM',
          title: 'Orthopedic Surgery',
          desc:
              'Successful repair of left hind leg fracture using a titanium plate. The surgery lasted approximately two hours with zero complications. The patient has been moved to Ward A for recovery and observation over the next forty-eight hours.',
          isLatest: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String desc,
    required bool isLatest,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLatest ? Colors.green : Colors.grey[400],
                border: Border.all(color: Colors.white, width: 2.w),
              ),
            ),
            if (!isLatest)
              Container(width: 2.w, height: 40.h, color: Colors.grey[300]),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isLatest ? Colors.green[700] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
              SizedBox(height: 8.h),
              TextToSpeechPlayer(text: desc),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabReports() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.picture_as_pdf, color: Colors.red[700]),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CBC Blood Panel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'Oct 25 • 1.2 MB',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.green[700]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataPoint(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildIconDataPoint(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey[500]),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }
}
