import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/router/app_router.dart';

class RegisterStep1Page extends StatelessWidget {
  const RegisterStep1Page({super.key});

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
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
                          const Spacer(),
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
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1E28)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Registrasi',
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
          'Langkah 1 dari 5',
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
              flex: 1,
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
              flex: 4,
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
          'Masukkan Email dan\nNo Telpon Anda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E24),
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Masukkan alamat email anda dan no telpon anda\nuntuk melanjutkan sesi Registrasi.',
          style: TextStyle(fontSize: 14, color: Color(0xFF7D8C9E), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E24),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(hint: 'Masukan Email Anda', icon: Icons.email_outlined),
        const SizedBox(height: 24),
        const Text(
          'Nomor Ponsel',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E24),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          hint: '+62  12345678',
          icon: Icons.phone_android_rounded,
        ),
      ],
    );
  }

  Widget _buildTextField({required String hint, required IconData icon}) {
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
          prefixIcon: Icon(icon, color: const Color(0xFF7D8C9E), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pushNamed(AppRouteNames.registerStep2),
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
