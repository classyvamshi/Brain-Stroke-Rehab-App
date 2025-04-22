import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/auth/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User logged in
          if (snapshot.hasData) {
            return HomePage();
          }
          // User is not logged in
          else {
            return LoginOrRegisterPage(); // This should now work with the import added
          }
        },
      ),
    );
  }
}
