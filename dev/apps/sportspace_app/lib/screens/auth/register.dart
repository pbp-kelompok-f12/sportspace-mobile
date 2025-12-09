import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/auth/login.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportspace_app/widgets/error_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  // Controller Utama Animasi
  late AnimationController _pageController;

  // Animasi Header
  late Animation<Offset> _headerOffset;
  late Animation<double> _logoScale;

  // Animasi Card
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  // Animasi Item (Staggered)
  late Animation<Offset> _itemSlide;
  late Animation<double> _itemFade;

  // Controllers Input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  // Focus Nodes untuk Animasi Border
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double buttonScale = 1.0;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 1. Header turun
    _headerOffset = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    // 2. Logo Pop
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    // 3. Card Muncul
    _cardScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // 4. Item Slide Up
    _itemSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad),
    ));
    _itemFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    _pageController.forward();

    // Listener untuk rebuild UI saat fokus berubah
    _usernameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color orangePrimary = Color(0xFFf97316);
    const Color navyColor = Color(0xFF0C2D57);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BaseBackground(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // --- HEADER (Motif & Logo) ---
                SlideTransition(
                  position: _headerOffset,
                  child: Container(
                    width: double.infinity,
                    height: 222,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36),
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/orangemotif.png"),
                        fit: BoxFit.cover,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(249, 115, 22, 0.85),
                          Color.fromRGBO(253, 186, 116, 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.2),
                          //   shape: BoxShape.circle,
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withOpacity(0.1),
                          //       blurRadius: 20,
                          //       spreadRadius: 2,
                          //     )
                          //   ],
                          // ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: FadeTransition(
                              opacity: _logoScale,
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
                ),

                const SizedBox(height: 10),

                // --- CARD FORM ---
                Expanded(
                  child: FadeTransition(
                    opacity: _cardOpacity,
                    child: ScaleTransition(
                      scale: _cardScale,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: navyColor.withOpacity(0.08),
                              spreadRadius: 4,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              SlideTransition(
                                position: _itemSlide,
                                child: FadeTransition(
                                  opacity: _itemFade,
                                  child: const Text(
                                    "Create Account",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: navyColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Form Inputs
                              SlideTransition(
                                position: _itemSlide,
                                child: FadeTransition(
                                  opacity: _itemFade,
                                  child: Column(
                                    children: [
                                      _buildModernTextField(
                                        controller: _usernameController,
                                        focusNode: _usernameFocus,
                                        label: "Username",
                                        icon: Icons.person_outline_rounded,
                                        color: orangePrimary,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildModernTextField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        label: "Email",
                                        icon: Icons.email_outlined,
                                        color: orangePrimary,
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildModernTextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        label: "Password",
                                        icon: Icons.lock_outline_rounded,
                                        color: orangePrimary,
                                        isPassword: true,
                                        isObscured: !_isPasswordVisible,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildModernTextField(
                                        controller: _passwordConfirmController,
                                        focusNode: _confirmPasswordFocus,
                                        label: "Confirm Password",
                                        icon: Icons.lock_reset_rounded,
                                        color: orangePrimary,
                                        isPassword: true,
                                        isObscured: !_isConfirmPasswordVisible,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Register Button
                              SlideTransition(
                                position: _itemSlide,
                                child: FadeTransition(
                                  opacity: _itemFade,
                                  child: _buildRegisterButton(request),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Login Link
                              Center(
                                child: SlideTransition(
                                  position: _itemSlide,
                                  child: FadeTransition(
                                    opacity: _itemFade,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          const TextSpan(
                                              text: "Already have an account? "),
                                          TextSpan(
                                            text: "Log In",
                                            style: const TextStyle(
                                              color: Color(0xFF84CC16),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const LoginPage(),
                                                  ),
                                                );
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusNode.hasFocus ? color : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          if (focusNode.hasFocus)
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscured,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: Color(0xFF0C2D57)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? color : Colors.grey.shade500,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus ? color : Colors.grey.shade400,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildRegisterButton(CookieRequest request) {
    return MouseRegion(
      onEnter: (_) => !isLoading ? setState(() => buttonScale = 1.05) : null,
      onExit: (_) => !isLoading ? setState(() => buttonScale = 1.0) : null,
      child: GestureDetector(
        onTapDown: (_) =>
            !isLoading ? setState(() => buttonScale = 0.95) : null,
        onTapUp: (_) => !isLoading ? setState(() => buttonScale = 1.0) : null,
        onTapCancel: () =>
            !isLoading ? setState(() => buttonScale = 1.0) : null,
        onTap: isLoading
            ? null
            : () async {
                // 1. Validasi Input Kosong
                if (_usernameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty ||
                    _passwordConfirmController.text.isEmpty) {
                  showErrorDialog(context, "Semua kolom harus diisi!");
                  return;
                }

                // 2. Validasi Password Match
                if (_passwordController.text !=
                    _passwordConfirmController.text) {
                  showErrorDialog(context, "Password tidak cocok!");
                  return;
                }

                setState(() => isLoading = true);

                // 3. Kirim Request
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

                // 4. Handle Response
                if (response.containsKey('status') &&
                    response['status'] == 'success') {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                         backgroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                         title: Center(child: Text("Registrasi Berhasil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                         content: Text("Akun Anda berhasil dibuat. Silakan login.", textAlign: TextAlign.center, style: GoogleFonts.inter()),
                         actions: [
                           Center(
                             child: TextButton(
                               child: Text("Login Sekarang", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFf97316))),
                               onPressed: () {
                                  Navigator.pop(context); // Tutup dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                  );
                               },
                             ),
                           )
                         ],
                      )
                    );
                  }
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                        context, response['message'] ?? 'Terjadi kesalahan tidak diketahui');
                  }
                }
              },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: buttonScale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFA3E635),
                  Color(0xFFFDE047),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA3E635).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF0C2D57),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Signing Up...",
                          style: TextStyle(
                            color: Color(0xFF0C2D57),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFF0C2D57),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}