import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Create2v2Page extends StatefulWidget {
  const Create2v2Page({super.key});

  @override
  State<Create2v2Page> createState() => _Create2v2PageState();
}

class _Create2v2PageState extends State<Create2v2Page> {
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  
  final TextEditingController _teammateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Palette Colors
  static const Color primaryNavy = Color(0xFF0D2C3E);

  Future<void> _handleCreateMatch(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Send data to backend
    // Only sending 'teammate' because location & time are removed/null
    final response = await request.postJson(
      '$baseUrl/matchmaking/create-2v2/',
      jsonEncode(<String, dynamic>{
        'teammate': _teammateController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("2v2 Match successfully created!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to list page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "An error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _teammateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Create 2v2 Match",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryNavy.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.group, // Group Icon for 2v2
                    size: 60,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title & Description
                Text(
                  "Match 2 vs 2",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enter your teammate's name to create a room.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Teammate Name Input (Required for 2v2)
                TextFormField(
                  controller: _teammateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Teammate name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Teammate Name",
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.person_add_alt_1, color: primaryNavy),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryNavy, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleCreateMatch(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Create Match Now",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
}