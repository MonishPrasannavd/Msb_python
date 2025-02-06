import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/tab_1_home.dart';
import 'package:msb_app/Screens/profile/profile_page.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/user.dart';

import '../../utils/colours.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({required this.onLogout, super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  MsbUser? user;
  late UserRepository userRepository;
  GlobalKey<HomeTabState> homeTabKey = GlobalKey<HomeTabState>();
  GlobalKey<ProfileScreenState> profileScreenState =
      GlobalKey<ProfileScreenState>();

  @override
  void initState() {
    userRepository = UserRepository(
        usersCollection: FirebaseFirestore.instance.collection('users'));
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        if (tabController.index == 0) {
          // homeTabKey.currentState?.fetchUsersData();
          homeTabKey.currentState?.getDashboard();
        }
      });
    });
    fetchUserProfile();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserProfile();
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

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      /*  floatingActionButton: FloatingActionButton(
          onPressed: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              PostFeeds(PostFeedType.video.value)));
      }),*/
      body: Column(
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
                        Text(
                            user != null
                                ? fetchFirstName(user?.name) ?? "User"
                                : "User",
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
                                      onLogout: widget.onLogout,
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
                              left: 7.0, top: 7.0, bottom: 7.0, right: 10.0),
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
                // Expanded(
                //   child: HomeTab(
                //     key: homeTabKey,
                //   ),
                // ),
                // buildTabView()
              ],
            ),
          ),
          Expanded(
            child: HomeTab(
              key: homeTabKey,
            ),
          ),
          // Expanded(
          //   child: TabBarView(controller: tabController, children: [
          //     HomeTab(
          //       key: homeTabKey,
          //     ),
          //     const MyFeedTab(),
          //     const PublicTab(),
          //   ]),
          // )
        ],
      ),
    );
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

  Widget buildTabView() {
    var query = MediaQuery.of(context).size;
    return TabBar(
        controller: tabController,
        unselectedLabelStyle: GoogleFonts.poppins(
            color: const Color(0xFFCDA1F7),
            fontWeight: FontWeight.w500,
            fontSize: 16),
        labelStyle: GoogleFonts.poppins(
            color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        physics: const NeverScrollableScrollPhysics(),
        tabs: [
          Container(
            height: 45,
            width: query.width / 1.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: tabController.index == 0
                      ? AppColors.white
                      : const Color(0xFFCDA1F7),
                )),
            child: const Tab(
              text: "Home",
            ),
          ),
          Container(
            height: 45,
            width: query.width / 1.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: tabController.index == 1
                      ? AppColors.white
                      : const Color(0xFFCDA1F7),
                )),
            child: const Tab(
              text: "My Feed",
            ),
          ),
          Container(
            width: query.width / 1.5,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                    color: tabController.index == 2
                        ? AppColors.white
                        : const Color(0xFFCDA1F7))),
            child: const Tab(
              text: "Public",
            ),
          ),
        ]);
  }
}
