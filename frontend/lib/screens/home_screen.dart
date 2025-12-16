import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'login_screen.dart';
import 'add_task_screen.dart';
import 'dart:ui';
import 'calendar_view.dart';
import 'stats_view.dart';
import 'profile_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    await Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          // 1. Main Content Area (Switches based on Index)
          _buildCurrentPage(),

          // 2. Floating Glass Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  // Page Switcher
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: // Home
        return _buildHomeContent();
      case 1: // Calendar
        return const CalendarView();
      case 2: // Stats
        return const StatsView();
      case 3: // Profile
        return const ProfileView();
      default:
        return _buildHomeContent();
    }
  }

  // The Premium Glass Nav Bar
  Widget _buildGlassNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 34),
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF181C26).withOpacity(0.7), // Semi-transparent
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The Glass Effect
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.home_filled),
                _buildNavItem(1, Icons.calendar_month_rounded),
                _buildNavItem(2, Icons.pie_chart_rounded),
                _buildNavItem(3, Icons.person_rounded),
                
                // The Distinct "Add" Button
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                    );
                    if (result == true) _loadTasks();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF246BFD), Color(0xFF5089FD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF246BFD).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 26,
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: Color(0xFF246BFD),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small circular icon buttons in header
  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF181C26),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // Extracted Home Content to keep code clean
  Widget _buildHomeContent() {
    final taskProvider = Provider.of<TaskProvider>(context);
    // Use "In Progress" as a proxy for "Today" for now
    var todayTasks = taskProvider.getTasksByStatus('in_progress');
    // If empty, show some pending ones just so it's not blank
    if (todayTasks.isEmpty && taskProvider.tasks.isNotEmpty) {
      todayTasks = taskProvider.getTasksByStatus('pending').take(3).toList();
    }
    
    final allTasks = taskProvider.tasks;
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 130), // Extra bottom padding for floating nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF246BFD),
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildIconButton(Icons.notifications_none_rounded),
                  const SizedBox(width: 12),
                  _buildIconButton(Icons.grid_view_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Hi, ${user?.name.split(' ')[0] ?? 'User'}',
            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            'Be useful right now.',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF246BFD),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF181C26),
              hintText: 'Search your tasks...',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today Task', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF181C26), borderRadius: BorderRadius.circular(20)),
                child: const Text('+ Add', style: TextStyle(color: Color(0xFF246BFD), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: todayTasks.isEmpty
              ? _buildEmptyStateHorizontal()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => _buildTodayTaskCard(todayTasks[index]),
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Task', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          if (allTasks.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No tasks yet", style: TextStyle(color: Colors.grey)))),
          ...allTasks.map((task) => _buildAllTaskItem(task)),
        ],
      ),
    );
  }

  // Profile Content Removed (Extracted to separate file)

  // Horizontal "Today Task" Card
  Widget _buildTodayTaskCard(TaskModel task) {
    // Generate random progress for visuals since backend doesn't support it
    final double progress = task.status == 'completed' ? 1.0 : (task.status == 'in_progress' ? 0.6 : 0.2);
    
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2333), Color(0xFF13161F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                color: const Color(0xFF181C26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                    ).then((result) {
                      if (result == true) Provider.of<TaskProvider>(context, listen: false).fetchTasks();
                    });
                  } else if (value == 'delete') {
                    _confirmDelete(context, task);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit', style: GoogleFonts.dmSans(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Color(0xFFFF4757), size: 18),
                        const SizedBox(width: 8),
                        Text('Delete', style: GoogleFonts.dmSans(color: const Color(0xFFFF4757))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description ?? 'Task management mobile app',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const Spacer(),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.blue.shade200, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF0B0E14),
            valueColor: AlwaysStoppedAnimation<Color>(
                task.priority == 'high' ? const Color(0xFFFF4757) : const Color(0xFF246BFD)
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mock Avatars
              SizedBox(
                width: 60,
                height: 24,
                child: Stack(
                  children: [
                    _buildMiniAvatar(Colors.red, 0),
                    _buildMiniAvatar(Colors.green, 15),
                    _buildMiniAvatar(Colors.blue, 30),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    task.dueDate != null ? DateFormat('MMM dd').format(task.dueDate!) : 'No date',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(Color color, double left) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: const Color(0xFF0B0E14),
        child: CircleAvatar(
          radius: 10,
          backgroundColor: color,
          child: const Icon(Icons.person, size: 12, color: Colors.white),
        ),
      ),
    );
  }

  // Vertical "All Task" List Item
  Widget _buildAllTaskItem(TaskModel task) {
    bool isDone = task.status == 'completed';
    return Dismissible(
       key: Key(task.id.toString()),
       background: Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
       ),
       onDismissed: (_) {
         Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!);
       },
       child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF181C26),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Design Agency', // Mock Category
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                 Row(
                   children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                      color: const Color(0xFF181C26),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                          ).then((result) {
                            if (result == true) Provider.of<TaskProvider>(context, listen: false).fetchTasks();
                          });
                        } else if (value == 'delete') {
                           _confirmDelete(context, task);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.dmSans(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, color: Color(0xFFFF4757), size: 18),
                              const SizedBox(width: 8),
                              Text('Delete', style: GoogleFonts.dmSans(color: const Color(0xFFFF4757))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Provider.of<TaskProvider>(context, listen: false).toggleTaskStatus(task),
                      child: Icon(
                        isDone ? Icons.check_circle : Icons.circle_outlined, 
                        color: isDone ? Colors.green : Colors.grey, 
                        size: 24
                      ),
                    ),
                   ],
                 ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : Colors.white,
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: 4),
              Text(task.description!, style: TextStyle(color: Colors.grey.shade500, fontSize: 13), maxLines: 1),
            ],

            const SizedBox(height: 16),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTag(Icons.attach_money, '20'),
                    const SizedBox(width: 12),
                    _buildTag(Icons.access_time_rounded, '4hour'),
                  ],
                ),
                // Mock Avatar Group
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Stack(
                    children: [
                      _buildMiniAvatar(Colors.orange, 0),
                      _buildMiniAvatar(Colors.purple, 15),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyStateHorizontal() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
         color: const Color(0xFF181C26).withOpacity(0.5),
         borderRadius: BorderRadius.circular(30),
      ),
      child: const Text("No tasks in progress today", style: TextStyle(color: Colors.grey)),
    );
  }

  void _confirmDelete(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181C26),
        title: Text('Delete Task', style: GoogleFonts.dmSans(color: Colors.white)),
        content: Text('Are you sure you want to delete "${task.title}"?', style: const TextStyle(color: Colors.grey)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
