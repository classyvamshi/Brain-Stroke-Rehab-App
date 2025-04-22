import 'package:flutter/material.dart';
import 'package:my_app/pages/auth/login_page.dart';
import 'package:my_app/pages/auth/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    debugPrint("togglePages called, current showLoginPage: $showLoginPage");
    setState(() {
      showLoginPage = !showLoginPage;
    });
    debugPrint("showLoginPage after toggle: $showLoginPage");
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(
        onTap: togglePages, // Corrected typo from togglepages to togglePages
      );
    }
  }
}