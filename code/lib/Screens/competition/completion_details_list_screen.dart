import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/post%20story/post_feed_screen.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/providers/post_feed_provider.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

import '../../models/post_feed.dart';
import '../../models/school_user.dart';
import '../../models/user.dart';
import '../../repository/comment_repository.dart';
import '../../repository/posts_repository.dart';
import '../../repository/user_repository.dart';
import '../../services/preferences_service.dart';
import '../../utils/colours.dart';
import '../../utils/firestore_collections.dart';
import '../../utils/post.dart';

class CompletionDetailsListScreen extends StatefulWidget {
  int categoryId;
  String categoryName, postCompilation, subCategoryId;
  String? contentType;

  List<PostFeed> postsFuture = [];

  CompletionDetailsListScreen(
      {required this.categoryId,
      required this.categoryName,
      required this.contentType,
      required this.postCompilation,
      required this.postsFuture,
      required this.subCategoryId,
      super.key});

  @override
  State<CompletionDetailsListScreen> createState() => _CompletionDetailsListScreenState();
}

class _CompletionDetailsListScreenState extends State<CompletionDetailsListScreen> {
  // late Future<MsbUser?> _userFuture;
  late Future<SchoolUser?> _schoolFuture;
  late Future<List<PostFeed>> _postsFuture;
  late PostFeedRepository postFeedRepository;
  final CommentRepository commentRepository =
      CommentRepository(commentCollection: FirebaseFirestore.instance.collection(FirestoreCollections.comments));
  bool isLoadingPosts = false; // Loading indicator for posts

  late PostFeedsProvider postFeedsProvider;
  late SubmissionApiProvider submissionApiProvider;
  late SubmissionProvider submissionProvider;
  late Future<Map<String, dynamic>> _submissionsFuture;

  @override
  void initState() {
    super.initState();
    //postFeedRepository = PostFeedRepository();
    submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);
    submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
    _submissionsFuture = submissionApiProvider.getSubmissionsBySubcategory(int.parse(widget.subCategoryId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postFeedsProvider = Provider.of<PostFeedsProvider>(context, listen: false);
      postFeedsProvider.getAllPost();
    });
  }

  // Helper to build post list for user or school
  Widget _buildPostList() {
    return Column(
      children: [
        Expanded(
          child: Consumer3<PostFeedsProvider, SubmissionProvider, SubmissionApiProvider>(builder: (
            context,
            postFeedsProvider,
            submissionProvider,
            submissionApiProvider,
            child,
          ) {
            return FutureBuilder(
              future: _submissionsFuture,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }

                var submissions = (snapshot.data?['submissions'] ?? []) as List<Submission>;

                return ListView.builder(
                  // shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: submissions.length,
                  itemBuilder: (BuildContext context, int index) {
                    Submission post = submissions[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => PostDetailScreen(post: post),
                        //   ),
                        // );
                      },
                      child: PostUiUtilsV2.buildPostTile(
                        context,
                        index,
                        post,
                        (postId) async {
                          await CommentBottomSheet.show(context, postId: postId);
                          // _userFuture =
                          //     UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
                          // _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
                        },
                        () => onLike(post, index: index),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
        SizedBox(
          height: 100,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: SvgPicture.asset("assets/svg/back.svg")),
            Text(
              widget.categoryName,
              style: GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SvgPicture.asset("assets/svg/dash_1.svg"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Make the FAB span 90% of the screen width
        child: FloatingActionButton.extended(
          onPressed: () {
            Widget value = PostFeeds(
              categoryId: widget.categoryId,
              subcategoryId: int.parse(widget.subCategoryId),
              widget.categoryName,
              contentType: widget.contentType,
              postCompilation: widget.postCompilation,
            );
            if (widget.contentType == null) {
              value = const QuizScreen();
            }
            Navigator.of(context, rootNavigator: false)
                .push(
              MaterialPageRoute(builder: (_) => value),
            )
                .then((value) {
              // fetchData();
            });
          },
          backgroundColor: AppColors.purpleDark,
          label: Text(
            'Submit post',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _buildPostList(),
    );
  }

  // Helper to build profile header for both user and school
  Widget _buildProfileHeader({MsbUser? user, SchoolUser? school}) {
    if (user != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(user.name, user.profileImageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Unknown User',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Studying in: ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                      children: [
                        TextSpan(
                          text: user.schoolName ?? "N/A",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Profile type: User',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 12,
                  //     color: Colors.white54,
                  //   ),
                  // ),
                  const SizedBox(height: 4),
                  Text(
                    user.grade!,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (school != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(school.schoolName, null),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                school.schoolName ?? 'Unknown School',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Handle long names
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> onLike(Submission post, {required int index}) async {
    var userHasLiked = post.isLiked!;

    post.isLiked = !userHasLiked;
    if (userHasLiked) {
      post.likesCount = post.likesCount! - 1;
    } else {
      post.likesCount = post.likesCount! + 1;
    }
    submissionProvider.updateSubmission(post);

    submissionApiProvider.toggleLike(post.id!);
  }

  // Helper function to build post tile based on post type
  Widget _buildPostTile(PostFeed post) {
    switch (post.postType) {
      case 'video':
        return _buildVideoTile(post);
      case 'image':
        return _buildImageTile(post);
      case 'audio':
        return _buildAudioTile(post);
      case 'text':
        return _buildTextTile(post);
      default:
        return _buildImageTile(post); // Default to image if type is unknown
    }
  }

  // Helper function to build video tile
  Widget _buildVideoTile(PostFeed post) {
    return Stack(
      children: [
        _buildImageBackground(post), // Use image background for the video
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Light black overlay
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  // Helper function to build image tile
  Widget _buildImageTile(PostFeed post) {
    return _buildImageBackground(post);
  }

  // Helper function to build text tile
  Widget _buildTextTile(PostFeed post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          post.title ?? 'No Title',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper function to build audio tile
  Widget _buildAudioTile(PostFeed post) {
    return Stack(
      children: [
        _buildImageBackground(post), // Background image for the audio post
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Light black overlay
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.music_note, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  // Helper function to build image background
  Widget _buildImageBackground(PostFeed post) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: post.mediaUrls != null && post.mediaUrls!.isNotEmpty
              ? CachedNetworkImageProvider(post.mediaUrls!.first)
              : const AssetImage("assets/images/image_placeholder.png") as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Helper function to create profile image based on initials of name
  Widget _buildProfileImage(String? name, String? profileImageUrl) {
    if (profileImageUrl != null) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(profileImageUrl),
      );
    }

    final initials = name != null ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '';

    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.blueAccent,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
