import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/post.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

import '../../models/msbuser.dart';

class UserProfileScreen extends StatefulWidget {
  final String id;
  final String type; // "user" or "school", default is "user"

  const UserProfileScreen({
    required this.id,
    this.type = "user", // Default type
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<SchoolUser?> _schoolFuture;
  late SchoolUserRepository schoolUserRepository;
  bool isLoadingPosts = true; // Loading indicator for posts
  List<PostFeed> posts = [];
  late MsbUser currentUser;

  late UserProvider _userProvider;
  late SubmissionProvider _submissionProvider;
  late SubmissionApiProvider _submissionApiProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
    _submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);

    // getUser();
    loadAllSubmissions();
  }

  Future<void> loadAllSubmissions() async {
    _submissionProvider.isLoadingSubmissions = true;
    Map<String, dynamic> response = {};
    if (widget.type == "user") {
      response = await _submissionApiProvider.getSubmissionsByUserId(int.parse(widget.id));
    } else if (widget.type == "school") {
      response = await _submissionApiProvider.getSubmissionsBySchool(int.parse(widget.id));
    }
    _submissionProvider.clearSubmissions();
    _submissionProvider.addSubmissions(response['submissions'] as List<Submission>);
    _submissionProvider.isLoadingSubmissions = false;
  }

  @override
  void dispose() {
    super.dispose();
    PostUiUtils.disposeVideoControllers();
  }

  // Helper to build post list for user or school
  Widget _buildPostList() {
    // if (isLoadingPosts) {
    //   return const Center(child: CircularProgressIndicator());
    // } else if (posts.isEmpty) {
    //   return const Center(child: Text('No posts available'));
    // }

    if (_submissionProvider.isLoadingSubmissions) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (_submissionProvider.submissions.isEmpty) {
        return const Center(child: Text('No posts available'));
      }

      return _buildPostsGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Consumer3<UserAuthProvider, SubmissionProvider, SubmissionApiProvider>(
          builder: (ctxt, authProvider, submissionProvider, submissionApiProvider, child) {
        return Column(
          children: [
            Container(
              height: query.height / 6,
              width: query.width,
              decoration: const BoxDecoration(
                  // color: AppColors.primary,
                  color: AppColors.purpleDark,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(25.0), bottomLeft: Radius.circular(25.0))),
              child: Column(
                children: [
                  SafeArea(child: widget.type == "user" ? _buildUserProfile() : _buildSchoolProfile()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPostList(),
          ],
        );
      }),
    );
  }

  // Builds the user profile screen
  Widget _buildUserProfile() {
    return _buildProfileHeader(user: _userProvider.user);
  }

  // Builds the school profile screen
  Widget _buildSchoolProfile() {
    return FutureBuilder<SchoolUser?>(
      future: _schoolFuture,
      builder: (context, schoolSnapshot) {
        if (schoolSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (schoolSnapshot.hasError || schoolSnapshot.data == null) {
          return const Center(child: Text('Error loading school data'));
        }

        SchoolUser school = schoolSnapshot.data!;
        return Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(school: school),
          ],
        );
      },
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
            _buildProfileImage(user.user?.name, user.user?.profileUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      user.user?.name ?? 'Unknown User',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
                          text: user.student.school?.name ?? "N/A",
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
                    user.student.grade?.name ?? "N/A",
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

  // Helper to build post list for user or school
  // Widget _buildPostList() {
  //   return FutureBuilder<List<PostFeed>>(
  //     future: _postsFuture,
  //     builder: (context, postsSnapshot) {
  //       if (postsSnapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (postsSnapshot.hasError ||
  //           postsSnapshot.data == null ||
  //           postsSnapshot.data!.isEmpty) {
  //         return const Center(child: Text('No posts available'));
  //       }
  //
  //       List<PostFeed> posts = postsSnapshot.data!;
  //       return Expanded(child: _buildPostsGrid(posts));
  //     },
  //   );
  // }

  // Helper to build the posts grid
  Widget _buildPostsGrid() {
    return Consumer<SubmissionProvider>(builder: (context, ref, child) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7, // Example height
          child: ListView.builder(
            // shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: _submissionProvider.submissions.length,
            itemBuilder: (BuildContext context, int index) {
              Submission post = _submissionProvider.submissions[index];
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
                    if (widget.type == "user") {
                      // _userFuture = UserRepository(usersCollection: FirebaseFirestore.instance.collection('users'))
                      //     .getOne(widget.id);
                      // _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
                    } else if (widget.type == "school") {
                      _schoolFuture = schoolUserRepository.findBySchoolId(widget.id);
                      // _fetchPosts(() => postFeedRepository.getPostsBySchoolId(widget.id, includeHidden: false));
                    }
                  },
                  () => {
                    // onLike(post, index: index)
                  },
                ),
              );
            },
          ));
    });
  }

  // Widget _buildPostsGrid(List<PostFeed> posts) {
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.7, // Example height
  //     child: ListView.builder(
  //       // shrinkWrap: true,
  //       padding: const EdgeInsets.all(8.0),
  //       itemCount: posts.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         PostFeed post = posts[index];
  //         return GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => PostDetailScreen(post: post),
  //               ),
  //             );
  //           },
  //           child: PostUiUtils.buildPostTile(
  //             context,
  //             index,
  //             post,
  //                 (postId) async {
  //               await CommentBottomSheet.show(context, postId: postId);
  //               if (widget.type == "user") {
  //                 _userFuture =
  //                     UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
  //                 _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
  //               } else if (widget.type == "school") {
  //                 _schoolFuture = schoolUserRepository.findBySchoolId(widget.id);
  //                 _fetchPosts(() => postFeedRepository.getPostsBySchoolId(widget.id, includeHidden: false));
  //               }
  //             },
  //                 () => onLike(post, index: index),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Future<void> onLike(PostFeed post, {required int index}) async {
    final userId = await PrefsService.getUserId();
    final likes = List<String>.from(post.likedBy);
    final userHasLiked = post.likedBy.contains(userId);
    setState(() {
      posts[index] = post.copyWith(
        likedBy: userHasLiked
            ? (likes..remove(userId))
            : (likes
              ..add(
                userId!,
              )),
      );
    });
    // await postFeedRepository.addLikedByForPost(
    //   post.id!,
    //   userId ?? '',
    //   userHasLiked,
    // );
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
              color: Colors.black.withValues(alpha: 0.3), // Light black overlay
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
              color: Colors.black.withValues(alpha: 0.3), // Light black overlay
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
