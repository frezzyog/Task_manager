import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'login_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF246BFD), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF181C26),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.dmSans(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User Name',
                      style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('12', 'Projects'),
                  _buildDivider(),
                  _buildStatColumn('64', 'Tasks'),
                  _buildDivider(),
                  _buildStatColumn('4.8', 'Ranking'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Menu Options
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181C26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.person_outline, 'My Profile'),
                    _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', hasBadge: true),
                    _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy & Policy'),
                    _buildMenuItem(Icons.settings_outlined, 'Settings'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                    Provider.of<TaskProvider>(context, listen: false).clearTasks();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF181C26),
                    foregroundColor: const Color(0xFFFF4757),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 8),
                      Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1));
  }

  Widget _buildMenuItem(IconData icon, String title, {bool hasBadge = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: hasBadge 
        ? Container(
            width: 8, height: 8, 
            decoration: const BoxDecoration(color: Color(0xFF246BFD), shape: BoxShape.circle),
          ) 
        : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {},
    );
  }
}
