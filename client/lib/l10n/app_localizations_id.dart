// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'NirPay';

  @override
  String get hello => 'Halo,';

  @override
  String get availableBalance => 'Saldo Tersedia';

  @override
  String get syncStatus => 'Status Sinkronisasi';

  @override
  String get onlineStatus => 'Online (Tersinkron)';

  @override
  String get offlineStatus => 'Offline (Belum Tersinkron)';

  @override
  String get recentTransactions => 'Transaksi Terakhir';

  @override
  String get noTransactions => 'Belum ada transaksi';

  @override
  String get actionSend => 'Kirim';

  @override
  String get actionReceive => 'Terima';

  @override
  String get actionTopUp => 'Top Up';

  @override
  String get actionWithdraw => 'Withdraw';

  @override
  String get actionSync => 'Sync';

  @override
  String get actionTapToPay => 'Tap to Pay';

  @override
  String get txTopUp => 'Top Up Saldo';

  @override
  String get txReceive => 'Terima Saldo';

  @override
  String get txSend => 'Kirim Saldo';

  @override
  String get settings => 'Pengaturan';

  @override
  String get accountSecurity => 'AKUN & KEAMANAN';

  @override
  String get personalInfo => 'Informasi Pribadi';

  @override
  String get changePin => 'Ganti PIN';

  @override
  String get preferences => 'PREFERENSI';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Bahasa';

  @override
  String get generalInfo => 'INFORMASI UMUM';

  @override
  String get helpCenter => 'Pusat Bantuan';

  @override
  String get checkDevice => 'Cek Status Device';

  @override
  String get logout => 'Logout dari Nirpay';

  @override
  String get history => 'Riwayat Transaksi';

  @override
  String get searchTx => 'Cari Transaksi';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterIn => 'Masuk';

  @override
  String get filterOut => 'Keluar';
}
