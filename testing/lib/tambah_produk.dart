import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  static const _maxImageSize = 2 * 1024 * 1024;

  final nameController = TextEditingController();
  final salePriceController = TextEditingController();
  final capitalPriceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _imageData;
  bool _isSaving = false;
  String category = 'Minuman';
  String unit = 'Porsi';

  @override
  void dispose() {
    nameController.dispose();
    salePriceController.dispose();
    capitalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildPhotoAndTips(),
                const SizedBox(height: 28),
                _buildLabel('label', 'Nama Produk'),
                _buildTextField(nameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown('Kategori', category, [
                        'Minuman',
                        'Makanan',
                        'Snack',
                      ], (value) => setState(() => category = value!)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildDropdown('Satuan', unit, [
                        'Porsi',
                        'Gelas',
                        'Buah',
                      ], (value) => setState(() => unit = value!)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('', 'Harga Jual'),
                _buildTextField(
                  salePriceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildLabel('', 'Harga Modal(opsional)'),
                _buildTextField(
                  capitalPriceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
        ),
        const Expanded(
          child: Text(
            'Tambah Produk',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
        GestureDetector(
          onTap: _isSaving ? null : () => _saveProduct(context),
          child: Row(
            children: [
              Text(
                _isSaving ? 'menyimpan...' : 'simpan',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.save_outlined, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoAndTips() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 112,
          height: 182,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            border: Border.all(color: Colors.black.withValues(alpha: 0.65)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageData == null)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined, size: 42),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _imageData!,
                      width: 92,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  _imageData == null ? 'Pilih Foto' : 'Ganti Foto',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const Text(
                  'PNG/JPG maksimal 2 MB',
                  style: TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 26),
        Expanded(
          child: Container(
            height: 182,
            padding: const EdgeInsets.fromLTRB(22, 20, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              border: Border.all(color: Colors.black.withValues(alpha: 0.65)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Foto Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'gunakan foto dengan percaya diri biar',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'patikan Produk Terlihat jelas',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'rekomendast ukuran 1:1',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'bacground Lbuh Lembis disarankan',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Row(
        children: [
          if (icon.isNotEmpty) const Icon(Icons.sell_outlined, size: 18),
          if (icon.isNotEmpty) const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.74),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('', label),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: values
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.74),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.black),
            label: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 38),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _saveProduct(context),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text(
              'Simpan Produk',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C2109),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (pickedImage == null) return;

      final fileName = pickedImage.name.toLowerCase();
      if (!fileName.endsWith('.png') &&
          !fileName.endsWith('.jpg') &&
          !fileName.endsWith('.jpeg')) {
        _showMessage('Format gambar harus PNG atau JPG');
        return;
      }

      final imageData = await pickedImage.readAsBytes();
      if (imageData.isEmpty) {
        _showMessage('File gambar kosong atau tidak dapat dibaca');
        return;
      }
      if (imageData.length > _maxImageSize) {
        _showMessage('Ukuran gambar maksimal 2 MB');
        return;
      }

      if (!mounted) return;
      setState(() => _imageData = imageData);
    } on PlatformException catch (error) {
      _showMessage(
        'Gagal memilih gambar: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (_isSaving) return;
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama produk wajib diisi')));
      return;
    }
    final salePrice = int.tryParse(salePriceController.text.trim());
    if (salePrice == null || salePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga jual wajib diisi dengan angka')),
      );
      return;
    }
    final costPrice = int.tryParse(capitalPriceController.text.trim());
    setState(() => _isSaving = true);
    try {
      await DatabaseHelper.instance.insertProduct(
        Product(
          name: nameController.text.trim(),
          category: category,
          unit: unit,
          salePrice: salePrice,
          costPrice: costPrice,
          imageData: _imageData,
        ),
      );
      if (context.mounted) Navigator.pop(context, true);
    } on DatabaseException catch (error) {
      _showMessage('Gagal menyimpan produk: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
