import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('hi', ''),
    Locale('ta', ''),
    Locale('te', ''),
    Locale('bn', ''),
    Locale('mr', ''),
    Locale('gu', ''),
    Locale('kn', ''),
    Locale('ml', ''),
    Locale('pa', ''),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appName => _getString('appName');
  String get welcome => _getString('welcome');
  String get login => _getString('login');
  String get register => _getString('register');
  String get email => _getString('email');
  String get password => _getString('password');
  String get name => _getString('name');
  String get continueText => _getString('continue');
  String get next => _getString('next');
  String get skip => _getString('skip');
  String get done => _getString('done');
  String get back => _getString('back');
  String get save => _getString('save');
  String get cancel => _getString('cancel');
  String get confirm => _getString('confirm');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  String get add => _getString('add');
  String get remove => _getString('remove');
  String get settings => _getString('settings');
  String get dashboard => _getString('dashboard');
  String get children => _getString('children');
  String get devices => _getString('devices');
  String get alerts => _getString('alerts');
  String get tara => _getString('tara');
  String get screenTime => _getString('screenTime');
  String get applications => _getString('applications');
  String get schedules => _getString('schedules');
  String get webSafety => _getString('webSafety');
  String get location => _getString('location');
  String get reports => _getString('reports');
  String get requests => _getString('requests');
  String get coParent => _getString('coParent');
  String get subscription => _getString('subscription');
  String get account => _getString('account');
  String get privacy => _getString('privacy');
  String get support => _getString('support');
  String get family => _getString('family');
  String get profile => _getString('profile');
  String get logout => _getString('logout');
  String get error => _getString('error');
  String get loading => _getString('loading');
  String get noData => _getString('noData');
  String get tryAgain => _getString('tryAgain');
  String get somethingWentWrong => _getString('somethingWentWrong');
  String get offline => _getString('offline');
  String get online => _getString('online');
  String get protected => _getString('protected');
  String get attentionRequired => _getString('attentionRequired');
  String get pairing => _getString('pairing');
  String get scanQRCode => _getString('scanQRCode');
  String get enterCode => _getString('enterCode');
  String get pairingCode => _getString('pairingCode');
  String get childDevice => _getString('childDevice');
  String get parentDevice => _getString('parentDevice');
  String get grantPermission => _getString('grantPermission');
  String get permissionRequired => _getString('permissionRequired');
  String get usageAccess => _getString('usageAccess');
  String get locationPermission => _getString('locationPermission');
  String get notificationPermission => _getString('notificationPermission');
  String get vpnPermission => _getString('vpnPermission');
  String get batteryOptimization => _getString('batteryOptimization');
  String get healthCheck => _getString('healthCheck');
  String get healthGood => _getString('healthGood');
  String get healthWarning => _getString('healthWarning');
  String get healthCritical => _getString('healthCritical');
  String get screenTimeLimit => _getString('screenTimeLimit');
  String get bedtime => _getString('bedtime');
  String get schoolTime => _getString('schoolTime');
  String get appLimits => _getString('appLimits');
  String get websiteBlocking => _getString('websiteBlocking');
  String get safeSearch => _getString('safeSearch');
  String get geofence => _getString('geofence');
  String get safeZone => _getString('safeZone');
  String get requestAccess => _getString('requestAccess');
  String get moreTime => _getString('moreTime');
  String get appAccess => _getString('appAccess');
  String get websiteAccess => _getString('websiteAccess');
  String get scheduleException => _getString('scheduleException');
  String get approve => _getString('approve');
  String get reject => _getString('reject');
  String get pending => _getString('pending');
  String get approved => _getString('approved');
  String get rejected => _getString('rejected');
  String get expired => _getString('expired');
  String get safetyScore => _getString('safetyScore');
  String get digitalWellness => _getString('digitalWellness');
  String get weeklyReport => _getString('weeklyReport');
  String get monthlyReport => _getString('monthlyReport');
  String get today => _getString('today');
  String get thisWeek => _getString('thisWeek');
  String get thisMonth => _getString('thisMonth');
  String get hours => _getString('hours');
  String get minutes => _getString('minutes');
  String get seconds => _getString('seconds');
  String get days => _getString('days');
  String get weeks => _getString('weeks');
  String get months => _getString('months');
  String get years => _getString('years');

  String _getString(String key) {
    final strings = _localizedStrings[locale.languageCode] ?? _localizedStrings['en']!;
    return strings[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appName': 'Druvatara Guardian',
      'welcome': 'Welcome to Druvatara Guardian',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'continue': 'Continue',
      'next': 'Next',
      'skip': 'Skip',
      'done': 'Done',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'remove': 'Remove',
      'settings': 'Settings',
      'dashboard': 'Dashboard',
      'children': 'Children',
      'devices': 'Devices',
      'alerts': 'Alerts',
      'tara': 'TARA',
      'screenTime': 'Screen Time',
      'applications': 'Applications',
      'schedules': 'Schedules',
      'webSafety': 'Web Safety',
      'location': 'Location',
      'reports': 'Reports',
      'requests': 'Requests',
      'coParent': 'Co-Parent',
      'subscription': 'Subscription',
      'account': 'Account',
      'privacy': 'Privacy',
      'support': 'Support',
      'family': 'Family',
      'profile': 'Profile',
      'logout': 'Logout',
      'error': 'Error',
      'loading': 'Loading...',
      'noData': 'No data available',
      'tryAgain': 'Try Again',
      'somethingWentWrong': 'Something went wrong',
      'offline': 'Offline',
      'online': 'Online',
      'protected': 'Protected',
      'attentionRequired': 'Attention Required',
      'pairing': 'Pairing',
      'scanQRCode': 'Scan QR Code',
      'enterCode': 'Enter Code',
      'pairingCode': 'Pairing Code',
      'childDevice': 'Child Device',
      'parentDevice': 'Parent Device',
      'grantPermission': 'Grant Permission',
      'permissionRequired': 'Permission Required',
      'usageAccess': 'Usage Access',
      'locationPermission': 'Location Permission',
      'notificationPermission': 'Notification Permission',
      'vpnPermission': 'VPN Permission',
      'batteryOptimization': 'Battery Optimization',
      'healthCheck': 'Health Check',
      'healthGood': 'Good',
      'healthWarning': 'Warning',
      'healthCritical': 'Critical',
      'screenTimeLimit': 'Screen Time Limit',
      'bedtime': 'Bedtime',
      'schoolTime': 'School Time',
      'appLimits': 'App Limits',
      'websiteBlocking': 'Website Blocking',
      'safeSearch': 'Safe Search',
      'geofence': 'Geofence',
      'safeZone': 'Safe Zone',
      'requestAccess': 'Request Access',
      'moreTime': 'More Time',
      'appAccess': 'App Access',
      'websiteAccess': 'Website Access',
      'scheduleException': 'Schedule Exception',
      'approve': 'Approve',
      'reject': 'Reject',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'expired': 'Expired',
      'safetyScore': 'Safety Score',
      'digitalWellness': 'Digital Wellness',
      'weeklyReport': 'Weekly Report',
      'monthlyReport': 'Monthly Report',
      'today': 'Today',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'hours': 'h',
      'minutes': 'm',
      'seconds': 's',
      'days': 'd',
      'weeks': 'w',
      'months': 'mo',
      'years': 'y',
    },
    'hi': {
      'appName': 'द्रुवतारा गार्जियन',
      'welcome': 'द्रुवतारा गार्जियन में आपका स्वागत है',
      'login': 'लॉगिन',
      'register': 'रजिस्टर',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'continue': 'जारी रखें',
      'next': 'अगला',
      'skip': 'छोड़ें',
      'done': 'पूर्ण',
      'back': 'वापस',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'confirm': 'पुष्टि करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'remove': 'हटाएं',
      'settings': 'सेटिंग्स',
      'dashboard': 'डैशबोर्ड',
      'children': 'बच्चे',
      'devices': 'डिवाइस',
      'alerts': 'अलर्ट',
      'tara': 'तारा',
      'screenTime': 'स्क्रीन समय',
      'applications': 'ऐप्स',
      'schedules': 'शेड्यूल',
      'webSafety': 'वेब सुरक्षा',
      'location': 'स्थान',
      'reports': 'रिपोर्ट्स',
      'requests': 'अनुरोध',
      'coParent': 'सह-माता-पिता',
      'subscription': 'सब्सक्रिप्शन',
      'account': 'खाता',
      'privacy': 'गोपनीयता',
      'support': 'सहायता',
      'family': 'परिवार',
      'profile': 'प्रोफाइल',
      'logout': 'लॉगआउट',
      'error': 'त्रुटि',
      'loading': 'लोड हो रहा है...',
      'noData': 'कोई डेटा उपलब्ध नहीं',
      'tryAgain': 'पुनः प्रयास करें',
      'somethingWentWrong': 'कुछ गलत हुआ',
      'offline': 'ऑफलाइन',
      'online': 'ऑनलाइन',
      'protected': 'सुरक्षित',
      'attentionRequired': 'ध्यान आवश्यक',
      'pairing': 'पेयरिंग',
      'scanQRCode': 'QR कोड स्कैन करें',
      'enterCode': 'कोड दर्ज करें',
      'pairingCode': 'पेयरिंग कोड',
      'childDevice': 'बच्चे का डिवाइस',
      'parentDevice': 'माता-पिता का डिवाइस',
      'grantPermission': 'अनुमति दें',
      'permissionRequired': 'अनुमति आवश्यक',
      'usageAccess': 'उपयोग एक्सेस',
      'locationPermission': 'स्थान अनुमति',
      'notificationPermission': 'सूचना अनुमति',
      'vpnPermission': 'VPN अनुमति',
      'batteryOptimization': 'बैटरी ऑप्टिमाइज़ेशन',
      'healthCheck': 'हेल्थ चेक',
      'healthGood': 'अच्छा',
      'healthWarning': 'चेतावनी',
      'healthCritical': 'गंभीर',
      'screenTimeLimit': 'स्क्रीन समय सीमा',
      'bedtime': 'सोने का समय',
      'schoolTime': 'स्कूल का समय',
      'appLimits': 'ऐप सीमाएं',
      'websiteBlocking': 'वेबसाइट ब्लॉकिंग',
      'safeSearch': 'सेफ सर्च',
      'geofence': 'जियोफेंस',
      'safeZone': 'सेफ जोन',
      'requestAccess': 'एक्सेस का अनुरोध',
      'moreTime': 'अधिक समय',
      'appAccess': 'ऐप एक्सेस',
      'websiteAccess': 'वेबसाइट एक्सेस',
      'scheduleException': 'शेड्यूल अपवाद',
      'approve': 'स्वीकृत',
      'reject': 'अस्वीकार',
      'pending': 'लंबित',
      'approved': 'स्वीकृत',
      'rejected': 'अस्वीकृत',
      'expired': 'समाप्त',
      'safetyScore': 'सुरक्षा स्कोर',
      'digitalWellness': 'डिजिटल वेलनेस',
      'weeklyReport': 'साप्ताहिक रिपोर्ट',
      'monthlyReport': 'मासिक रिपोर्ट',
      'today': 'आज',
      'thisWeek': 'इस सप्ताह',
      'thisMonth': 'इस महीने',
      'hours': 'घंटे',
      'minutes': 'मिनट',
      'seconds': 'सेकंड',
      'days': 'दिन',
      'weeks': 'सप्ताह',
      'months': 'महीने',
      'years': 'वर्ष',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}