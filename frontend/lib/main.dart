import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0E14), // Deepest Dark
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF246BFD), // Electric Blue
            secondary: Color(0xFF246BFD),
            surface: Color(0xFF181C26), // Card Surface
            onSurface: Colors.white,
            background: Color(0xFF0B0E14),
          ),
          textTheme: GoogleFonts.dmSansTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF181C26),
            contentPadding: const EdgeInsets.all(20),
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF246BFD), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF246BFD),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuth();
    
    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF246BFD)),
        ),
      );
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
