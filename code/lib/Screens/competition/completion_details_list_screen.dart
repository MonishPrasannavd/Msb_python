import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/post%20story/post_feed_screen.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/providers/post_feed_provider.dart';
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
  String categoryName, postCompilation, subCategoryId;
  String? contentType ;

  List<PostFeed> postsFuture = [];

  CompletionDetailsListScreen(
      {required this.categoryName,
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
  @override
  void initState() {
    super.initState();
    //postFeedRepository = PostFeedRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postFeedsProvider = Provider.of<PostFeedsProvider>(context, listen: false);
    });
  }

  // Helper to build post list for user or school
  Widget _buildPostList() {
    if (isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    } else if (widget.postsFuture.isEmpty) {
      return const Center(child: Text('No posts available'));
    }

    return Column(
      children: [
        Expanded(
          child: ChangeNotifierProvider.value(
            value:  postFeedsProvider,
            child: Consumer<PostFeedsProvider>(builder: (context, value, child){
              return ListView.builder(
                // shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: widget.postsFuture.length,
                itemBuilder: (BuildContext context, int index) {
                  PostFeed post = widget.postsFuture[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PostDetailScreen(post: post),
                      //   ),
                      // );
                    },
                    child: PostUiUtils.buildPostTile(
                      context,
                      index,
                      post,
                          (postId) async {
                        // await CommentBottomSheet.show(context, postId: postId);
                        // _userFuture =
                        //     UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
                        // _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
                      },
                          () => onLike(post, index: index),
                    ),
                  );
                },
              );
            })
            ),
          ),

        SizedBox(height: 100,)
      ],
    );
  }

  Future<void> _fetchPosts(Future<List<PostFeed>> Function() fetchFunction) async {
    try {
      final fetchedPosts = await fetchFunction();
      for (var post in fetchedPosts) {
        var comments = await commentRepository.getCommentsByPost(post.id!);
        fetchedPosts[fetchedPosts.indexOf(post)] = post.copyWith(comments: comments);
      }
      setState(() {
        widget.postsFuture = fetchedPosts;
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
      height: MediaQuery.of(context).size.height * 0.8, // Example height
      child: ListView.builder(
        // shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          PostFeed post = posts[index];
          return GestureDetector(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => PostDetailScreen(post: post),
            //     ),
            //   );
            // },
            child: PostUiUtils.buildPostTile(
              context,
              index,
              post,
              (postId) async {
                // await CommentBottomSheet.show(context, postId: postId);
                // _userFuture =
                //     UserRepository(usersCollection: FirebaseFirestore.instance.collection('users')).getOne(widget.id);
                // _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.id, includeHidden: false));
              },
              () => onLike(post, index: index),
            ),
          );
        },
      ),
    );
  }

  Future<void> onLike(PostFeed post, {required int index}) async {
    final userId = await PrefsService.getUserId();
    final likes = List<String>.from(post.likedBy);
    final userHasLiked = post.likedBy.contains(userId);
    setState(() {
      widget.postsFuture[index] = post.copyWith(
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
