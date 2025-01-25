import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/sign_up/sign_up_screen.dart';
import 'package:msb_app/models/comment.dart';
import 'package:msb_app/repository/comment_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/firestore_collections.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key, required this.postId});
  final String postId;

  static Future<void> show(
    BuildContext context, {
    required String postId,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return CommentBottomSheet(
          postId: postId,
        );
      },
    );
  }

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  TextEditingController commentController = TextEditingController();

  List<CommentPost> commentList = [];
  late CommentRepository commentRepository;

  @override
  void initState() {
    super.initState();
    commentRepository = CommentRepository(
        commentCollection: FirebaseFirestore.instance
            .collection(FirestoreCollections.comments));
    loadComments();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void loadComments() async {
    final comments = await commentRepository.getCommentsByPost(widget.postId);

    if (comments.isNotEmpty) {
      setState(() {
        commentList = comments.cast<CommentPost>();
      });
    }
  }

  fetchComment() async {
    final comments = await commentRepository.getCommentsByPost(widget.postId);

    if (comments.isNotEmpty) {
      setState(() {
        commentList = comments.cast<CommentPost>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      const SizedBox(height: 5),
                      Text("Comments",
                          style: GoogleFonts.poppins(
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: commentList.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemBuilder: (context, index) {
                      final e = commentList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.nameOrEmail,
                            style: GoogleFonts.poppins(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            e.comment,
                            style: GoogleFonts.poppins(
                              color: AppColors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: commentController,
                  obscureText: false,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: "Add a comment",
                    labelText: "Add a comment",
                    prefixIcon: const Text(""),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          var fetchedUserId = await PrefsService.getUserId();
                          var fetchedUserNameEmail =
                              await PrefsService.getUserNameEmail();
                          var commentRecord = CommentPost(
                            nameOrEmail: fetchedUserNameEmail.toString(),
                            userId: fetchedUserId.toString(),
                            postId: widget.postId,
                            comment: commentController.text,
                            createdAt: DateTime.now()
                          );
                          commentRepository.saveOne(commentRecord);
                          setState(() {
                            commentController.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                          fetchComment();
                        },
                        icon: const Icon(Icons.send_rounded,
                            color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
