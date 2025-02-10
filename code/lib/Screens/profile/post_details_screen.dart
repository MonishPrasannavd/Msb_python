import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/enums/post_feed_type.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/repository/comment_repository.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/post.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:msb_app/utils/post_video_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../repository/posts_repository.dart';

@immutable
class PostDetailScreen extends StatefulWidget {
  Submission? post;
  MsbUser? currentUser;
  MsbUser? writerUser;
  int? postIndex;
  final int? postId;
  final String? title, description;
  PostDetailScreen({
    this.currentUser,
    this.writerUser,
    this.postIndex,
    this.post,
    this.postId,
    this.title,
    this.description,
    super.key,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostFeedRepository postFeedRepository;
  late SubmissionApiProvider submissionApiProvider;
  var userName = '';
  final CommentRepository commentRepository = CommentRepository(
      commentCollection:
          FirebaseFirestore.instance.collection(FirestoreCollections.comments));
  bool isLoadingPosts = true; // Loading indicator for posts

  @override
  void initState() {
    super.initState();
    submissionApiProvider = SubmissionApiProvider();
    postFeedRepository = PostFeedRepository();
    // _fetchPosts(
    //   () => postFeedRepository.getPostsByUserId(
    //       widget.post!.user!.id!.toString(),
    //       includeHidden: false),
    // );
    if (widget.postId != null) {
      fetchPostData();
    }
    // userName = widget.currentUser!.name!;
  }

  // Future<void> _fetchPosts(
  //     Future<List<PostFeed>> Function() fetchFunction) async {
  //   try {
  //     final fetchedPosts = await fetchFunction();
  //     for (var post in fetchedPosts) {
  //       var comments = await commentRepository.getCommentsByPost(post.id!);
  //       fetchedPosts[fetchedPosts.indexOf(post)] =
  //           post.copyWith(comments: comments);
  //     }
  //     setState(() {
  //       posts = fetchedPosts;
  //       isLoadingPosts = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoadingPosts = false;
  //     });
  //     debugPrint('Error fetching posts: $e');
  //   }
  // }

  // Build the post content (video, image, text, or audio)
  Widget _buildPostContent() {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(
      //     16), // Increased corner radius for more rounded edges

      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.black38, width: 1)),
        child: SizedBox(
          width: double.infinity,
          height: 400, // Increased height for larger content
          child: _buildContentByType(
            context,
            0,
            widget.post!,
          ),
        ),
      ),
    );
  }

  Widget _buildContentByType(BuildContext context, int index, Submission post) {
    final postType = PostUiUtilsV2.getPostFeedType(post);
    switch (postType) {
      case PostFeedType.image:
        return _buildImagePost(context, post);
      case PostFeedType.video:
      case PostFeedType.audio:
        {
          {
            if (post.mediaUrl == null) {
              return Center(
                child: Text(
                  '',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF151414),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return PostVideoViewer(post: post);
          }
        }
      case PostFeedType.text:
        return _buildTextPost(post);
      default:
        return _buildTextPost(post);
    }
  }

  Future<void> onLike() async {
    final likes = widget.post!.likesCount ?? 0;
    final userHasLiked = widget.post!.isLiked ?? false;
    setState(() {
      widget.post = widget.post!.copyWith(
        isLiked: !userHasLiked,
        likesCount: likes + (userHasLiked ? -1 : 1),
      );
    });
    submissionApiProvider.toggleLike(widget.post!.id!);
  }

// Helper method to build image post using CachedNetworkImage
  static Widget _buildImagePost(BuildContext context, Submission post) {
    return GestureDetector(
      onLongPress: () {
        // Open image preview on long press
        _openImagePreview(context, post.mediaUrl!);
      },
      child: CachedNetworkImage(
        imageUrl: post.mediaUrl ?? "",
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
        imageBuilder: (context, imageProvider) {
          return AspectRatio(
            aspectRatio: 16 / 9, // Maintain a consistent aspect ratio
            child: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10), // Optional: Add rounded corners
                image: DecorationImage(
                  image: imageProvider,
                  fit:
                      BoxFit.cover, // Ensures the image fits without distortion
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// Method to open the image in a preview dialog
  static void _openImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context, // Use the correct BuildContext here
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close preview on tap
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                fit: BoxFit.contain, // Ensure image is fully visible
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build text post
  static Widget _buildTextPost(Submission post) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: SingleChildScrollView(
        child: Text(
          post.description ?? 'No description available',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  fetchPostData() async {
    final data = await submissionApiProvider
        .getSubmissionById(widget.postId ?? widget.post!.id!);
    final submission = data['submission'] as Submission?;
    setState(() {
      widget.post = submission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: _buildPostHeader(),
        elevation: 0,
      ),
      body: widget.post == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
              child: PostUiUtilsV2.buildPostTile(
                context,
                0,
                widget.post!,
                (postId) async {
                  await CommentBottomSheet.show(context, postId: postId);
                },
                onLike,
                enableOnTapNavigation: false,
              ),
            ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/images/profile.png",
          height: 40,
        ),
        const SizedBox(width: 8),
        Text(
          widget.post != null ? widget.post!.user!.name ?? 'Unknown' : "",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPostHeaderTitle() {
    final postType = widget.post != null
        ? PostUiUtilsV2.getPostFeedType(widget.post!)
        : null;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black12, Colors.black12, Colors.blueGrey],
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(0.0),
        child: Row(
          children: [
            if (postType != null) ...[
              PostUiUtils.getIconForPostFeedType(postType),
              const SizedBox(
                width: 5,
              )
            ],
            const SizedBox(height: 5),
            Column(
              children: [
                Text(
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  widget.post?.title ?? 'Unkown Category',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.background),
                ),
                Text(
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  (widget.post?.schoolId ?? "Anonymous").toString(),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.background),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
