// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NirPay';

  @override
  String get hello => 'Hello,';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get onlineStatus => 'Online (Synced)';

  @override
  String get offlineStatus => 'Offline (Not Synced)';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get actionSend => 'Send';

  @override
  String get actionReceive => 'Receive';

  @override
  String get actionTopUp => 'Top Up';

  @override
  String get actionWithdraw => 'Withdraw';

  @override
  String get actionSync => 'Sync';

  @override
  String get actionTapToPay => 'Tap to Pay';

  @override
  String get txTopUp => 'Top Up Balance';

  @override
  String get txReceive => 'Receive Balance';

  @override
  String get txSend => 'Send Balance';

  @override
  String get settings => 'Settings';

  @override
  String get accountSecurity => 'ACCOUNT & SECURITY';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changePin => 'Change PIN';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get generalInfo => 'GENERAL INFO';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get checkDevice => 'Check Device Status';

  @override
  String get logout => 'Logout from Nirpay';

  @override
  String get history => 'Transaction History';

  @override
  String get searchTx => 'Search Transactions';

  @override
  String get filterAll => 'All';

  @override
  String get filterIn => 'In';

  @override
  String get filterOut => 'Out';
}
