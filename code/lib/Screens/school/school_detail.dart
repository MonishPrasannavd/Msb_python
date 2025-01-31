import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/all_school_competitions.dart';
import 'package:msb_app/Screens/profile/post_details_screen.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/Screens/school/top_users.dart';
import 'package:msb_app/Screens/user/view_all_users.dart';
import 'package:msb_app/components/msb_carousel.dart';
import 'package:msb_app/components/msb_post_carousel.dart';
import 'package:msb_app/components/text_builder.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/school_dashboard.dart';
import 'package:msb_app/models/school_rank.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/ui/carousel_slides.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/school/school_api_provider.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/points_system.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/loaders.dart';
import 'package:msb_app/utils/user.dart';
import 'package:provider/provider.dart';

import '../../components/button_builder.dart';
import '../../enums/post_feed_type.dart';
import '../../utils/colours.dart';
import '../competition/post story/post_feed_screen.dart';
import '../competition/quiz/quiz_screen.dart';

class SchoolDetailPage extends StatefulWidget {
  final String schoolId;
  final SchoolRank? schoolRank;

  const SchoolDetailPage({super.key, required this.schoolId, this.schoolRank});

  @override
  State<SchoolDetailPage> createState() => _SchoolDetailPageState();
}

class _SchoolDetailPageState extends State<SchoolDetailPage> {
  SchoolUserRepository schoolUserRepository = SchoolUserRepository();
  UserRepository userRepository =
      UserRepository(usersCollection: FirebaseFirestore.instance.collection(FirestoreCollections.users));
  PostFeedRepository postFeedRepository = PostFeedRepository();
  SchoolUser? school;
  MsbUser? user;
  int schoolTotalLikes = 0;
  late Future<void> fetchDataFuture; // unresolved promise
  double progress = 0.0;
  List<MsbUser> topUsers = [];
  List<PostFeed> recentPosts = [];
  List<PostFeed> popularPosts = [];
  List<MsbUser> otherUsers = [];
  int? schoolRank;
  SchoolDashboard? schoolDashboard;

  late SchoolApiProvider _schoolApiProvider;

  @override
  void initState() {
    super.initState();
    setState(() {
      progress = 0.0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schoolApiProvider = Provider.of<SchoolApiProvider>(context, listen: false);

      fetchDataFuture = fetchScreenData();
      fetchScreenData();
    });
  }

  Future<void> fetchScreenData() {
    return Future.wait([
      fetchUsersData(),
      fetchSchoolDetails(),
      fetchRecentPosts(),
      fetchPopularPosts(),
      fetchOtherUsers(),
      fetchSchoolRank(),
      getSchoolDashboard()
    ]);
  }

  Future<void> getSchoolDashboard() async {
    Map<String, dynamic> response = await _schoolApiProvider.getSchoolDashboard(int.parse(widget.schoolId));
    setState(() {
      schoolDashboard = response['dashboard'];
    });
  }

  Future<void> fetchSchoolRank() async {
    try {
      var fetchedRank = await schoolUserRepository.getSchoolRank(widget.schoolId);
      setState(() {
        schoolRank = fetchedRank;
      });
    } catch (e) {
      print("Error fetching other users: $e");
    }
  }

  Future<void> fetchOtherUsers() async {
    try {
      // Gather all user IDs to exclude
      List<String> excludedUserIds = [
        FirebaseAuth.instance.currentUser!.uid, // Exclude current user
        ...topUsers.map((user) => user.id!).whereType<String>(), // Exclude top users
        ...recentPosts.map((post) => post.userId!).whereType<String>(), // Exclude users from recent posts
        ...popularPosts.map((post) => post.userId!).whereType<String>(), // Exclude users from popular posts
      ];

      // Remove duplicates
      excludedUserIds = excludedUserIds.toSet().toList();

      // Fetch all users except those in the excluded list
      var fetchedOtherUsers = await userRepository.getAllExcept(userIds: excludedUserIds, schoolIds: [widget.schoolId]);
      setState(() {
        progress = 1.0;
        otherUsers = fetchedOtherUsers;
      });
    } catch (e) {
      print("Error fetching other users: $e");
    }
  }

  Future<void> fetchUsersData() async {
    try {
      var retrievedUser = await userRepository.getOne(FirebaseAuth.instance.currentUser!.uid);
      var fetchedTopUsers = await userRepository.getTopUsersBySchoolId(widget.schoolId);
      setState(() {
        user = retrievedUser;
        topUsers = fetchedTopUsers;
        progress = 0.33;
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> fetchRecentPosts() async {
    var posts = await postFeedRepository.getRecentForUserBySchoolId(widget.schoolId, limit: 4);
    setState(() {
      recentPosts = posts;
      progress = 1.0;
    });
  }

  Future<void> fetchPopularPosts() async {
    var posts = await postFeedRepository.getTopPostsByLikesInSchool(widget.schoolId, limit: 4);
    setState(() {
      popularPosts = posts;
      progress = 1.0;
    });
  }

  Future<void> fetchSchoolDetails() async {
    try {
      var retrievedSchool = await schoolUserRepository.findBySchoolId(widget.schoolId);
      setState(() {
        progress = 0.66;
      });
      if (retrievedSchool?.schoolId != null) {
        var retrievedTotalLikes = await postFeedRepository.getTotalLikesBySchoolId(retrievedSchool!.schoolId!);
        setState(() {
          school = retrievedSchool;
          schoolTotalLikes = retrievedTotalLikes;
          progress = 0.83;
        });
      }
    } catch (e) {
      print("Error fetching school details: $e");
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
    {"title": "Quiz", "icon": 'assets/images/quiz.png', "route": const QuizScreen()},
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<SchoolApiProvider>(builder: (ctxt, schoolApiProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: query.height / 5,
                width: query.width,
                decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(25.0), bottomLeft: Radius.circular(25.0))),
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
                                    color: AppColors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                            Text(fetchFirstName(user?.name) ?? "User",
                                style: GoogleFonts.poppins(
                                    color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 24)),
                          ],
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          "assets/svg/chat.svg",
                          height: 36,
                          color: const Color(0xFFCDA1F7),
                        ),
                        SvgPicture.asset(
                          "assets/svg/notification.svg",
                          height: 36,
                          color: const Color(0xFFCDA1F7),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          decoration: const BoxDecoration(
                              color: Color(0xFF3F0A70),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.0),
                                bottomLeft: Radius.circular(50.0),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 7.0, top: 7.0, bottom: 7.0, right: 10.0),
                            child: user != null
                                ? _buildProfileImage(user!.name, user!.profileImageUrl)
                                : Image.asset(
                                    "assets/images/profile.png",
                                    height: 40,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                  future: fetchDataFuture,
                  builder: (cxt, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                            buildProgressIndictaor(progress),
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

                    return mainUi();
                  }),
            ],
          ),
        );
      }),
    );
  }

  Widget mainUi() {
    var query = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Container(
        decoration: const BoxDecoration(
          // Image set to background of the body
          image: DecorationImage(image: AssetImage("assets/images/profile_frame copy.png"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: SvgPicture.asset(
                    "assets/svg/back.svg",
                    height: 20,
                    color: const Color(0xFF6A6262),
                  ),
                ),
                // const Spacer(),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.schoolRank?.name ?? "School Name",
                        style: GoogleFonts.poppins(color: const Color(0xFF212121), fontWeight: FontWeight.w600)),
                  ),
                ),
                // const SizedBox.shrink()
              ],
            ),
            const SizedBox(height: 10),
            MsbCarousel(slides: [
              MsbCarouselSlide(imagePath: 'assets/dashboard/appslide1.png'),
            ]),
            const SizedBox(height: 10),
            if (schoolRank != null) ...[
              SizedBox(
                width: double.infinity,
                child: ButtonBuilder(
                    text: 'School Ranking #$schoolRank',
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppColors.black38),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
                    textStyle: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 120,
                    width: query.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.studentsCount?.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96), fontWeight: FontWeight.w700, fontSize: 24)),
                        Text("Total Students",
                            style:
                                GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 120,
                    width: query.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.submissionsCount.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96), fontWeight: FontWeight.w700, fontSize: 24)),
                        Text("Total Entries",
                            style:
                                GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 120,
                    width: query.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.submissionsCount.toString() ?? '0',
                            // PointsSystem.getTotalScore(
                            //   averagePoints: school?.averagePoints,
                            //   studentCount: school?.studentCount,
                            // ).toString(),
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96), fontWeight: FontWeight.w700, fontSize: 24)),
                        Text("Total Points",
                            style:
                                GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 120,
                    width: query.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.topSubmissionsLikes.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96), fontWeight: FontWeight.w700, fontSize: 24)),
                        Text("Appreciation",
                            style:
                                GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "Hall of ",
                style: GoogleFonts.poppins(color: const Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 22),
                children: [
                  TextSpan(
                    text: "Fame  ",
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF540D96), fontWeight: FontWeight.w600, fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TopUsersWidget(topUsers: topUsers),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ButtonBuilder(
                text: 'View Full List',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewAllUsersInSchool(
                                schoolId: widget.schoolId,
                              )));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.purpleDark),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                textStyle: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),

            /// Recent entries
            if (recentPosts.isNotEmpty) ...[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Recent ',
                      style: GoogleFonts.poppins(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'Entries',
                      style: GoogleFonts.poppins(color: AppColors.purple, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MsbPostsCarousel(
                  posts: recentPosts,
                  showLikes: false,
                ),
              ),
              const SizedBox(height: 15),
            ],

            /// Popular post
            if (popularPosts.isNotEmpty) ...[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Popular ',
                      style: GoogleFonts.poppins(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'Posts',
                      style: GoogleFonts.poppins(color: AppColors.purple, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MsbPostsCarousel(posts: popularPosts),
              ),
              const SizedBox(height: 15),
            ],

            /// other students
            if (otherUsers.isNotEmpty)
              Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Other Students",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF094F9A), fontWeight: FontWeight.w600, fontSize: 16)),
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: otherUsers.length,
                      itemBuilder: (context, index) {
                        var user = otherUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => UserProfileScreen(id: user.id!)))
                                  .then((val) async => await fetchScreenData());
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(width: 2, color: const Color(0xFFCECACA))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Row(
                                  children: [
                                    Text(user.name ?? user.email ?? 'Unknown',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF151414), fontWeight: FontWeight.w500, fontSize: 16)),
                                    const Spacer(),
                                    Text(user.totalPoints.toString() ?? "0",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF6A6262), fontWeight: FontWeight.w400, fontSize: 14)),
                                    const SizedBox(width: 15),
                                    SvgPicture.asset(
                                      "assets/svg/right.svg",
                                      height: 16,
                                      color: const Color(0xFF6A6262),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            const SizedBox(height: 15),

            /// showcase
            RichText(
              text: TextSpan(
                text: "Showcase ",
                style: GoogleFonts.poppins(color: const Color(0xFF540D96), fontWeight: FontWeight.w700, fontSize: 18),
                children: [
                  TextSpan(
                    text: "Your talents in",
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: query.height / 7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: menuItems.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (BuildContext context, int index) {
                  final menuItem = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      //callNextScreen(context, const QuizScreen());
                      Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(builder: (_) => menuItem["route"]),
                      );
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 85,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                      colors: [Color(0xFFE1C7FA), AppColors.white30],
                                      center: Alignment.bottomCenter,
                                      radius: 1.0),
                                  border: Border.all(color: const Color(0xFFE1C7FA), width: 5)),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Image.asset(menuItem['icon']),
                              ),
                            ),
                            Text(menuItem['title'],
                                style: GoogleFonts.poppins(
                                    color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(width: 5)
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            ButtonBuilder(
                text: 'View All Competitions',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                                id: widget.schoolId,
                                type: 'school',
                              ))).then((val) async => await fetchScreenData());
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primary),
                    shape:
                        MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)))),
                textStyle: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
