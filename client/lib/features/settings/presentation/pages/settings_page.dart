import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/l10n_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout'),
        content: Text(
          'Semua data lokal akan dihapus. Anda harus login ulang dengan internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final router = GoRouter.of(context);
              nav.pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (mounted) {
                router.goNamed(AppRouteNames.login);
              }
            },
            child: Text('Logout', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildAvatarArea(colors),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.accountSecurity, colors),
              const SizedBox(height: 12),
              _buildSecurityCard(context, colors, l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.preferences, colors),
              const SizedBox(height: 12),
              _buildPreferencesCard(colors, l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.generalInfo, colors),
              const SizedBox(height: 12),
              _buildHelpCard(context, colors, l10n),
              const SizedBox(height: 32),
              _buildLogoutButton(context, colors, l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarArea(AppColorsExtension colors) {
    final user = ref.watch(currentUserProvider);
    final initials = _getInitials(user?.fullName ?? '');
    final name = user?.fullName ?? 'User';
    final email = user?.email ?? '-';
    final kycStatus = user?.kycStatus ?? 'UNVERIFIED';

    Color kycColor = colors.textSecondary;
    String kycLabel = 'Unverified';
    if (kycStatus == 'APPROVED') {
      kycColor = colors.success;
      kycLabel = 'Verified';
    } else if (kycStatus == 'PENDING') {
      kycColor = colors.warning;
      kycLabel = 'Pending KYC';
    }

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.1),
            border: Border.all(color: colors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kycColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: kycColor, size: 14),
              const SizedBox(width: 4),
              Text(
                kycLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kycColor,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildSectionHeader(String title, AppColorsExtension colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: colors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, AppColorsExtension colors, AppL10n l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline_rounded,
            title: l10n.personalInfo,
            colors: colors,
            onTap: () => context.pushNamed(AppRouteNames.personalInfo),
          ),
          Divider(height: 1, thickness: 0.5, color: colors.border),
          _buildListTile(
            icon: Icons.pin_outlined,
            title: l10n.changePin,
            colors: colors,
            onTap: () => context.pushNamed(AppRouteNames.changePin),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(AppColorsExtension colors, AppL10n l10n) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(Icons.dark_mode_outlined, color: colors.textPrimary, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.darkMode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                activeTrackColor: colors.primary.withValues(alpha: 0.5),
                activeThumbColor: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context, AppColorsExtension colors, AppL10n l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.help_outline_rounded,
            title: l10n.helpCenter,
            colors: colors,
            onTap: () async {
              final phone = '6285230369011';
              final message = 'Halo NirPay, saya butuh bantuan.';
              // Coba buka WhatsApp dengan URL scheme
              final whatsappUrl = Uri.parse('whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
              final webUrl = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

              try {
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl);
                } else if (await canLaunchUrl(webUrl)) {
                  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                } else {
                  // Fallback: buka di browser
                  await launchUrl(webUrl, mode: LaunchMode.platformDefault);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall.'),
                      backgroundColor: context.colors.error,
                    ),
                  );
                }
              }
            },
          ),
          Divider(height: 1, thickness: 0.5, color: colors.border),
          _buildListTile(
            icon: Icons.phonelink_setup_rounded,
            title: l10n.checkDevice,
            colors: colors,
            onTap: () => context.pushNamed(AppRouteNames.deviceStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required AppColorsExtension colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: colors.textPrimary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppColorsExtension colors, AppL10n l10n) {
    return OutlinedButton(
      onPressed: () => _showLogoutDialog(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20),
          SizedBox(width: 8),
          Text(
            l10n.logout,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
