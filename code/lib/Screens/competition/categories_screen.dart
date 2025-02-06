import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/models/msbuser.dart';
import 'package:msb_app/providers/competitions_provider.dart';
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
  late MsbUser user;
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

    await compDataProvider.getCompetitionsData();
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
                final FutureCategories? menuItem =competitions.compititions.elementAt(index);

                return GestureDetector(
                  onTap: () {
                    if (menuItem?.name  == '') {
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
                            categoryId: menuItem?.id ?? 1,
                            categoryName: menuItem?.name ?? '',
                            contentType: menuItem?.categoryType?.name,
                            subcategories: menuItem?.subcategories,
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
                              backgroundImage: menuItem?.iconUrl != null
                                  ? NetworkImage(menuItem!.iconUrl!)
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
                        child: Text(menuItem?.name ?? '',
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
