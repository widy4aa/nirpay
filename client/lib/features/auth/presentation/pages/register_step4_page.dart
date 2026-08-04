import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../providers/registration_form_provider.dart';

class RegisterStep4Page extends ConsumerStatefulWidget {
  RegisterStep4Page({super.key});

  @override
  ConsumerState<RegisterStep4Page> createState() => _RegisterStep4PageState();
}

class _RegisterStep4PageState extends ConsumerState<RegisterStep4Page> {
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _postalCodeController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(registrationFormProvider.notifier).update((state) {
      return state.copyWith(
        province: _provinceController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
      );
    });

    if (mounted) {
      context.pushNamed(AppRouteNames.registerStep5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProgressBar(),
                          const SizedBox(height: 32),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildForm(),
                          const SizedBox(height: 48),
                          _buildNextButton(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Registrasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah 4 dari 9',
          style: TextStyle(
            color: context.colors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 5,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Sesuai KTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Masukkan alamat sesuai Kartu Tanda Penduduk Anda.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Provinsi'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _provinceController,
          hint: 'Contoh: DKI Jakarta',
          icon: Icons.map_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Provinsi wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Kota / Kabupaten'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _cityController,
          hint: 'Contoh: Jakarta Selatan',
          icon: Icons.location_city_rounded,
          validator: (v) => (v == null || v.isEmpty) ? 'Kota wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Kecamatan'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _districtController,
          hint: 'Contoh: Kebayoran Baru',
          icon: Icons.domain_outlined,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Kecamatan wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Kelurahan / Desa'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _villageController,
          hint: 'Contoh: Gandaria Utara',
          icon: Icons.home_outlined,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Kelurahan wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Kode Pos'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _postalCodeController,
                    hint: '12345',
                    icon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Angka saja';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('RT'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _rtController,
                    hint: '001',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('RW'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _rwController,
                    hint: '002',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Lanjutkan',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
