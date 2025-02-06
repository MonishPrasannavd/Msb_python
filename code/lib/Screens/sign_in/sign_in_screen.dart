import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/forget_password/forget_password.dart';
import 'package:msb_app/components/loading.dart';
import 'package:msb_app/models/msbuser.dart' as msb;
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/api.dart';
import 'package:msb_app/utils/extention_text.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import FlutterToast for toast messages

import '../../components/button_builder.dart';
import '../../constants/navigation.dart';
import '../../services/preferences_service.dart';
import '../../utils/colours.dart';
import '../dashboard/dashboard_setup.dart';
import '../sign_up/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _validate = false;

  late UserAuthProvider userAuth;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      emailController.text = "vishweshone@gmail.com";
      passwordController.text = "vishweshone";
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  void showToast(String message, {Color backgroundColor = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  void _validateLoginDetails() {
    tryLoggingIn();
  }

  void tryLoggingIn() async {
    final Future<Map<String, dynamic>> successfulMessage =
        userAuth.login(emailController.text, passwordController.text);
    DialogBuilder(context).showLoadingIndicator('');
    successfulMessage.then((response) async {
      var errorMessage = response['message'].toString();
      if (response['status'] == true) {
        DialogBuilder(context).hideOpenDialog();
        msb.MsbUser user = response['user'];
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        // SharedPreferences prefs = await SharedPreferences.getInstance();

        // ✅ Use PrefsService instead of SharedPreferences instance
        await PrefsService.saveUser(user);
        await PrefsService.setUserId(user.user?.id.toString() ?? "");
        await PrefsService.setString(
            "nameEmail", user.user?.email.toString() ?? "");
        await PrefsService.setToken(user.accessToken);

        AppUrl.addHeader("Authorization", "Bearer ${user.accessToken}");

        // Debugging: Check if data is saved correctly
        String? storedUserId = await PrefsService.getUserId();
        String? storedEmail =
            await PrefsService.getUserNameEmail().whenComplete(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text("Successfully logged in"),
                  backgroundColor: AppColors.primary))
              .closed
              .then((value) => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardSetup()),
                    (route) => false,
                  ));
        });

        print("Stored User ID: $storedUserId"); // Should print actual user ID
        print("Stored Email: $storedEmail"); // Should print email
      } else {
        DialogBuilder(context).hideOpenDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login failed'), backgroundColor: Colors.red));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    userAuth = Provider.of<UserAuthProvider>(context);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: const CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: query.height / 2.1,
                width: query.width,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(40.0),
                    bottomLeft: Radius.circular(40.0),
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 35),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset("assets/images/sign_in.png",
                              height: query.height * 0.18, fit: BoxFit.contain),
                          const SizedBox(height: 20),
                          Text("Sign In",
                              style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36)),
                          const SizedBox(height: 4),
                          Text("Time to showcase your talent.",
                              style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16))
                        ])),
              ),
              Container(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _validate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: "Email Address",
                            labelText: "Email Address",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset("assets/svg/email.svg",
                                  colorFilter: const ColorFilter.mode(
                                      AppColors.fontHint, BlendMode.srcIn)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ⓘ Please enter your email";
                            } else if (!emailController.text.isValidEmail) {
                              return "ⓘ Enter valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: "Password",
                              labelText: "Password",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                    "assets/svg/password.svg",
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.fontHint, BlendMode.srcIn)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "ⓘ Please enter correct password";
                              }
                              return null;
                            }),
                        const SizedBox(height: 15),
                        SizedBox(
                            width: query.width,
                            height: 60,
                            child: ButtonBuilder(
                                text: 'Sign in',
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  // if (kDebugMode) {
                                  //   emailController.text = "monishvd@gmail.com";
                                  //   passwordController.text = "1234567890";
                                  // }
                                  setState(() {
                                    _validate = true;
                                    showSpinner =
                                        _formKey.currentState!.validate()
                                            ? true
                                            : false;
                                  });

                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      _validateLoginDetails();
                                    } on FirebaseAuthException catch (e) {
                                      String errorMessage;
                                      switch (e.code) {
                                        case 'user-not-found':
                                          errorMessage =
                                              'No user found with this email.';
                                          break;
                                        case 'wrong-password':
                                          errorMessage = 'Incorrect password.';
                                          break;
                                        case 'invalid-email':
                                          errorMessage =
                                              'Invalid email address.';
                                          break;
                                        case 'invalid-credential':
                                          errorMessage =
                                              'Invalid credentials. Please try again.';
                                          break;
                                        default:
                                          errorMessage =
                                              'An unexpected error occurred.';
                                      }
                                      showToast(errorMessage);
                                    } catch (e) {
                                      showToast(
                                          "An unexpected error occurred.");
                                    }
                                    setState(() {
                                      showSpinner = false;
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        AppColors.primary),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)))),
                                textStyle: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16))),
                        const SizedBox(height: 35),
                        RichText(
                          text: TextSpan(
                            text: "Don’t have an account? ",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF938A8A),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF2B8BF2),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    callNextScreen(context, const SignUpPage());
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            text: "Forgot Password?",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF2B8BF2),
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                callNextScreen(
                                    context, const ForgotPasswordScreen());
                              },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
