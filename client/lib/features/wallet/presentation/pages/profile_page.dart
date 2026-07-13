import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/router/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildAvatarArea(),
                const SizedBox(height: 32),
                _buildSectionHeader('AKUN DAN KEAMANAN'),
                const SizedBox(height: 12),
                _buildSecurityCard(),
                const SizedBox(height: 24),
                _buildSectionHeader('BANTUAN'),
                const SizedBox(height: 12),
                _buildHelpCard(context),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarArea() {
    return Column(
      children: [
        // Avatar circle WF
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFBEEFF0),
            border: Border.all(color: const Color(0xFF00C4D4), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C4D4).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'WF',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF103B3D),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Widya Fitriadi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E24),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'widyafitriadi123@gmail.com',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF238AED),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E6EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline_rounded,
            title: 'Informasi Pribadi',
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E6EE)),
          _buildListTile(icon: Icons.lock_outline_rounded, title: 'Masuk PIN'),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E6EE)),
          _buildListTile(
            icon: Icons.shield_outlined,
            title: 'Verifikasi Dua Langkah',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E6EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E6EE)),
          _buildListTile(
            icon: Icons.devices_rounded,
            title: 'Cek Device',
            onTap: () => context.pushNamed(AppRouteNames.deviceStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2F2F38), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F38),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.goNamed(AppRouteNames.login),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD14B5A),
        side: const BorderSide(color: Color(0xFFD14B5A), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20),
          SizedBox(width: 8),
          Text(
            'Logout from Nirpay',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
