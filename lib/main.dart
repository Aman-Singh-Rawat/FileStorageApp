import 'package:cloudinary_file_upload/services/auth_service.dart';
import 'package:cloudinary_file_upload/views/home.dart';
import 'package:cloudinary_file_upload/views/login.dart';
import 'package:cloudinary_file_upload/views/signup.dart';
import 'package:cloudinary_file_upload/views/upload_area.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Drive',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A51F1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const CheckUser(),
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignupPage(),
        "/upload": (context) => const UploadArea(),
      },
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
