import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msb_app/Screens/competition/post%20story/post_feed_screen.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/utils/post.dart';

import '../../models/competition_data.dart';
import '../../models/competition_type.dart';
import '../../models/post_feed.dart';
import '../../repository/posts_repository.dart';
import '../../utils/colours.dart';
import '../../utils/firestore_collections.dart';
import 'completion_details_list_screen.dart';

class CompletionScreen extends StatefulWidget {
  String categoryName;
  String? contentType;

   CompletionScreen({required this.categoryName, required this.contentType, super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  // List<String> completionList = ["Hip Hop Dance", "Bharatanatyam Dance", "Rumba Dance" , "Kathakali Dance", "Ballet Dance"];
  final CollectionReference completionsCollection = FirebaseFirestore.instance.collection(FirestoreCollections.competitions);

  late PostFeedRepository postFeedRepository;
  late Future<List<PostFeed>> _postsFuture;
  late Future<List<CompetitionType>> _completionFuture;

  @override
  void initState() {
    super.initState();
    postFeedRepository = PostFeedRepository();

    ///this below code is to create Competition in database with Category.
    // createCompetition();

    fetchData();
  }

  Future<Competition?> createCompetitionByCategory(Competition entry) async {
    try {
        String documentId = completionsCollection.doc().id;
        entry = entry.copyWith(id: documentId);
      await completionsCollection.doc(entry.id).set(entry.toJson());
      return entry;
    } catch (e) {
      print("Error saving post: $e");
    }
    return null;
  }

  // Get all posts for a specific school
  Future<List<CompetitionType>> getCompetitionByCategory(String categoryName) async {
    try {
      Query query = completionsCollection.where('categoryName', isEqualTo: categoryName);

      QuerySnapshot snapshot = await query.get();

      List<Competition> value = snapshot.docs.map((doc) => Competition.fromJson(doc.data() as Map<String, dynamic>)).toList();
      DateTime today = DateTime.now();
      // value.first.competitionNames.removeWhere((item) => DateTime.parse(item.competitionLastDate).isBefore(today));

      return value.first.competitionNames;
    } catch (e) {
      print("Error getting posts by schoolId: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
                child: SvgPicture.asset("assets/svg/back.svg")),
            Text(
              widget.categoryName,
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
        child: Column(
          children: [
            Text(
              "Competitions List",
              style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            FutureBuilder<List<CompetitionType>?>(
                future: _completionFuture,
                builder: (context, completionSnapshot) {
                  if (completionSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center (child: CircularProgressIndicator());
                  } else if (completionSnapshot.hasError || completionSnapshot.data == null) {
                    return Center(child: Text('Error loading user data', style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 12),));
                  }
                return FutureBuilder<List<PostFeed>?>(
                    future: _postsFuture,
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (userSnapshot.hasError || userSnapshot.data == null) {
                        return Center(child: Text('Error loading user data', style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 12),));
                      }

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        shrinkWrap: true,
                        //physics: const NeverScrollableScrollPhysics(),
                        itemCount: completionSnapshot.data?.length??0,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // next(index);
                              PostUiUtils.videoControllers = {};

                              Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
                                  builder: (_) => CompletionDetailsListScreen(categoryName: widget.categoryName,
                                      postCompilation: index.toString(),
                                      contentType: widget.contentType, postsFuture: getPostListForCompletionIndex(userSnapshot.data, index: index),)),
                              ).then((value){
                                fetchData();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3), // Shadow color
                                      blurRadius: 6.0, // Softness of the shadow
                                      offset: const Offset(0, 3), // Vertical offset
                                    ),
                                  ],// Card background color
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        completionSnapshot.data![index].competitionNames,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Total Submissions: ${getTotalSubmissionForCompletionIndex(userSnapshot.data, index: index)}",
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black54,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "Grade 10", // Hardcoded Grade 10
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black54,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF003366), // Blue background for submission date row
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8.0),
                                          bottomRight: Radius.circular(8.0),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Submission Date: ${DateFormat('d MMM, y, hh:mm a').format(DateTime.parse(completionSnapshot.data![index].competitionLastDate))}",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SvgPicture.asset(
                                            "assets/svg/right.svg",
                                            height: 20,
                                            color: Colors.white, // Icon color matches the row background
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
                    );
                  }
                );
              }
            ),
          ],
        )
      ),
    );
  }

  void next(int index) {
    Widget value = PostFeeds(widget.categoryName, contentType: widget.contentType, postCompilation: index.toString());
    if(widget.contentType == null){
      value = const QuizScreen();
    }
    Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
      builder: (_) => value),
    ).then((value){
      fetchData();
    });
  }

  String getLastDateForCompletionIndex(List<PostFeed>? data, {required int index}) {
    if(data!=null){
      List<PostFeed> temp = data.where((value) => value.postCompilation == index.toString()).toList();
      return temp.isNotEmpty ? DateFormat('d MMM y, hh:mm a').format(temp.first.createdAt) : "";
    }
    return "";
  }

  List<PostFeed> getPostListForCompletionIndex(List<PostFeed>? data, {required int index}) {
    if(data!=null){
      return data.where((value) => value.postCompilation == index.toString()).toList();
    }
    return [];
  }

  getTotalSubmissionForCompletionIndex(List<PostFeed>? data, {required int index}) {
    if(data!=null){
      return data.where((value) => value.postCompilation == index.toString()).toList().length.toString();
    }
    return "";
  }

  void fetchData() {
    _postsFuture = postFeedRepository.getPostsByCategoryId(postCategory: widget.categoryName);
    _completionFuture = getCompetitionByCategory(widget.categoryName);

  }

  void createCompetition() {
    List<Competition> value = [];

    value.add(Competition(categoryName: "Dance", id: '', competitionNames: [CompetitionType(competitionNames: "Hip Hop Dance", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Bharatanatyam Dance", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Rumba Dance", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Kathakali Dance", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Ballet Dance", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )]));

    value.add(Competition(categoryName: "Music", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Photography", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Art & Crafts", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Quiz", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Painting", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Story Telling", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Writing", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Poetry", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Comedy", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Action / Drama", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Speaking", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Coding", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Science", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));
    value.add(Competition(categoryName: "Debate", competitionNames: [CompetitionType(competitionNames: "Dummy 1", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 2", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", ),
      CompetitionType(competitionNames: "Dummy 3", competitionLastDate: DateTime.now().add(Duration(hours: 5)).toString(), id: "", )], id: ''));

    for(Competition va in value){
      createCompetitionByCategory(va);
    }
  }
}
