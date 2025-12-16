class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.status = 'pending',
    this.priority = 'medium',
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? 'Untitled Task', // Defensive coding
      description: json['description'],
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T')[0],
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
