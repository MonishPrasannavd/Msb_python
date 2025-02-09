import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/user.dart';

import '../../../../components/button_builder.dart';
import '../../../../utils/colours.dart';

class ResultScreen extends StatefulWidget {
  final int resultScore;
  final int wrongAns;

  const ResultScreen(this.resultScore, this.wrongAns, {super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  MsbUser? user;

  final UserRepository _userRepository = UserRepository(
      usersCollection:
          FirebaseFirestore.instance.collection(FirestoreCollections.users));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    if (userId == null) return;
    var fetchedUser = await _userRepository.getOne(userId!);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
              height: query.height,
              width: query.width,
              child: Image.asset("assets/images/frame.png", fit: BoxFit.fill)),
          Column(
            children: [
              SizedBox(height: query.height * 0.05),
              Image.asset("assets/images/frame1.png",
                  height: query.height * 0.85,
                  width: query.width,
                  fit: BoxFit.cover),
              SizedBox(
                  width: query.width / 1.1,
                  height: 60,
                  child: ButtonBuilder(
                      text: 'Continue',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.primary),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)))),
                      textStyle: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16))),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: query.height * 0.065),
              Image.asset("assets/images/profile.png",
                  height: 80, fit: BoxFit.fill),
              const SizedBox(height: 8),
              Text(fetchFirstName(user?.name) ?? "User",
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 24)),
              const SizedBox(height: 8),

              if (user?.schoolName != null && user?.grade != null) ...[
                Text("${user?.grade} - ${user?.schoolName}",
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14)),
                const SizedBox(height: 10),
              ],
              SizedBox(
                  width: query.width / 1.2,
                  child:
                      Image.asset("assets/images/line.png", fit: BoxFit.fill)),
              const SizedBox(height: 8),
              Image.asset(
                "assets/images/congo.png",
                height: 55,
              ),
              const SizedBox(height: 8),
              Text("CONGRATULATIONS",
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24)),
              const SizedBox(height: 10),
              // Text("Your ranking",
              //     style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w400, fontSize: 12)),
              // const SizedBox(height: 8),
              // Text("1884 / 20,000",
              //     style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              // const SizedBox(height: 8),
              SizedBox(
                  width: query.width / 1.2,
                  child: Image.asset(
                    "assets/images/line.png",
                    fit: BoxFit.fill,
                  )),
              const SizedBox(height: 8),
              Text("Your Results",
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                height: query.height / 10,
                width: query.width / 1.35,
                decoration: BoxDecoration(
                    color: const Color(0xFFEEFBEF),
                    borderRadius: BorderRadius.circular(12.0),
                    border:
                        Border.all(width: 1, color: const Color(0xFF23A931))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Correct Answers",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF23A931),
                            fontWeight: FontWeight.w300,
                            fontSize: 12)),
                    Text(widget.resultScore.toString(),
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF23A931),
                            fontWeight: FontWeight.w700,
                            fontSize: 24)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: query.height / 10,
                width: query.width / 1.35,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(12.0),
                    border:
                        Border.all(width: 1, color: const Color(0xFFCC0000))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Wrong Answers",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFCC0000),
                            fontWeight: FontWeight.w300,
                            fontSize: 12)),
                    Text(widget.wrongAns.toString(),
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFCC0000),
                            fontWeight: FontWeight.w700,
                            fontSize: 24)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
