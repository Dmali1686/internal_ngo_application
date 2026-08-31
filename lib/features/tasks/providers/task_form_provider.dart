import 'package:flutter/material.dart';

class TaskFormProvider extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  final FocusNode titleFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  String? selectedDepartmentId;
  String? selectedAssigneeId;
  String selectedPriority = 'NORMAL';
  DateTime? selectedDueDate;

  String? activeVoiceField;

  void setActiveVoiceField(String? field) {
    activeVoiceField = field;
    notifyListeners();
  }

  void setDepartmentId(String? id) {
    selectedDepartmentId = id;
    notifyListeners();
  }

  void setAssigneeId(String? id) {
    selectedAssigneeId = id;
    notifyListeners();
  }

  void setPriority(String priority) {
    selectedPriority = priority;
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    selectedDueDate = date;
    notifyListeners();
  }
  
  void clear() {
    titleController.clear();
    descriptionController.clear();
    selectedDepartmentId = null;
    selectedAssigneeId = null;
    selectedPriority = 'NORMAL';
    selectedDueDate = null;
    activeVoiceField = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    titleFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }
}
