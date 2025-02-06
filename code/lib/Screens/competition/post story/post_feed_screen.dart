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
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/auth.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:provider/provider.dart';

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
  final _formKey = GlobalKey<FormState>();
  late int? userId;
  bool _validate = false;
  XFile? _videoFile;
  bool _isUploading = false;
  bool _clicked = false;
  MsbUser? currentUser;

  late SubmissionApiProvider _submissionApiProvider;
  late SubmissionProvider _submissionProvider;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();

    _submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);
    _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    loadUserId();
  }

  Future<void> loadUserId() async {
    userId = _userProvider.user.user?.id;
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
    if (userId == null) {
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

      await _submissionApiProvider.createSubmission(
        widget.categoryId,
        widget.subcategoryId,
        storyTitleController.text,
        descriptionController.text,
        mediaFile: _videoFile,
      );

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
                            if (_formKey.currentState!.validate()) {
                              uploadPostFeed();
                            }
                          },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primary),
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
