class TaskRef {
  final String id;
  final String name;
  final String? code;
  final String? employeeCode; // sometimes 'code', sometimes 'employee_code' depending on if it's department or employee

  TaskRef({
    required this.id,
    required this.name,
    this.code,
    this.employeeCode,
  });

  factory TaskRef.fromJson(Map<String, dynamic> json) {
    return TaskRef(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      employeeCode: json['employee_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (employeeCode != null) 'employee_code': employeeCode,
    };
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String taskType;
  final String? taskCode;
  final String? dueDate;
  final String? createdAt;
  final String? completedAt;
  final TaskRef? assignedTo;
  final TaskRef? assignedBy;
  final TaskRef? completedBy;
  final TaskRef? department;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.taskType,
    this.taskCode,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.assignedTo,
    this.assignedBy,
    this.completedBy,
    this.department,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      priority: json['priority'] ?? 'NORMAL',
      taskType: json['task_type'] ?? 'ONE_TIME',
      taskCode: json['task_code'],
      dueDate: json['due_date'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
      assignedTo: json['assigned_to'] != null ? TaskRef.fromJson(json['assigned_to']) : null,
      assignedBy: json['assigned_by'] != null ? TaskRef.fromJson(json['assigned_by']) : null,
      completedBy: json['completed_by'] != null ? TaskRef.fromJson(json['completed_by']) : null,
      department: json['department'] != null ? TaskRef.fromJson(json['department']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'task_type': taskType,
      if (taskCode != null) 'task_code': taskCode,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (assignedTo != null) 'assigned_to': assignedTo!.toJson(),
      if (assignedBy != null) 'assigned_by': assignedBy!.toJson(),
      if (completedBy != null) 'completed_by': completedBy!.toJson(),
      if (department != null) 'department': department!.toJson(),
    };
  }
}
