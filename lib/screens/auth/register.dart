import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/auth/login.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
// import 'package:sportspace_app/widgets/error_dialog.dart'; // Tidak diperlukan lagi

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

  // --- STATE ERROR VARIABLES ---
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

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
        // SingleChildScrollView adalah PARENT UTAMA.
        // Ini memastikan seluruh halaman bisa discroll.
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // Atau BouncingScrollPhysics()
          child: Column(
            children: [
              // --- HEADER (Motif & Logo) ---
              SlideTransition(
                position: _headerOffset,
                child: Container(
                  width: double.infinity,
                  height: 220,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: FadeTransition(
                            opacity: _logoScale,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Image.asset(
                                "assets/images/logosportspace.png",
                                width: 170,
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
              // HAPUS Expanded di sini. Biarkan container tumbuh sesuai isinya.
              FadeTransition(
                opacity: _cardOpacity,
                child: ScaleTransition(
                  scale: _cardScale,
                  child: Container(
                    width: double.infinity,
                    // Margin bawah diperbesar agar enak dilihat saat scroll mentok bawah
                    margin: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        SlideTransition(
                          position: _itemSlide,
                          child: FadeTransition(
                            opacity: _itemFade,
                            child: Text(
                              "Create Account",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: navyColor,
                                letterSpacing: -1.0,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

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
                                  errorText: _usernameError,
                                  onChanged: (_) {
                                    if (_usernameError != null) {
                                      setState(() => _usernameError = null);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildModernTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  label: "Email",
                                  icon: Icons.email_outlined,
                                  color: orangePrimary,
                                  keyboardType: TextInputType.emailAddress,
                                  errorText: _emailError,
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() => _emailError = null);
                                    }
                                  },
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
                                  errorText: _passwordError,
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
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
                                  errorText: _confirmPasswordError,
                                  onChanged: (_) {
                                    if (_confirmPasswordError != null) {
                                      setState(
                                          () => _confirmPasswordError = null);
                                    }
                                  },
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

                        const SizedBox(height: 25), // Jarak ke tombol

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
            ],
          ),
        ),
      ),
    );
  }
  // --- HELPERS (Modern Style) ---

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
    String? errorText,
    Function(String)? onChanged,
  }) {
    // Logic Error
    bool hasError = errorText != null && errorText.isNotEmpty;

    // Warna Border
    Color borderColor = hasError
        ? Colors.red.shade400
        : (focusNode.hasFocus ? color : Colors.transparent);

    // Warna Icon
    Color iconColor = hasError
        ? Colors.red.shade400
        : (focusNode.hasFocus ? color : Colors.grey.shade400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              if (focusNode.hasFocus && !hasError)
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
            onChanged: onChanged,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Color(0xFF0C2D57)),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: hasError ? Colors.red.shade400 : (focusNode.hasFocus ? color : Colors.grey.shade500),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: iconColor,
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
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjusted padding
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
        ),
        
        // Error Message Widget
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: hasError
              ? Padding(
                  key: ValueKey<String>(errorText),
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: Colors.red.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          errorText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
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
                // 1. Reset Error
                setState(() {
                  _usernameError = null;
                  _emailError = null;
                  _passwordError = null;
                  _confirmPasswordError = null;
                });

                // 2. Local Validation (Cek Kosong)
                bool hasLocalError = false;

                if (_usernameController.text.isEmpty) {
                  setState(() => _usernameError = "Username tidak boleh kosong");
                  hasLocalError = true;
                }
                if (_emailController.text.isEmpty) {
                   setState(() => _emailError = "Email tidak boleh kosong");
                   hasLocalError = true;
                }
                if (_passwordController.text.isEmpty) {
                   setState(() => _passwordError = "Password tidak boleh kosong");
                   hasLocalError = true;
                }
                if (_passwordConfirmController.text.isEmpty) {
                   setState(() => _confirmPasswordError = "Konfirmasi password wajib diisi");
                   hasLocalError = true;
                }

                if (hasLocalError) return;

                // 3. Local Validation (Match Password)
                if (_passwordController.text != _passwordConfirmController.text) {
                  setState(() => _confirmPasswordError = "Konfirmasi password tidak sesuai");
                  return;
                }

                setState(() => isLoading = true);

                // 4. Request
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

                // 5. Handle Response
                if (response.containsKey('status') &&
                    (response['status'] == 'success' || response['status'] == true)) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Center(
                            child: Text("Registrasi Berhasil",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold))),
                        content: Text(
                            "Akun Anda berhasil dibuat. Silakan login.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter()),
                        actions: [
                          Center(
                            child: TextButton(
                              child: Text("Login Sekarang",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFf97316))),
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }
                } else {
                  // Handle Error dari Backend
                  if (context.mounted) {
                    String message = response['message'] ?? 'Terjadi kesalahan';
                    
                    setState(() {
                      // Mapping pesan error backend ke field
                      if (message.toLowerCase().contains("username")) {
                         _usernameError = message;
                      } else if (message.toLowerCase().contains("password")) {
                         // Asumsi error password dari backend masuk ke confirm password atau password utama
                         _confirmPasswordError = message;
                      } else {
                        // Jika error umum, tampilkan SnackBar
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(message),
                             backgroundColor: Colors.red,
                           )
                         );
                      }
                    });
                  }
                }
              },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: buttonScale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
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