import 'package:flutter/material.dart';

class LazyLoadPage extends StatefulWidget {
  final Widget child;
  final int index;
  final int currentIndex;

  const LazyLoadPage({
    super.key,
    required this.child,
    required this.index,
    required this.currentIndex,
  });

  @override
  State<LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<LazyLoadPage> {
  bool _hasBeenLoaded = false;

  @override
  Widget build(BuildContext context) {
    // Jika index saat ini cocok dengan index halaman ini, tandai sbg loaded
    if (widget.currentIndex == widget.index) {
      _hasBeenLoaded = true;
    }

    // Jika belum pernah diload, tampilkan Container kosong (ringan)
    // Jika sudah pernah, tampilkan halamannya (dan state tetap tersimpan)
    return _hasBeenLoaded ? widget.child : const SizedBox();
  }
}