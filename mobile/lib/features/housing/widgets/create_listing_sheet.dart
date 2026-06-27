import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/housing_service.dart';

class CreateListingSheet extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreateListingSheet({super.key, this.onCreated});

  @override
  State<CreateListingSheet> createState() => _CreateListingSheetState();
}

class _CreateListingSheetState extends State<CreateListingSheet> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedLocation;
  String? _selectedType;
  String? _selectedRoom;
  int? _leaseMonths;
  bool _isSubmitting = false;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  static const _locations = ['Central', 'Northern', 'Southern', 'Eastern', 'Western'];
  static const _types = ['hdb', 'condo', 'landed'];
  static const _rooms = ['share', 'private', 'studio'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }
 
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = picked;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final price = double.tryParse(_priceController.text.trim());
    if (_titleController.text.trim().isEmpty ||
        price == null ||
        _selectedLocation == null ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title, price, location, and type.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await HousingService.uploadImage(_selectedImage!);
      }

      await HousingService.createListing(
        title: _titleController.text.trim(),
        priceSgd: price,
        location: _selectedLocation!,
        type: _selectedType!,
        room: _selectedRoom,
        leaseMonths: _leaseMonths,
        url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onCreated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing posted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Post a Listing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 20),

            _FormField(
              label: 'Photo (optional)',
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 28),
                              SizedBox(height: 8),
                              Text('Tap to add a photo',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                            ],
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [    
                            Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedImage = null;
                                  _selectedImageBytes = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            _FormField(
              label: 'Title',
              child: TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Cozy room near Kent Ridge MRT'),
              ),
            ),

            _FormField(
              label: 'Price per month (SGD)',
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 900'),
              ),
            ),

            _FormField(
              label: 'Region',
              child: DropdownButtonFormField<String>(
                value: _selectedLocation,
                hint: const Text('Select region', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                decoration: _inputDecoration(''),
                items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _selectedLocation = v),
              ),
            ),

            _FormField(
              label: 'Property type',
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                hint: const Text('Select type', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                decoration: _inputDecoration(''),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
              ),
            ),

            _FormField(
              label: 'Room type (optional)',
              child: DropdownButtonFormField<String>(
                value: _selectedRoom,
                hint: const Text('Select room type', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                decoration: _inputDecoration(''),
                items: _rooms.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedRoom = v),
              ),
            ),

            _FormField(
              label: 'Lease duration (months, optional)',
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 12'),
                onChanged: (v) => _leaseMonths = int.tryParse(v),
              ),
            ),

            _FormField(
              label: 'Original listing URL (optional)',
              child: TextField(
                controller: _urlController,
                decoration: _inputDecoration('https://...'),
              ),
            ),

            _FormField(
              label: 'Notes (optional)',
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration('Anything else potential roommates should know'),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFFA78BFA)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3D818CF8), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_outlined, size: 16, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Posting...' : 'Post Listing',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
