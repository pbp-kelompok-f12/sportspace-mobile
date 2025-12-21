import 'package:flutter/material.dart';

// --- 1. MODEL & DUMMY DATA ---

class PadelField {
  final int id;
  final String nama;
  final String alamat;
  final double rating;
  final int totalReviews;

  PadelField({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.rating,
    required this.totalReviews,
  });
}

// Dummy Data
List<PadelField> dummyFields = [
  PadelField(
    id: 1,
    nama: "Padel Arena Kemang",
    alamat: "Jl. Kemang Raya No. 12, Jakarta Selatan",
    rating: 4.8,
    totalReviews: 125,
  ),
  PadelField(
    id: 2,
    nama: "GBK Padel Court",
    alamat: "Gelora Bung Karno, Jakarta Pusat",
    rating: 4.9,
    totalReviews: 340,
  ),
  PadelField(
    id: 3,
    nama: "West Jakarta Padel",
    alamat: "Jl. Panjang No. 5, Jakarta Barat",
    rating: 4.2,
    totalReviews: 56,
  ),
  PadelField(
    id: 4,
    nama: "Kelapa Gading Sports",
    alamat: "Jl. Boulevard Raya, Jakarta Utara",
    rating: 4.5,
    totalReviews: 89,
  ),
  PadelField(
    id: 5,
    nama: "Cilandak Town Square Padel",
    alamat: "Citos, Jakarta Selatan",
    rating: 3.8,
    totalReviews: 24,
  ),
];

class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({super.key});

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  // Warna Utama
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color bgLight = const Color(0xFFF8FAFC);

  // State Filter & Sort
  String selectedWilayah = 'Semua Wilayah';
  String selectedRating = 'Semua Rating';
  String sortOption = 'Default';
  final TextEditingController minReviewController = TextEditingController();

  // Data List (Untuk simulasi filter)
  List<PadelField> displayedFields = List.from(dummyFields);

  // Opsi Dropdown
  final List<String> wilayahOptions = [
    'Semua Wilayah',
    'Jakarta Barat',
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Timur',
    'Jakarta Utara'
  ];
  final List<String> ratingOptions = ['Semua Rating', '4+', '3+', '2+', '1+'];
  final List<String> sortOptions = [
    'Default',
    'Rating Tertinggi',
    'Review Terbanyak',
    'Nama A-Z',
    'Nama Z-A'
  ];

  @override
  void initState() {
    super.initState();
    // Listener untuk filter review real-time
    minReviewController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    minReviewController.dispose();
    super.dispose();
  }

  // Logika Filter & Sort (Simulasi Frontend)
  void _applyFilters() {
    setState(() {
      displayedFields = dummyFields.where((field) {
        // Filter Wilayah
        bool matchWilayah = selectedWilayah == 'Semua Wilayah' ||
            field.alamat.contains(selectedWilayah.replaceAll('Jakarta ', '')); // Simplifikasi cek string
        
        // Filter Rating
        double minRating = selectedRating == 'Semua Rating' 
            ? 0 
            : double.parse(selectedRating.replaceAll('+', ''));
        bool matchRating = field.rating >= minRating;

        // Filter Review
        int minReview = int.tryParse(minReviewController.text) ?? 0;
        bool matchReview = field.totalReviews >= minReview;

        return matchWilayah && matchRating && matchReview;
      }).toList();

      // Logika Sorting
      switch (sortOption) {
        case 'Rating Tertinggi':
          displayedFields.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Review Terbanyak':
          displayedFields.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
          break;
        case 'Nama A-Z':
          displayedFields.sort((a, b) => a.nama.compareTo(b.nama));
          break;
        case 'Nama Z-A':
          displayedFields.sort((a, b) => b.nama.compareTo(a.nama));
          break;
        default:
          // Default ID asc
          displayedFields.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Kelola Lapangan",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- HEADER & FILTER SECTION ---
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Expansion Tile untuk Filter agar hemat tempat
                ExpansionTile(
                  title: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, color: primaryNavy),
                      const SizedBox(width: 8),
                      Text(
                        "Filter & Urutkan",
                        style: TextStyle(
                            color: primaryNavy, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "Total: ${displayedFields.length} Lapangan",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    // Grid Filter
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: "Wilayah",
                            value: selectedWilayah,
                            items: wilayahOptions,
                            onChanged: (val) {
                              selectedWilayah = val!;
                              _applyFilters();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            label: "Rating Min",
                            value: selectedRating,
                            items: ratingOptions,
                            onChanged: (val) {
                              selectedRating = val!;
                              _applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Input Manual untuk Review
                        Expanded(
                          child: TextField(
                            controller: minReviewController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Min Review",
                              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            label: "Urutkan",
                            value: sortOption,
                            items: sortOptions,
                            onChanged: (val) {
                              sortOption = val!;
                              _applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: displayedFields.isEmpty
                ? Center(child: Text("Data tidak ditemukan", style: TextStyle(color: Colors.grey.shade500)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedFields.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildFieldCard(displayedFields[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFieldForm(context),
        backgroundColor: primaryNavy,
        icon: const Icon(Icons.add),
        label: const Text("Lapangan"),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(color: primaryNavy, fontSize: 12),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard(PadelField field) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Nama & Rating Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    field.nama,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryNavy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        field.rating.toString(),
                        style: TextStyle(
                            color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Alamat
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    field.alamat,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 3: Reviews
            Row(
              children: [
                Icon(Icons.rate_review_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  "${field.totalReviews} Reviews",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            
            const Divider(height: 24),

            // Row 4: Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showFieldForm(context, field: field),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hapus ${field.nama}")),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Hapus"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- MODAL FORM ---
  void _showFieldForm(BuildContext context, {PadelField? field}) {
    final bool isEdit = field != null;
    final nameController = TextEditingController(text: field?.nama ?? '');
    final addressController = TextEditingController(text: field?.alamat ?? '');
    final ratingController = TextEditingController(text: field?.rating.toString() ?? '');
    final reviewController = TextEditingController(text: field?.totalReviews.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? "Edit Lapangan" : "Tambah Lapangan",
            style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField("Nama Lapangan", nameController),
                  const SizedBox(height: 12),
                  _buildTextField("Alamat", addressController, maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Rating (0-5)", ratingController, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Total Review", reviewController, isNumber: true)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic Save Here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryNavy),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: primaryNavy, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: "Contoh...",
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryNavy)),
          ),
        ),
      ],
    );
  }
}