import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/medicine_provider.dart';

class MedicinesListScreen extends StatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  State<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;
  bool _showLowStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedicines(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<MedicineProvider>();
        if (provider.hasMore && !provider.isLoading) {
          _fetchMedicines();
        }
      }
    });
  }

  void _fetchMedicines({bool refresh = false}) {
    context.read<MedicineProvider>().fetchMedicines(
      refresh: refresh,
      search: _searchController.text,
      isActive: _showActiveOnly ? true : null,
      lowStock: _showLowStock ? true : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        title: Text(
          'Medicines Inventory',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF34A853),
        onPressed: () {
          context.push('/add-medicine');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                  ),
                  onSubmitted: (_) => _fetchMedicines(refresh: true),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Active'),
                      selected: _showActiveOnly,
                      onSelected: (val) {
                        setState(() => _showActiveOnly = val);
                        _fetchMedicines(refresh: true);
                      },
                    ),
                    SizedBox(width: 8.w),
                    FilterChip(
                      label: const Text('Low Stock'),
                      selected: _showLowStock,
                      selectedColor: Colors.red[100],
                      onSelected: (val) {
                        setState(() => _showLowStock = val);
                        _fetchMedicines(refresh: true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MedicineProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.medicines.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null && provider.medicines.isEmpty) {
                  return Center(child: Text(provider.error!));
                }
                if (provider.medicines.isEmpty) {
                  return const Center(child: Text('No medicines found.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: provider.medicines.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.medicines.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ));
                    }

                    final medicine = provider.medicines[index];
                    final isLowStock = medicine.currentStock <= medicine.minimumStock;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: ListTile(
                        onTap: () {
                          // Note: In a real app we might pass the full object, 
                          // here we pass the ID to fetch details or we pass the object.
                          context.push('/edit-medicine/${medicine.id}', extra: medicine);
                        },
                        title: Text(
                          medicine.name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Stock: ${medicine.currentStock} ${medicine.unit ?? ''}',
                          style: TextStyle(
                            color: isLowStock ? Colors.red : Colors.grey[600],
                            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!medicine.isActive) 
                              const Chip(label: Text('Inactive', style: TextStyle(fontSize: 10))),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
