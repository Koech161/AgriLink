// lib/main.dart
import 'package:agrilink/screens/common/main_app.dart';
import 'package:agrilink/screens/onboarding/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'screens/common/splash_screen.dart';
import 'screens/onboarding/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/location_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On web, Firebase must be initialized with explicit FirebaseOptions.
  // Replace the placeholder values below with your Firebase project's
  // configuration from the Firebase console, or run `flutterfire configure`
  // which will generate a `firebase_options.dart` file you can import and
  // use instead (recommended).
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAlm1xADG6UVnH5j1n0FAZ2nR6pgYow5dk',
        authDomain: 'agrilink-bfa18.firebaseapp.com',
        projectId: 'agrilink-bfa18',
        storageBucket: 'agrilink-bfa18.firebasestorage.app',
        messagingSenderId: '739020453147',
        appId: '1:739020453147:android:01482c76c15636a6608fbe',
        // measurementId: 'YOUR_MEASUREMENT_ID',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(AgriLinkApp());
}

class AgriLinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriLink',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/role-selection': (_) => RoleSelectionScreen(),
        '/login': (_) => LoginScreen(),
        '/location': (_) => LocationScreen(),
        '/main-app': (_) => MainApp(),
        // '/profile-setup': (_) => ProfileSetupScreen(),
      },
    );
  }
}