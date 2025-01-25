import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/sign_in/sign_in_screen.dart';

import '../../components/button_builder.dart';
import '../../constants/navigation.dart';
import '../../utils/colours.dart';

class OtpSentScreen extends StatefulWidget {
  const OtpSentScreen({super.key});

  @override
  State<OtpSentScreen> createState() => _OtpSentScreenState();
}

class _OtpSentScreenState extends State<OtpSentScreen> {
  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Container(
                  width: query.width,
                  decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(40.0), bottomLeft: Radius.circular(40.0))),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 35),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset("assets/images/otp_2.png",
                                //"assets/images/otp_1.png"
                                height: query.height * 0.18,
                                fit: BoxFit.contain),
                            const SizedBox(height: 20),
                            Text("Email Sent", //verified
                                style: GoogleFonts.poppins(
                                    color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 36)),
                            const SizedBox(height: 4),
                            // Text("4 digit code sent to your email address.",
                            Text("Verification link sent to your email address.",
                                style: GoogleFonts.poppins(
                                    color: AppColors.white, fontWeight: FontWeight.w400, fontSize: 16))
                          ])))),
          Expanded(
              child: Container(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  SizedBox(
                      width: query.width,
                      height: 60,
                      child: ButtonBuilder(
                          text: 'verify',
                          onPressed: () {
                            callNextScreen(context, const SignInScreen());
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(AppColors.primary),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
                          textStyle:
                              GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16))),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
