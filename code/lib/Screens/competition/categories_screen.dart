import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/models/currentstudent.dart' as cs;
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/competitions_provider.dart';
import 'package:msb_app/providers/user_data_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/navigation.dart';
import '../../enums/post_feed_type.dart';
import '../../utils/colours.dart';
import 'completion_screen.dart';
import 'post story/post_feed_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CompetitionsProvider compDataProvider;
  late cs.CurrentStudent user;
//late List<CompetitionCategories> competions = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      compDataProvider =
          Provider.of<CompetitionsProvider>(context, listen: false);
      getCompetitions();
    });
  }

  void getCompetitions() async {
    var compDataProvider =
        Provider.of<CompetitionsProvider>(context, listen: false);
    compDataProvider.getCompetitionsData().then((result) {
      if (result['status']) {
        print("Master data fetched successfully.");
        //   dynamic comp = result['competitions']
        //  Competition copm1 =  Competition.fromJson(comp);
        compDataProvider.setCompetitions = result['competitions'];
        setState(() {});
      }

      // print(masterProvider.grades);
    }).catchError((error) {
      print("Error fetching master data: $error");
    });
  }

  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Dance",
      "icon": 'assets/images/trending.png',
      "route": PostFeedType.video.value
    },
    {
      "title": "Music",
      "icon": 'assets/images/music.png',
      "route": PostFeedType.audio.value
    },
    {
      "title": "Photography",
      "icon": 'assets/images/photography.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Art & Crafts",
      "icon": 'assets/images/art.png',
      "route": PostFeedType.image.value
    },
    {"title": "Quiz", "icon": 'assets/images/quiz.png', "route": null},
    {
      "title": "Painting",
      "icon": 'assets/images/painting.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Story Telling",
      "icon": 'assets/images/story.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Writing",
      "icon": 'assets/images/writing.png',
      "route": PostFeedType.text.value
    },
    {
      "title": "Poetry",
      "icon": 'assets/images/poetry.png',
      "route": PostFeedType.text.value
    },
    {
      "title": "Comedy",
      "icon": 'assets/images/comedy.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Action / Drama",
      "icon": 'assets/images/action.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Speaking",
      "icon": 'assets/images/speaking.png',
      "route": PostFeedType.audio.value
    },
    {
      "title": "Coding",
      "icon": 'assets/images/coding.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Science",
      "icon": 'assets/images/science1.png',
      "route": PostFeedType.image.value
    },
    {
      "title": "Debate",
      "icon": 'assets/images/debate.png',
      "route": PostFeedType.image.value
    },
  ];

  @override
  Widget build(BuildContext context) {
    var competitions =
        Provider.of<CompetitionsProvider>(context, listen: false);
    var query = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /*GestureDetector(
              onTap: () => Navigator.pop(context),
                child: SvgPicture.asset("assets/svg/back.svg")),*/
            const SizedBox.shrink(),
            Text(
              "Talent",
              style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            SvgPicture.asset("assets/svg/dash_1.svg"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Card(
          color: AppColors.white,
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: GridView.builder(
              itemCount: competitions.compititions.length,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 8.0,
                  crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                final menuItem = competitions.compititions[index].data;

                return GestureDetector(
                  onTap: () {
                    if (menuItem.name == '') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuizScreen()));
                    } else {
                      // callNextScreen(context, CompletionScreen(categoryName: menuItem["title"],));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompletionScreen(
                            categoryName: (menuItem.name),
                            contentType: menuItem.categoryType.name,
                            subcategoryList: menuItem.subcategories,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(colors: [
                                Color(0xFFE1C7FA),
                                AppColors.white30
                              ], center: Alignment.bottomCenter, radius: 1.0),
                              border: Border.all(
                                  color: const Color(0xFFE1C7FA), width: 5)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              backgroundImage: menuItem.iconUrl != null
                                  ? NetworkImage(menuItem.iconUrl)
                                  : const AssetImage(
                                          'assets/images/profile1.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(menuItem.name,
                            style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
