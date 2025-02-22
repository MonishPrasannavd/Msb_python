import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/tab_3_public.dart';
import 'package:msb_app/Screens/profile/profile_page.dart';
import 'package:msb_app/Screens/school/school_detail.dart';
import 'package:msb_app/Screens/school/view_all_schools.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/auth.dart';
import 'package:msb_app/utils/user.dart';

import '../../components/button_builder.dart';
import '../../enums/post_feed_type.dart';
import '../../models/user.dart';
import '../../repository/user_repository.dart';
import '../../utils/colours.dart';
import '../competition/post story/post_feed_screen.dart';
import '../competition/quiz/quiz_screen.dart';

class SchoolScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SchoolScreen({required this.onLogout, super.key});

  @override
  State<SchoolScreen> createState() => SchoolScreenState();
}

class SchoolScreenState extends State<SchoolScreen> {
  MsbUser? user;
  late UserRepository userRepository;
  TextEditingController searchController = TextEditingController();
  final SchoolUserRepository schoolRepository = SchoolUserRepository();
  late Future<void> _fetchDataFuture;
  List<SchoolUser> topSchools = [];
  List<SchoolUser> recentlyJoinedSchools = [];
  int totalUsersCount = 0;
  int totalSchoolsCounts = 0;
  double progress = 0.0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(
        usersCollection: FirebaseFirestore.instance.collection('users'));
    setState(() {
      progress = 0.0;
    });
    _fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    await fetchSchoolsData();
    await fetchUserProfile();
    await fetchUsersData();
  }

  Future<void> fetchSchoolsData() async {
    // var fetchedTopSchools = await schoolRepository.getTopSchoolsByAveragePoints();
    var [fetchedTopSchools, fetchedRecentlyJoinedSchools] = await Future.wait([
      schoolRepository.getTopSchoolsByAveragePoints(),
      schoolRepository.getRecentlyJoinedSchools(),
    ]);
    setState(() {
      progress = 0.33;
    });
    var fetchTopSchoolsCount = await schoolRepository.getTotalSchoolCount();
    setState(() {
      totalSchoolsCounts = fetchTopSchoolsCount;
      topSchools = fetchedTopSchools;
      recentlyJoinedSchools = fetchedRecentlyJoinedSchools;
      progress = 0.66;
    });
  }

  Future<void> fetchUsersData() async {
    var fetchedTotalCount = await userRepository.getTotalUserCount();
    setState(() {
      progress = 0.83;
    });
    setState(() {
      totalUsersCount = fetchedTotalCount;
      progress = 1.0;
    });
  }

  Future<void> fetchUserProfile() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var fetchedUser = await userRepository.getOne(userId);
      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
        });
      }
    }
  }

  Widget _buildProfileImage(String? name, String? profileImageUrl) {
    if (profileImageUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(profileImageUrl),
      );
    } else {
      return Image.asset(
        "assets/images/profile.png",
        height: 40,
      );
    }
  }

  void refetchData() {
    setState(() {
      _fetchDataFuture = fetchData();
    });
  }

  var colors = [
    const Color(0xFFF79027),
    const Color(0xFF683AB7),
    const Color(0xFF23A931),
    const Color(0xFFFF4747),
    const Color(0xFF763E04),
  ];
  var colorsBorder = [
    const Color(0xFFCC0000),
    const Color(0xFF683AB7),
    const Color(0xFFFF9999),
    const Color(0xFF15651D),
    const Color(0xFF1C8727),
  ];

  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Dance",
      "icon": 'assets/images/trending.png',
      "route": PostFeeds("Dance", contentType: PostFeedType.video.value)
    },
    {
      "title": "Art & Crafts",
      "icon": 'assets/images/art.png',
      "route": PostFeeds("Art & Crafts", contentType: PostFeedType.image.value)
    },
    {
      "title": "Quiz",
      "icon": 'assets/images/quiz.png',
      "route": const QuizScreen()
    },
    {
      "title": "Story Telling",
      "icon": 'assets/images/story.png',
      "route": PostFeeds("Story Telling", contentType: PostFeedType.image.value)
    },
  ];

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:  AppColors.black12,
      body: DecoratedBox(
        // BoxDecoration takes the image
        decoration: const BoxDecoration(
          // Image set to background of the body
          image: DecorationImage(
              image: AssetImage("assets/images/profile_frame copy.png"),
              fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: query.width,
                decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox.shrink(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hey Superstar",
                                style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12)),
                            Text(fetchFirstName(user?.name) ?? "User",
                                style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24)),
                          ],
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            await PrefsService.clear();
                            widget.onLogout();
                          },
                          child: const Icon(Icons.logout,
                              color: Color(0xFFCDA1F7), size: 28),
                        ),
                        // SvgPicture.asset(
                        //   "assets/svg/chat.svg",
                        //   height: 36,
                        //   color: const Color(0xFFCDA1F7),
                        // ),
                        // SvgPicture.asset(
                        //   "assets/svg/notification.svg",
                        //   height: 36,
                        //   color: const Color(0xFFCDA1F7),
                        // ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                          onLogout:
                                              AuthUtils.handleLogout(context),
                                        )));
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0xFF3F0A70),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50.0),
                                  bottomLeft: Radius.circular(50.0),
                                )),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, top: 5.0, bottom: 5.0, right: 5.0),
                              child: user != null
                                  ? _buildProfileImage(
                                      user!.name, user!.profileImageUrl)
                                  : Image.asset(
                                      "assets/images/profile.png",
                                      height: 40,
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    /// School Search bar
                    // TextFormField(
                    //   controller: searchController,
                    //   decoration: kTextFieldDecoration.copyWith(
                    //       fillColor: const Color(0xFFFFEBEB),
                    //       filled: true,
                    //       hintText: "Search School",
                    //       labelText: "Search School",
                    //       prefixIcon: Container(),
                    //       suffixIcon: Padding(
                    //         padding: const EdgeInsets.all(10.0),
                    //         child: SvgPicture.asset("assets/svg/search.svg",
                    //             colorFilter: const ColorFilter.mode(AppColors.fontHint, BlendMode.srcIn)),
                    //       )),
                    // ),
                    // const SizedBox(height: 10),

                    FutureBuilder(
                      future: _fetchDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Curating schools screen",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                buildProgressIndicator(),
                                const SizedBox(height: 10),
                                Text(
                                  '${(progress * 100).toInt()}%', // Display the percentage
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            /// School List placeholder
                            RichText(
                              text: TextSpan(
                                text: "Our ",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF212121),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                                children: [
                                  TextSpan(
                                    text: "Schools ",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF540D96),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  TextSpan(
                                    text: "List",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF212121),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// total schools and students
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 120,
                                    width: query.width,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.peachLight
                                              .withOpacity(0.50),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black45
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(totalSchoolsCounts.toString(),
                                            style: GoogleFonts.poppins(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24)),
                                        Text("Total Schools",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: Container(
                                    height: 120,
                                    width: query.width,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.peachLight
                                              .withOpacity(0.50),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black45
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(totalUsersCount.toString(),
                                            style: GoogleFonts.poppins(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24)),
                                        Text("Total Students",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15),

                            /// top 10 leaderboard
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.black12,
                                        Colors.black12,
                                        Colors.blueGrey
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "Our ",
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFF212121),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                          children: [
                                            TextSpan(
                                              text: "Top 5 ",
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.msbGold,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 20),
                                            ),
                                            TextSpan(
                                              text: "Leader Board",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF212121),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        // Prevent internal scrolling
                                        shrinkWrap: true,
                                        // Adjust size dynamically
                                        itemCount: topSchools.length,
                                        // Limit to Top 5
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          var school = topSchools[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.50),
                                                    spreadRadius: 0,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 4),
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.50),
                                                    spreadRadius: 0,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.blueGrey
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SchoolDetailPage(
                                                            schoolId: school
                                                                .schoolId!,
                                                          ),
                                                        ))
                                                    .then((val) => val
                                                        ? refetchData()
                                                        : null),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        (index + 1)
                                                            .toString()
                                                            .padLeft(2,
                                                                '0'), // Add leading zero
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: _getRankColor(
                                                              index),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            school.schoolName ??
                                                                "Unknown School",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: AppColors
                                                                  .peach,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            "Total Point: ${school.averagePoints.toStringAsFixed(2)}",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: AppColors
                                                                  .peachLight,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            /// recently joined schools
                            Container(
                              // decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.0)),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ViewAllSchools(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View all >>",
                                      style: GoogleFonts.poppins(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16),
                                    ),
                                  ),
                                  // ListView.builder(
                                  //   padding: const EdgeInsets.only(top: 10),
                                  //   shrinkWrap: true,
                                  //   physics: const NeverScrollableScrollPhysics(),
                                  //   itemCount: recentlyJoinedSchools.length,
                                  //   itemBuilder: (context, index) {
                                  //     var recentSchool = recentlyJoinedSchools[index];
                                  //     return Padding(
                                  //       padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  //       child: GestureDetector(
                                  //         onTap: () {
                                  //           Navigator.push(
                                  //               context,
                                  //               MaterialPageRoute(
                                  //                   builder: (context) =>
                                  //                       SchoolDetailPage(schoolId: recentSchool.schoolId!)));
                                  //         },
                                  //         child: Container(
                                  //           height: 60,
                                  //           decoration: BoxDecoration(
                                  //               borderRadius: BorderRadius.circular(8.0),
                                  //               border: Border.all(width: 2, color: const Color(0xFFCECACA))),
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                  //             child: Row(
                                  //               children: [
                                  //                 Expanded(
                                  //                   child: Text(recentSchool.schoolName!,
                                  //                       style: GoogleFonts.poppins(
                                  //                           color: const Color(0xFF151414),
                                  //                           fontWeight: FontWeight.w500,
                                  //                           fontSize: 16)),
                                  //                 ),
                                  //                 const Spacer(),
                                  //                 Text(recentSchool.averagePoints.toString(),
                                  //                     style: GoogleFonts.poppins(
                                  //                         color: const Color(0xFF6A6262),
                                  //                         fontWeight: FontWeight.w400,
                                  //                         fontSize: 14)),
                                  //                 const SizedBox(width: 15),
                                  //                 SvgPicture.asset(
                                  //                   "assets/svg/right.svg",
                                  //                   height: 20,
                                  //                   color: const Color(0xFF6A6262),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => const ViewAllSchools(),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: const Text('View more'),
                                  // )
                                ],
                              ),
                            ),
                                                Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.black12,
                                        Colors.blueGrey,
                                        Colors.black12
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),

                                      /// showcase talents
                                      RichText(
                                        text: TextSpan(
                                          text: "Showcase ",
                                          style: GoogleFonts.poppins(
                                              color: AppColors.msbGold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17),
                                          children: [
                                            TextSpan(
                                              text: "Your talents in",
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.peachLight,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: query.height / 8,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: menuItems.length,
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final menuItem = menuItems[index];
                                            return GestureDetector(
                                              onTap: () {
                                                //callNextScreen(context, const QuizScreen());
                                                if (index == 0) {
                                                  Navigator.of(context,
                                                          rootNavigator: false)
                                                      .push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            PostFeeds("Dance",
                                                                contentType:
                                                                    PostFeedType
                                                                        .video
                                                                        .value)),
                                                  );
                                                } else if (index == 1) {
                                                  Navigator.of(context,
                                                          rootNavigator: false)
                                                      .push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            PostFeeds(
                                                                "Art & Crafts",
                                                                contentType:
                                                                    PostFeedType
                                                                        .image
                                                                        .value)),
                                                  );
                                                } else if (index == 2) {
                                                  Navigator.of(context,
                                                          rootNavigator: false)
                                                      .push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            PostFeeds(
                                                                "Story Telling",
                                                                contentType:
                                                                    PostFeedType
                                                                        .image
                                                                        .value)),
                                                  );
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient: const RadialGradient(
                                                                  colors: [
                                                                    AppColors
                                                                        .black38,
                                                                    AppColors
                                                                        .white30
                                                                  ],
                                                                  center: Alignment
                                                                      .bottomCenter,
                                                                  radius: 1.0),
                                                              border: Border.all(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  width: 1)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(21.0),
                                                            child: Image.asset(
                                                                menuItem[
                                                                    'icon']),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(menuItem['title'],
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: AppColors
                                                                      .peachLight,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      12)),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 5)
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),

                                      SizedBox(
                                        height: 50,
                                        child: ButtonBuilder(
                                            text: 'View All Competitions',
                                            onPressed: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Padding(
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      child: PublicTab(),
                                                    ),
                                                  ));
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        AppColors.black54),
                                                shape: MaterialStateProperty
                                                    .all(RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    50.0)))),
                                            textStyle: GoogleFonts.poppins(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14)),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get color based on rank
  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.orangeAccent;
      case 1:
        return Colors.purpleAccent;
      case 2:
        return Colors.greenAccent;
      case 3:
        return Colors.redAccent;
      case 4:
        return Colors.greenAccent;
      default:
        return Colors.blueAccent; // Default fallback color
    }
  }

  Widget buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Stack(
        children: [
          Container(
            height: 12, // Height of the progress bar
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Rounded corners
              color: Colors.grey[300], // Background color of the progress bar
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth *
                    progress, // Adjust the width based on progress
                height: 12, // Height of the progress bar
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  gradient: const LinearGradient(
                    colors: [
                      Colors.greenAccent,
                      Colors.blueAccent
                    ], // Gradient from green to blue
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
