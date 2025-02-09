import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:syncio_capstone/providers/locale_provider.dart';
import 'package:syncio_capstone/providers/auth_provider.dart';
import 'package:syncio_capstone/routes/app_route.dart';
import 'package:syncio_capstone/screens/home/tab.dart';
import 'package:syncio_capstone/services/websocket_service.dart';
import 'package:syncio_capstone/theme/app_theme.dart';
import 'package:syncio_capstone/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}

void main() async {
  // Set up page transitions
  PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initFCM();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  try {
    final List<DisplayMode> modes = await FlutterDisplayMode.supported;
    final bestMode =
        modes.reduce((a, b) => a.refreshRate > b.refreshRate ? a : b);
    await FlutterDisplayMode.setPreferredMode(bestMode);
  } catch (e) {
    throw Exception(e);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WebSocketService().connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> _initFCM() async {
  final fcm = FirebaseMessaging.instance;

  await fcm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.notification?.title}');
  });

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened: ${message.notification?.title}');
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WebSocketService().connect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed - reconnecting WebSocket");
      WebSocketService().connect();
    } else if (state == AppLifecycleState.paused) {
      debugPrint("App paused - disconnecting WebSocket");
      WebSocketService().disconnect();
    } else if (state == AppLifecycleState.detached) {
      debugPrint("App detached - disconnecting WebSocket");
      WebSocketService().disconnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WebSocketService().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.currentTheme,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoute.generateRoute,
      home: FutureBuilder<bool>(
        future: authProvider.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
