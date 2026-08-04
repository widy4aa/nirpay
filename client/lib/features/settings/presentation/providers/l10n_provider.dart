import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final l10nProvider = Provider<AppL10n>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'en' ? _EnL10n() : _IdL10n();
});

abstract class AppL10n {
  String get appTitle;
  String get hello;
  String get availableBalance;
  String get syncStatus;
  String get onlineStatus;
  String get offlineStatus;
  String get recentTransactions;
  String get noTransactions;

  String get actionSend;
  String get actionReceive;
  String get actionTopUp;
  String get actionWithdraw;
  String get actionSync;
  String get actionTapToPay;

  String get txTopUp;
  String get txReceive;
  String get txSend;

  String get settings;
  String get accountSecurity;
  String get personalInfo;
  String get changePin;
  String get preferences;
  String get darkMode;
  String get language;
  String get generalInfo;
  String get helpCenter;
  String get checkDevice;
  String get logout;

  String get history;
  String get searchTx;
  String get filterAll;
  String get filterIn;
  String get filterOut;
}

class _IdL10n implements AppL10n {
  @override String get appTitle => 'NirPay';
  @override String get hello => 'Halo,';
  @override String get availableBalance => 'Saldo Tersedia';
  @override String get syncStatus => 'Status Sinkronisasi';
  @override String get onlineStatus => 'Online (Tersinkron)';
  @override String get offlineStatus => 'Offline (Belum Tersinkron)';
  @override String get recentTransactions => 'Transaksi Terakhir';
  @override String get noTransactions => 'Belum ada transaksi';

  @override String get actionSend => 'Kirim';
  @override String get actionReceive => 'Terima';
  @override String get actionTopUp => 'Top Up';
  @override String get actionWithdraw => 'Tarik Tunai';
  @override String get actionSync => 'Sync';
  @override String get actionTapToPay => 'Tap to Pay';

  @override String get txTopUp => 'Top Up Saldo';
  @override String get txReceive => 'Terima Saldo';
  @override String get txSend => 'Kirim Saldo';

  @override String get settings => 'Pengaturan';
  @override String get accountSecurity => 'AKUN & KEAMANAN';
  @override String get personalInfo => 'Informasi Pribadi';
  @override String get changePin => 'Ganti PIN';
  @override String get preferences => 'PREFERENSI';
  @override String get darkMode => 'Mode Gelap';
  @override String get language => 'Bahasa';
  @override String get generalInfo => 'INFORMASI UMUM';
  @override String get helpCenter => 'Pusat Bantuan';
  @override String get checkDevice => 'Cek Status Device';
  @override String get logout => 'Keluar dari Nirpay';

  @override String get history => 'Riwayat Transaksi';
  @override String get searchTx => 'Cari Transaksi';
  @override String get filterAll => 'Semua';
  @override String get filterIn => 'Masuk';
  @override String get filterOut => 'Keluar';
}

class _EnL10n implements AppL10n {
  @override String get appTitle => 'NirPay';
  @override String get hello => 'Hello,';
  @override String get availableBalance => 'Available Balance';
  @override String get syncStatus => 'Sync Status';
  @override String get onlineStatus => 'Online (Synced)';
  @override String get offlineStatus => 'Offline (Not Synced)';
  @override String get recentTransactions => 'Recent Transactions';
  @override String get noTransactions => 'No transactions yet';

  @override String get actionSend => 'Send';
  @override String get actionReceive => 'Receive';
  @override String get actionTopUp => 'Top Up';
  @override String get actionWithdraw => 'Withdraw';
  @override String get actionSync => 'Sync';
  @override String get actionTapToPay => 'Tap to Pay';

  @override String get txTopUp => 'Top Up Balance';
  @override String get txReceive => 'Receive Balance';
  @override String get txSend => 'Send Balance';

  @override String get settings => 'Settings';
  @override String get accountSecurity => 'ACCOUNT & SECURITY';
  @override String get personalInfo => 'Personal Information';
  @override String get changePin => 'Change PIN';
  @override String get preferences => 'PREFERENCES';
  @override String get darkMode => 'Dark Mode';
  @override String get language => 'Language';
  @override String get generalInfo => 'GENERAL INFO';
  @override String get helpCenter => 'Help Center';
  @override String get checkDevice => 'Check Device Status';
  @override String get logout => 'Logout from Nirpay';

  @override String get history => 'Transaction History';
  @override String get searchTx => 'Search Transactions';
  @override String get filterAll => 'All';
  @override String get filterIn => 'In';
  @override String get filterOut => 'Out';
}
