// // import 'package:animated_splash_screen/animated_splash_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:jwt_decoder/jwt_decoder.dart';
// // import 'package:rentcon/dbHelper/mongodb.dart';
// // import 'package:rentcon/display.dart';
// // import 'package:rentcon/insert.dart';
// // import 'package:rentcon/insertListing.dart';
// // import 'package:rentcon/nav_try.dart';
// // import 'package:rentcon/navigation_menu.dart';
// // import 'package:rentcon/pages/home.dart';
// // import 'package:rentcon/pages/index.dart';
// // import 'package:rentcon/pages/landlords/addListing.dart';
// // import 'package:rentcon/pages/landlords/current_listing.dart';
// // import 'package:rentcon/pages/login.dart';
// // import 'package:rentcon/splash.dart';
// // import 'package:rentcon/theme_controller.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //   await MongoDatabase.connect();
// //   String? token = prefs.getString('token'); // Nullable token
// //   runApp(MyApp(token: token));
// // }

// // class MyApp extends StatelessWidget {
// //   final String? token; // Nullable token
// //   final themeController = Get.put(ThemeController());

// //    MyApp({
// //     this.token,
// //     Key? key,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     // Check if token is null or expired
// //     bool isAuthenticated = token != null && !JwtDecoder.isExpired(token!);

// //     return Obx(() => GetMaterialApp(
// //           debugShowCheckedModeBanner: false,
// //           theme: ThemeData(fontFamily: 'Poppins'),
// //           darkTheme: ThemeData.dark(), // Set dark theme
// //           themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
// //           //home: NavTry(),
// //           home: isAuthenticated ? AnimatedSplashScreen(
// //             splash: Image.asset('assets/icons/ren.png'),
// //             duration: 3000,
// //             backgroundColor: const Color.fromARGB(255, 255, 255, 255),
// //             splashTransition: SplashTransition.fadeTransition,
// //             nextScreen : 
// //             NavigationMenu(token: token!)) 
// //           : AnimatedSplashScreen(
// //             splash: Image.asset('assets/icons/ren.png'),
// //             duration: 3000,
// //             backgroundColor: const Color.fromARGB(255, 255, 255, 255),
// //             splashTransition: SplashTransition.fadeTransition,
// //             nextScreen: IndexPage()),
// //           routes: {

// //             '/login': (context) => LoginPage(),
// //             '/current-listing': (context) => CurrentListingPage(token: token!),
// //             '/home' :  (context) => HomePage(token: token!,)
// //           },
// //         ));
// //   }
// // }



// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:rentcon/dbHelper/mongodb.dart';
// import 'package:rentcon/navigation_menu.dart';
// import 'package:rentcon/pages/components/formshadcn.dart';
// import 'package:rentcon/pages/home.dart';
// import 'package:rentcon/pages/index.dart';
// import 'package:rentcon/pages/landlords/current_listing.dart';
// import 'package:rentcon/pages/login.dart';
// import 'package:rentcon/theme_controller.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await MongoDatabase.connect();
//   String? token = prefs.getString('token'); // Nullable token
//   runApp(MyApp(token: token));
// }

// class MyApp extends StatelessWidget {
//   final String? token; // Nullable token
//   final themeController = Get.put(ThemeController());

//   MyApp({
//     this.token,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Check if token is null or expired
//     bool isAuthenticated = token != null && !JwtDecoder.isExpired(token!);

//     return ShadApp.material(
//       darkTheme: ShadThemeData(colorScheme: ShadSlateColorScheme.dark(), brightness: Brightness.dark),
//       debugShowCheckedModeBanner: false,
//       materialThemeBuilder: (context, theme) {
//         return theme.copyWith(
//           primaryColor: const Color.fromARGB(255, 17, 25, 92), // Customize material theme if needed
//           appBarTheme: const AppBarTheme(toolbarHeight: 56.0),
//         );
//       },
//       // Use TransitionBuilder instead of directly returning Obx
//       builder: (BuildContext context, Widget? child) {
//         return Obx(() => GetMaterialApp(
//               debugShowCheckedModeBanner: false,
//               theme: ThemeData(fontFamily: 'Poppins'),
//               darkTheme: ThemeData.dark(), // Set dark theme
//               themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
//               home: isAuthenticated
//                   ? AnimatedSplashScreen(
//                       splash: Image.asset('assets/icons/ren.png'),
//                       duration: 3000,
//                       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                       splashTransition: SplashTransition.fadeTransition,
//                       nextScreen: NavigationMenu(token: token!))
//                   : AnimatedSplashScreen(
//                       splash: Image.asset('assets/icons/ren.png'),
//                       duration: 3000,
//                       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                       splashTransition: SplashTransition.fadeTransition,
//                       nextScreen: IndexPage()),
//               routes: {
//                 '/login': (context) => LoginPage(),
//                 '/current-listing': (context) => CurrentListingPage(token: token!),
//                 '/home': (context) => HomePage(token: token!),
//               },
//             ));
//       },
//     );
//   }
// }

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/dbHelper/mongodb.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/index.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/pages/loginOTP.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await MongoDatabase.connect();
  String? token = prefs.getString('token'); // Nullable token
  runApp(MyApp(token: token));
}

class MyApp extends StatefulWidget {
  final String? token;

  MyApp({this.token, Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey(); // To regenerate the widget tree
  final themeController = Get.put(ThemeController());
  final AppLinks appLinks = AppLinks(); // Initialize app links

  void restartApp() {
    setState(() {
      key = UniqueKey(); // Change key to restart the app
    });
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    // Handle the deep link based on its path
    switch (uri.path) {
      case '/login':
        Get.toNamed('/login');
        break;
      case '/forgot-password':
        Get.toNamed('/forgot-password');
        break;
      // Add more cases as needed
      default:
        break;
    }
  }

@override
Widget build(BuildContext context) {
  // Check if token is null or expired
  bool isAuthenticated = widget.token != null && !JwtDecoder.isExpired(widget.token!);

  return Obx(() {
    // Determine the theme mode
    final isDarkMode = themeController.isDarkMode.value;

    return ShadApp.material(
      darkTheme: ShadThemeData(colorScheme: ShadSlateColorScheme.dark(), brightness: Brightness.dark), // Ensure this uses the dark color scheme
      debugShowCheckedModeBanner: false,
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          primaryColor: const Color.fromARGB(255, 17, 25, 92),
          appBarTheme: const AppBarTheme(toolbarHeight: 56.0),
          colorScheme: isDarkMode 
            ? theme.colorScheme.copyWith(
                primary: const Color.fromARGB(255, 17, 25, 92), // Dark theme primary color
                secondary: Colors.teal, // Adjust secondary color as needed
              )
            : theme.colorScheme.copyWith(
                primary: const Color.fromARGB(255, 255, 255, 255), // Light theme primary color
                secondary: Colors.blue, // Adjust secondary color as needed
              ),
        );
      },
      builder: (BuildContext context, Widget? child) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light, // Apply the correct brightness
          ),
          child: GetMaterialApp(
            key: key, // Use the key to restart the app
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Poppins'),
            darkTheme: ThemeData.dark(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: isAuthenticated
                ? AnimatedSplashScreen(
                    splash: Image.asset('assets/icons/ren.png'),
                    duration: 3000,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    splashTransition: SplashTransition.fadeTransition,
                    nextScreen: NavigationMenu(token: widget.token!))
                : AnimatedSplashScreen(
                    splash: Image.asset('assets/icons/ren.png'),
                    duration: 3000,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    splashTransition: SplashTransition.fadeTransition,
                    nextScreen: IndexPage()),
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


// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:rentcon/dbHelper/mongodb.dart';
// import 'package:rentcon/navigation_menu.dart';
// import 'package:rentcon/pages/home.dart';
// import 'package:rentcon/pages/index.dart';
// import 'package:rentcon/pages/landlords/current_listing.dart';
// import 'package:rentcon/pages/login.dart';
// import 'package:rentcon/pages/loginOTP.dart';
// import 'package:rentcon/theme_controller.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await MongoDatabase.connect();
//   String? token = prefs.getString('token'); // Nullable token
//   runApp(MyApp(token: token));
// }

// class MyApp extends StatefulWidget {
//   final String? token;

//   MyApp({this.token, Key? key}) : super(key: key);

//   static void restartApp(BuildContext context) {
//     context.findAncestorStateOfType<_MyAppState>()?.restartApp();
//   }

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Key key = UniqueKey(); // To regenerate the widget tree

//   final themeController = Get.put(ThemeController());

//   void restartApp() {
//     setState(() {
//       key = UniqueKey(); // Change key to restart the app
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Check if token is null or expired
//     bool isAuthenticated = widget.token != null && !JwtDecoder.isExpired(widget.token!);

//     return ShadApp.material(
//       darkTheme: ShadThemeData(colorScheme: ShadSlateColorScheme.dark(), brightness: Brightness.dark),
//       debugShowCheckedModeBanner: false,
//       materialThemeBuilder: (context, theme) {
//         return theme.copyWith(
//           primaryColor: const Color.fromARGB(255, 17, 25, 92),
//           appBarTheme: const AppBarTheme(toolbarHeight: 56.0),
//         );
//       },
//       builder: (BuildContext context, Widget? child) {
//         return Obx(() => GetMaterialApp(
//               key: key, // Use the key to restart the app
//               debugShowCheckedModeBanner: false,
//               theme: ThemeData(fontFamily: 'Poppins'),
//               darkTheme: ThemeData.dark(),
//               themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
//               home: isAuthenticated
//                   ? AnimatedSplashScreen(
//                       splash: Image.asset('assets/icons/ren.png'),
//                       duration: 3000,
//                       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                       splashTransition: SplashTransition.fadeTransition,
//                       nextScreen: NavigationMenu(token: widget.token!))
//                   : AnimatedSplashScreen(
//                       splash: Image.asset('assets/icons/ren.png'),
//                       duration: 3000,
//                       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                       splashTransition: SplashTransition.fadeTransition,
//                       nextScreen: IndexPage()),
//               routes: {
//                 '/login': (context) => LoginPage(),
//                 '/current-listing': (context) => CurrentListingPage(token: widget.token!),
//                 '/home': (context) => HomePage(token: widget.token!),
//               },
//             ));
//       },
//     );
//   }
// }
