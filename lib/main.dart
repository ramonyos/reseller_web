import 'package:ccf_reseller_web_app/l10n/l10n.dart';
import 'package:ccf_reseller_web_app/providers/listAllReferer/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // important
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/l10n/l10n.dart';
import 'package:ccf_reseller_web_app/providers/historyBalance/index.dart';
import 'package:ccf_reseller_web_app/providers/locale/index.dart';
import 'package:ccf_reseller_web_app/providers/verifyAccount/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/assignUser/index.dart';
import 'providers/branch/index.dart';
import 'providers/customerApprove/index.dart';
import 'providers/listAllUserInternal/index.dart';
import 'providers/listCustomer/indext.dart';
import 'providers/login/index.dart';
import 'providers/notification/index.dart';
import 'providers/registerRef/index.dart';
import 'screens/home/home.dart';
import 'screens/login/index.dart';

Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue, // navigation bar color
  //   statusBarColor: Colors.pink, // status bar color
  // ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    isLogin();
    super.didChangeDependencies();
  }

  bool _isLogin = false;

  Future<void> isLogin() async {
    final storage = await SharedPreferences.getInstance();

    String? ids = await storage.getString('user_id');
    if (ids != null || ids == '') {
      setState(() {
        _isLogin = true;
      });
    } else {
      setState(() {
        _isLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<RegisterRef>(create: (_) => RegisterRef()),
        ListenableProvider<Customer>(create: (_) => Customer()),
        ListenableProvider<RegisterCustomerProvider>(
            create: (_) => RegisterCustomerProvider()),
        ListenableProvider<BranchProvider>(create: (_) => BranchProvider()),
        ListenableProvider<AssignUserProvider>(
            create: (_) => AssignUserProvider()),
        ListenableProvider<CustomerApprove>(create: (_) => CustomerApprove()),
        ListenableProvider<NotificationProvider>(
            create: (_) => NotificationProvider()),
        ListenableProvider<HistroyBalance>(create: (_) => HistroyBalance()),
        ListenableProvider<VerifyProvider>(create: (_) => VerifyProvider()),
        ListenableProvider<ListAllUserInternalProvider>(
            create: (_) => ListAllUserInternalProvider()),
        ListenableProvider<ListAllRefererProvider>(
            create: (_) => ListAllRefererProvider()),
        ListenableProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
          builder: (context, child) {
            final locale = Provider.of<LocaleProvider>(
              context,
            ).locale;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              home: _isLogin ? HomeScreen() : LoginScreenNewTamplate(),
              supportedLocales: L10n.all,
              localizationsDelegates: [
                AppLocalizations.delegate, // Add this line
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ],
    );
  }
}
