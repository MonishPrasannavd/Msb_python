import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/completion_screen.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/Screens/school/top_users.dart';
import 'package:msb_app/Screens/user/view_all_users.dart';
import 'package:msb_app/components/msb_carousel.dart';
import 'package:msb_app/components/msb_post_carousel.dart';
import 'package:msb_app/components/msb_post_carousel_v2.dart';
import 'package:msb_app/models/dashboard.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/school_dashboard.dart';
import 'package:msb_app/models/school_rank.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/ui/carousel_slides.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/school/school_api_provider.dart';
import 'package:msb_app/providers/student_dashboard_provider.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/loaders.dart';
import 'package:msb_app/utils/user.dart';
import 'package:provider/provider.dart';

import '../../components/button_builder.dart';
import '../../utils/colours.dart';

class SchoolDetailPage extends StatefulWidget {
  final String schoolId;
  final SchoolRank? schoolRank;

  const SchoolDetailPage({super.key, required this.schoolId, this.schoolRank});

  @override
  State<SchoolDetailPage> createState() => _SchoolDetailPageState();
}

class _SchoolDetailPageState extends State<SchoolDetailPage> {
  SchoolUser? school;
  MsbUser? user;
  int schoolTotalLikes = 0;
  late Future<void> fetchDataFuture; // unresolved promise
  double progress = 0.0;
  List<MsbUser> topUsers = [];
  List<PostFeed> recentPosts = [];
  List<PostFeed> popularPosts = [];
  List<MsbUser> otherUsers = [];
  List<Submission> submissions = [];
  int? schoolRank;
  SchoolDashboard? schoolDashboard;

  late SchoolApiProvider _schoolApiProvider;
  late SubmissionApiProvider _submissionApiProvider;
  late StudentDashboardProvider studentDashboardProvider;

  @override
  void initState() {
    super.initState();
    setState(() {
      progress = 0.0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schoolApiProvider =
          Provider.of<SchoolApiProvider>(context, listen: false);
      studentDashboardProvider =
          Provider.of<StudentDashboardProvider>(context, listen: false);
      fetchDataFuture = fetchScreenData();
      fetchScreenData();
    });
  }

  Future<void> fetchScreenData() {
    return Future.wait([getSchoolDashboard()]);
  }

  Future<void> getSchoolDashboard() async {
    Map<String, dynamic> response =
        await _schoolApiProvider.getSchoolDashboard(int.parse(widget.schoolId));
    setState(() {
      schoolDashboard = response['dashboard'];
    });
  }

  Future<void> getSchoolPosts() async {
    Map<String, dynamic> response = await _submissionApiProvider
        .getSubmissionsBySchool(int.parse(widget.schoolId));
    setState(() {
      submissions.clear();
      if (response['submissions'] != null) {
        submissions.addAll(response['submissions'] as List<Submission>);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Consumer4<SchoolApiProvider, SubmissionProvider,
              SubmissionApiProvider, UserProvider>(
          builder: (ctxt, schoolApiProvider, submissionProvider,
              submissionApiProvider, userProvider, child) {
        var loggedInUser = userProvider.user.user;
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: query.height / 7,
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
                            Text(fetchFirstName(loggedInUser?.name) ?? "User",
                                style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24)),
                          ],
                        ),
                        const Spacer(),
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
                        Container(
                          decoration: const BoxDecoration(
                              color: Color(0xFF3F0A70),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.0),
                                bottomLeft: Radius.circular(50.0),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 7.0, top: 7.0, bottom: 7.0, right: 10.0),
                            child: (loggedInUser?.name != null &&
                                    loggedInUser?.profileUrl != null)
                                ? _buildProfileImage(
                                    loggedInUser!.name, loggedInUser.profileUrl)
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
          image: DecorationImage(
              image: AssetImage("assets/images/profile_frame copy.png"),
              fit: BoxFit.cover),
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
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF212121),
                            fontWeight: FontWeight.w600)),
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
                        backgroundColor:
                            MaterialStateProperty.all(AppColors.black38),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)))),
                    textStyle: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16)),
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
                        image: const DecorationImage(
                            image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.studentsCount?.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96),
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
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 120,
                    width: query.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(
                            image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            schoolDashboard?.submissionsCount.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96),
                                fontWeight: FontWeight.w700,
                                fontSize: 24)),
                        Text("Total Entries",
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
                        image: const DecorationImage(
                            image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schoolDashboard?.avgPoints.toString() ?? '0',
                            // PointsSystem.getTotalScore(
                            //   averagePoints: school?.averagePoints,
                            //   studentCount: school?.studentCount,
                            // ).toString(),
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96),
                                fontWeight: FontWeight.w700,
                                fontSize: 24)),
                        Text("Total Points",
                            style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16)),
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
                        image: const DecorationImage(
                            image: AssetImage("assets/images/back.png"))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            schoolDashboard?.submissionsLikes.toString() ?? "0",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF540D96),
                                fontWeight: FontWeight.w700,
                                fontSize: 24)),
                        Text("Appreciation",
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
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "Hall of ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF212121),
                    fontWeight: FontWeight.w600,
                    fontSize: 22),
                children: [
                  TextSpan(
                    text: "Fame  ",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF540D96),
                        fontWeight: FontWeight.w600,
                        fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TopUsersWidget(topUsers: schoolDashboard?.topStudents ?? []),
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
                  backgroundColor:
                      WidgetStateProperty.all(AppColors.purpleDark),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                textStyle: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
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
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'Entries',
                      style: GoogleFonts.poppins(
                          color: AppColors.purple,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MsbPostsCarouselV2(
                  posts: submissions,
                  showLikes: false,
                ),
              ),
              const SizedBox(height: 15),
            ],

            /// top posts v2
            if(schoolDashboard?.topLikeSubmissions != null && schoolDashboard!.topLikeSubmissions!.isNotEmpty) ...[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Popular ',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'Posts 2',
                      style: GoogleFonts.poppins(
                          color: AppColors.purple,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  MsbPostsCarouselV2(posts: schoolDashboard!.topLikeSubmissions!, showLikes: true,),
                ],
              ),
              const SizedBox(height: 15),
            ],

            /// other students
            if (otherUsers.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Other Students",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF094F9A),
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
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
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserProfileScreen(id: user.id!)))
                                  .then((val) async => await fetchScreenData());
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      width: 2,
                                      color: const Color(0xFFCECACA))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Row(
                                  children: [
                                    Text(user.name ?? user.email ?? 'Unknown',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF151414),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16)),
                                    const Spacer(),
                                    Text(user.totalPoints.toString(),
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF6A6262),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14)),
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
                style: GoogleFonts.poppins(
                    color: const Color(0xFF540D96),
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
                children: [
                  TextSpan(
                    text: "Your talents in",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF212121),
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: query.height / 8,
              child: ChangeNotifierProvider.value(
                value: studentDashboardProvider,
                child: Consumer<StudentDashboardProvider>(
                    builder: (context, value, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: (value.dashboardCategoryList?.length ?? 0),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemBuilder: (BuildContext context, int index) {
                      final FutureCategories? menuItem =
                          value.dashboardCategoryList?[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompletionScreen(
                                  categoryId: menuItem?.id ?? 1,
                                  subcategories: menuItem?.subcategories,
                                  categoryName: menuItem?.name ?? "",
                                  contentType: menuItem?.categoryType?.name,
                                ),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: CachedNetworkImage(
                                    imageUrl: menuItem?.iconUrl ?? "",
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Center(child: Icon(Icons.error)),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Text(menuItem?.name ?? "",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            // SizedBox(
            //   height: query.height / 7,
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     itemCount: menuItems.length,
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 2),
            //     itemBuilder: (BuildContext context, int index) {
            //       final menuItem = menuItems[index];
            //       return GestureDetector(
            //         onTap: () {
            //           //callNextScreen(context, const QuizScreen());
            //           Navigator.of(context, rootNavigator: false).push(
            //             MaterialPageRoute(builder: (_) => menuItem["route"]),
            //           );
            //         },
            //         child: Row(
            //           children: [
            //             Column(
            //               children: [
            //                 Container(
            //                   height: 85,
            //                   decoration: BoxDecoration(
            //                       shape: BoxShape.circle,
            //                       gradient: const RadialGradient(
            //                           colors: [Color(0xFFE1C7FA), AppColors.white30],
            //                           center: Alignment.bottomCenter,
            //                           radius: 1.0),
            //                       border: Border.all(color: const Color(0xFFE1C7FA), width: 5)),
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(20.0),
            //                     child: Image.asset(menuItem['icon']),
            //                   ),
            //                 ),
            //                 Text(menuItem['title'],
            //                     style: GoogleFonts.poppins(
            //                         color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 14)),
            //               ],
            //             ),
            //             const SizedBox(width: 5)
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(height: 5),
            ButtonBuilder(
                text: 'View All Submissions',
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
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)))),
                textStyle: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
