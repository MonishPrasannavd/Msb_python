import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:msb_app/Screens/sign_in/sign_in_screen.dart';
import 'package:msb_app/models/msbuser.dart';
import 'package:msb_app/providers/competitions_provider.dart';
import 'package:msb_app/providers/dash.dart';
import 'package:msb_app/providers/master/master_api_provider.dart';
import 'package:msb_app/providers/master/master_provider.dart';
import 'package:msb_app/providers/post_feed_provider.dart';
import 'package:msb_app/providers/school/school_api_provider.dart';
import 'package:msb_app/providers/student_dashboard_provider.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/api.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';

import 'Screens/dashboard/dashboard_setup.dart';
import 'Screens/profile/post_details_screen.dart';

// import 'package:is_first_run/is_first_run.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.init(); // Initialize SharedPreference

  await Firebase.initializeApp();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.debug, // Use debug for Android in development
    appleProvider: AppleProvider.debug, // Use debug for iOS in development
  );
  FirebaseFirestore.setLoggingEnabled(false);

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),

        // master provider
        ChangeNotifierProvider(create: (_) => MasterProvider()),
        ChangeNotifierProvider(create: (_) => MasterApiProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => Dash()),
        ChangeNotifierProvider(create: (_) => SchoolApiProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionApiProvider()),
        ChangeNotifierProvider(create: (_) => PostFeedsProvider()),
        ChangeNotifierProvider(create: (_) => CompetitionsProvider()),
        // ChangeNotifierProvider(create: (_) => Dash()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: AppColors.white,
          useMaterial3: true,
        ),
        builder: (context, child) {
          return _DeepLinkListenerBuilder(
            child: child!,
          );
        },
        home: IsLoginCheckPage(),
      ),
    );
  }
}

class _DeepLinkListenerBuilder extends StatefulWidget {
  const _DeepLinkListenerBuilder({
    required this.child,
  });

  final Widget child;

  @override
  State<_DeepLinkListenerBuilder> createState() =>
      __DeepLinkListenerBuilderState();
}

class __DeepLinkListenerBuilderState extends State<_DeepLinkListenerBuilder> {
  late StreamSubscription<Map>? streamSubscriptionDeepLink;

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

  void listenDeepLinkData(BuildContext context) {
    streamSubscriptionDeepLink = FlutterBranchSdk.listSession().listen((data) {
      debugPrint('data: $data');
      if (data['+clicked_branch_link'] == true) {
        String? postId, title, description;
        if (data.containsKey("post_id")) {
          postId = data["post_id"];
          title = data["\$og_title"];
          description = data["\$og_description"];
        }

        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              postId: int.tryParse(postId ?? ''),
              title: title,
              description: description,
            ),
          ),
        );
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      debugPrint('exception: $platformException');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class IsLoginCheckPage extends StatefulWidget {
  const IsLoginCheckPage({super.key});

  @override
  State<IsLoginCheckPage> createState() => _IsLoginCheckPageState();
}

class _IsLoginCheckPageState extends State<IsLoginCheckPage> {
  late MasterApiProvider _masterApiProvider;
  late MasterProvider _masterProvider;
  late UserAuthProvider _userAuthProvider;
  late UserProvider _userProvider;

  void fetchMaster() async {
    var result = await _masterApiProvider.getMasterData();
    debugPrint('result when fetching master data: $result');
    _masterProvider.countries = result['countries'];
    _masterProvider.states = result['states'];
    _masterProvider.schools = result['schools'];
    _masterProvider.grades = result['grades'];
  }

  Future<void> checkAppVersion(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Fetch saved app version from SharedPreferences
    String? savedVersion = await PrefsService.getString('app_version');

    if (savedVersion == null || savedVersion != currentVersion) {
      debugPrint("is clear version");
      // App version has changed or no version is stored
      await PrefsService
          .clear(); // Clear all saved preferences (logs out the user)
      await PrefsService.setString(
          'app_version', currentVersion); // Save new app version
      debugPrint("User logged out due to app update.");
    } else {
      debugPrint("App version is up-to-date.");
    }
  }

  Future<bool> checkUserLogin(BuildContext context) async {
    // bool firstCall = await IsFirstRun.isFirstCall();
    // bool firstRun = await IsFirstRun.isFirstRun();
    // Check the app version first
    await checkAppVersion(context);

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = await PrefsService.getUserId();
    var token = await PrefsService.getToken();
    var prefsUser = await PrefsService.getUser();
    if (userId != null && token != null && prefsUser != null) {
      AppUrl.addHeader("Authorization", "Bearer $token");

      // from persisted token, get user details and load in provider
      var response = await _userAuthProvider.getUserMe(prefsUser);
      var user = response['user'] as MsbUser;
      _userProvider.setUser(user);
    }
    // print("what is user id :-  ${userId}");
    // return firstCall && firstRun ? false : userId != null; // removing this because its outdated library and creating issue
    return userId != null ? true : false;
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
          // print("what is snapshot data ${isLoggedIn}");
          return isLoggedIn ? const DashboardSetup() : const SignInScreen();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _userAuthProvider = Provider.of<UserAuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _masterApiProvider =
          Provider.of<MasterApiProvider>(context, listen: false);
      _masterProvider = Provider.of<MasterProvider>(context, listen: false);

      fetchMaster();
    });
  }
}
