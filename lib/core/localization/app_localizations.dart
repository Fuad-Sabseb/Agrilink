import 'package:flutter/material.dart';

/// AgriLink Localization Support
/// Afaan Oromoo (om), Amharic (am), and English (en)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method to access localizations from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Static delegate for flutter_localizations
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('om'), // Afaan Oromoo
    Locale('am'), // Amharic
    Locale('en'), // English
  ];

  /// Localized strings map
  static final Map<String, Map<String, String>> _localizedValues = {
    'om': _om, // Afaan Oromoo
    'am': _am, // Amharic
    'en': _en, // English
  };

  /// Get translated string
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // ============================================================================
  // CONVENIENCE GETTERS - Common UI Strings
  // ============================================================================

  // Navigation
  String get home => translate('home');
  String get marketIntelligence => translate('market_intelligence');
  String get marketplace => translate('marketplace');
  String get orders => translate('orders');
  String get profile => translate('profile');

  // Common Actions
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get refresh => translate('refresh');
  String get submit => translate('submit');

  // User Roles
  String get roleFarmer => translate('role_farmer');
  String get roleBuyer => translate('role_buyer');
  String get roleTransporter => translate('role_transporter');
  String get roleBureau => translate('role_bureau');

  // Commodities
  String get coffee => translate('coffee');
  String get maize => translate('maize');
  String get teff => translate('teff');
  String get wheat => translate('wheat');
  String get potato => translate('potato');

  // Core Features
  String get whereShouldISell => translate('where_should_i_sell');
  String get priceComparison => translate('price_comparison');
  String get nearbyMarkets => translate('nearby_markets');
  String get activeBuyers => translate('active_buyers');

  // Units
  String get etbPerKg => translate('etb_per_kg');
  String get kg => translate('kg');
  String get quintal => translate('quintal');
  String get birr => translate('birr');

  // Time
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('this_week');

  // Farm Management
  String get totalHectares => translate('total_hectares');
  String get crops => translate('crops');
  String get primaryCrop => translate('primary_crop');
  String get addFarm => translate('add_farm');
  String get editFarm => translate('edit_farm');
  String get farmName => translate('farm_name');
  String get enterFarmName => translate('enter_farm_name');
  String get farmNameRequired => translate('farm_name_required');
  String get enterLocation => translate('enter_location');
  String get locationRequired => translate('location_required');
  String get gpsCoordinates => translate('gps_coordinates');
  String get getCurrentLocation => translate('get_current_location');
  String get latitude => translate('latitude');
  String get longitude => translate('longitude');
  String get invalidNumber => translate('invalid_number');
  String get latitudeRange => translate('latitude_range');
  String get longitudeRange => translate('longitude_range');
  String get gpsOptionalInfo => translate('gps_optional_info');
  String get saveChanges => translate('save_changes');
  String get gpsFeatureComingSoon => translate('gps_feature_coming_soon');

  // ============================================================================
  // PHASE 9 TRANSLATIONS - Settings, Theme, Language, Notifications, Profile
  // ============================================================================

  // Settings
  String get settings => translate('settings');
  String get generalSettings => translate('general_settings');
  String get accountSettings => translate('account_settings');
  String get privacySettings => translate('privacy_settings');
  String get notificationSettings => translate('notification_settings');
  String get marketUpdates => translate('market_updates');
  String get appSettings => translate('app_settings');
  String get dataSync => translate('data_sync');
  String get syncNow => translate('sync_now');
  String get lastSync => translate('last_sync');
  String get autoSync => translate('auto_sync');
  String get syncEnabled => translate('sync_enabled');
  String get syncDisabled => translate('sync_disabled');
  String get offlineMode => translate('offline_mode');
  String get clearCache => translate('clear_cache');
  String get cacheCleared => translate('cache_cleared');

  // Theme Settings
  String get theme => translate('theme');
  String get themeSettings => translate('theme_settings');
  String get lightMode => translate('light_mode');
  String get darkMode => translate('dark_mode');
  String get systemDefault => translate('system_default');
  String get chooseTheme => translate('choose_theme');
  String get appearance => translate('appearance');

  // Language Settings
  String get language => translate('language');
  String get languageSettings => translate('language_settings');
  String get changeLanguage => translate('change_language');
  String get selectLanguage => translate('select_language');
  String get afaanOromoo => translate('afaan_oromoo');
  String get amharic => translate('amharic');
  String get english => translate('english');
  String get languageChanged => translate('language_changed');
  String get restartRequired => translate('restart_required');

  // Notification Settings
  String get enableNotifications => translate('enable_notifications');
  String get disableNotifications => translate('disable_notifications');
  String get notificationSound => translate('notification_sound');
  String get vibration => translate('vibration');
  String get orderNotifications => translate('order_notifications');
  String get transportNotifications => translate('transport_notifications');
  String get priceAlerts => translate('price_alerts');
  String get systemNotifications => translate('system_notifications');
  String get marketingNotifications => translate('marketing_notifications');
  String get pushNotifications => translate('push_notifications');
  String get doNotDisturb => translate('do_not_disturb');
  String get notificationChannels => translate('notification_channels');
  String get notificationPreferences => translate('notification_preferences');

  // Profile
  String get myProfile => translate('my_profile');
  String get editProfile => translate('edit_profile');
  String get viewProfile => translate('view_profile');
  String get profileSettings => translate('profile_settings');
  String get fullName => translate('full_name');
  String get email => translate('email');
  String get phoneNumber => translate('phone_number');
  String get profilePicture => translate('profile_picture');
  String get changeProfilePicture => translate('change_profile_picture');
  String get removeProfilePicture => translate('remove_profile_picture');
  String get updateProfile => translate('update_profile');
  String get profileUpdated => translate('profile_updated');
  String get profileUpdateFailed => translate('profile_update_failed');

  // Account Management
  String get changePassword => translate('change_password');
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get confirmPassword => translate('confirm_password');
  String get passwordChanged => translate('password_changed');
  String get passwordMismatch => translate('password_mismatch');
  String get passwordTooShort => translate('password_too_short');
  String get deleteAccount => translate('delete_account');
  String get confirmDeleteAccount => translate('confirm_delete_account');
  String get accountDeleted => translate('account_deleted');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');

  // Help & Support
  String get help => translate('help');
  String get helpSupport => translate('help_support');
  String get faq => translate('faq');
  String get contactSupport => translate('contact_support');
  String get reportIssue => translate('report_issue');
  String get sendFeedback => translate('send_feedback');
  String get tutorial => translate('tutorial');
  String get gettingStarted => translate('getting_started');
  String get userGuide => translate('user_guide');
  String get termsOfService => translate('terms_of_service');
  String get privacyPolicy => translate('privacy_policy');
  String get aboutApp => translate('about_app');
  String get appVersion => translate('app_version');
  String get checkForUpdates => translate('check_for_updates');
  String get updateAvailable => translate('update_available');
  String get noUpdatesAvailable => translate('no_updates_available');

  // Transactions
  String get transactions => translate('transactions');
  String get myTransactions => translate('my_transactions');
  String get transactionHistory => translate('transaction_history');
  String get transactionDetails => translate('transaction_details');
  String get filterTransactions => translate('filter_transactions');
  String get exportTransactions => translate('export_transactions');
  String get dateRange => translate('date_range');
  String get startDate => translate('start_date');
  String get endDate => translate('end_date');
  String get selectDateRange => translate('select_date_range');
  String get allTransactions => translate('all_transactions');
  String get recentTransactions => translate('recent_transactions');
  String get transactionType => translate('transaction_type');
  String get transactionAmount => translate('transaction_amount');
  String get transactionDate => translate('transaction_date');
  String get transactionId => translate('transaction_id');
  String get paymentMethod => translate('payment_method');
  String get paymentStatus => translate('payment_status');

  // States - Loading
  String get loadingData => translate('loading_data');
  String get pleaseWait => translate('please_wait');
  String get processing => translate('processing');
  String get fetchingData => translate('fetching_data');
  String get syncing => translate('syncing');
  String get uploading => translate('uploading');
  String get downloading => translate('downloading');
  String get savingChanges => translate('saving_changes');

  // States - No Data
  String get noDataAvailable => translate('no_data_available');
  String get noResultsFound => translate('no_results_found');
  String get noNotifications => translate('no_notifications');
  String get noTransactions => translate('no_transactions');
  String get noOrders => translate('no_orders');
  String get noFarms => translate('no_farms');
  String get noMarkets => translate('no_markets');
  String get emptyList => translate('empty_list');
  String get nothingToShow => translate('nothing_to_show');

  // States - Error
  String get errorOccurred => translate('error_occurred');
  String get somethingWentWrong => translate('something_went_wrong');
  String get connectionError => translate('connection_error');
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get timeoutError => translate('timeout_error');
  String get authenticationError => translate('authentication_error');
  String get permissionDenied => translate('permission_denied');
  String get notFound => translate('not_found');
  String get invalidData => translate('invalid_data');

  // States - Retry
  String get retry => translate('retry');
  String get tryAgain => translate('try_again');
  String get retryLater => translate('retry_later');
  String get tapToRetry => translate('tap_to_retry');
  String get pullToRefresh => translate('pull_to_refresh');
  String get swipeToRefresh => translate('swipe_to_refresh');

  // Role Switching
  String get switchRole => translate('switch_role');
  String get currentRole => translate('current_role');
  String get selectRole => translate('select_role');
  String get roleSwitched => translate('role_switched');
  String get switchToFarmer => translate('switch_to_farmer');
  String get switchToBuyer => translate('switch_to_buyer');
  String get switchToTransporter => translate('switch_to_transporter');
  String get switchToBureau => translate('switch_to_bureau');

  // Woreda Switching
  String get switchWoreda => translate('switch_woreda');
  String get currentWoreda => translate('current_woreda');
  String get selectWoreda => translate('select_woreda');
  String get woredaSwitched => translate('woreda_switched');
  String get changeWoreda => translate('change_woreda');
  String get noWoredaSelected => translate('no_woreda_selected');

  // Location Services
  String get locationServices => translate('location_services');
  String get enableLocation => translate('enable_location');
  String get locationPermission => translate('location_permission');
  String get locationPermissionRequired => translate('location_permission_required');
  String get locationPermissionDenied => translate('location_permission_denied');
  String get locationNotAvailable => translate('location_not_available');
  String get locationError => translate('location_error');
  String get acquiringLocation => translate('acquiring_location');
  String get useCurrentLocation => translate('use_current_location');
  String get locationAccuracy => translate('location_accuracy');
  String get distanceToMarket => translate('distance_to_market');

  // Notification Messages
  String get notificationReceived => translate('notification_received');
  String get markAsRead => translate('mark_as_read');
  String get markAllAsRead => translate('mark_all_as_read');
  String get clearNotifications => translate('clear_notifications');
  String get notificationHistory => translate('notification_history');
  String get unreadNotifications => translate('unread_notifications');
  String get readNotifications => translate('read_notifications');
  String get newNotification => translate('new_notification');
  String get youHaveNewNotifications => translate('you_have_new_notifications');

  // Validation Messages
  String get fieldRequired => translate('field_required');
  String get invalidEmail => translate('invalid_email');
  String get invalidPhoneNumber => translate('invalid_phone_number');
  String get invalidInput => translate('invalid_input');
  String get valueTooLow => translate('value_too_low');
  String get valueTooHigh => translate('value_too_high');
  String get enterValidValue => translate('enter_valid_value');
  String get passwordRequired => translate('password_required');
  String get emailRequired => translate('email_required');

  // Confirmation Messages
  String get areYouSure => translate('are_you_sure');
  String get confirmAction => translate('confirm_action');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get dismiss => translate('dismiss');
  String get continue_ => translate('continue');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');

  // Success Messages
  String get successfullyUpdated => translate('successfully_updated');
  String get successfullySaved => translate('successfully_saved');
  String get successfullyDeleted => translate('successfully_deleted');
  String get operationSuccessful => translate('operation_successful');
  String get changesSaved => translate('changes_saved');

  // App Info
  String get developedBy => translate('developed_by');
  String get copyright => translate('copyright');
  String get allRightsReserved => translate('all_rights_reserved');
  String get contactUs => translate('contact_us');
  String get followUs => translate('follow_us');
  String get rateApp => translate('rate_app');
  String get shareApp => translate('share_app');
}

// ============================================================================
// AFAAN OROMOO (om) Translations
// ============================================================================

const Map<String, String> _om = {
  // Navigation
  'home': 'Mana',
  'market_intelligence': 'Odeeffannoo Gabaa',
  'marketplace': 'Gabaa',
  'orders': 'Ajajawwan',
  'profile': 'Piiroofaayilii',

  // Common Actions
  'save': 'Olkaa\'i',
  'cancel': 'Haqii',
  'delete': 'Haqi',
  'edit': 'Gulaali',
  'search': 'Barbaadi',
  'filter': 'Gingilchii',
  'refresh': 'Haaromsi',
  'submit': 'Ergi',

  // User Roles
  'role_farmer': 'Qotee Bulaa',
  'role_buyer': 'Daldalaa',
  'role_transporter': 'Geessaa',
  'role_bureau': 'Biiroo Qonnaa',

  // Commodities
  'coffee': 'Buna',
  'maize': 'Boqqoo',
  'teff': 'Xaafii',
  'wheat': 'Qamadii',
  'potato': 'Dinnichii',

  // Core Features
  'where_should_i_sell': 'Eessatti Gurguruu Qaba?',
  'price_comparison': 'Madaallii Gatii',
  'nearby_markets': 'Gabaalee Dhiyoo',
  'active_buyers': 'Daldaltoonni Hojjetan',

  // Units
  'etb_per_kg': 'Qarshii/kg',
  'kg': 'kg',
  'quintal': 'Kuwaantaala',
  'birr': 'Qarshii',

  // Time
  'today': 'Har\'a',
  'yesterday': 'Kaleessa',
  'this_week': 'Torban Kana',

  // Dashboard
  'welcome': 'Baga Nagaan Dhuftan',
  'select_woreda': 'Aanaa Filadhu',
  'notifications': 'Beeksisa',

  // Market Intelligence
  'current_prices': 'Gatii Ammaa',
  'price_trends': 'Adeemsa Gatii',
  'best_market': 'Gabaa Gaarii',
  'transport_cost': 'Baasii Geejjibaa',
  'net_revenue': 'Galii Qulqulluu',

  // Marketplace
  'post_demand': 'Barbaachisummaa Maxxansi',
  'find_buyers': 'Bitattootaa Barbaadi',
  'find_sellers': 'Gurgurtoota Barbaadi',
  'verified_buyer': 'Bitattoo Mirkaneeffame',
  'buying_now': 'Amma Bitaa Jira',

  // Forms
  'quantity': 'Hamma',
  'quality': 'Qulqullina',
  'location': 'Bakka',
  'phone_number': 'Lakkoofsa Bilbilaa',
  'price_offer': 'Gatii Dhiyeessitu',

  // Status
  'pending': 'Eegaa Jira',
  'confirmed': 'Mirkaneeffame',
  'in_transit': 'Karaa Irra',
  'delivered': 'Geeffame',
  'completed': 'Xummurame',

  // Messages
  'no_data': 'Daataan Hin Jiru',
  'loading': 'Fe\'aa jira...',
  'error': 'Dogongora',
  'success': 'Milkaa\'ine',

  // Farm Management
  'total_hectares': 'Heektara Waliigalaa',
  'crops': 'Midhaan',
  'primary_crop': 'Midhaan Ijoo',
  'add_farm': 'Qonna Ida\'i',
  'edit_farm': 'Qonna Gulaali',
  'farm_name': 'Maqaa Qonnaa',
  'enter_farm_name': 'Maqaa Qonnaa Galchi',
  'farm_name_required': 'Maqaan Qonnaa Barbaachisaadha',
  'enter_location': 'Bakka Galchi',
  'location_required': 'Bakkii Barbaachisaadha',
  'gps_coordinates': 'Bakka GPS',
  'get_current_location': 'Bakka Ammaa Argadhu',
  'latitude': 'Latitude',
  'longitude': 'Longitude',
  'invalid_number': 'Lakkoofsi Sirrii Miti',
  'latitude_range': 'Latitude -90 hanga 90 ta\'uu qaba',
  'longitude_range': 'Longitude -180 hanga 180 ta\'uu qaba',
  'gps_optional': 'GPS filannoodha',
  'gps_optional_info': 'GPS filannoodha. Ykn yeroo dhufu dabaluu dandeessa.',
  'save_changes': 'Jijjirama Olkaa\'i',
  'gps_feature_coming_soon': 'Kennaan GPS dhiyootti ni dhufa',

  // Phase 9 - Settings
  'settings': 'Qindaa\'ina',
  'general_settings': 'Qindaa\'ina Waliigalaa',
  'account_settings': 'Qindaa\'ina Herregaa',
  'privacy_settings': 'Qindaa\'ina Iccitii',
  'notification_settings': 'Qindaa\'ina Beeksisa',
  'app_settings': 'Qindaa\'ina Appii',
  'data_sync': 'Walsimsiisuu Daataa',
  'sync_now': 'Amma Walsimsiisi',
  'last_sync': 'Walsimsiisaa Dhumaa',
  'auto_sync': 'Ofumaan Walsimsiisuu',
  'sync_enabled': 'Walsimsiisuu Dandeessifame',
  'sync_disabled': 'Walsimsiisuu Dhaabame',
  'offline_mode': 'Haalata Offline',
  'clear_cache': 'Cache Qulqulleessi',
  'cache_cleared': 'Cache Qulqulleeffame',

  // Theme
  'theme': 'Bifaa',
  'theme_settings': 'Qindaa\'ina Bifaa',
  'light_mode': 'Haalata Ifaa',
  'dark_mode': 'Haalata Dukkana',
  'system_default': 'Durta Sirnaa',
  'choose_theme': 'Bifaa Filadhu',
  'appearance': 'Mul\'ata',

  // Language
  'language': 'Afaan',
  'language_settings': 'Qindaa\'ina Afaanii',
  'change_language': 'Afaan Jijjiiri',
  'select_language': 'Afaan Filadhu',
  'afaan_oromoo': 'Afaan Oromoo',
  'amharic': 'Amaariffaa',
  'english': 'Ingiliffaa',
  'language_changed': 'Afaan Jijjiirame',
  'restart_required': 'Irra Deebi\'uun Barbaachisa',

  // Notifications
  'enable_notifications': 'Beeksisa Dandeessisi',
  'disable_notifications': 'Beeksisa Dhaabi',
  'notification_sound': 'Sagalee Beeksisa',
  'vibration': 'Hollannoo',
  'order_notifications': 'Beeksisa Ajajaa',
  'transport_notifications': 'Beeksisa Geejjibaa',
  'price_alerts': 'Beeksisa Gatii',
  'system_notifications': 'Beeksisa Sirnaaa',
  'marketing_notifications': 'Beeksisa Gabaa',
  'push_notifications': 'Beeksisa Dhiheeffama',
  'do_not_disturb': 'Hin Rakkisin',
  'notification_channels': 'Jaannalii Beeksisa',
  'notification_preferences': 'Filannoo Beeksisa',

  // Profile
  'my_profile': 'Piiroofaayilii Koo',
  'edit_profile': 'Piiroofaayilii Gulaali',
  'view_profile': 'Piiroofaayilii Ilaali',
  'profile_settings': 'Qindaa\'ina Piiroofaayilii',
  'full_name': 'Maqaa Guutuu',
  'email': 'Iimeelii',
  'profile_picture': 'Suuraa Piiroofaayilii',
  'remove_profile_picture': 'Suuraa Piiroofaayilii Haqi',
  'update_profile': 'Piiroofaayilii Haaromsi',
  'profile_updated': 'Piiroofaayiliin Haaromfame',
  'profile_update_failed': 'Haaromsuu Piiroofaayilii Dadhabe',

  // Account Management
  'change_password': 'Jechibarruu Jijjiiri',
  'current_password': 'Jechibarruu Ammaa',
  'new_password': 'Jechibarruu Haaraa',
  'confirm_password': 'Jechibarruu Mirkaneessi',
  'password_changed': 'Jechibarruun Jijjiirame',
  'password_mismatch': 'Jechibarruun Hin Walsimne',
  'password_too_short': 'Jechibarruun Baay\'ee Gabaabaa',
  'delete_account': 'Herrega Haqi',
  'confirm_delete_account': 'Haqquu Herregaa Mirkaneessi',
  'account_deleted': 'Herregni Haqame',
  'logout': 'Ba\'i',
  'logout_confirm': 'Ba\'uun Kee Mirkaneessa?',

  // Help & Support
  'help': 'Gargaarsa',
  'help_support': 'Gargaarsa & Deeggarsaa',
  'faq': 'Gaaffii Irra Deddeebiin Gaafataman',
  'contact_support': 'Gargaarsaa Quunnamii',
  'report_issue': 'Dhimma Gabaasi',
  'send_feedback': 'Yaada Ergi',
  'tutorial': 'Barnoota',
  'getting_started': 'Eegaluu',
  'user_guide': 'Qajeelfama Fayyadamaa',
  'terms_of_service': 'Haalota Tajaajilaa',
  'privacy_policy': 'Imaammata Iccitii',
  'about_app': 'Waa\'ee Appii',
  'app_version': 'Qubee Appii',
  'check_for_updates': 'Haaromsaa Sakatta\'i',
  'update_available': 'Haaromsi Ni Jira',
  'no_updates_available': 'Haaromsi Hin Jiru',

  // Transactions
  'transactions': 'Daldalaa',
  'my_transactions': 'Daldalaa Koo',
  'transaction_history': 'Seenaa Daldalaa',
  'transaction_details': 'Bal\'ina Daldalaa',
  'filter_transactions': 'Daldalaa Gingilchii',
  'export_transactions': 'Daldalaa Ergii',
  'date_range': 'Hangii Guyyaa',
  'start_date': 'Guyyaa Jalqabaa',
  'end_date': 'Guyyaa Xumuraa',
  'select_date_range': 'Hangii Guyyaa Filadhu',
  'all_transactions': 'Daldalaa Hunda',
  'recent_transactions': 'Daldalaa Dhiyeenya',
  'transaction_type': 'Gosa Daldalaa',
  'transaction_amount': 'Hamma Daldalaa',
  'transaction_date': 'Guyyaa Daldalaa',
  'transaction_id': 'Eenyummaa Daldalaa',
  'payment_method': 'Mala Kaffaltii',
  'payment_status': 'Haala Kaffaltii',

  // States - Loading
  'loading_data': 'Daataa Fe\'aa Jira',
  'please_wait': 'Mee Eegi',
  'processing': 'Adeemsisaa Jira',
  'fetching_data': 'Daataa Fidaa Jira',
  'syncing': 'Walsimsiisaa Jira',
  'uploading': 'Ol Fe\'aa Jira',
  'downloading': 'Gadi Buusaa Jira',
  'saving_changes': 'Jijjiirama Olkaa\'aa Jira',

  // States - No Data
  'no_data_available': 'Daataan Hin Argamu',
  'no_results_found': 'Bu\'aan Hin Argamne',
  'no_notifications': 'Beeksisni Hin Jiru',
  'no_transactions': 'Daldalaan Hin Jiru',
  'no_orders': 'Ajajni Hin Jiru',
  'no_farms': 'Qonni Hin Jiru',
  'no_markets': 'Gabaan Hin Jiru',
  'empty_list': 'Tarreen Duwwaa',
  'nothing_to_show': 'Wanti Mul\'ifamu Hin Jiru',

  // States - Error
  'error_occurred': 'Dogongorri Uumame',
  'something_went_wrong': 'Wanti Tokko Dogoggore',
  'connection_error': 'Dogongora Wal Geessaa',
  'network_error': 'Dogongora Networkii',
  'server_error': 'Dogongora Serveraa',
  'timeout_error': 'Dogongora Yeroo Dabraa',
  'authentication_error': 'Dogongora Mirkaneessaa',
  'permission_denied': 'Eeyyamni Hanqate',
  'not_found': 'Hin Argamne',
  'invalid_data': 'Daataan Sirrii Miti',

  // States - Retry
  'retry': 'Irra Deebi\'ii Yaali',
  'try_again': 'Deebi\'ii Yaali',
  'retry_later': 'Booda Yaali',
  'tap_to_retry': 'Irra Deebi\'ii Yaaluuf Tuqi',
  'pull_to_refresh': 'Haaromsuuf Harkisi',
  'swipe_to_refresh': 'Haaromsuuf Qiriinsi',

  // Role Switching
  'switch_role': 'Gahee Jijjiiri',
  'current_role': 'Gahee Ammaa',
  'select_role': 'Gahee Filadhu',
  'role_switched': 'Gaheen Jijjiirame',
  'switch_to_farmer': 'Gara Qotee Bulaatti Jijjiiri',
  'switch_to_buyer': 'Gara Daldalaatti Jijjiiri',
  'switch_to_transporter': 'Gara Geessaatti Jijjiiri',
  'switch_to_bureau': 'Gara Biiroo Qonnaatti Jijjiiri',

  // Woreda Switching
  'switch_woreda': 'Aanaa Jijjiiri',
  'current_woreda': 'Aanaa Ammaa',
  'woreda_switched': 'Aanaan Jijjiirame',
  'no_woreda_selected': 'Aanaan Hin Filatamne',

  // Location Services
  'location_services': 'Tajaajila Bakka',
  'enable_location': 'Bakka Dandeessisi',
  'location_permission': 'Eeyyama Bakka',
  'location_permission_required': 'Eeyyamni Bakka Barbaachisa',
  'location_permission_denied': 'Eeyyamni Bakka Hanqate',
  'location_not_available': 'Bakkii Hin Jiru',
  'location_error': 'Dogongora Bakka',
  'acquiring_location': 'Bakka Argachaa Jira',
  'use_current_location': 'Bakka Ammaa Fayyadami',
  'location_accuracy': 'Sirrii Bakka',
  'distance_to_market': 'Fageenya Gara Gabaatti',

  // Notification Messages
  'notification_received': 'Beeksisni Argame',
  'mark_as_read': 'Akka Dubbifametti Mallattoo Godhi',
  'mark_all_as_read': 'Hunda Akka Dubbifametti Mallattoo Godhi',
  'clear_notifications': 'Beeksisa Qulqulleessi',
  'notification_history': 'Seenaa Beeksisa',
  'unread_notifications': 'Beeksisa Hin Dubbifamne',
  'read_notifications': 'Beeksisa Dubbifame',
  'new_notification': 'Beeksisa Haaraa',
  'you_have_new_notifications': 'Beeksisa Haaraa Qabda',

  // Validation Messages
  'field_required': 'Dirreen Barbaachisa',
  'invalid_email': 'Iimeeliin Sirrii Miti',
  'invalid_phone_number': 'Lakkoofsi Bilbilaa Sirrii Miti',
  'invalid_input': 'Galchaan Sirrii Miti',
  'value_too_low': 'Gatiin Baay\'ee Gadi',
  'value_too_high': 'Gatiin Baay\'ee Ol\'aana',
  'enter_valid_value': 'Gatii Sirrii Ta\'e Galchi',
  'password_required': 'Jechibarruun Barbaachisa',
  'email_required': 'Iimeeliin Barbaachisa',

  // Confirmation Messages
  'are_you_sure': 'Mirkaneessita?',
  'confirm_action': 'Gocha Mirkaneessi',
  'confirm': 'Mirkaneessi',
  'yes': 'Eeyyen',
  'no': 'Lakkii',
  'ok': 'Tole',
  'close': 'Cufi',
  'dismiss': 'Gati',
  'continue': 'Itti Fufi',
  'back': 'Duuba',
  'next': 'Itti Aanu',
  'done': 'Xumuruu',

  // Success Messages
  'successfully_updated': 'Milkaa\'inaan Haaromfame',
  'successfully_saved': 'Milkaa\'inaan Olkaa\'ame',
  'successfully_deleted': 'Milkaa\'inaan Haqame',
  'operation_successful': 'Hojiin Milkaa\'e',
  'changes_saved': 'Jijjiramni Olkaa\'ame',

  // App Info
  'developed_by': 'Kan Misoome',
  'copyright': 'Mirga Koopii',
  'all_rights_reserved': 'Mirgi Hundi Eegame',
  'contact_us': 'Nu Quunnamaa',
  'follow_us': 'Nu Hordofi',
  'rate_app': 'Appii Madaali',
  'share_app': 'Appii Qoodi',
};

// ============================================================================
// AMHARIC (am) Translations
// ============================================================================

const Map<String, String> _am = {
  // Navigation
  'home': 'መነሻ',
  'market_intelligence': 'የገበያ መረጃ',
  'marketplace': 'ገበያ',
  'orders': 'ትዕዛዞች',
  'profile': 'መገለጫ',

  // Common Actions
  'save': 'አስቀምጥ',
  'cancel': 'ሰርዝ',
  'delete': 'ሰርዝ',
  'edit': 'አርትዕ',
  'search': 'ፈልግ',
  'filter': 'አጣራ',
  'refresh': 'አድስ',
  'submit': 'ላክ',

  // User Roles
  'role_farmer': 'ገበሬ',
  'role_buyer': 'ገዢ',
  'role_transporter': 'ተሸካሚ',
  'role_bureau': 'ቢሮ ሰራተኛ',

  // Commodities
  'coffee': 'ቡና',
  'maize': 'በቆሎ',
  'teff': 'ጤፍ',
  'wheat': 'ስንዴ',
  'potato': 'ድንች',

  // Core Features
  'where_should_i_sell': 'የት መሸጥ አለብኝ?',
  'price_comparison': 'የዋጋ ማወዳደሪያ',
  'nearby_markets': 'በአቅራቢያ ያሉ ገበያዎች',
  'active_buyers': 'ንቁ ገዢዎች',

  // Units
  'etb_per_kg': 'ብር/ኪግ',
  'kg': 'ኪግ',
  'quintal': 'ኩንታል',
  'birr': 'ብር',

  // Time
  'today': 'ዛሬ',
  'yesterday': 'ትናንት',
  'this_week': 'በዚህ ሳምንት',

  // Dashboard
  'welcome': 'እንኳን በደህና መጡ',
  'select_woreda': 'ወረዳ ይምረጡ',
  'notifications': 'ማሳወቂያዎች',

  // Market Intelligence
  'current_prices': 'የአሁን ዋጋዎች',
  'price_trends': 'የዋጋ አዝማሚያዎች',
  'best_market': 'ምርጥ ገበያ',
  'transport_cost': 'የትራንስፖርት ወጪ',
  'net_revenue': 'የተጣራ ገቢ',

  // Marketplace
  'post_demand': 'ፍላጎት ለጥፍ',
  'find_buyers': 'ገዢዎችን ያግኙ',
  'find_sellers': 'ሻጮችን ያግኙ',
  'verified_buyer': 'የተረጋገጠ ገዢ',
  'buying_now': 'አሁን እየገዛ ነው',

  // Forms
  'quantity': 'ብዛት',
  'quality': 'ጥራት',
  'location': 'ቦታ',
  'phone_number': 'ስልክ ቁጥር',
  'price_offer': 'የዋጋ አቅርቦት',

  // Status
  'pending': 'በመጠባበቅ ላይ',
  'confirmed': 'ተረጋግጧል',
  'in_transit': 'በመንገድ ላይ',
  'delivered': 'ደርሷል',
  'completed': 'ተጠናቅቋል',

  // Messages
  'no_data': 'መረጃ የለም',
  'loading': 'በመጫን ላይ...',
  'error': 'ስህተት',
  'success': 'ተሳክቷል',

  // Farm Management
  'total_hectares': 'ጠቅላላ ሄክታር',
  'crops': 'ሰብሎች',
  'primary_crop': 'ዋና ሰብል',
  'add_farm': 'እርሻ አክል',
  'edit_farm': 'እርሻ አርትዕ',
  'farm_name': 'የእርሻ ስም',
  'enter_farm_name': 'የእርሻ ስም አስገባ',
  'farm_name_required': 'የእርሻ ስም ያስፈልጋል',
  'enter_location': 'ቦታ አስገባ',
  'location_required': 'ቦታ ያስፈልጋል',
  'gps_coordinates': 'የጂፒኤስ መጋጠሚያዎች',
  'get_current_location': 'አሁን ያለበት ቦታ አግኝ',
  'latitude': 'Latitude',
  'longitude': 'Longitude',
  'invalid_number': 'የተሳሳተ ቁጥር',
  'latitude_range': 'Latitude ከ-90 እስከ 90 መሆን አለበት',
  'longitude_range': 'Longitude ከ-180 እስከ 180 መሆን አለበት',
  'gps_optional': 'ጂፒኤስ አማራጭ ነው',
  'gps_optional_info': 'ጂፒኤስ አማራጭ ነው። በኋላ ማከል ይችላሉ።',
  'save_changes': 'ለውጦችን አስቀምጥ',
  'gps_feature_coming_soon': 'የጂፒኤስ ባህሪ በቅርቡ ይመጣል',

  // Phase 9 - Settings
  'settings': 'ቅንብሮች',
  'general_settings': 'አጠቃላይ ቅንብሮች',
  'account_settings': 'የመለያ ቅንብሮች',
  'privacy_settings': 'የግላዊነት ቅንብሮች',
  'notification_settings': 'የማሳወቂያ ቅንብሮች',
  'app_settings': 'የመተግበሪያ ቅንብሮች',
  'data_sync': 'መረጃ ማመሳሰል',
  'sync_now': 'አሁን አመሳስል',
  'last_sync': 'የመጨረሻ ማመሳሰል',
  'auto_sync': 'ራስ-ሰር ማመሳሰል',
  'sync_enabled': 'ማመሳሰል ነቅቷል',
  'sync_disabled': 'ማመሳሰል ቦዝኗል',
  'offline_mode': 'ከመስመር ውጭ ሁኔታ',
  'clear_cache': 'መሸጎጫ አጽዳ',
  'cache_cleared': 'መሸጎጫ ተጽድቷል',

  // Theme
  'theme': 'ገጽታ',
  'theme_settings': 'የገጽታ ቅንብሮች',
  'light_mode': 'የብርሃን ሁኔታ',
  'dark_mode': 'የጨለማ ሁኔታ',
  'system_default': 'የስርዓት ነባሪ',
  'choose_theme': 'ገጽታ ይምረጡ',
  'appearance': 'መልክ',

  // Language
  'language': 'ቋንቋ',
  'language_settings': 'የቋንቋ ቅንብሮች',
  'change_language': 'ቋንቋ ይቀይሩ',
  'select_language': 'ቋንቋ ይምረጡ',
  'afaan_oromoo': 'አፋን ኦሮሞ',
  'amharic': 'አማርኛ',
  'english': 'እንግሊዝኛ',
  'language_changed': 'ቋንቋ ተቀይሯል',
  'restart_required': 'እንደገና ማስጀመር ያስፈልጋል',

  // Notifications
  'enable_notifications': 'ማሳወቂያዎችን አንቃ',
  'disable_notifications': 'ማሳወቂያዎችን አቦዝን',
  'notification_sound': 'የማሳወቂያ ድምጽ',
  'vibration': 'ንዝረት',
  'order_notifications': 'የትዕዛዝ ማሳወቂያዎች',
  'transport_notifications': 'የትራንስፖርት ማሳወቂያዎች',
  'price_alerts': 'የዋጋ ማስጠንቀቂያዎች',
  'system_notifications': 'የስርዓት ማሳወቂያዎች',
  'marketing_notifications': 'የግብይት ማሳወቂያዎች',
  'push_notifications': 'የግፊት ማሳወቂያዎች',
  'do_not_disturb': 'አትረብሽ',
  'notification_channels': 'የማሳወቂያ ቻናሎች',
  'notification_preferences': 'የማሳወቂያ ምርጫዎች',

  // Profile
  'my_profile': 'የእኔ መገለጫ',
  'edit_profile': 'መገለጫ አርትዕ',
  'view_profile': 'መገለጫ ይመልከቱ',
  'profile_settings': 'የመገለጫ ቅንብሮች',
  'full_name': 'ሙሉ ስም',
  'email': 'ኢሜይል',
  'profile_picture': 'የመገለጫ ምስል',
  'remove_profile_picture': 'የመገለጫ ምስል ያስወግዱ',
  'update_profile': 'መገለጫ አዘምን',
  'profile_updated': 'መገለጫ ተዘምኗል',
  'profile_update_failed': 'መገለጫ ማዘመን አልተሳካም',

  // Account Management
  'change_password': 'የይለፍ ቃል ይቀይሩ',
  'current_password': 'የአሁኑ የይለፍ ቃል',
  'new_password': 'አዲስ የይለፍ ቃል',
  'confirm_password': 'የይለፍ ቃል ያረጋግጡ',
  'password_changed': 'የይለፍ ቃል ተቀይሯል',
  'password_mismatch': 'የይለፍ ቃል አይዛመድም',
  'password_too_short': 'የይለፍ ቃል በጣም አጭር ነው',
  'delete_account': 'መለያ ሰርዝ',
  'confirm_delete_account': 'መለያ መሰረዝን ያረጋግጡ',
  'account_deleted': 'መለያ ተሰርዟል',
  'logout': 'ውጣ',
  'logout_confirm': 'መውጣትዎን ያረጋግጡ?',

  // Help & Support
  'help': 'እገዛ',
  'help_support': 'እገዛ እና ድጋፍ',
  'faq': 'በተደጋጋሚ የሚጠየቁ ጥያቄዎች',
  'contact_support': 'ድጋፍን ያግኙ',
  'report_issue': 'ችግር ሪፖርት ያድርጉ',
  'send_feedback': 'አስተያየት ይላኩ',
  'tutorial': 'ትምህርት',
  'getting_started': 'መጀመር',
  'user_guide': 'የተጠቃሚ መመሪያ',
  'terms_of_service': 'የአገልግሎት ውሎች',
  'privacy_policy': 'የግላዊነት ፖሊሲ',
  'about_app': 'ስለ መተግበሪያው',
  'app_version': 'የመተግበሪያ ስሪት',
  'check_for_updates': 'ዝማኔዎችን ያረጋግጡ',
  'update_available': 'ዝማኔ አለ',
  'no_updates_available': 'ምንም ዝማኔዎች የሉም',

  // Transactions
  'transactions': 'ግብይቶች',
  'my_transactions': 'የእኔ ግብይቶች',
  'transaction_history': 'የግብይት ታሪክ',
  'transaction_details': 'የግብይት ዝርዝሮች',
  'filter_transactions': 'ግብይቶችን ያጣሩ',
  'export_transactions': 'ግብይቶችን ላክ',
  'date_range': 'የቀን ክልል',
  'start_date': 'የመጀመሪያ ቀን',
  'end_date': 'የመጨረሻ ቀን',
  'select_date_range': 'የቀን ክልል ይምረጡ',
  'all_transactions': 'ሁሉም ግብይቶች',
  'recent_transactions': 'የቅርብ ግብይቶች',
  'transaction_type': 'የግብይት ዓይነት',
  'transaction_amount': 'የግብይት መጠን',
  'transaction_date': 'የግብይት ቀን',
  'transaction_id': 'የግብይት መለያ',
  'payment_method': 'የክፍያ መንገድ',
  'payment_status': 'የክፍያ ሁኔታ',

  // States - Loading
  'loading_data': 'መረጃ በመጫን ላይ',
  'please_wait': 'እባክዎ ይጠብቁ',
  'processing': 'በማስኬድ ላይ',
  'fetching_data': 'መረጃ በማምጣት ላይ',
  'syncing': 'በማመሳሰል ላይ',
  'uploading': 'በመጫን ላይ',
  'downloading': 'በማውረድ ላይ',
  'saving_changes': 'ለውጦችን በማስቀመጥ ላይ',

  // States - No Data
  'no_data_available': 'ምንም መረጃ የለም',
  'no_results_found': 'ምንም ውጤት አልተገኘም',
  'no_notifications': 'ማሳወቂያዎች የሉም',
  'no_transactions': 'ግብይቶች የሉም',
  'no_orders': 'ትዕዛዞች የሉም',
  'no_farms': 'እርሻዎች የሉም',
  'no_markets': 'ገበያዎች የሉም',
  'empty_list': 'ባዶ ዝርዝር',
  'nothing_to_show': 'ምንም የሚታይ ነገር የለም',

  // States - Error
  'error_occurred': 'ስህተት ተፈጥሯል',
  'something_went_wrong': 'የሆነ ችግር ተፈጥሯል',
  'connection_error': 'የግንኙነት ስህተት',
  'network_error': 'የአውታረ መረብ ስህተት',
  'server_error': 'የአገልጋይ ስህተት',
  'timeout_error': 'የጊዜ ማብቂያ ስህተት',
  'authentication_error': 'የማረጋገጫ ስህተት',
  'permission_denied': 'ፈቃድ ተከልክሏል',
  'not_found': 'አልተገኘም',
  'invalid_data': 'ልክ ያልሆነ መረጃ',

  // States - Retry
  'retry': 'እንደገና ሞክር',
  'try_again': 'እንደገና ይሞክሩ',
  'retry_later': 'በኋላ ይሞክሩ',
  'tap_to_retry': 'እንደገና ለመሞከር ይንኩ',
  'pull_to_refresh': 'ለማዘመን ይሳቡ',
  'swipe_to_refresh': 'ለማዘመን ያንሸራቱ',

  // Role Switching
  'switch_role': 'ሚና ይቀይሩ',
  'current_role': 'የአሁኑ ሚና',
  'select_role': 'ሚና ይምረጡ',
  'role_switched': 'ሚና ተቀይሯል',
  'switch_to_farmer': 'ወደ ገበሬ ይቀይሩ',
  'switch_to_buyer': 'ወደ ገዢ ይቀይሩ',
  'switch_to_transporter': 'ወደ ተሸካሚ ይቀይሩ',
  'switch_to_bureau': 'ወደ ቢሮ ሰራተኛ ይቀይሩ',

  // Woreda Switching
  'switch_woreda': 'ወረዳ ይቀይሩ',
  'current_woreda': 'የአሁኑ ወረዳ',
  'woreda_switched': 'ወረዳ ተቀይሯል',
  'no_woreda_selected': 'ምንም ወረዳ አልተመረጠም',

  // Location Services
  'location_services': 'የቦታ አገልግሎቶች',
  'enable_location': 'ቦታን አንቃ',
  'location_permission': 'የቦታ ፈቃድ',
  'location_permission_required': 'የቦታ ፈቃድ ያስፈልጋል',
  'location_permission_denied': 'የቦታ ፈቃድ ተከልክሏል',
  'location_not_available': 'ቦታ አይገኝም',
  'location_error': 'የቦታ ስህተት',
  'acquiring_location': 'ቦታ በማግኘት ላይ',
  'use_current_location': 'የአሁኑን ቦታ ተጠቀም',
  'location_accuracy': 'የቦታ ትክክለኛነት',
  'distance_to_market': 'ወደ ገበያ ያለው ርቀት',

  // Notification Messages
  'notification_received': 'ማሳወቂያ ተቀብሏል',
  'mark_as_read': 'እንደተነበበ ምልክት አድርግ',
  'mark_all_as_read': 'ሁሉንም እንደተነበበ ምልክት አድርግ',
  'clear_notifications': 'ማሳወቂያዎችን አጽዳ',
  'notification_history': 'የማሳወቂያ ታሪክ',
  'unread_notifications': 'ያልተነበቡ ማሳወቂያዎች',
  'read_notifications': 'የተነበቡ ማሳወቂያዎች',
  'new_notification': 'አዲስ ማሳወቂያ',
  'you_have_new_notifications': 'አዲስ ማሳወቂያዎች አሉዎት',

  // Validation Messages
  'field_required': 'መስክ ያስፈልጋል',
  'invalid_email': 'ልክ ያልሆነ ኢሜይል',
  'invalid_phone_number': 'ልክ ያልሆነ ስልክ ቁጥር',
  'invalid_input': 'ልክ ያልሆነ ግቤት',
  'value_too_low': 'ዋጋ በጣም ዝቅተኛ',
  'value_too_high': 'ዋጋ በጣም ከፍተኛ',
  'enter_valid_value': 'ልክ የሆነ ዋጋ ያስገቡ',
  'password_required': 'የይለፍ ቃል ያስፈልጋል',
  'email_required': 'ኢሜይል ያስፈልጋል',

  // Confirmation Messages
  'are_you_sure': 'እርግጠኛ ነዎት?',
  'confirm_action': 'እርምጃ ያረጋግጡ',
  'confirm': 'አረጋግጥ',
  'yes': 'አዎ',
  'no': 'አይ',
  'ok': 'እሺ',
  'close': 'ዝጋ',
  'dismiss': 'አስወግድ',
  'continue': 'ቀጥል',
  'back': 'ተመለስ',
  'next': 'ቀጣይ',
  'done': 'ተጠናቅቋል',

  // Success Messages
  'successfully_updated': 'በተሳካ ሁኔታ ተዘምኗል',
  'successfully_saved': 'በተሳካ ሁኔታ ተቀምጧል',
  'successfully_deleted': 'በተሳካ ሁኔታ ተሰርዟል',
  'operation_successful': 'ስራው ተሳክቷል',
  'changes_saved': 'ለውጦች ተቀምጠዋል',

  // App Info
  'developed_by': 'የተሰራው በ',
  'copyright': 'የቅጂ መብት',
  'all_rights_reserved': 'ሁሉም መብቶች የተጠበቁ ናቸው',
  'contact_us': 'ያግኙን',
  'follow_us': 'ይከተሉን',
  'rate_app': 'መተግበሪያውን ይገምግሙ',
  'share_app': 'መተግበሪያውን ያጋሩ',
};

// ============================================================================
// ENGLISH (en) Translations
// ============================================================================

const Map<String, String> _en = {
  // Navigation
  'home': 'Home',
  'market_intelligence': 'Market Intelligence',
  'marketplace': 'Marketplace',
  'orders': 'Orders',
  'profile': 'Profile',

  // Common Actions
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'search': 'Search',
  'filter': 'Filter',
  'refresh': 'Refresh',
  'submit': 'Submit',

  // User Roles
  'role_farmer': 'Farmer',
  'role_buyer': 'Buyer',
  'role_transporter': 'Transporter',
  'role_bureau': 'Bureau Officer',

  // Commodities
  'coffee': 'Coffee',
  'maize': 'Maize',
  'teff': 'Teff',
  'wheat': 'Wheat',
  'potato': 'Potato',

  // Core Features
  'where_should_i_sell': 'Where Should I Sell?',
  'price_comparison': 'Price Comparison',
  'nearby_markets': 'Nearby Markets',
  'active_buyers': 'Active Buyers',

  // Units
  'etb_per_kg': 'ETB/kg',
  'kg': 'kg',
  'quintal': 'Quintal',
  'birr': 'Birr',

  // Time
  'today': 'Today',
  'yesterday': 'Yesterday',
  'this_week': 'This Week',

  // Dashboard
  'welcome': 'Welcome',
  'select_woreda': 'Select Woreda',
  'notifications': 'Notifications',

  // Market Intelligence
  'current_prices': 'Current Prices',
  'price_trends': 'Price Trends',
  'best_market': 'Best Market',
  'transport_cost': 'Transport Cost',
  'net_revenue': 'Net Revenue',

  // Marketplace
  'post_demand': 'Post Demand',
  'find_buyers': 'Find Buyers',
  'find_sellers': 'Find Sellers',
  'verified_buyer': 'Verified Buyer',
  'buying_now': 'Buying Now',

  // Forms
  'quantity': 'Quantity',
  'quality': 'Quality',
  'location': 'Location',
  'phone_number': 'Phone Number',
  'price_offer': 'Price Offer',

  // Status
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'in_transit': 'In Transit',
  'delivered': 'Delivered',
  'completed': 'Completed',

  // Messages
  'no_data': 'No Data Available',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',

  // Farm Management
  'total_hectares': 'Total Hectares',
  'crops': 'Crops',
  'primary_crop': 'Primary Crop',
  'add_farm': 'Add Farm',
  'edit_farm': 'Edit Farm',
  'farm_name': 'Farm Name',
  'enter_farm_name': 'Enter farm name',
  'farm_name_required': 'Farm name is required',
  'enter_location': 'Enter location',
  'location_required': 'Location is required',
  'gps_coordinates': 'GPS Coordinates',
  'get_current_location': 'Get Current Location',
  'latitude': 'Latitude',
  'longitude': 'Longitude',
  'invalid_number': 'Invalid number',
  'latitude_range': 'Latitude must be between -90 and 90',
  'longitude_range': 'Longitude must be between -180 and 180',
  'gps_optional': 'GPS is optional',
  'gps_optional_info': 'GPS coordinates are optional. You can add them later.',
  'save_changes': 'Save Changes',
  'gps_feature_coming_soon': 'GPS feature coming soon',

  // Phase 9 - Settings
  'settings': 'Settings',
  'general_settings': 'General Settings',
  'account_settings': 'Account Settings',
  'privacy_settings': 'Privacy Settings',
  'notification_settings': 'Notification Settings',
  'app_settings': 'App Settings',
  'data_sync': 'Data Sync',
  'sync_now': 'Sync Now',
  'last_sync': 'Last Sync',
  'auto_sync': 'Auto Sync',
  'sync_enabled': 'Sync Enabled',
  'sync_disabled': 'Sync Disabled',
  'offline_mode': 'Offline Mode',
  'clear_cache': 'Clear Cache',
  'cache_cleared': 'Cache Cleared',

  // Theme
  'theme': 'Theme',
  'theme_settings': 'Theme Settings',
  'light_mode': 'Light Mode',
  'dark_mode': 'Dark Mode',
  'system_default': 'System Default',
  'choose_theme': 'Choose Theme',
  'appearance': 'Appearance',

  // Language
  'language': 'Language',
  'language_settings': 'Language Settings',
  'change_language': 'Change Language',
  'select_language': 'Select Language',
  'afaan_oromoo': 'Afaan Oromoo',
  'amharic': 'Amharic',
  'english': 'English',
  'language_changed': 'Language Changed',
  'restart_required': 'Restart Required',

  // Notifications
  'enable_notifications': 'Enable Notifications',
  'disable_notifications': 'Disable Notifications',
  'notification_sound': 'Notification Sound',
  'vibration': 'Vibration',
  'order_notifications': 'Order Notifications',
  'transport_notifications': 'Transport Notifications',
  'price_alerts': 'Price Alerts',
  'system_notifications': 'System Notifications',
  'marketing_notifications': 'Marketing Notifications',
  'market_updates': 'Market Updates',
  'push_notifications': 'Push Notifications',
  'do_not_disturb': 'Do Not Disturb',
  'notification_channels': 'Notification Channels',
  'notification_preferences': 'Notification Preferences',

  // Profile
  'my_profile': 'My Profile',
  'edit_profile': 'Edit Profile',
  'view_profile': 'View Profile',
  'profile_settings': 'Profile Settings',
  'full_name': 'Full Name',
  'email': 'Email',
  'profile_picture': 'Profile Picture',
  'remove_profile_picture': 'Remove Profile Picture',
  'update_profile': 'Update Profile',
  'profile_updated': 'Profile Updated',
  'profile_update_failed': 'Profile Update Failed',

  // Privacy & Legal
  'privacy_policy': 'Privacy Policy',
  'terms_of_service': 'Terms of Service',
  'terms_and_conditions': 'Terms and Conditions',
  'agree_to_terms': 'I agree to the Terms and Conditions',
  'data_privacy': 'Data Privacy',
  'data_collection': 'Data Collection',
  'data_usage': 'Data Usage',
  'third_party_sharing': 'Third Party Sharing',
  'accept': 'Accept',
  'decline': 'Decline',
  'read_more': 'Read More',
  'last_updated': 'Last Updated',

  // Support
  'help': 'Help',
  'support': 'Support',
  'contact_support': 'Contact Support',
  'help_center': 'Help Center',
  'faq': 'FAQ',
  'frequently_asked_questions': 'Frequently Asked Questions',
  'report_issue': 'Report an Issue',
  'send_feedback': 'Send Feedback',
  'version': 'Version',
  'about': 'About',
  'about_app': 'About App',

  // Accessibility
  'accessibility': 'Accessibility',
  'accessibility_settings': 'Accessibility Settings',
  'font_size': 'Font Size',
  'increase_font_size': 'Increase Font Size',
  'decrease_font_size': 'Decrease Font Size',
  'high_contrast': 'High Contrast',
  'screen_reader': 'Screen Reader',
  'voice_commands': 'Voice Commands',
};

// ============================================================================
// LOCALIZATION DELEGATE
// ============================================================================

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['om', 'am', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
