import 'package:flutter/material.dart';

class SmoothIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const SmoothIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<SmoothIndexedStack> createState() => _SmoothIndexedStackState();
}

class _SmoothIndexedStackState extends State<SmoothIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _index;
  int? _previousIndex;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _previousIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart, // Kurva animasi smooth (cepat di awal, pelan di akhir)
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SmoothIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _index) {
      _previousIndex = _index;
      _index = widget.index;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logika Arah Slide:
    // Jika Index Baru > Lama (misal 0 -> 1): Geser dari Kanan
    // Jika Index Baru < Lama (misal 1 -> 0): Geser dari Kiri
    final bool isGoingRight = (_index > (_previousIndex ?? 0));
    
    // Jarak geser (0.15 = 15% lebar layar). Efek paralaks halus.
    const double slideOffset = 0.15; 

    return Stack(
      children: widget.children.asMap().entries.map((entry) {
        final int idx = entry.key;
        final Widget child = entry.value;

        // 1. Halaman yang AKTIF (Sedang masuk)
        if (idx == _index) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isGoingRight ? slideOffset : -slideOffset, 0),
              end: Offset.zero,
            ).animate(_animation),
            child: FadeTransition(
              opacity: _animation,
              child: child,
            ),
          );
        }
        
        // 2. Halaman SEBELUMNYA (Sedang keluar)
        else if (idx == _previousIndex) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(isGoingRight ? -slideOffset : slideOffset, 0),
            ).animate(_animation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
              child: child,
            ),
          );
        }

        // 3. Halaman LAINNYA (State tetap hidup tapi disembunyikan)
        else {
          return IgnorePointer(child: Opacity(opacity: 0, child: child));
        }
      }).toList(),
    );
  }
}