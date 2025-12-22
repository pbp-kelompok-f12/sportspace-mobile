import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportSpaceNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SportSpaceNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Palet Warna Footer
    final Color bgDark = const Color(0xFF001B33);
    final Color limeAccent = const Color(0xFFA3E635);
    final Color topBorder = const Color(0xFF0C2D57);

    // MENGGUNAKAN SafeArea agar tidak tertabrak Navbar Android
    return Container(
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: topBorder, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        // top: false agar tidak memberi padding di bagian atas navbar
        top: false, 
        child: Container(
          height: 70, // Sesuaikan tinggi konten (sedikit lebih kecil karena sudah ada padding Safearea)
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, Icons.home_outlined, "Home", limeAccent),
              _buildNavItem(1, Icons.assignment, Icons.assignment_outlined, "Bookings", limeAccent),
              _buildNavItem(2, Icons.sports_tennis, Icons.sports_tennis_outlined, "Match", limeAccent),
              _buildNavItem(3, Icons.star, Icons.star_outline, "Reviews", limeAccent),
              _buildNavItem(4, Icons.person, Icons.person_outline, "Profile", limeAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index, 
    IconData activeIcon, 
    IconData inactiveIcon, 
    String label, 
    Color accentColor
  ) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(0, isSelected ? -5 : 0, 0),
            child: Container(
              decoration: isSelected 
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: -2,
                        )
                      ],
                    ) 
                  : null,
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? accentColor : Colors.white.withOpacity(0.5),
                size: isSelected ? 26 : 24,
              ),
            ),
          ),
          
          const SizedBox(height: 2),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? accentColor : Colors.white.withOpacity(0.5),
            ),
            child: Text(label),
          ),
          
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }
}