import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/constants/navigation.dart';

import '../../../../components/button_builder.dart';
import '../../../../utils/colours.dart';
import 'questions_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final List quizIds;

  final String title;

  const QuizDetailScreen(this.quizIds, this.title, {super.key});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  @override
  Widget build(BuildContext context) {
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
              widget.title,
              style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            const Icon(Icons.info_outline)
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Select Test",
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
                  const SizedBox(height: 10),
                  ...widget.quizIds.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return InstructionsDialog(
                                    widget.title, e.toString());
                              },
                            );
                            //callNextScreen1(context, QuestionsScreen(widget.title, e.toString()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 12),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: const Color(0xFFCECACA)),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Row(
                              children: [
                                Text(e.toString(),
                                    style: GoogleFonts.poppins(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                                const Spacer(),
                                Text("25 Mins",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF6A6262),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12)),
                                const SizedBox(width: 10),
                                SvgPicture.asset(
                                  color: const Color(0xFF6A6262),
                                  "assets/svg/right.svg",
                                  height: 14,
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionsDialog extends StatefulWidget {
  final String? title;
  final String? quizId;

  const InstructionsDialog(this.title, this.quizId, {super.key});

  @override
  State<InstructionsDialog> createState() => _InstructionsDialogState();
}

class _InstructionsDialogState extends State<InstructionsDialog> {
  bool read = false;

  @override
  Widget build(BuildContext context) {
    return read
        ? Dialog(
            surfaceTintColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Instructions',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF403B3B),
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey[400]),
                  SizedBox(height: 8),
                  // List of instructions
                  buildInstructionsList(),
                  SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: 50,
                        child: ButtonBuilder(
                            text: 'Play Now',
                            onPressed: () {
                              Navigator.pop(context);
                              callNextScreen1(
                                  context,
                                  QuestionsScreen(
                                      widget.title!, widget.quizId!));
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
                  ),
                ],
              ),
            ),
          )
        : Dialog(
            surfaceTintColor: AppColors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),
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
                    "Ready Instructions Before You Play",
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
                              text: 'Read',
                              onPressed: () {
                                setState(() {
                                  read = true;
                                });
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
                                  fontSize: 14))),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          callNextScreen1(context,
                              QuestionsScreen(widget.title!, widget.quizId!));
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
                            "Continue Playing",
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

  Widget buildInstructionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'This is a multiple choice quiz. There is only one right answer for every question. Think and answer. You get points for doing well.'),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("2. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'Attempt all the questions and click Submit.'),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("3. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'There is a time limit for every quiz. If you fail to submit the quiz within the given time, the quiz will be submitted automatically.'),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("4. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'You can participate in a test any number of times to practice, but your first attempt points are valid.'),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("5. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'For each correct answer, you will get 2 points.'),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("6. ",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6262),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)),
            Expanded(
              child: buildInstructionItem(
                  'If all answers are correct, you will get 5 bonus points.'),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildInstructionItem(String instruction) {
    return Text(instruction,
        style: GoogleFonts.poppins(
            color: const Color(0xFF6A6262),
            fontWeight: FontWeight.w400,
            fontSize: 14));
  }
}

/*
class InstructionDialog extends StatefulWidget {
  const InstructionDialog({super.key});

  @override
  State<InstructionDialog> createState() => _InstructionDialogState();
}

class _InstructionDialogState extends State<InstructionDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ⓘ instructions",
                style: GoogleFonts.poppins(
                color: const Color(0xFF403B3B),
                fontWeight: FontWeight.w500,
                fontSize: 16)),
            Divider(height: 5)
          ],
        ),
      ),
    );
  }
}
*/
