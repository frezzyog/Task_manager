import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<TaskModel> _getTasksForDay(DateTime day, List<TaskModel> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedTasks = _getTasksForDay(_selectedDay!, taskProvider.tasks);

    return Scaffold( // Use Scaffold to ensure background color covers everything
       backgroundColor: const Color(0xFF0B0E14),
       body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181C26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Icon(Icons.add_alert_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Calendar Widget
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF181C26),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                
                // Styling
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.grey.shade500),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF246BFD),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF246BFD).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.grey.shade600),
                  weekendStyle: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF246BFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${selectedTasks.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Task List for Selected Day
            Expanded(
              child: selectedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available_rounded, size: 60, color: Colors.grey.shade800),
                          const SizedBox(height: 16),
                          Text(
                            "No tasks for this day",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: selectedTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskItem(context, selectedTasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    bool isDone = task.status == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: const Color(0xFF181C26),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF246BFD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined, color: Color(0xFF246BFD)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                   DateFormat('hh:mm a').format(task.dueDate ?? DateTime.now()), // Mock time if none
                   style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isDone)
             const Icon(Icons.check_circle, color: Colors.green)
          else 
             const Icon(Icons.circle_outlined, color: Colors.grey),
        ],
      ),
    );
  }
}
