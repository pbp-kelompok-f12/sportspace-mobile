import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/auth/register.dart';
import 'package:sportspace_app/widgets/base_background.dart';
import 'package:flutter/gestures.dart';
import 'package:sportspace_app/screens/homepage.dart';
// import 'package:sportspace_app/widgets/error_dialog.dart'; // Hapus ini karena tidak dipakai lagi
import 'package:sportspace_app/screens/admin/dashboard_admin_page.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // --- STATE UNTUK ERROR TEXT ---
  String? _usernameError;
  String? _passwordError;

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
        // 1. LayoutBuilder: Untuk mendapatkan tinggi layar yang tersedia
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 2. SingleChildScrollView: Agar bisa discroll saat keyboard muncul
            return SingleChildScrollView(
              child: ConstrainedBox(
                // 3. ConstrainedBox: Memastikan tinggi minimal konten = tinggi layar
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                // 4. IntrinsicHeight: Agar widget seperti Spacer() atau Expanded tetap bekerja
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // --- BAGIAN ATAS: MOTIF & LOGO ---
                      SlideTransition(
                        position: _headerOffset,
                        child: Container(
                          width: double.infinity,
                          height: 225,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(36),
                            ),
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/orangemotif.png"),
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
                      FadeTransition(
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
                                      children:  [
                                        Text(
                                          "Welcome Back!",
                                          style: GoogleFonts.poppins( // <-- MENGGUNAKAN GOOGLE FONTS
                                            fontSize: 30, // Ukuran sedikit diperbesar agar lebih impact
                                            fontWeight: FontWeight.w600, // Paling Tebal (Black)
                                            color:  Color(0xFF0C2D57),
                                            letterSpacing: -1.0, // Sedikit dirapatkan agar terlihat solid
                                            height: 1.5,
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

                                // Form Fields
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
                                          errorText: _usernameError, // Pass Error
                                          onChanged: (value) {
                                            // Hapus error saat user mengetik
                                            if (_usernameError != null) {
                                              setState(() {
                                                _usernameError = null;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildModernTextField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          label: "Password",
                                          icon: Icons.lock_outline_rounded,
                                          color: orangePrimary,
                                          isPassword: true,
                                          isObscured: !_isPasswordVisible,
                                          errorText: _passwordError, // Pass Error
                                          onChanged: (value) {
                                            // Hapus error saat user mengetik
                                            if (_passwordError != null) {
                                              setState(() {
                                                _passwordError = null;
                                              });
                                            }
                                          },
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

                                const SizedBox(height: 30),

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
                                                color: Color(0xFF84CC16),
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

                      // SpacerOpsional: Jika ingin Card nempel ke bawah jika layar tinggi
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
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
    String? errorText,
    Function(String)? onChanged,
  }) {
    // Logic Error
    bool hasError = errorText != null && errorText.isNotEmpty;
    
    // Warna Border: Merah jika error, Warna Brand jika fokus, Transparan jika idle
    Color borderColor = hasError
        ? Colors.red.shade400
        : (focusNode.hasFocus ? color : Colors.transparent);

    // Warna Icon: Merah jika error, Warna Brand jika fokus, Abu jika idle
    Color iconColor = hasError
        ? Colors.red.shade400
        : (focusNode.hasFocus ? color : Colors.grey.shade400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. INPUT CONTAINER
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              // Shadow halus hanya jika fokus & tidak error
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
            onChanged: onChanged,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF0C2D57),
            ),
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
              // Hapus contentPadding bawaan yang berlebihan agar centered
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
        ),

        // 2. ERROR MESSAGE (DITARUH DI LUAR / DI BAWAH CONTAINER)
        // Menggunakan AnimatedSwitcher agar munculnya halus
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0, // Muncul dari atas ke bawah
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: hasError
              ? Padding(
                  key: ValueKey<String>(errorText), // Key penting untuk animasi
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
              : const SizedBox.shrink(), // Widget kosong jika tidak ada error
        ),
      ],
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
        setState(() {
          _usernameError = null;
          _passwordError = null;
          isLoading = true; // Mulai loading
        });

        String username = _usernameController.text;
        String password = _passwordController.text;

        // Validasi Lokal
        bool hasLocalError = false;
        if (username.isEmpty) {
          _usernameError = "Username tidak boleh kosong";
          hasLocalError = true;
        }
        if (password.isEmpty) {
          _passwordError = "Password tidak boleh kosong";
          hasLocalError = true;
        }

        if (hasLocalError) {
          setState(() => isLoading = false); // Matikan loading hanya jika error input
          return;
        }

        final response = await request.login(
          "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/login-flutter/",
          {"username": username, "password": password},
        );

        if (request.loggedIn) {
          if (context.mounted) {
            String role = response['role'] ?? 'user';
            
            // --- POINT PENTING ---
            // Jangan panggil setState(() => isLoading = false) di sini!
            // Biarkan loading tetap berjalan sampai Navigator selesai bekerja.

            if (role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardAdminPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }

            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text("${response['message']} Selamat datang, ${response['username']}!"),
            //     backgroundColor: const Color(0xFF0C2D57),
            //   ),
            // );
          }
        } else {
          // Jika Gagal, baru matikan loading agar user bisa mencoba lagi
          if (context.mounted) {
            setState(() {
              isLoading = false; 
              _passwordError = response['message'] ?? "Login gagal";
            });
          }
        }
      },child: AnimatedScale(
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