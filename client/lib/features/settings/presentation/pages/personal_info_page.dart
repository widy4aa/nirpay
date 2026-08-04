import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PersonalInfoPage extends ConsumerWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colors = context.colors;

    if (user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(context, colors),
        body: Center(child: Text('Data user tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            // Header dengan avatar
            _buildHeader(context, colors, user),
            const SizedBox(height: 24),

            // Data Pribadi
            _buildSection(
              context: context,
              colors: colors,
              title: 'DATA PRIBADI',
              icon: Icons.person_rounded,
              children: [
                _infoRow(context, colors, 'Nama Lengkap', user.fullName ?? '-'),
                _infoRow(context, colors, 'Email', user.email ?? '-'),
                _infoRow(context, colors, 'Username', user.username ?? '-'),
                _infoRow(context, colors, 'No. Telepon', user.phone ?? '-'),
                _infoRow(context, colors, 'NIK', user.nik ?? '-', isLast: true),
              ],
            ),
            const SizedBox(height: 16),

            // Alamat KTP
            _buildSection(
              context: context,
              colors: colors,
              title: 'ALAMAT KTP',
              icon: Icons.home_rounded,
              children: [
                _infoRow(context, colors, 'Provinsi', user.province ?? '-'),
                _infoRow(context, colors, 'Kota/Kabupaten', user.city ?? '-'),
                _infoRow(context, colors, 'Kecamatan', user.district ?? '-'),
                _infoRow(context, colors, 'Kelurahan', user.village ?? '-'),
                _infoRow(context, colors, 'Kode Pos', user.postalCode ?? '-'),
                _infoRow(context, colors, 'RT/RW', '${user.rt ?? '-'}/${user.rw ?? '-'}'),
                _infoRow(context, colors, 'Jenis Kelamin', _formatGender(user.gender), isLast: true),
              ],
            ),
            const SizedBox(height: 16),

            // Status Verifikasi
            _buildSection(
              context: context,
              colors: colors,
              title: 'STATUS VERIFIKASI',
              icon: Icons.verified_rounded,
              children: [
                _kycStatusRow(context, colors, user.kycStatus ?? 'UNVERIFIED'),
                _infoRow(context, colors, 'Role', user.role ?? 'USER', isLast: true),
              ],
            ),
            const SizedBox(height: 16),

            // Info Teknis
            _buildSection(
              context: context,
              colors: colors,
              title: 'INFO TEKNIS',
              icon: Icons.info_outline_rounded,
              children: [
                _copyableRow(context, colors, 'User ID', user.id ?? '-'),
                _infoRow(context, colors, 'Public Key', _truncateKey(user.publicKeyB64), isLast: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppColorsExtension colors) {
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Informasi Pribadi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => GoRouter.of(context).pushNamed(AppRouteNames.editProfile),
          icon: Icon(Icons.edit_rounded, size: 18),
          label: Text('Edit'),
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppColorsExtension colors, dynamic user) {
    final initials = _getInitials(user.fullName ?? '');
    final kycStatus = user.kycStatus ?? 'UNVERIFIED';

    Color kycColor = colors.textSecondary;
    String kycLabel = 'Belum Verifikasi';
    IconData kycIcon = Icons.shield_outlined;
    if (kycStatus == 'APPROVED') {
      kycColor = colors.success;
      kycLabel = 'Terverifikasi';
      kycIcon = Icons.verified_rounded;
    } else if (kycStatus == 'PENDING') {
      kycColor = colors.warning;
      kycLabel = 'Menunggu Verifikasi';
      kycIcon = Icons.schedule_rounded;
    } else if (kycStatus == 'REJECTED') {
      kycColor = colors.error;
      kycLabel = 'Ditolak';
      kycIcon = Icons.cancel_outlined;
    }

    final hasPhoto = user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.1),
              border: Border.all(color: colors.primary, width: 2),
              image: hasPhoto
                  ? DecorationImage(
                      image: NetworkImage(user.profilePhotoUrl!),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName ?? 'User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username ?? '-'}',
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kycColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(kycIcon, size: 16, color: kycColor),
                const SizedBox(width: 6),
                Text(
                  kycLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kycColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required AppColorsExtension colors,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
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
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, AppColorsExtension colors, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 16 : 12),
      child: Column(
        children: [
          if (isLast == false) Divider(height: 1, thickness: 0.5, color: colors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _copyableRow(BuildContext context, AppColorsExtension colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Divider(height: 1, thickness: 0.5, color: colors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label disalin'),
                      backgroundColor: colors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.copy_rounded, size: 16, color: colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kycStatusRow(BuildContext context, AppColorsExtension colors, String kycStatus) {
    Color kycColor;
    String kycLabel;
    IconData kycIcon;

    switch (kycStatus) {
      case 'APPROVED':
        kycColor = colors.success;
        kycLabel = 'Terverifikasi';
        kycIcon = Icons.check_circle_rounded;
        break;
      case 'PENDING':
        kycColor = colors.warning;
        kycLabel = 'Menunggu Verifikasi';
        kycIcon = Icons.schedule_rounded;
        break;
      case 'REJECTED':
        kycColor = colors.error;
        kycLabel = 'Ditolak';
        kycIcon = Icons.cancel_outlined;
        break;
      default:
        kycColor = colors.textSecondary;
        kycLabel = 'Belum Verifikasi';
        kycIcon = Icons.shield_outlined;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Divider(height: 1, thickness: 0.5, color: colors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  'Status KYC',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(kycIcon, size: 18, color: kycColor),
                    const SizedBox(width: 8),
                    Text(
                      kycLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kycColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '-';
    if (gender == 'MALE') return 'Laki-laki';
    if (gender == 'FEMALE') return 'Perempuan';
    return gender;
  }

  String _truncateKey(String? key) {
    if (key == null || key.isEmpty) return '-';
    if (key.length <= 20) return key;
    return '${key.substring(0, 10)}...${key.substring(key.length - 6)}';
  }
}
