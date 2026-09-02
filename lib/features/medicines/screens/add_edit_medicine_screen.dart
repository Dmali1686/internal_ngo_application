import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine_model.dart';
import '../models/medicine_request_model.dart';
import '../providers/medicine_provider.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;
  
  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late TextEditingController _unitController;
  late TextEditingController _currentStockController;
  late TextEditingController _minimumStockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name);
    _descriptionController = TextEditingController(text: widget.medicine?.description);
    _typeController = TextEditingController(text: widget.medicine?.medicineType);
    _unitController = TextEditingController(text: widget.medicine?.unit);
    _currentStockController = TextEditingController(text: widget.medicine?.currentStock.toString() ?? '0');
    _minimumStockController = TextEditingController(text: widget.medicine?.minimumStock.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _unitController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = MedicineRequestModel(
        name: _nameController.text,
        description: _descriptionController.text,
        medicineType: _typeController.text,
        unit: _unitController.text,
        currentStock: int.tryParse(_currentStockController.text) ?? 0,
        minimumStock: int.tryParse(_minimumStockController.text) ?? 0,
      );

      final provider = context.read<MedicineProvider>();
      bool success;
      
      if (widget.medicine == null) {
        success = await provider.addMedicine(request);
      } else {
        success = await provider.updateMedicine(widget.medicine!.id, request);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medicine saved successfully')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to save medicine')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirm == true && mounted) {
      final provider = context.read<MedicineProvider>();
      final success = await provider.deleteMedicine(widget.medicine!.id);
      if (success && mounted) {
         context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MedicineProvider>().isLoading;
    final isEditing = widget.medicine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(labelText: 'Medicine Type (e.g., TABLET)', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit (e.g., STRIP)', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _currentStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Current Stock *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: TextFormField(
                          controller: _minimumStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Minimum Stock *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34A853),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text('Save Medicine', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                  ),
                ],
              ),
            ),
    );
  }
}
