import 'package:flutter/material.dart';

class BaseBackground extends StatelessWidget {
  final Widget child;

  const BaseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image — tidak menghalangi klik
        IgnorePointer(
          child: Image.asset(
            "assets/images/padelbackground.jpg",
            fit: BoxFit.cover,
          ),
        ),

        // Gradient overlay — juga tidak boleh memblokir klik
        IgnorePointer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 43, 79, 0.7),
                  Color.fromRGBO(0, 105, 192, 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Konten halaman (login / register)
        child,
      ],
    );
  }
}
