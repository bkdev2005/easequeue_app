import 'package:eqlite/Component/Confirmation/exitConfirmation.dart';
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SplashScreen/SplashScreen_widget.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'flutter_flow/nav/nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'function.dart';

void getFcmToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (required on iOS)
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    FFAppState().fcmToken = token??'';
  } else {
    print("User declined or has not accepted permission");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!isWeb && !isiOS){
  await Firebase.initializeApp(); // Initialize Firebase
  }
  usePathUrlStrategy();
  await FlutterFlowTheme.initialize();
  getFcmToken();
  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF37625A),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EaseQueue',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
      ],
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(),
        primarySwatch: Colors.orange,
        textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Color(0xFF37625a),
            selectionColor: Color.fromARGB(255, 233, 232, 232)),
      ),

      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'HomePage';
  late Widget? _currentPage;
  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'HomePage': HomePageWidget(),
      'customerReport': HomePageWidget(),
      // 'BusinessAppointment': InboxWidget(),
      // 'BusinessAbout': FinalNewProfileWidget(),
    };

    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    final MediaQueryData queryData = MediaQuery.of(context);

    return WillPopScope(
        onWillPop: () async{
          showDialog(context: context,
              builder: (context){
                return Center( child: ExitWidget());
              }).then((value) {
            if(value){
              return value;
            }else{
              return false;
            }
          });
          return false;
        },
        child: Scaffold(
        body: HomePageWidget())
    );
  }
}






