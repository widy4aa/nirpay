import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/database/database_service.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/user_local_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _provinceCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _villageCtrl;
  late TextEditingController _postalCodeCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _profilePhotoUrl;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _provinceCtrl = TextEditingController(text: user?.province ?? '');
    _cityCtrl = TextEditingController(text: user?.city ?? '');
    _districtCtrl = TextEditingController(text: user?.district ?? '');
    _villageCtrl = TextEditingController(text: user?.village ?? '');
    _postalCodeCtrl = TextEditingController(text: user?.postalCode ?? '');
    _rtCtrl = TextEditingController(text: user?.rt ?? '');
    _rwCtrl = TextEditingController(text: user?.rw ?? '');
    _profilePhotoUrl = user?.profilePhotoUrl;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _villageCtrl.dispose();
    _postalCodeCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kamera tidak tersedia')),
          );
        }
        return;
      }

      // Ambil foto dari kamera depan
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(frontCamera, ResolutionPreset.medium);
      await controller.initialize();

      if (!mounted) return;

      // Tampilkan preview dan ambil foto
      final photo = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          builder: (_) => _CameraPreviewPage(controller: controller),
        ),
      );

      await controller.dispose();

      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
        });
        await _uploadPhoto(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto(String filePath) async {
    setState(() => _isUploadingPhoto = true);

    try {
      final uploadService = ref.read(uploadServiceProvider);
      final url = await uploadService.uploadProfilePhoto(filePath);

      // Update local DB
      final userLocal = ref.read(userLocalDatasourceProvider);
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        await userLocal.updateProfilePhoto(currentUser.id, url);
        final updatedUser = await userLocal.getActiveUser();
        if (updatedUser != null) {
          ref.read(currentUserProvider.notifier).state = updatedUser;
        }
      }

      setState(() => _profilePhotoUrl = url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diupload'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userLocal = ref.read(userLocalDatasourceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Update local DB + tandai dirty
      await userLocal.updateProfile(
        userId: currentUser.id,
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        province: _provinceCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        village: _villageCtrl.text.trim(),
        postalCode: _postalCodeCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
      );

      // Update currentUser provider
      final updatedUser = await userLocal.getActiveUser();
      if (updatedUser != null) {
        ref.read(currentUserProvider.notifier).state = updatedUser;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil tersimpan. Akan di-sync saat online.'),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'Simpan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // Foto Profil
              _buildPhotoSection(colors, user),
              const SizedBox(height: 24),

              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: colors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Perubahan disimpan di perangkat dan di-sync ke server saat online.',
                        style: TextStyle(fontSize: 13, color: colors.primary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Pribadi
              _buildSectionHeader('DATA PRIBADI', Icons.person_rounded, colors),
              const SizedBox(height: 12),
              _buildFormCard(colors, [
                _buildTextField(
                  controller: _fullNameCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                _buildTextField(
                  controller: _phoneCtrl,
                  label: 'No. Telepon',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ]),
              const SizedBox(height: 24),

              // Alamat
              _buildSectionHeader('ALAMAT KTP', Icons.home_rounded, colors),
              const SizedBox(height: 12),
              _buildFormCard(colors, [
                _buildTextField(controller: _provinceCtrl, label: 'Provinsi', icon: Icons.map_rounded),
                _buildTextField(controller: _cityCtrl, label: 'Kota/Kabupaten', icon: Icons.location_city_rounded),
                _buildTextField(controller: _districtCtrl, label: 'Kecamatan', icon: Icons.domain_rounded),
                _buildTextField(controller: _villageCtrl, label: 'Kelurahan', icon: Icons.place_rounded),
                _buildTextField(controller: _postalCodeCtrl, label: 'Kode Pos', icon: Icons.markunread_mailbox_rounded, keyboardType: TextInputType.number),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _rtCtrl, label: 'RT', keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller: _rwCtrl, label: 'RW', keyboardType: TextInputType.number)),
                  ],
                ),
              ]),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppColorsExtension colors, dynamic user) {
    final initials = _getInitials(user?.fullName ?? '');
    final hasPhoto = _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: _isUploadingPhoto ? null : _takePhoto,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.1),
                  border: Border.all(color: colors.primary, width: 2.5),
                  image: hasPhoto
                      ? DecorationImage(
                          image: NetworkImage(_profilePhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasPhoto
                    ? null
                    : Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 2),
                  ),
                  child: _isUploadingPhoto
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isUploadingPhoto ? 'Mengupload foto...' : 'Tap untuk ganti foto',
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, AppColorsExtension colors) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AppColorsExtension colors, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: children
            .expand((w) => [w, const SizedBox(height: 14)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = context.colors;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: colors.textSecondary,
        ),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: colors.textSecondary) : null,
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}

// Camera Preview Page
class _CameraPreviewPage extends StatefulWidget {
  final CameraController controller;

  const _CameraPreviewPage({required this.controller});

  @override
  State<_CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<_CameraPreviewPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Center(
            child: CameraPreview(widget.controller),
          ),

          // Guide frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary.withValues(alpha: 0.5), width: 2),
                borderRadius: BorderRadius.circular(125),
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Text(
              'Posisikan wajah di dalam lingkaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  try {
                    final photo = await widget.controller.takePicture();
                    if (mounted) {
                      Navigator.pop(context, photo);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengambil foto: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Cancel button
          Positioned(
            bottom: 50,
            left: 30,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
