import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'NirPay'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In id, this message translates to:
  /// **'Halo,'**
  String get hello;

  /// No description provided for @availableBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Tersedia'**
  String get availableBalance;

  /// No description provided for @syncStatus.
  ///
  /// In id, this message translates to:
  /// **'Status Sinkronisasi'**
  String get syncStatus;

  /// No description provided for @onlineStatus.
  ///
  /// In id, this message translates to:
  /// **'Online (Tersinkron)'**
  String get onlineStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In id, this message translates to:
  /// **'Offline (Belum Tersinkron)'**
  String get offlineStatus;

  /// No description provided for @recentTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Terakhir'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get noTransactions;

  /// No description provided for @actionSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get actionSend;

  /// No description provided for @actionReceive.
  ///
  /// In id, this message translates to:
  /// **'Terima'**
  String get actionReceive;

  /// No description provided for @actionTopUp.
  ///
  /// In id, this message translates to:
  /// **'Top Up'**
  String get actionTopUp;

  /// No description provided for @actionWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Withdraw'**
  String get actionWithdraw;

  /// No description provided for @actionSync.
  ///
  /// In id, this message translates to:
  /// **'Sync'**
  String get actionSync;

  /// No description provided for @actionTapToPay.
  ///
  /// In id, this message translates to:
  /// **'Tap to Pay'**
  String get actionTapToPay;

  /// No description provided for @txTopUp.
  ///
  /// In id, this message translates to:
  /// **'Top Up Saldo'**
  String get txTopUp;

  /// No description provided for @txReceive.
  ///
  /// In id, this message translates to:
  /// **'Terima Saldo'**
  String get txReceive;

  /// No description provided for @txSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim Saldo'**
  String get txSend;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @accountSecurity.
  ///
  /// In id, this message translates to:
  /// **'AKUN & KEAMANAN'**
  String get accountSecurity;

  /// No description provided for @personalInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Pribadi'**
  String get personalInfo;

  /// No description provided for @changePin.
  ///
  /// In id, this message translates to:
  /// **'Ganti PIN'**
  String get changePin;

  /// No description provided for @preferences.
  ///
  /// In id, this message translates to:
  /// **'PREFERENSI'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @generalInfo.
  ///
  /// In id, this message translates to:
  /// **'INFORMASI UMUM'**
  String get generalInfo;

  /// No description provided for @helpCenter.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get helpCenter;

  /// No description provided for @checkDevice.
  ///
  /// In id, this message translates to:
  /// **'Cek Status Device'**
  String get checkDevice;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Logout dari Nirpay'**
  String get logout;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get history;

  /// No description provided for @searchTx.
  ///
  /// In id, this message translates to:
  /// **'Cari Transaksi'**
  String get searchTx;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @filterIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get filterIn;

  /// No description provided for @filterOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get filterOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
