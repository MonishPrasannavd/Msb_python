import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_detail/result_screen.dart';
import 'package:msb_app/constants/navigation.dart';
import 'package:msb_app/enums/point_type.dart';
import 'package:msb_app/models/answer.dart';
import 'package:msb_app/models/quiz_record.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/points_system.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../components/button_builder.dart';
import '../../../../models/question.dart';
import '../../../../repository/answer_repository.dart';
import '../../../../repository/question_repository.dart';
import '../../../../repository/quiz_record_repository.dart';
import '../../../../utils/colours.dart';
import '../../../../utils/firestore_collections.dart';

class QuestionsScreen extends StatefulWidget {
  final String title;

  final String quizId;

  const QuestionsScreen(this.title, this.quizId, {super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  String? _selectedOption;

  CollectionReference questionsCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.questions);

  CollectionReference answersCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.answers);

  late AnswerRepository answerRepository;
  late QuestionRepository questionRepository;
  late QuizRecordRepository quizRecordRepository;
  late UserRepository userRepository;

  late PageController pageController; // Define the PageController
  int _currentPage = 0;
  int resultScore = 0;
  int wrongAns = 0;
  final Map<String, String> questionAnswerMap = {};

  @override
  void initState() {
    super.initState();
    answerRepository = AnswerRepository(answersCollection: answersCollection);

    questionRepository = QuestionRepository(
        questionsCollection: questionsCollection,
        answerRepository: answerRepository);
    answerRepository = AnswerRepository(answersCollection: answersCollection);
    quizRecordRepository = QuizRecordRepository();
    userRepository = UserRepository(
        usersCollection:
            FirebaseFirestore.instance.collection(FirestoreCollections.users));

    fetchQuestions();
    fetchAnswers();
    pageController = PageController(initialPage: _currentPage);
  }

  List<Question> questionList = [];
  List<Answer> ansList = [];

  fetchQuestions() async {
    final questions = await questionRepository.getAll();

    debugPrint(questions.toString());
    if (questions.isNotEmpty) {
      setState(() {
        questionList = questions.cast<Question>();
      });
    }
    debugPrint(questionList.length.toString());
  }

  Future<void> fetchAnswers() async {
    final answers = await answerRepository.getAll();

    if (answers.isNotEmpty) {
      setState(() {
        ansList = answers.cast<Answer>();
      });
    }
    /* for(int i = 0; i< questionList.length; i++){
      List<Answer> filteredAnswers = ansList.where((Answer answer) =>
        questionList[i].answerIds.contains(answer.id)
      ).toList();
      debugPrint("@@@@@@@@@@@@@ $filteredAnswers");
    }*/
    debugPrint(ansList.toString());
  }

  @override
  void dispose() {
    pageController.dispose(); // Dispose the controller when not needed
    super.dispose();
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ExitConfirmationDialog();
                    },
                  );
                },
                child: const Icon(Icons.close)),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            const Icon(Icons.info_outline, color: Colors.transparent)
          ],
        ),
      ),
      body: questionList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "${_currentPage + 1}/${questionList.length}",
                              style: GoogleFonts.poppins(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                            Slider(
                              value: _currentPage / questionList.length,
                              onChanged: (double value) {},
                              inactiveColor: const Color(0xFFCDA1F7),
                            ),
                            Text(
                              "00:10 / 00:30",
                              style: GoogleFonts.poppins(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: query.height * 0.6,
                          child: PageView.builder(
                              itemCount: questionList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              controller: pageController,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage =
                                      page; // Update the current page index
                                });
                              },
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: query.height * 0.22,
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      child: Stack(
                                        children: [
                                          Image.asset("assets/images/back.png",
                                              width: query.width,
                                              fit: BoxFit.fill),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Center(
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                questionList[index]
                                                    .questionText
                                                    .toString(),
                                                style: GoogleFonts.poppins(
                                                    color: AppColors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text("Select Correct Answer",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF7F7676),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                    const SizedBox(height: 8),
                                    ...ansList
                                        .where((Answer answer) =>
                                            questionList[index]
                                                .answerIds
                                                .contains(answer.id))
                                        .map((ans) => Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 3),
                                                child: ListTile(
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFE2DFDF)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  title: Text(ans.answerText,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: AppColors
                                                                  .black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                  trailing: Radio<String>(
                                                    value: ans.id,
                                                    groupValue: _selectedOption,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        _selectedOption =
                                                            value!;
                                                        if (ans.isCorrect) {
                                                          resultScore =
                                                              resultScore + 1;
                                                        } else {
                                                          wrongAns =
                                                              wrongAns + 1;
                                                        }
                                                        moveToNextPage(
                                                            questionList[index]
                                                                .id,
                                                            _selectedOption);
                                                        debugPrint(value);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )),
                                  ],
                                );
                              }),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_currentPage != questionList.length - 1)
                    SizedBox(
                        width: query.width / 1.1,
                        height: 60,
                        child: ButtonBuilder(
                            text: 'Next',
                            onPressed: () {
                              moveToNextPage();
                            },
                            style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                    const BorderSide(
                                        color: AppColors.primary, width: 1)),
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primary),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)))),
                            textStyle: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16))),
                  const SizedBox(height: 5),
                  if (_currentPage == questionList.length - 1)
                    SizedBox(
                        width: query.width / 1.1,
                        height: 60,
                        child: ButtonBuilder(
                            text: 'Result',
                            onPressed: () {
                              callNextScreen(
                                  context, ResultScreen(resultScore, wrongAns));
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primary),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)))),
                            textStyle: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16))),
                ],
              ),
            ),
    );
  }

  Future<void> moveToNextPage([questionId, answerId]) async {
    // String? userId;
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // userId = prefs.getString("userId").toString();

    questionAnswerMap[questionId] = answerId;
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    debugPrint(questionAnswerMap.toString());
    if (_currentPage + 1 == questionList.length) {
      var userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        var user = await userRepository.getOne(userId);

        var quizRecord = QuizRecord(
            userId: userId,
            quizId: widget.quizId,
            questionAnswerMap: questionAnswerMap,
            score: resultScore);
        quizRecordRepository.saveOne(quizRecord);

        if (user != null && user.grade != null) {
          var selectedQuizGrade =
              await PrefsService.getString("selectedQuizGrade");
          PointsSystem.updateUserPoints(
            userId: userId,
            quizGrade: selectedQuizGrade,
            pointType: PointType.quiz,
            correctAnswers: resultScore,
            userGrade: user.grade,
          );
        }
      }
    }
  }
}

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Image.asset("assets/images/warning.png", height: 50),
            const SizedBox(height: 16),
            Text(
              "Are You Sure You Want To Exit?",
              style: GoogleFonts.poppins(
                  color: const Color(0xFF403B3B),
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: 50,
                    child: ButtonBuilder(
                        text: 'Continue Playing',
                        onPressed: () => Navigator.pop(context),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.primary),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)))),
                        textStyle: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14))),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.grey),
                      backgroundColor: const Color(0xFFF5F4F4)),
                  child: Center(
                    child: Text(
                      "Quit",
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF6A6262),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
