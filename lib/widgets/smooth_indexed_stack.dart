import 'package:flutter/material.dart';

class SmoothIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const SmoothIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<SmoothIndexedStack> createState() => _SmoothIndexedStackState();
}

class _SmoothIndexedStackState extends State<SmoothIndexedStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: widget.children.asMap().entries.map((entry) {
        final int idx = entry.key;
        final Widget child = entry.value;
        
        // Cek apakah halaman ini adalah halaman yang sedang aktif
        final bool isActive = idx == widget.index;

        return IgnorePointer(
          // KUNCI PERBAIKAN: 
          // Jika halaman tidak aktif (!isActive), abaikan semua sentuhan/klik.
          ignoring: !isActive, 
          
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            // Jika aktif, tampilkan (1.0). Jika tidak, sembunyikan (0.0).
            opacity: isActive ? 1.0 : 0.0,
            child: child,
          ),
        );
      }).toList(),
    );
  }
}