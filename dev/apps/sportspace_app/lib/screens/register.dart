import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/login.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  late AnimationController _motifController;
  late Animation<Offset> _motifOffset;
  late Animation<double> _motifOpacity;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _cardController;
  late Animation<Offset> _cardOffset;
  late Animation<double> _cardOpacity;

  late AnimationController _welcomeController;
  late Animation<Offset> _welcomeOffset;
  late Animation<double> _welcomeOpacity;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool isLoading = false;
  double buttonScale = 1.0;

  @override
  void initState() {
    super.initState();

    // Motif orange atas
    _motifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _motifOffset = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _motifController, curve: Curves.easeOut));
    _motifOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _motifController, curve: Curves.easeIn));
    _motifController.forward();

    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });

    // Card putih bawah
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardController.forward();
    });

    // Welcome text di dalam card
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _welcomeOffset = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut));
    _welcomeOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _welcomeController.forward();
    });
  }

  @override
  void dispose() {
    _motifController.dispose();
    _logoController.dispose();
    _cardController.dispose();
    _welcomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BaseBackground(
        child: Column(
          children: [
            // Motif orange atas
            SlideTransition(
              position: _motifOffset,
              child: FadeTransition(
                opacity: _motifOpacity,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("assets/images/orangemotif.png"),
                      fit: BoxFit.cover,
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(249, 115, 22, 0.55),
                        Color.fromRGBO(253, 186, 116, 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Image.asset(
                            "assets/images/logosportspace.png",
                            width: 180,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Card putih bawah
            Expanded(
              child: SlideTransition(
                position: _cardOffset,
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _welcomeOffset,
                            child: FadeTransition(
                              opacity: _welcomeOpacity,
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFf97316),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Password Confirmation
                          TextFormField(
                            controller: _passwordConfirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Register button
                          MouseRegion(
                            onEnter: (_) => !isLoading ? setState(() => buttonScale = 0.97) : null,
                            onExit: (_) => !isLoading ? setState(() => buttonScale = 1.0) : null,
                            child: GestureDetector(
                              onTapDown: (_) => !isLoading ? setState(() => buttonScale = 0.94) : null,
                              onTapUp: (_) => !isLoading ? setState(() => buttonScale = 1.0) : null,
                              onTapCancel: () => !isLoading ? setState(() => buttonScale = 1.0) : null,
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      // Validasi sederhana sebelum request
                                      if (_usernameController.text.isEmpty ||
                                          _emailController.text.isEmpty ||
                                          _passwordController.text.isEmpty ||
                                          _passwordConfirmController.text.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Missing Fields"),
                                            content: const Text("All fields are required."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      if (_passwordController.text != _passwordConfirmController.text) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Password Mismatch"),
                                            content: const Text("Passwords do not match."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => isLoading = true);

                                      // Kirim request ke backend
                                      final response = await request.postJson(
                                        "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/register-flutter/",
                                        jsonEncode({
                                          "username": _usernameController.text,
                                          "email": _emailController.text,
                                          "password1": _passwordController.text,
                                          "password2": _passwordConfirmController.text,
                                        }),
                                      );

                                      setState(() => isLoading = false);

                                      if (response.containsKey('status') && response['status'] == 'success') {
                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginPage()),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text("Registration Failed"),
                                              content: Text(response['message'] ?? 'Unknown error'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 120),
                                scale: buttonScale,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFA3E635), Color(0xFFFDE047)],
                                    ),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Color(0xFF0C2D57),
                                          )
                                        : const Text(
                                            "Create Account",
                                            style: TextStyle(
                                              color: Color(0xFF0C2D57),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Login link
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Log In",
                                  style: const TextStyle(
                                    color: Color(0xFF84CC16),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginPage()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
