import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_detail/quiz_detail.dart';
import 'package:msb_app/constants/navigation.dart';
import 'package:msb_app/models/category_type.dart';
import 'package:msb_app/services/preferences_service.dart';

import '../../../models/category.dart';
import '../../../repository/category_repository.dart';
import '../../../utils/colours.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late CategoryRepository categoryRepository;

  @override
  void initState() {
    super.initState();
    categoryRepository = CategoryRepository();
    fetchCategories();
  }

  List<Category> categoryList = [];

  fetchCategories() async {
    final categoryItem = await categoryRepository.getAll();

    if (categoryItem.isNotEmpty) {
      setState(() {
        categoryList = categoryItem;
      });
    }
    debugPrint(categoryList.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset("assets/svg/back.svg")),
              Text(
                "Quiz",
                style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              SvgPicture.asset("assets/svg/dash_1.svg"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Choose Category",
                              style: GoogleFonts.poppins(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const Spacer(),
                          SvgPicture.asset(
                            "assets/svg/submission.svg",
                            color: const Color(0xFF938A8A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            final item = categoryList[index];
                            return CategoryTile(
                                categoryTitle: item.name,
                                imageName: "assets/images/gk.png",
                                subcategories:
                                    item.types.map((e) => e).toList(),
                                title: item.name);
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class CategoryTile extends StatefulWidget {
  final String categoryTitle;
  final String imageName;
  final String title;
  final List<CategoryType> subcategories;

  const CategoryTile({
    super.key,
    required this.categoryTitle,
    required this.imageName,
    required this.subcategories,
    required this.title,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding:
            EdgeInsets.only(bottom: _isExpanded ? 10 : 0, left: 0, right: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: AssetImage(
              _isExpanded
                  ? "assets/images/back.png"
                  : "assets/images/back2.png",
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: ExpansionTile(
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          initiallyExpanded: false,
          backgroundColor: Colors.transparent,
          childrenPadding: const EdgeInsets.symmetric(vertical: 0),
          tilePadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Define a custom shape
            side: BorderSide(
                color: Colors.grey.shade400, width: 1.0), // Add a border
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(
                color: Colors
                    .transparent), // Remove top and bottom lines when expanded
          ),
          visualDensity: VisualDensity.compact,
          leading: Image.asset(widget.imageName, height: 40),
          title: Text(
            widget.categoryTitle,
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          children: widget.subcategories
              .map((subcategory) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFE2DFDF), width: 1),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(subcategory.name,
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF151414),
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(subcategory.id.toString(),
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF151414),
                                fontSize: 10,
                                fontWeight: FontWeight.w300)),
                        trailing: SvgPicture.asset("assets/svg/right.svg"),
                        onTap: () {
                          PrefsService.setString(
                              'selectedQuizGrade', subcategory.name);
                          callNextScreen(
                              context,
                              QuizDetailScreen(
                                  subcategory.quizIds, widget.title));
                        },
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
