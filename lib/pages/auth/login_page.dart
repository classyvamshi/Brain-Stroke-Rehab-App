import 'package:flutter/material.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'], // Simplified for testing
  );

  void signUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailnameController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Error"),
            content: Text(e.message ?? "An unexpected error occurred"),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint('Unexpected Sign-In Error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      debugPrint("Starting Google Sign-In");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled by user");
        if (mounted) Navigator.pop(context);
        return;
      }

      debugPrint("Google User: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint("Access Token: ${googleAuth.accessToken}, ID Token: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Signing in with Firebase");
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("Google Sign-In successful");

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Google Sign-In Failed: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Google Sign-In Error"),
            content: Text('Error details: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Incorrect Email"),
        content: Text("No user found with this email address."),
      ),
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Incorrect Password"),
        content: Text("The password you entered is incorrect."),
      ),
    );
  }

  @override
  void dispose() {
    emailnameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: MyTextfield(
                            controller: emailnameController,
                            hintText: 'Email',
                            obscureText: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                          child: MyTextfield(
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final email = emailnameController.text.trim();
                            if (email.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Please enter your email first."),
                                ),
                              );
                              return;
                            }
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text("Password Reset"),
                                  content: Text("A password reset link has been sent to your email."),
                                ),
                              );
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    child: MyButton(
                      text: "Sign In",
                      onTap: signUserIn,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        imagePath: 'lib/images/Google.jpeg',
                        onTap: signInWithGoogle,
                      ),
                      const SizedBox(width: 25),
                      SquareTile(
                        onTap: () {},
                        imagePath: 'lib/images/Apple.jpeg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a Member?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          debugPrint("Register now button pressed");
                          if (widget.onTap == null) {
                            debugPrint("Error: onTap callback is null");
                          } else {
                            debugPrint("Calling onTap callback");
                            widget.onTap!();
                          }
                        },
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}