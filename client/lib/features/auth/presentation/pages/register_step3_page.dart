import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/router/app_router.dart';

class RegisterStep3Page extends StatelessWidget {
  const RegisterStep3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F7FB), Colors.white, Color(0xFFC7F4ED)],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressBar(),
                const SizedBox(height: 32),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 40),
                _buildNextButton(context),
                const SizedBox(height: 24),
              ],
            ),
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
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1E28)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Data Diri',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B1E28),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 1.5),
            ),
            child: const Icon(
              Icons.question_mark_rounded,
              color: Colors.black87,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah 3 dari 5',
          style: TextStyle(
            color: Color(0xFF009CFF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF009CFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E6EE),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Masukkan Data Diri Anda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E24),
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Masukkan Data diri anda untuk melanjutkan sesi,\nData diri harus sesuai dengan Identitas asli anda.',
          style: TextStyle(fontSize: 14, color: Color(0xFF7D8C9E), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nama Anda'),
        _buildTextField(
          hint: 'Masukkan Nama Anda',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildLabel('Username'),
        _buildTextField(
          hint: 'Masukkan Nama Anda',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildLabel('Tanggal Lahir'),
        _buildTextField(
          hint: 'MM/DD/YYYY',
          suffixIcon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 20),
        _buildLabel('Jenis Kelamin'),
        Row(
          children: [
            Expanded(child: _buildGenderButton('Laki-laki', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderButton('Perempuan', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1E24),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E6EE)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7D8C9E), fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF7D8C9E), size: 20)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: const Color(0xFF7D8C9E), size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String label, bool isSelected) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: isSelected ? const Color(0xFF009CFF) : const Color(0xFFE2E6EE),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF009CFF) : const Color(0xFF4A4A54),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pushNamed(AppRouteNames.registerStep4),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF009CFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF009CFF).withValues(alpha: 0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selanjutnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
