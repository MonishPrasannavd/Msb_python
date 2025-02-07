import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/completion_screen.dart';
import 'package:msb_app/Screens/home/tab_3_public.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/components/button_builder.dart';
import 'package:msb_app/models/dashboard.dart' as dashboard;
import 'package:msb_app/models/dashboard.dart';
import 'package:msb_app/providers/dash.dart';
import 'package:msb_app/providers/student_dashboard_provider.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  int _selectedMood = 2; // Default selected mood (Neutral)
  final PostFeedRepository postRepository = PostFeedRepository();
  int totalUsersCount = 0;
  int totalSchoolsCounts = 0;
  List<TopScoreStudents> topStudents = [];
  List<TopScoreStudents> top3Students = [];
  List<TopScoreStudents> remainingTopStudents = [];
  late Future<void> _fetchDataFuture;
  double progress = 0.0;
  bool isFirstTimeLoading = false;
  bool isLoading = false;
  late StudentDashboardProvider studentDashboardProvider;
  late Dash _dash;

  @override
  void initState() {
    super.initState();

    isFirstTimeLoading = true;

    // Initialize studentDashboardProvider here
    studentDashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
    _dash = Provider.of<Dash>(context, listen: false);

    _fetchDataFuture = fetchData();
  }

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentDashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
  }

  Future<void> getDashboard() async {
    setState(() {
      isLoading = true;
    });
    var response = await studentDashboardProvider.getStudentDashboard();
    final Future<Map<String, dynamic>> successfulMessage = studentDashboardProvider.getStudentDashboard();

    if (response['status'] == true) {
      dashboard.DashboardResponse dashboardData = response['data'];

      Provider.of<Dash>(context, listen: false).setDash(dashboardData);
      Provider.of<Dash>(context, listen: false).students(dashboardData.topScoreStudents ?? []);
      Provider.of<Dash>(context, listen: false).category(dashboardData.futureCategories ?? []);

      totalUsersCount = _dash.dashboardResponse.totalStudent ?? 0;
      totalSchoolsCounts = _dash.dashboardResponse.totalSchools ?? 0;
      topStudents = _dash.tsStudents!;

      setState(() {
        if (_dash.tsStudents!.isNotEmpty) {
          top3Students =
          topStudents.length >= 3 ? topStudents.sublist(0, 3) : topStudents.sublist(0, topStudents.length);
          remainingTopStudents = topStudents.length > 3 ? topStudents.sublist(3) : [];

          isLoading = false;
        } else {
          isLoading = false;
          setState(() {});
          top3Students = [];
          remainingTopStudents = [];
        }
      });
    }
  }

  Future<void> refetchData() async {
    setState(() {
      _fetchDataFuture = fetchData();
    });
  }

  Future<void> fetchData() async {
    await getDashboard();
    setState(() {
      progress = 1.0;
    });
  }

  // List of moods
  final List<String> moods = ['Terrible', 'Bad', 'Neutral', 'Good', 'Excellent'];

  String? updateMood = "";
  int _currentIndex = 0;

  // List of icon paths corresponding to each mood
  final List<String> moodIcons = [
    'assets/images/terrible.png', // Path to the Terrible mood icon
    'assets/images/sad.png', // Path to the Bad mood icon
    'assets/images/neutral.png', // Path to the Neutral mood icon
    'assets/images/happy.png', // Path to the Good mood icon
    'assets/images/excited.png' // Path to the Excellent mood icon
  ];

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
    const Color(0xFF15651D),
    const Color(0xFFFF9999),
    const Color(0xFF1C8727),
  ];

  final List<Map<String, String>> slides = [
    {
      "title": "GET READY FOR ACADEMIC YEAR",
      "description": "Great deals on school supplies",
      "image": "assets/dashboard/appslide1.png", // Update the image path
      "discount": "30% OFF",
    },
    {
      "title": "BACK TO SCHOOL SUPER SALE",
      "description": "Best choice for your lovely kids",
      "image": "assets/dashboard/9491946_842.jpg", // Update the image path
      "discount": "50% OFF",
    },
  ];

  // Custom dot indicator
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: slides.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => setState(() {
            _currentIndex = entry.key;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _currentIndex == entry.key ? 20.0 : 8.0,
            // Longer width for active indicator
            height: 8.0,
            // Fixed height for capsule shape
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), // Capsule shape
              color: _currentIndex == entry.key ? Colors.grey : Colors.grey.shade400,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  CarouselSlider.builder(
                    itemCount: slides.length,
                    itemBuilder: (context, index, realIndex) {
                      final slide = slides[index];
                      return _buildCarouselItem(slide);
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      height: 250,
                      // Adjust for better visibility
                      viewportFraction: 1.0,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  _buildIndicator(),
                  const SizedBox(height: 5),

                  // Mood text display
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'I\'m Feeling ',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: moods[_selectedMood], // Display the selected mood
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.msbMain500, // Highlight the mood in purple
                                ),
                          ),
                          TextSpan(
                            text: ' Today',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Row of mood icons (now using asset images)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      moods.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                _selectedMood = index; // Update selected mood on tap
                                updateMood = moods[index];
                                moodUpdate(updateMood!);
                                // ProgressDialogUtils.showProgressDialog(context);
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getMoodColor(index),
                              border: Border.all(
                                color: _getMoodColor(index),
                                width: 4,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              moodIcons[index],
                              height: 40, // Adjust the size as needed
                              width: 40, // Adjust the size as needed
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  FutureBuilder(
                    future: _fetchDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Curating your home screen",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildProgressIndictaor(),
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

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching data'));
                      }

                      return Column(
                        children: [
                          /// Total Schools and Students
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    width: query.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(totalSchoolsCounts.toString(),
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF540D96),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24)),
                                        Text("Total Schools",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    width: query.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        image: const DecorationImage(image: AssetImage("assets/images/back.png"))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(totalUsersCount.toString(),
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF540D96),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24)),
                                        Text("Total Students",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// top 10 leaderboard
                          // title
                          RichText(
                            text: TextSpan(
                              text: "Our ",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 22),
                              children: [
                                TextSpan(
                                  text: "Top 10  ",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF540D96), fontWeight: FontWeight.w600, fontSize: 22),
                                ),
                                TextSpan(
                                  text: "Leader Board",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 22),
                                ),
                              ],
                            ),
                          ),

                          // top 3 leaderboard listview
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: top3Students.length,
                              itemBuilder: (context, index) {
                                var student = top3Students[index];
                                bool isOdd = index % 2 != 0; // Corrected logic for odd-even
                                var backgroundColor = colors[index % colors.length];
                                var borderColor = colorsBorder[index % colorsBorder.length];

                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigation to UserProfileScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(id: student.id.toString()),
                                        ),
                                      ).then((val) => refetchData());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.only(
                                          // Correctly alternate shapes based on isOdd condition
                                          topRight: Radius.circular(isOdd ? 60.0 : 12.0),
                                          topLeft: Radius.circular(isOdd ? 12.0 : 60.0),
                                          bottomLeft: Radius.circular(isOdd ? 12.0 : 60.0),
                                          bottomRight: Radius.circular(isOdd ? 60.0 : 12.0),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (isOdd) ...[
                                            // Profile image appears on the right for odd indexes
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
                                                  child: FittedBox(
                                                    alignment: Alignment.centerLeft,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      "${index + 1}. ${student.user!.name ?? "Anonymous"}",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
                                                  child: FittedBox(
                                                    alignment: Alignment.centerLeft,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      student.city ?? "Unknown School",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white70,
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Score: ${student.points}",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: borderColor, width: 5),
                                              ),
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: student.user!.imageUrl != null
                                                    ? NetworkImage(student.user!.imageUrl!)
                                                    : const AssetImage('assets/images/profile1.png') as ImageProvider,
                                              ),
                                            ),
                                          ] else ...[
                                            // Profile image appears on the left for even indexes
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: borderColor, width: 5),
                                              ),
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: student.user!.imageUrl != null
                                                    ? NetworkImage(student.user!.imageUrl!)
                                                    : const AssetImage('assets/images/profile1.png') as ImageProvider,
                                              ),
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
                                                  child: FittedBox(
                                                    alignment: Alignment.centerLeft,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      "${index + 1}. ${student.user!.name ?? "Anonymous"}",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment: Alignment.centerRight,
                                                    child: Text(
                                                      student.schoolId.toString() ?? "Unknown School",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white70,
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Score: ${student.points}",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // remaining 7 leaderboard
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 10),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: remainingTopStudents.length,
                              itemBuilder: (context, index) {
                                var student = remainingTopStudents[index];
                                var currentIncrement = top3Students.length + index + 1;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(id: student.id.toString()),
                                        )).then((val) => refetchData());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(width: 2, color: const Color(0xFFCECACA))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                        child: Row(
                                          children: [
                                            Text("$currentIncrement. ${student.user!.name ?? "Anonymous"}",
                                                style: GoogleFonts.poppins(
                                                    color: const Color(0xFF151414),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16)),
                                            const Spacer(),
                                            Text(student.points?.toString() ?? "0",
                                                style: GoogleFonts.poppins(
                                                    color: const Color(0xFF6A6262),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14)),
                                            const SizedBox(width: 15),
                                            SvgPicture.asset(
                                              "assets/svg/right.svg",
                                              height: 20,
                                              color: const Color(0xFF6A6262),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  /// showcase talents
                  // title
                  RichText(
                    text: TextSpan(
                      text: "Showcase ",
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 22),
                      children: [
                        TextSpan(
                          text: "your talents in",
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF540D96), fontWeight: FontWeight.w600, fontSize: 22),
                        ),
                      ],
                    ),
                  ),

                  // carousel
                  SizedBox(
                    height: query.height / 8,
                    child: ChangeNotifierProvider.value(
                      value: studentDashboardProvider,
                      child: Consumer<StudentDashboardProvider>(builder: (context, value, child) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: (value.dashboardCategoryList?.length ?? 0),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          itemBuilder: (BuildContext context, int index) {
                            final FutureCategories? menuItem = value.dashboardCategoryList?[index];
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
                                    )).then((value) async {
                                      await refetchData();
                                });
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
                                          placeholder: (context, url) =>
                                              const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Text(menuItem?.name ?? "",
                                        style: GoogleFonts.poppins(
                                            color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 14)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ButtonBuilder(
                      text: 'View All Submissions',
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: PublicTab(),
                              ),
                            ));
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppColors.primary),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)))),
                      textStyle:
                          GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                  const SizedBox(height: 15),
                ],
              ),
      ),
    );
  }

// Build each carousel item
  Widget _buildCarouselItem(Map<String, String> slide) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(20),
        //   boxShadow: const [
        //     BoxShadow(
        //       color: Colors.black26,
        //       offset: Offset(0, 4),
        //       blurRadius: 6,
        //     ),
        //   ],
        // ),
        child: Image.asset(
          slide["image"]!,
          fit: BoxFit.fitWidth, // Ensures image fits inside without distortion
        ));
  }

  Widget getUserImage(String? profileImageUrl) {
    return CircleAvatar(
      radius: 40, // Radius of the circle
      backgroundColor: Colors.transparent, // Transparent background to focus on the image
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Subtle shadow
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: profileImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: profileImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Ensures the image fits well
                  height: double.infinity,
                  // Ensures the image fits well
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ), // Show progress indicator while image loads
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.person, // Fallback icon if image fails to load
                    size: 40,
                    color: Colors.grey,
                  ),
                )
              : Image.asset(
                  "assets/images/profile1.png", // Fallback image when URL is null
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget buildProgressIndictaor() {
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
                width: constraints.maxWidth * progress, // Adjust the width based on progress
                height: 12, // Height of the progress bar
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  gradient: const LinearGradient(
                    colors: [Colors.greenAccent, Colors.blueAccent], // Gradient from green to blue
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

  void moodUpdate(String updateMood) async {
    // var request = http.Request(
    //     'PUT', Uri.parse('http://74.208.221.20:8080/school_app/safety/user/116/update-emotion/$updateMood'));
    // request.body = '''''';
    //
    // http.StreamedResponse response = await request.send();

    // if (response.statusCode == 201) {
    //   debugPrint(await response.stream.bytesToString());
    //   ProgressDialogUtils.hideProgressDialog();
    //   Helpers.showSnackBar(context, "Mood update");
    // } else {
    //   debugPrint(response.reasonPhrase);
    // }
  }

  Color _getMoodColor(int index) {
    return _selectedMood == index ? AppColors.msbMain500 : AppColors.transparent;
  }
}
