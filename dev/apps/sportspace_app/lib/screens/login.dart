import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/register.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'package:sportspace_app/screens/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
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
  final TextEditingController _passwordController = TextEditingController();
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
    _motifOffset = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _motifController, curve: Curves.easeOut));
    _motifOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _motifController, curve: Curves.easeIn));
    _motifController.forward();

    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });

    // Card putih bawah
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardOffset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardController.forward();
    });

    // Welcome Back! di dalam card
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _welcomeOffset =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut),
        );
    _welcomeOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn),
    );
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
    _passwordController.dispose();
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

            const SizedBox(height: 20),

            // Card putih bawah
            Expanded(
              child: SlideTransition(
                position: _cardOffset,
                child: FadeTransition(
                  opacity: _cardOpacity,
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
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFf97316),
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    color: Color.fromARGB(255, 255, 173, 80),
                                    blurRadius: 1.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Username
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Username",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            hintText: "Enter your username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            hintText: "Enter your password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Login button dengan animasi scale saat ditekan
                        MouseRegion(
                          onEnter: (_) => !isLoading
                              ? setState(() => buttonScale = 0.97)
                              : null,
                          onExit: (_) => !isLoading
                              ? setState(() => buttonScale = 1.0)
                              : null,
                          child: GestureDetector(
                            onTapDown: (_) => !isLoading
                                ? setState(() => buttonScale = 0.94)
                                : null,
                            onTapUp: (_) => !isLoading
                                ? setState(() => buttonScale = 1.0)
                                : null,
                            onTapCancel: () => !isLoading
                                ? setState(() => buttonScale = 1.0)
                                : null,
                            onTap: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);

                                    String username = _usernameController.text;
                                    String password = _passwordController.text;

                                    final response = await request.login(
                                      "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/login-flutter/",
                                      {
                                        "username": username,
                                        "password": password,
                                      },
                                    );

                                    setState(() => isLoading = false);

                                    if (request.loggedIn) {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HomePage(),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Login Failed"),
                                            content: Text(response["message"]),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFA3E635),
                                      Color(0xFFFDE047),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFA3E635).withOpacity(0.5),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Color(0xFF0C2D57),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Logging In...",
                                              style: TextStyle(
                                                color: Color(0xFF0C2D57),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          "Log In",
                                          style: TextStyle(
                                            color: Color(0xFF0C2D57),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Sign up link
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800, // warna default teks
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign Up",
                                style: const TextStyle(
                                  color: Color(0xFF84CC16), // text-lime-500
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterPage(),
                                      ),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
