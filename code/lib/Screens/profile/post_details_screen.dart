import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/enums/post_feed_type.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/comment_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/post.dart';
import 'package:video_player/video_player.dart' as VPlayer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msb_app/models/post_feed.dart';

import '../../repository/posts_repository.dart';

@immutable
class PostDetailScreen extends StatefulWidget {
  PostFeed? post;
  MsbUser? currentUser;
    MsbUser? writerUser;
  int? postIndex;
  final String? postId, title, description;
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
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ChewieController? _chewieController;
  VPlayer.VideoPlayerController? _videoPlayerController;

  late PostFeedRepository postFeedRepository;
  static Map<int, CachePatch> videoControllers = {};
  static final Map<int, bool> _isOverlayVisible =
      {}; // Tracks visibility of overlays
  static final Map<int, Timer?> _overlayTimers =
      {}; // Tracks timers for auto-hiding overlays
  var userName = '';
  late Future<MsbUser?> _userFuture;
  late Future<List<PostFeed>> _postsFuture;
  final CommentRepository commentRepository = CommentRepository(
      commentCollection:
          FirebaseFirestore.instance.collection(FirestoreCollections.comments));
            bool isLoadingPosts = true; // Loading indicator for posts
  List<PostFeed> posts = [];

  @override
  void initState() {
    super.initState();
        postFeedRepository = PostFeedRepository();
_fetchPosts(() => postFeedRepository.getPostsByUserId(widget.post!.userId!,
        includeHidden: false));
    if (widget.postId != null && widget.postId!.isNotEmpty) {  
      fetchPostData();
    } else {
      loadData();
    }
   // userName = widget.currentUser!.name!;
  }

  Future<void> _fetchPosts(
      Future<List<PostFeed>> Function() fetchFunction) async {
    try {
      final fetchedPosts = await fetchFunction();
      for (var post in fetchedPosts) {
        var comments = await commentRepository.getCommentsByPost(post.id!);
        fetchedPosts[fetchedPosts.indexOf(post)] =
            post.copyWith(comments: comments);
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
  void dispose() {
    for (var controller in videoControllers.values) {
      controller.playerPlusController.dispose();
    }
    videoControllers.clear();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  /*Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post?.title ?? "Post Details",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostContent(),
              const SizedBox(height: 20),
              _buildPostDescription(),
              const SizedBox(height: 20),
              _buildPostInfo(),
            ],
          ),
        ),
      ),
    );
  }*/

  // Build the post content (video, image, text, or audio)
  Widget _buildPostContent() {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(
      //     16), // Increased corner radius for more rounded edges
      
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.black38, width: 1)),
        child:
      SizedBox(
        width: double.infinity,
        height: 400, // Increased height for larger content
        child: _buildContentByType(context, 0, widget.post!)
        // PostUiUtils.buildPostTile(
        //       context,
        //       widget.postIndex!,
        //       widget.post!,
        //       (postId) async {
        //         await CommentBottomSheet.show(context, postId: postId);
        //           _userFuture = UserRepository(
        //                   usersCollection:
        //                       FirebaseFirestore.instance.collection('users'))
        //               .getOne(widget.user!.id!);
        //           _fetchPosts(() => postFeedRepository
        //               .getPostsByUserId(widget.user!.id!, includeHidden: false));
                
        //       },
        //       () => onLike(widget.post!, index: widget.postIndex!),
        //     ),
      ),
      ),
    );
  }

   Widget _buildContentByType(
      BuildContext context, int index, PostFeed post) {
    switch (post.postType) {
      case 'video':
        return _buildVideoPlayer();
      case 'image':
        return _buildImagePost(context, post);
      case 'audio':
        return _buildVideoPlayer();
      case 'text':
        return _buildTextPost(post!);
      default:
        return const Text("No content available");
    }
  }

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
    setState(() {
            fetchPostData();
    });
  }

  // Custom video player with tap-to-show overlay controls
  static Widget _buildCustomVideoPlayer(
      BuildContext context, int index, PostFeed post) {
    if (post.mediaUrls == null) {
      return Center(
        child: Text("",
            style: GoogleFonts.poppins(
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w500,
                fontSize: 16)),
      );
    }
    if (!videoControllers.containsKey(index)) {
      videoControllers[index] = CachePatch(
          dateTime: DateTime.now(),
          playerPlusController: CachedVideoPlayerPlusController.networkUrl(
            Uri.parse(post.mediaUrls!.first),
            invalidateCacheIfOlderThan: const Duration(minutes: 10),
          )..initialize().then((_) {
              (context as Element).markNeedsBuild();
            }).catchError((error) {
              print("Video initialization error: $error");
            }));
      _isOverlayVisible[index] = false;
    } else if (videoControllers[index] != null) {
      final difference =
          DateTime.now().difference(videoControllers[index]!.dateTime);
      if (difference.inSeconds > 10) {
        videoControllers[index] = CachePatch(
            dateTime: DateTime.now(),
            playerPlusController: CachedVideoPlayerPlusController.networkUrl(
              Uri.parse(post.mediaUrls!.first),
              invalidateCacheIfOlderThan: const Duration(minutes: 10),
            )..initialize().then((_) {
                (context as Element).markNeedsBuild();
              }).catchError((error) {
                print("Video initialization error: $error");
              }));
        _isOverlayVisible[index] = false;
      }
    }

    final controller = videoControllers[index]!;
    return controller.playerPlusController.value.isInitialized
        ? GestureDetector(
            onTap: () {
              _toggleOverlay(context, index);
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (post.postType == 'audio')
                  Center(
                    child: Container(color: AppColors.black87),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: AspectRatio(
                    aspectRatio:
                        controller.playerPlusController.value.aspectRatio,
                    child:
                        CachedVideoPlayerPlus(controller.playerPlusController),
                  ),
                ),
                _isOverlayVisible[index] ?? false
                    ? _buildOverlayControls(
                        controller.playerPlusController, context, index)
                    : const SizedBox.shrink(),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  // Method to toggle visibility of the overlay and set a timer to hide it after 2-3 seconds
  static void _toggleOverlay(BuildContext context, int index) {
    _isOverlayVisible[index] = !(_isOverlayVisible[index] ?? false);

    if (_isOverlayVisible[index] == true) {
      // Cancel any existing timer
      _overlayTimers[index]?.cancel();

      // Set a timer to hide the overlay after 3 seconds
      _overlayTimers[index] = Timer(const Duration(seconds: 3), () {
        _isOverlayVisible[index] = false;
        (context as Element).markNeedsBuild();
      });
    }

    (context as Element).markNeedsBuild();
  }

  // Custom video controls (play/pause, sound, replay) shown in the bottom overlay
  static Widget _buildOverlayControls(
      CachedVideoPlayerPlusController controller,
      BuildContext context,
      int index) {
    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.black54, // Light black overlay
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play/pause button
            IconButton(
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
                _hideOverlayOnTap(
                  context,
                  index,
                ); // Hide overlay when icon is tapped
              },
            ),
            // Volume toggle button
            IconButton(
              icon: Icon(
                controller.value.volume == 0
                    ? Icons.volume_off
                    : Icons.volume_up,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                controller.setVolume(controller.value.volume == 0 ? 1.0 : 0);
                _hideOverlayOnTap(
                  context,
                  index,
                ); // Hide overlay when icon is tapped
              },
            ),
            // Replay button
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.white, size: 30),
              onPressed: () {
                controller.seekTo(Duration.zero);
                controller.play();
                _hideOverlayOnTap(
                  context,
                  index,
                ); // Hide overlay when icon is tapped
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to hide overlay when any icon is tapped
  static void _hideOverlayOnTap(BuildContext context, int index) {
    _isOverlayVisible[0] = false;
    (context as Element).markNeedsBuild();
  }

// Helper method to build image post using CachedNetworkImage
  static Widget _buildImagePost(BuildContext context, PostFeed post) {
    return GestureDetector(
      onLongPress: () {
        // Open image preview on long press
        _openImagePreview(context, post.mediaUrls!.first);
      },
      child: CachedNetworkImage(
        imageUrl: post.mediaUrls != null ? post.mediaUrls!.first : "",
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

  // Helper method to build audio post
  static Widget _buildAudioPost(PostFeed post) {
    return Container(
      color: AppColors.primary,
      height: 150,
      child: Center(
        child: Text(
          'Audio Post: ${post.title ?? 'No title'}',
          style: GoogleFonts.poppins(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // Helper method to build text post
  static Widget _buildTextPost(PostFeed post) {
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

  // Build video player for video posts
  Widget _buildVideoPlayer() {
    if (_chewieController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: GestureDetector(
          //onLongPress: () => _showFullScreenVideo(),
          child: Chewie(controller: _chewieController!),
        ),
      );
    } else {
      return const Center(child: Text("Video unavailable"));
    }
  }

  // Build image post
  Widget _buildImage() {
    return GestureDetector(
      onLongPress: () {
        if (widget.post != null) {
          _showImagePreview(widget.post!.mediaUrls!.first);
        }
      },
      child: CachedNetworkImage(
        imageUrl: widget.post?.mediaUrls?.first ?? "",
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
      ),
    );
  }

  // Build text post

  Widget _buildTextPost1(PostFeed post) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.post?.description ?? "No description available",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Build audio post
  Widget _buildAudioPost1() {
    return Column(
      children: [
        const Icon(Icons.audiotrack, size: 100, color: Colors.blueAccent),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.post?.title ?? "Audio Post",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Placeholder for audio player (You can integrate an actual audio player)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }

  // Build post description
  Widget _buildPostDescription() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.post?.description ?? "No description available",
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.left,
      ),
    );
  }

  // Build post info like posted by and other details
  Widget _buildPostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostedBy(),
        const SizedBox(height: 10),
        Text(
          widget.post != null
              ? "Comments enabled: ${widget.post!.commentsEnabled ? 'Yes' : 'No'}"
              : "",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Text(
          widget.post != null ? "Created at: ${widget.post!.createdAt}" : "",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Helper widget to show "Posted by" info
  Widget _buildPostedBy() {
    return RichText(
      text: TextSpan(
        text: 'Posted by: ',
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: <TextSpan>[
          TextSpan(
            text: widget.post != null
                ? widget.post!.nameOrEmail ?? 'Unknown'
                : "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  // Show image preview in full screen
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Dialog(
            backgroundColor: Colors.black,
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  // Show video in full screen
  void _showFullScreenVideo() {
    if (_videoPlayerController != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(backgroundColor: Colors.black),
            body: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }
  }

  fetchPostData() async {
    PostFeed? data = await postFeedRepository.getOne(widget.postId ?? widget.post!.id!);
    setState(() {
      widget.post = data;
      _fetchPosts(() => postFeedRepository.getPostsByUserId(widget.post!.userId!,
          includeHidden: false));
                            PostUiUtils.buildPostTile(context, widget.postIndex!, widget.post!,  (postId) async {
          // await CommentBottomSheet.show(context, postId: postId);
        },
        () => onLike(widget.post!, index: 0),
      );
                  PostUiUtils.buildPostFooterIndependent(
                    context,
                    widget.post!,
                    (postId) async {
                      // await CommentBottomSheet.show(context, postId: postId);
                    },
                    () => onLike(widget.post!, index: 0),
                  );    });

    loadData();
  }

  void loadData() {
    if (widget.post != null &&
        widget.post!.mediaUrls != null) {
      _videoPlayerController =
          VPlayer.VideoPlayerController.network(widget.post!.mediaUrls!.first);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        allowPlaybackSpeedChanging: false,
        showOptions: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: AppColors.primary,
      home: Scaffold(
        appBar: AppBar(
          title: _buildPostHeader(),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            // Image set to background of the body
            image: DecorationImage(
                image: AssetImage("assets/images/profile_frame copy.png"),
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeaderTitle(),
                                const SizedBox(height: 10),
                _buildPostContent(),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(5.0),
                 // height: 45,
                   decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black12, Colors.black12, Colors.blueGrey],
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: 
                  PostUiUtils.buildPostFooterIndependent(
                    context,
                    widget.post!,
                    (postId) async {
                      // await CommentBottomSheet.show(context, postId: postId);
                    },
                    () => onLike(widget.post!, index: 0),
                  ),
                ),
               
                //_buildPostActions(),
                                const SizedBox(height: 5),
                //_buildPostLikesAndComments(),
                  const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.asset(
                  "assets/images/profile.png",
                  height: 40,
                ),
          const SizedBox(width: 8),
          Text(
            widget.post != null ? widget.post!.nameOrEmail ?? 'Unknown' : "",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeaderTitle() {
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
        child:
       Row(
        children: [
          if (widget.post!.postType != null) ...[
            PostUiUtils.getIconForPostFeedType(
                PostFeedType.fromValue(widget.post!.postType!)),
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
                  widget.post!.title! ?? "Unkown Category",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.background),

                ),
              Text(
                textAlign: TextAlign.left,
                          maxLines: 2,
                widget.post!.schoolName ?? "Anonymous",
                style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                    fontSize: 12, color: AppColors.background),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildProfileImage(String? name, String? profileImageUrl) {
    if (profileImageUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(profileImageUrl),
      );
    } else {
      return Image.asset(
        "assets/images/profile.png",
        height: 40,
      );
    }
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      height: 400,
      child: Image.network(
        'https://example.com/post_image.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPostActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /// liked by counter and toggle
        GestureDetector(
          // onTap: onLike,
          child: Container(
            decoration: BoxDecoration(
              color: widget.post!.likedBy
                      .contains(FirebaseAuth.instance.currentUser?.uid)
                  ? AppColors.peach.withOpacity(0.2)
                  : null,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: const Color(0xFFCECACA),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Row(
                children: [
                  SvgPicture.asset(
                    widget.post!.likedBy
                            .contains(FirebaseAuth.instance.currentUser?.uid)
                        ? "assets/svg/like.svg"
                        : "assets/svg/unLike.svg",
                    height: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.post!.likedBy.length.toString(),
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        // if (writerUser != null) ...[
        //   const SizedBox(width: 10),
        //   _buildIconText(
        //     writerUser.follower.contains(currentUser?.id) ? Icons.person : Icons.person_outline,
        //     writerUser.follower.length.toString(),
        //     onClick: followUser,
        //   ),
        // ],

        /// comments counter and bottomsheet
        // if (post.commentsEnabled) ...[
        //   const SizedBox(width: 10),
        //   GestureDetector(
        //     onTap: () {
        //       onCommentButtonPressed(post
        //           .id!); // Properly call the function when comment is pressed
        //     },
        //     child: _buildIconText(
        //       Icons.comment_outlined,
        //       post.comments.length.toString() ?? "0",
        //     ),
        //   ),
        // ],

        // Row(
        //   children: [
        //     Expanded(
        //       child: GestureDetector(
        //         child: Text(
        //           widget.user!.schoolName ?? "Anonymous",
        //           style:
        //               GoogleFonts.poppins(fontSize: 12, color: Colors.blue),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildPostLikesAndComments() {
    var isCurrentUserLiked =
        widget.post!.likedBy.contains(FirebaseAuth.instance.currentUser?.uid);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.post!.likedBy.length > 0
              ? isCurrentUserLiked
                  ? widget.post!.likedBy.length == 1
                      ? Text(
                          'Liked by $userName',
                          style: TextStyle(color: Colors.white),
                        )
                      : widget.post!.likedBy.length <= 2
                          ? Text(
                              'Liked by $userName and ${widget.post!.likedBy.length - 1} user',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              'Liked by $userName and ${widget.post!.likedBy.length - 1} users',
                              style: TextStyle(color: Colors.white),
                            )
                  : widget.post!.likedBy.length <= 1
                      ? Text(
                          'Liked by ${widget.post!.likedBy.length} user',
                          style: TextStyle(color: Colors.white),
                        )
                      : Text(
                          'Liked by ${widget.post!.likedBy.length} users',
                          style: TextStyle(color: Colors.white),
                        )
              : Text(
                  '',
                  style: TextStyle(color: Colors.white),
                ),
        ],
      ),
    );
  }

  Widget _buildPostCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        'View all 20 comments',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildPostComments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComment('username Comment 1'),
        ],
      ),
    );
  }

  Widget _buildComment(String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // CircleAvatar(
          //   backgroundImage:
          //      // NetworkImage('https://example.com/profile_image.jpg'),
          //  // radius: 15,
          // ),
          const SizedBox(width: 8),
          Text(
            comment,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
