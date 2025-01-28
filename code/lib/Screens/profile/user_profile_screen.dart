import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/Screens/profile/post_details_screen.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/repository/comment_repository.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/post.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

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
  late Future<MsbUser?> _userFuture;
  late Future<SchoolUser?> _schoolFuture;
  late Future<List<PostFeed>> _postsFuture;
  late PostFeedRepository postFeedRepository;
  final CommentRepository commentRepository =
      CommentRepository(commentCollection: FirebaseFirestore.instance.collection(FirestoreCollections.comments));
  late SchoolUserRepository schoolUserRepository;
  bool isLoadingPosts = true; // Loading indicator for posts
  List<PostFeed> posts = [];
  late MsbUser currentUser;
  UserRepository userRepository =
      UserRepository(usersCollection: FirebaseFirestore.instance.collection(FirestoreCollections.users));

  late UserAuthProvider _authProvider;
  late SubmissionProvider _submissionProvider;
  late SubmissionApiProvider _submissionApiProvider;

  @override
  void initState() {
    super.initState();
    postFeedRepository = PostFeedRepository();
    schoolUserRepository = SchoolUserRepository();
    if (widget.type == "user") {
      _userFuture = UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
      _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
    } else if (widget.type == "school") {
      _schoolFuture = schoolUserRepository.findBySchoolId(widget.id);
      _fetchPosts(() => postFeedRepository.getPostsBySchoolId(widget.id, includeHidden: false));
    }
    loadUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<UserAuthProvider>(context, listen: false);
      _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
      _submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);

      // getUser();
      loadAllSubmissions();
    });
  }

  void loadAllSubmissions() async {
    var response = await _submissionApiProvider.getAllSubmissions();
    _submissionProvider.submissions = response['submissions'] as List<Submission>;
  }

  Future<void> loadUser() async {
    setState(() async {
      currentUser = (await userRepository.getOne(widget.id))!;
    });
  }

  @override
  void dispose() {
    super.dispose();
    PostUiUtils.disposeVideoControllers();
  }

  // Helper to build post list for user or school
  Widget _buildPostList() {
    if (isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    } else if (posts.isEmpty) {
      return const Center(child: Text('No posts available'));
    }

    return _buildPostsGrid(posts);
  }

  Future<void> _fetchPosts(Future<List<PostFeed>> Function() fetchFunction) async {
    try {
      final fetchedPosts = await fetchFunction();
      for (var post in fetchedPosts) {
        var comments = await commentRepository.getCommentsByPost(post.id!);
        fetchedPosts[fetchedPosts.indexOf(post)] = post.copyWith(comments: comments);
      }
      setState(() {
        posts = fetchedPosts;
        isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPosts = false;
      });
      debugPrint('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: query.height / 6,
            width: query.width,
            decoration: const BoxDecoration(
                // color: AppColors.primary,
                color: AppColors.purpleDark,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(25.0), bottomLeft: Radius.circular(25.0))),
            child: Column(
              children: [
                // SafeArea(
                //   child: Text(
                //     widget.type == "user" ? "User Profile" : "School Profile",
                //     style: GoogleFonts.poppins(
                //       color: Colors.white,
                //       fontWeight: FontWeight.w600,
                //       fontSize: 30,
                //     ),
                //   ),
                // ),
                SafeArea(child: widget.type == "user" ? _buildUserProfile() : _buildSchoolProfile()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPostList(),
        ],
      ),
    );
  }

  // Builds the user profile screen
  Widget _buildUserProfile() {
    return FutureBuilder<MsbUser?>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasError || userSnapshot.data == null) {
          return const Center(child: Text('Error loading user data'));
        }

        MsbUser user = userSnapshot.data!;
        return Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(user: user),
          ],
        );
      },
    );
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
            _buildProfileImage(user.name, user.profileImageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      user.name ?? 'Unknown User',
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
  Widget _buildPostsGrid(List<PostFeed> posts) {
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
                  _userFuture =
                      UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
                  _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
                } else if (widget.type == "school") {
                  _schoolFuture = schoolUserRepository.findBySchoolId(widget.id);
                  _fetchPosts(() => postFeedRepository.getPostsBySchoolId(widget.id, includeHidden: false));
                }
              },
                  () => {
                // onLike(post, index: index)
              },
            ),
          );
        },
      )
    );
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
    await postFeedRepository.addLikedByForPost(
      post.id!,
      userId ?? '',
      userHasLiked,
    );
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
