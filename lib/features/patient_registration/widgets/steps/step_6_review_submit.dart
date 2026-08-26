import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Step6ReviewSubmit extends StatefulWidget {
  const Step6ReviewSubmit({super.key});

  @override
  State<Step6ReviewSubmit> createState() => _Step6ReviewSubmitState();
}

class _Step6ReviewSubmitState extends State<Step6ReviewSubmit> {
  bool _declarationChecked = false;
  bool _termsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildSummarySections(),
          SizedBox(height: 24.h),
          _buildTokenSection(),
          SizedBox(height: 24.h),
          _buildTermsAndSignature(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final Review',
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B1C1C),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please review all information carefully before final submission. Once submitted, records are locked for official processing.',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySections() {
    return Column(
      children: [
        _buildSummaryCard(
          'Reporter Details',
          Icons.person,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Full Name', 'Sarah Jenkins')),
                  Expanded(
                    child: _buildInfoItem('Contact', '+1 (555) 123-4567'),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildInfoItem('Organization', 'Independent Volunteer'),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSummaryCard(
          'Rescue Location',
          Icons.location_on,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                'Coordinates / Address',
                '124 Maple Avenue, Springfield\n[40.7128° N, 74.0060° W]',
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSummaryCard(
          'Animal Details',
          Icons.pets,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  'https://images.unsplash.com/photo-1552053831-71594a27632d',
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Species / Breed', 'Canine • Labrador Mix'),
                    SizedBox(height: 8.h),
                    Text(
                      'Traits',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildTraitChip(
                          'Friendly',
                          const Color(0xFFC2E8FF),
                          const Color(0xFF004D67),
                        ),
                        SizedBox(width: 8.w),
                        _buildTraitChip(
                          'Hungry',
                          const Color(0xFFFFDDB9),
                          const Color(0xFF663E00),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, IconData icon, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: title == 'Reporter Details',
          iconColor: Colors.grey.shade700,
          collapsedIconColor: Colors.grey.shade700,
          title: Row(
            children: [
              Icon(icon, color: const Color(0xFF006E1C), size: 24.w),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200),
                  SizedBox(height: 12.h),
                  content,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunitoSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: isLarge ? 20.sp : 14.sp,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF1B1C1C),
          ),
        ),
      ],
    );
  }

  Widget _buildTraitChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTokenSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF006E1C).withOpacity(0.05),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: const Color(0xFF006E1C).withOpacity(0.2),
          style: BorderStyle.solid,
          width: 2.w,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Container(
              width: 100.w,
              height: 100.w,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.qr_code_2,
                size: 80.w,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Temporary Entry Token',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003C0B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This unique ID will identify this rescue until the official shelter admission is processed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDED),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'RR-2024-X9F22',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006E1C),
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndSignature() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _termsExpanded = !_termsExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Read Admission Terms & Legal Conditions',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006E1C),
                      ),
                    ),
                    Icon(
                      _termsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF006E1C),
                    ),
                  ],
                ),
                if (_termsExpanded) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '1. By submitting this form, you certify that the information provided is accurate.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '2. The animal described becomes the temporary responsibility of the designated facility.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '3. Registration data is collected for public health and safety purposes.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _declarationChecked = !_declarationChecked;
            });
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: _declarationChecked,
                    onChanged: (val) {
                      setState(() {
                        _declarationChecked = val!;
                      });
                    },
                    activeColor: const Color(0xFF006E1C),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'I hereby declare that the rescue was performed under safe conditions and the animal was found at the specified location without intent of theft or misrepresentation.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12.sp,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3F3),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DIGITAL SIGNATURE',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: const Color(0xFFBA1A1A),
                          size: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Clear',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.sp,
                            color: const Color(0xFFBA1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 150.h,
                width: double.infinity,
                alignment: Alignment.center,
                child: Icon(
                  Icons.edit,
                  color: Colors.grey.shade300,
                  size: 48.w,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
