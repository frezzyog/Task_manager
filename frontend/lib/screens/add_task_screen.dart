import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController(); // Description controller
  String _priority = 'medium';
  String _status = 'pending'; // Default status
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _dueDate = widget.task!.dueDate;
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // Fallback date if none selected
    final dateToSend = _dueDate ?? DateTime.now().add(const Duration(days: 1));

    try {
      if (widget.task == null) {
        final newTask = TaskModel(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          status: _status,
          dueDate: dateToSend,
        );
        await taskProvider.createTask(newTask);
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          status: _status,
          dueDate: dateToSend,
        );
        await taskProvider.updateTask(updatedTask);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Deep Navy Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.task == null ? 'New Task' : 'Edit Task',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: Text(
              'Save',
              style: GoogleFonts.dmSans(
                color: const Color(0xFF246BFD),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Task Title Input
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 32),

              // 2. Description Section
              _buildSectionLabel('DESCRIPTION'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181C26), // Dark Card Color
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white), // Visible Text!
                  decoration: InputDecoration(
                    hintText: 'Enter task details...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    fillColor: Colors.transparent, 
                  ),
                ),
              ),
              
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Priority Selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('PRIORITY'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildPriorityCircle('low', const Color(0xFF2ED573)), // Green
                            const SizedBox(width: 12),
                            _buildPriorityCircle('medium', const Color(0xFFFF9F43)), // Orange
                            const SizedBox(width: 12),
                            _buildPriorityCircle('high', const Color(0xFFFF4757)), // Red
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 4. Due Date Selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('DUE DATE'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF246BFD),
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF181C26),
                                      onSurface: Colors.white,
                                    ),
                                    dialogBackgroundColor: const Color(0xFF181C26),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => _dueDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: Color(0xFF246BFD), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _dueDate == null ? 'Set Date' : DateFormat('MMM dd').format(_dueDate!),
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 5. Status Selection (Optional, useful if editing)
               if (widget.task != null) ...[
                const SizedBox(height: 32),
                _buildSectionLabel('STATUS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildStatusChip('pending', 'To Do'),
                    _buildStatusChip('in_progress', 'Doing'),
                    _buildStatusChip('completed', 'Done'),
                  ],
                ),
               ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Icon(Icons.notes, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityCircle(String value, Color color) {
    bool isSelected = _priority == value;
    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2), // Lighten bg
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected 
          ? Icon(Icons.check, color: color, size: 20)
          : null,
      ),
    );
  }

  Widget _buildStatusChip(String value, String label) {
    bool isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF246BFD) : const Color(0xFF181C26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF246BFD) : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
