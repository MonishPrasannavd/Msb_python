import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/Screens/profile/post_details_screen.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user_single.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
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
  bool isLoadingPosts = true; // Loading indicator for posts
  List<Submission> posts = [];
  late MsbUser currentUser;
  late bool isLoadingPostUser = false;
  late UserSingle postUser;
  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;

  late UserProvider _userProvider;
  late SubmissionProvider _submissionProvider;
  late SubmissionApiProvider _submissionApiProvider;
  late UserAuthProvider _userAuthProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);
    _submissionApiProvider =
        Provider.of<SubmissionApiProvider>(context, listen: false);
    _userAuthProvider = Provider.of<UserAuthProvider>(context, listen: false);

    _scrollController = ScrollController()..addListener(_scrollListener);

    // getUser();
    loadAllSubmissions();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMoreData) {
        _fetchMoreSubmissions();
      }
    }
  }

  Future<void> _fetchMoreSubmissions() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++; // Increase page count
    Map<String, dynamic> response =
        await _submissionApiProvider.getSubmissionsByUserId(
      int.parse(widget.id),
      page: _currentPage,
    );

    var newSubmissions = response['submissions'];
    if (newSubmissions != null && newSubmissions.isNotEmpty) {
      _submissionProvider.addSubmissions(newSubmissions);
    } else {
      _hasMoreData = false; // No more pages left
    }

    setState(() {
      _isFetchingMore = false;
    });
  }

  Future<void> loadAllSubmissions() async {
    setState(() {
      isLoadingPostUser = true;
    });
    var postUserResponse = await _userAuthProvider.getUser(widget.id);

    setState(() {
      isLoadingPostUser = false;
      postUser = postUserResponse['user'];
    });
    _submissionProvider.isLoadingSubmissions = true;
    Map<String, dynamic> response = {};
    if (widget.type == "user") {
      response = await _submissionApiProvider
          .getSubmissionsByUserId(int.parse(widget.id));
    } else if (widget.type == "school") {
      response = await _submissionApiProvider
          .getSubmissionsBySchool(int.parse(widget.id));
    }
    _submissionProvider.clearSubmissions();
    var fetchedSubmissions = response['submissions'];
    if (fetchedSubmissions != null) {
      _submissionProvider.addSubmissions(fetchedSubmissions);
    } else {
      _submissionProvider.addSubmissions([]);
    }
    posts = _submissionProvider.submissions;
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
      body: Consumer4<UserAuthProvider, SubmissionProvider,
              SubmissionApiProvider, UserAuthProvider>(
          builder: (ctxt, authProvider, submissionProvider,
              submissionApiProvider, userAuthProvider, child) {
        return Column(
          children: [
            Container(
              height: query.height / 6,
              width: query.width,
              decoration: const BoxDecoration(
                  // color: AppColors.primary,
                  color: AppColors.purpleDark,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(25.0),
                      bottomLeft: Radius.circular(25.0))),
              child: Column(
                children: [
                  SafeArea(
                      child: widget.type == "user"
                          ? _buildUserProfile()
                          : _buildSchoolProfile()),
                ],
              ),
            ),
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
    if (widget.type == "user" && isLoadingPostUser) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (school != null) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImage(postUser.name, postUser.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    postUser.name ?? 'Unknown User',
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
                        text:
                            postUser.student?.school?.name?.toString() ?? "N/A",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("Likes: ",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold)),
                    Text(postUser.likesCount.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.normal)),
                    SizedBox(width: 10),
                    Text("Comments: ",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold)),
                    Text(postUser.commentsCount.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("Grade: ",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold)),
                    Text(postUser.student?.grade?.name?.toString() ?? "N/A",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the posts grid
  Widget _buildPostsGrid() {
    return Consumer<SubmissionProvider>(builder: (context, ref, child) {
      return Expanded(
        child: ListView.builder(
          controller: _scrollController,
          // shrinkWrap: true,
          padding: const EdgeInsets.all(8.0),
          itemCount: _submissionProvider.submissions.length,
          itemBuilder: (BuildContext context, int index) {
            Submission post = _submissionProvider.submissions[index];
            return PostUiUtilsV2.buildPostTile(
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
                  // _schoolFuture = schoolUserRepository.findBySchoolId(widget.id);
                  // _fetchPosts(() => postFeedRepository.getPostsBySchoolId(widget.id, includeHidden: false));
                }
              },
              () => onLike(post, index: index),
              onTap: loadAllSubmissions,
            );
          },
        ),
      );
    });
  }

  Future<void> onLike(Submission post, {required int index}) async {
    final likes = post.likesCount ?? 0;
    final userHasLiked = post.isLiked ?? false;
    setState(() {
      posts[index] = post.copyWith(
        isLiked: !userHasLiked,
        likesCount: likes + (userHasLiked ? -1 : 1),
      );
    });

    _submissionApiProvider.toggleLike(post.id!);
  }

  // Helper function to create profile image based on initials of name
  Widget _buildProfileImage(String? name, String? profileImageUrl) {
    if (profileImageUrl != null) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(profileImageUrl),
      );
    }

    final initials = name != null
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '';

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
