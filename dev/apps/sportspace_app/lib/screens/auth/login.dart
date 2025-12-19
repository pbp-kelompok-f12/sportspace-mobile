import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/auth/register.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'package:sportspace_app/screens/homepage.dart';
import 'package:sportspace_app/widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Controller Utama untuk orchestrasi animasi halaman
  late AnimationController _pageController;

  // Animasi Header (Motif & Logo)
  late Animation<Offset> _headerOffset;
  late Animation<double> _logoScale;


  // Animasi Card
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  // Animasi Item di dalam Card (Staggered)
  late Animation<Offset> _itemSlide;
  late Animation<double> _itemFade;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;
  double buttonScale = 1.0;

  // Fokus Node untuk animasi border input
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 1. Header turun dari atas
    _headerOffset =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // 2. Logo Pop Up
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    // 3. Card Muncul (Scale & Fade)
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

    // 4. Item dalam card muncul bertahap (slide up)
    _itemSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad),
          ),
        );
    _itemFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    _pageController.forward();

    // Listener untuk rebuild saat fokus berubah (untuk animasi border)
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Warna Brand
    const Color orangePrimary = Color(0xFFf97316);
    const Color navyColor = Color(0xFF0C2D57);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BaseBackground(
        child: SingleChildScrollView(
          // Agar aman di layar kecil
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // --- BAGIAN ATAS: MOTIF & LOGO ---
                SlideTransition(
                  position: _headerOffset,
                  child: Container(
                    width: double.infinity,
                    height: 225, // Sedikit lebih tinggi untuk proporsi
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36), // Lengkungan bawah
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/orangemotif.png"),
                        fit: BoxFit.cover,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(249, 115, 22, 0.85), // Lebih vibrant
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
                          //   shape: BoxShape.rectangle,
                          //   borderRadius: BorderRadius.circular(24),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withOpacity(0.1),
                          //       blurRadius: 30,
                          //       spreadRadius: 3,
                                
                          //     ),
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

                // --- BAGIAN BAWAH: CARD FORM ---
                Expanded(
                  child: FadeTransition(
                    opacity: _cardOpacity,
                    child: ScaleTransition(
                      scale: _cardScale,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Teks "Welcome Back"
                            SlideTransition(
                              position: _itemSlide,
                              child: FadeTransition(
                                opacity: _itemFade,
                                child: Column(
                                  children: const [
                                    Text(
                                      "Welcome Back!",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: navyColor,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Please sign in to continue",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Form Fields dengan Animasi
                            SlideTransition(
                              position: _itemSlide,
                              child: FadeTransition(
                                opacity: _itemFade,
                                child: Column(
                                  children: [
                                    // Username Input
                                    _buildModernTextField(
                                      controller: _usernameController,
                                      focusNode: _usernameFocus,
                                      label: "Username",
                                      icon: Icons.person_outline_rounded,
                                      color: orangePrimary,
                                    ),

                                    const SizedBox(height: 20),

                                    // Password Input
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
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Tombol Login
                            SlideTransition(
                              position: _itemSlide,
                              child: FadeTransition(
                                opacity: _itemFade,
                                child: _buildLoginButton(request),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign Up Link
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
                                          text: "Don't have an account? ",
                                        ),
                                        TextSpan(
                                          text: "Sign Up",
                                          style: const TextStyle(
                                            color: Color(
                                              0xFF84CC16,
                                            ), // Lime Green
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterPage(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
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
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF0C2D57),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? color : Colors.grey.shade500,
            fontSize: 14,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildLoginButton(CookieRequest request) {
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
                setState(() => isLoading = true);

                String username = _usernameController.text;
                String password = _passwordController.text;

                // --- VALIDASI INPUT KOSONG DISINI ---
                if (username.isEmpty || password.isEmpty) {
                  
                  setState(() => isLoading = false);
                  showErrorDialog(
                    context, 
                    "Username dan Password tidak boleh kosong!"
                  );
                  return; // Hentikan proses, jangan lanjut ke loading
                }
                // ------------------------------------

                setState(() => isLoading = true);

                final response = await request.login(
                  "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/login-flutter/",
                  {"username": username, "password": password},
                );

                setState(() => isLoading = false);

                if (request.loggedIn) {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  }
                } else {
                  if (context.mounted) {
                      showErrorDialog(context, response['message']);
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
                  Color(0xFFA3E635), // Lime
                  Color(0xFFFDE047), // Yellow
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
              // LOGIKA TAMPILAN LOADING VS LOG IN
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
                        SizedBox(width: 12), // Jarak ikon loading ke teks
                        Text(
                          "Logging In...",
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
                      "Log In",
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
