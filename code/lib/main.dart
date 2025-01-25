import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:msb_app/Screens/sign_in/sign_in_screen.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Screens/dashboard/dashboard_setup.dart';
import 'Screens/profile/post_details_screen.dart';
import 'Screens/school/school_screen.dart';
import 'package:is_first_run/is_first_run.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.debug, // Use debug for Android in development
    appleProvider: AppleProvider.debug, // Use debug for iOS in development
  );

  ///init Branch.io for deeplink.
  await FlutterBranchSdk.init();
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp(firestore: fireStore));
  });
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore;

  const MyApp({required this.firestore, super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: AppColors.white,
        useMaterial3: true,
      ),
      home: IsLoginCheckPage(),
    );
  }
}

class IsLoginCheckPage extends StatefulWidget {
  IsLoginCheckPage({super.key});

  @override
  State<IsLoginCheckPage> createState() => _IsLoginCheckPageState();
}

class _IsLoginCheckPageState extends State<IsLoginCheckPage> {
  StreamSubscription<Map>? streamSubscriptionDeepLink;

  Future<void> checkAppVersion(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Fetch saved app version from SharedPreferences
    String? savedVersion = prefs.getString('app_version');

    if (savedVersion == null || savedVersion != currentVersion) {
      // App version has changed or no version is stored
      await prefs.clear(); // Clear all saved preferences (logs out the user)
      await prefs.setString(
          'app_version', currentVersion); // Save new app version
      print("User logged out due to app update.");
    } else {
      print("App version is up-to-date.");
    }
  }


  Future<bool> checkUserLogin(BuildContext context) async {
    bool firstCall = await IsFirstRun.isFirstCall();
    bool firstRun = await IsFirstRun.isFirstRun();
    // Check the app version first
    await checkAppVersion(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('userId');
    return firstCall && firstRun ? false : userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, _, deviceType) {
      return FutureBuilder<bool>(
        future: checkUserLogin(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Material(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            );
          }
          bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const DashboardSetup() : const SignInScreen();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    listenDeepLinkData(context);
  }

  @override
  void dispose() {
    streamSubscriptionDeepLink?.cancel();
    super.dispose();
  }

  void listenDeepLinkData(BuildContext context) async {
    streamSubscriptionDeepLink = FlutterBranchSdk.initSession().listen((data) {
      debugPrint('data: $data');
      if (data.containsKey('+clicked_branch_link')) {
        if (data['+clicked_branch_link'] == true) {
          String? postId, title, description;
          if (data.containsKey("post_id")) {
            postId = data["post_id"];
            title = data["\$og_title"];
            description = data["\$og_description"];
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                    postId: postId, title: title, description: description),
              ));
          // Navigator.pushReplacementNamed(navigatorKey.currentContext??context, '/home',  arguments: [false, postId]);
        }
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      debugPrint('exception: $platformException');
    });
  }
}
