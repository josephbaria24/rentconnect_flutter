import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/colorController.dart';
import 'package:rentcon/dbHelper/mongodb.dart';
import 'package:rentcon/dependency_injection.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/index.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/landlords/services/getPaymentForSelectedMonth.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/pages/loginOTP.dart';
import 'package:rentcon/pages/services/backend_service.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/provider/bookmark.dart';
import 'package:rentcon/provider/conversation.dart';
import 'package:rentcon/provider/message.dart';
import 'package:rentcon/provider/notification.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI
import 'package:video_player/video_player.dart'; // Import video_player package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put(ColorController()); // Register ColorController
  Get.put(ThemeController()); // Ensure your ThemeController is also registered
  String? token = prefs.getString('token'); // Nullable token

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MessageProvider>(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => PaymentService()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => BookmarkProvider()),
        ChangeNotifierProvider<ConversationProvider>(create: (context) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider(userId: 'user-id-here',token: token!))
      ],
      child: MyApp(token: token),
    ),
  );
  DependencyInjection.init();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("af1220cb-edec-447f-a4e2-8bc6b7638322");
  // OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatefulWidget {
  final String? token;

  MyApp({this.token, Key? key}) : super(key: key);

  

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey(); // To regenerate the widget tree
  final themeController = Get.put(ThemeController());
  final AppLinks appLinks = AppLinks(); // Initialize app links
  late VideoPlayerController _videoController; // Declare the VideoPlayerController

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    // Initialize video controller
    _videoController = VideoPlayerController.asset('assets/icons/rentcon.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play(); // Start playing the video
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // Dispose of the video controller
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    switch (uri.path) {
      case '/login':
        Get.toNamed('/login');
        break;
      case '/forgot-password':
        Get.toNamed('/forgot-password');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated = widget.token != null && !JwtDecoder.isExpired(widget.token!);
    final toastNotification = ToastNotification(context);

    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      
      return ShadApp.material(
        darkTheme: ShadThemeData(colorScheme: ShadSlateColorScheme.dark(), brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        materialThemeBuilder: (context, theme) {
          return theme.copyWith(
            primaryColor: const Color.fromARGB(255, 17, 25, 92),
            appBarTheme: const AppBarTheme(toolbarHeight: 56.0),
            colorScheme: isDarkMode
                ? theme.colorScheme.copyWith(
                    primary: const Color.fromARGB(255, 17, 25, 92),
                    secondary: Colors.teal,
                  )
                : theme.colorScheme.copyWith(
                    primary: const Color.fromARGB(255, 255, 255, 255),
                    secondary: Colors.blue,
                  ),
          );
        },
        builder: (BuildContext context, Widget? child) {
          return CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: GetMaterialApp(
              key: key,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(fontFamily: 'Manrope'),
              darkTheme: ThemeData.dark(),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: isAuthenticated
                  ? AnimatedSplashScreen(
                      splash: _videoController.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            )
                          : AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            ), // Show loader until the video is ready
                      splashIconSize: 150,
                      duration: 3000, // Adjust based on video length
                       splashTransition: SplashTransition.fadeTransition,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      nextScreen: NavigationMenu(token: widget.token!),
                      pageTransitionType: PageTransitionType.fade,
                    )
                  : AnimatedSplashScreen(
                      splash: _videoController.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            )
                          : AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            ),
                      splashIconSize: 150,
                      duration: 3000,
                      splashTransition: SplashTransition.fadeTransition,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      nextScreen: IndexPage(),
                      pageTransitionType: PageTransitionType.fade,
                    ),
              routes: {
                '/login': (context) => LoginPage(),
                '/current-listing': (context) => CurrentListingPage(token: widget.token!),
                '/home': (context) => HomePage(token: widget.token!),
              },
            ),
          );
        },
      );
    });
  }
}
