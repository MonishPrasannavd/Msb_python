import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/auth.dart';
import 'package:msb_app/utils/firestore_collections.dart';

import '../../../components/button_builder.dart';
import '../../../utils/colours.dart';

class PostFeeds extends StatefulWidget {
  final int categoryId, subcategoryId;
  final String type;
  final String? contentType, postCompilation;

  const PostFeeds(this.type,
      {required this.categoryId, required this.subcategoryId, super.key, this.postCompilation, this.contentType});

  @override
  State<PostFeeds> createState() => _PostFeedsState();
}

class _PostFeedsState extends State<PostFeeds> {
  TextEditingController storyTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  PostFeedRepository postFeedRepository = PostFeedRepository();
  UserRepository userRepository =
      UserRepository(usersCollection: FirebaseFirestore.instance.collection(FirestoreCollections.users));
  final _formKey = GlobalKey<FormState>();
  late String userId;
  bool _validate = false;
  XFile? _videoFile;
  bool _isUploading = false;
  bool _clicked = false;
  MsbUser? currentUser;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() async {
      currentUser = await userRepository.getOne(userId);
    });
  }

  void pickMedia() async {
    FilePickerResult? result;
    XFile? pickedFile;
    if (widget.contentType == "video") {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.video,
      );
    } else if (widget.contentType == "audio") {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.audio,
      );
    } else if (widget.contentType == "image") {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
    }
    pickedFile = XFile(result!.files.first.path!,
        name: result.files.first.name, bytes: result.files.first.bytes, length: result.files.first.size);
    setState(() {
      _videoFile = pickedFile;
    });
  }

  void showAlertForVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Email Not Verified"),
        content: const Text(
          "Your email address is not verified. Please verify your email to post content.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await user.sendEmailVerification();
                Fluttertoast.showToast(
                  msg: "Verification email sent!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              }
            },
            child: const Text("Resend Verification Email"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> uploadPostFeed() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Fluttertoast.showToast(
        msg: "User not signed in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      AuthUtils.handleLogout(context);
      return;
    }

    // Reload the user to get the latest email verification status
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && !refreshedUser.emailVerified) {
      showAlertForVerification();
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> mediaUrls = [];
      if (_videoFile != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child("$userId/media/${DateTime.now().millisecondsSinceEpoch}");
        File file = File(_videoFile!.path);

        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() async {
          String fileUrl = await ref.getDownloadURL();
          mediaUrls.add(fileUrl);
        });
      }

      final postFeed = PostFeed(
          userId: user.uid,
          title: storyTitleController.text,
          description: descriptionController.text,
          postCompilation: widget.postCompilation,
          mediaUrls: mediaUrls.isNotEmpty ? mediaUrls : null,
          postType: widget.contentType,
          schoolId: currentUser?.schoolId ?? '',
          // Add appropriate schoolId
          schoolName: currentUser?.schoolName ?? '',
          // Add appropriate schoolName
          grade: currentUser?.grade,
          createdAt: DateTime.now(),
          nameOrEmail: currentUser?.name ?? currentUser?.email ?? '',
          postCategory: widget.type);

      await postFeedRepository.saveOne(postFeed);

      Fluttertoast.showToast(
        msg: "Post uploaded successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error uploading post: $e");
      Fluttertoast.showToast(
        msg: "Failed to upload post.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
        _clicked = false;
      });
    }
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
            GestureDetector(onTap: () => Navigator.pop(context), child: SvgPicture.asset("assets/svg/back.svg")),
            Text(
              widget.type,
              style: GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(width: 24), // Spacer for symmetry
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: Column(
              children: [
                const SizedBox(height: 15),
                TextFormField(
                  controller: storyTitleController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    labelText: "Title",
                    prefixIcon: Icon(Icons.title, color: AppColors.fontHint),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "ⓘ Please enter title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                if (widget.contentType == "video" || widget.contentType == "audio" || widget.contentType == "image")
                  GestureDetector(
                    onTap: pickMedia,
                    child: Container(
                      height: 200,
                      width: query.width,
                      decoration: BoxDecoration(
                        color: AppColors.fontHint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : Text(
                                _videoFile != null
                                    ? "Selected ${widget.contentType}: ${_videoFile!.name}"
                                    : "Upload ${widget.contentType}",
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Description",
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description, color: AppColors.fontHint),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "ⓘ Please enter story description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: query.width,
                  height: 50,
                  child: ButtonBuilder(
                    text: 'Submit Entry',
                    onPressed: _clicked
                        ? null
                        : () {
                            _clicked = true;
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _validate = true;
                            });
                            if (_formKey.currentState!.validate() && _videoFile != null) {
                              uploadPostFeed();
                            }
                          },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(_videoFile != null ? AppColors.primary : AppColors.black12),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    textStyle: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
