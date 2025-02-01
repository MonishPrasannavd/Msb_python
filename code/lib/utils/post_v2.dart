import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msb_app/Screens/profile/post_details_screen.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/enums/post_feed_type.dart';
import 'package:msb_app/models/comment.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/share_feature.dart';
import 'package:msb_app/utils/user.dart';
import 'package:shimmer/shimmer.dart';

class CachePatch {
  late CachedVideoPlayerPlusController playerPlusController;
  late DateTime dateTime;

  CachePatch({required this.dateTime, required this.playerPlusController});
}

class PostUiUtilsV2 {
  static Map<int, CachePatch> videoControllers = {};
  static final Map<int, bool> _isOverlayVisible =
      {}; // Tracks visibility of overlays
  static final Map<int, Timer?> _overlayTimers =
      {}; // Tracks timers for auto-hiding overlays
  static const double postContentHeight = 350;

  // Function to build a full post tile
  static Widget buildPostTile(
    BuildContext context,
    int index,
    Submission post,
    Function(int) onCommentButtonPressed,
    Function() onLike, {
    Widget? sideMenu,
    MsbUser? writerUser,
    Function()? followUser,
    MsbUser? currentUser,
    Function(String schoolId)? onSchoolTap,
    VoidCallback? onNavigateBack,
    Widget Function(
      BuildContext context,
      int index,
      Submission post, {
      Widget? sideMenu,
      MsbUser? writerUser,
      MsbUser? currentUser,
      Function(String schoolId)? onSchoolTap,
      VoidCallback? onNavigateBack,
    })? customPostHeader,
    Widget Function(BuildContext context, int index, Submission post)?
        customPostContent,
    Widget Function(
      BuildContext context,
      Submission post,
      Function(int) onCommentButtonPressed,
      Function() onLike, {
      MsbUser? writerUser,
      MsbUser? currentUser,
      Function()? followUser,
    })? customPostFooter,
  }) {
    final postHeader = customPostHeader ?? _buildPostHeader;
    final postContent = customPostContent ?? _buildPostContent;
    final postFooter = customPostFooter ?? _buildPostFooter;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            postHeader(
              context,
              index,
              post,
              sideMenu: sideMenu,
              writerUser: writerUser,
              currentUser: currentUser,
              onSchoolTap: onSchoolTap,
              onNavigateBack: onNavigateBack,
            ),
            const SizedBox(height: 10),
            postContent(context, index, post),
            const SizedBox(height: 10),
            postFooter(
              context,
              post,
              onCommentButtonPressed,
              onLike,
              writerUser: writerUser,
              currentUser: currentUser,
              followUser: followUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostContentIndependent(context, index, post) {
    return post.mediaUrls != null
        ? _buildPostContent(context, index, post)
        : Center(
            child: Container(),
          );
  }

  static Widget _buildPostHeader(
    BuildContext context,
    int index,
    Submission post, {
    Widget? sideMenu,
    MsbUser? writerUser,
    MsbUser? currentUser,
    Function(String schoolId)? onSchoolTap,
    VoidCallback? onNavigateBack,
  }) {
    var postType = getPostFeedType(post);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => PostDetailScreen(post: post),
                  //     ));
                },
                child: Text(
                  post.user?.name ?? post.user?.email ?? "Unknown",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // const Spacer(),
              // if (sideMenu != null) sideMenu,
            ],
          ),
        ),
        Row(
          children: [
            if (postType != null) ...[
              getIconForPostFeedType(postType),
              const SizedBox(
                width: 5,
              )
            ],
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => PostDetailScreen(post: post,),
                //     ));
              },
              child: Text(
                post.title ?? "Unkown Category",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const Spacer(),
            if (sideMenu != null) sideMenu,
          ],
        ),
        const SizedBox(height: 5),
        if (writerUser != null) ...[
          Row(
            children: [
              Text(
                'By ',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              GestureDetector(
                onTap: () async {
                  // Navigate to uploader's profile
                  // await Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           UserProfileScreen(id: post.userId!)),
                  // );

                  // onNavigateBack?.call();
                },
                child: Text(
                  writerUser.name ?? writerUser.email ?? "Anonymous",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // onSchoolTap?.call(post.schoolId);
                  },
                  child: Text(
                    writerUser.schoolName ?? "Anonymous",
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 5),
        if (post.createdAt != null) ...[
          Text(
            DateFormat('d MMM y, hh:mm a').format(post.createdAt),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ]
      ],
    );
  }

  static PostFeedType? getPostFeedType(Submission submission) {
    // Ensure category and categoryType are not null
    if (submission.category?.categoryType?.name != null) {
      // Match the categoryType.name to the corresponding PostFeedType
      return PostFeedType.fromValue(submission.category!.categoryType!.name!);
    }
    // Return null if categoryType or name is null
    return null;
  }

  // Method to build post content based on post type (image, video, text, etc.)
  static Widget _buildPostContent(
      BuildContext context, int index, Submission post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
          16), // Increased corner radius for more rounded edges
      child: SizedBox(
        width: double.infinity,
        height: postContentHeight, // Increased height for larger content
        child: _buildContentByType(context, index, post),
      ),
    );
  }

  static Widget _buildContentByType(
      BuildContext context, int index, Submission post) {
    var postType = getPostFeedType(post);
    switch (postType?.value) {
      case 'video':
        return _buildCustomVideoPlayer(context, index, post);
      case 'image':
        return _buildImagePost(context, post);
      case 'audio':
        return _buildCustomVideoPlayer(context, index, post);
      case 'text':
      default:
        return _buildTextPost(post);
    }
  }

  // Custom video player with tap-to-show overlay controls
  static Widget _buildCustomVideoPlayer(
      BuildContext context, int index, Submission post) {
    if (post.mediaUrl == null) {
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
            Uri.parse(post.mediaUrl!),
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
              Uri.parse(post.mediaUrl!),
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
    var postType = getPostFeedType(post);
    return controller.playerPlusController.value.isInitialized
        ? GestureDetector(
            onTap: () {
              _toggleOverlay(context, index);
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (postType?.value == 'audio')
                  Center(
                    child: Container(color: AppColors.black87),
                  ),
                SizedBox(
                  height: postContentHeight, // Fixed height for all videos
                  width: double.infinity,
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
      height: postContentHeight, // Overlay covering the entire video
      width: double.infinity,
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
    _isOverlayVisible[index] = false;
    (context as Element).markNeedsBuild();
  }

// Helper method to build image post using CachedNetworkImage
  static Widget _buildImagePost(BuildContext context, Submission post) {
    return GestureDetector(
      onLongPress: () {
        // Open image preview on long press
        _openImagePreview(context, post.mediaUrl!);
      },
      child: CachedNetworkImage(
        imageUrl: post.mediaUrl != null ? post.mediaUrl! : "",
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey,
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
        imageBuilder: (context, imageProvider) {
          return AspectRatio(
            aspectRatio: 16 / 9, // Maintain a consistent aspect ratio
            child: Container(
              width: double.infinity,
              height: postContentHeight,
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
  static Widget _buildTextPost(Submission post) {
    return SizedBox(
      height: postContentHeight,
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

  // Method to build the footer (e.g., likes, comments, etc.)
  static Widget _buildPostFooter(
    BuildContext context,
    Submission post,
    Function(int) onCommentButtonPressed,
    Function() onLike, {
    MsbUser? writerUser,
    MsbUser? currentUser,
    Function()? followUser,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// liked by counter and toggle
                GestureDetector(
                  onTap: onLike,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (post.isLiked != null && post.isLiked!)
                          ? AppColors.primary.withOpacity(0.2)
                          : null,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: const Color(0xFFCECACA),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            (post.isLiked != null && post.isLiked!)
                                ? "assets/svg/like.svg"
                                : "assets/svg/unLike.svg",
                            height: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            post.likesCount.toString(),
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey),
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    onCommentButtonPressed(post
                        .id!); // Properly call the function when comment is pressed
                  },
                  child: _buildIconText(
                    Icons.comment_outlined,
                    "0",
                  ),
                ),
                // if (post.commentsEnabled) ...[
                //   const SizedBox(width: 10),
                //   GestureDetector(
                //     onTap: () {
                //       onCommentButtonPressed(post.id!); // Properly call the function when comment is pressed
                //     },
                //     child: _buildIconText(
                //       Icons.comment_outlined,
                //       post.comments.length.toString() ?? "0",
                //     ),
                //   ),
                // ],
              ],
            ),

            // share
            GestureDetector(
              child: const Icon(Icons.share, color: AppColors.purple),
              onTap: () {
                if (post.id != null) {
                  // sharePost(postId: post.id!, post: post);
                }
              },
            )
          ],
        ),

        // 2 comments display
        // if (post.comments.isNotEmpty) ...[
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start, // Ensures everything aligns to the left
        //       children: post.comments.take(2).map(
        //         (comment) {
        //           return Row(
        //             // Use Row to keep text inline and aligned
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Expanded(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     // Text(
        //                     //   extractUserNameOrFirstName(comment.nameOrEmail) ?? "Anonymous",
        //                     //   style: GoogleFonts.poppins(
        //                     //     color: AppColors.black,
        //                     //     fontWeight: FontWeight.w600,
        //                     //     fontSize: 12,
        //                     //   ),
        //                     // ),
        //                     // const SizedBox(height: 2), // Reduced spacing
        //                     Text(
        //                       comment.comment,
        //                       style: GoogleFonts.poppins(
        //                         color: AppColors.black,
        //                         fontWeight: FontWeight.w400,
        //                         fontSize: 13,
        //                       ),
        //                     ),
        //                     const SizedBox(height: 2), // Reduced spacing
        //                     Text(
        //                       DateFormat('d MMM y, hh:mm a').format(comment.createdAt),
        //                       style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           );
        //         },
        //       ).toList(),
        //     ),
        //   ),
        // ]
      ],
    );
  }

  // Helper method to build icon with text (for likes, comments, etc.)
  static Widget _buildIconText(
    IconData icon,
    String label, {
    VoidCallback? onClick,
  }) {
    return GestureDetector(
      onTap: onClick,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Call this method to dispose the video controllers properly
  static void disposeVideoControllers() {
    for (var controller in videoControllers.values) {
      controller.playerPlusController.dispose();
    }
    videoControllers.clear();
  }

  static Icon getIconForPostFeedType(PostFeedType? type) {
    switch (type) {
      case PostFeedType.video:
        return const Icon(
          Icons.videocam_outlined,
          color: Colors.black,
        );
      case PostFeedType.text:
        return const Icon(
          Icons.text_fields_outlined,
          color: Colors.black,
        );
      case PostFeedType.image:
        return const Icon(
          Icons.image_outlined,
          color: Colors.black,
        );
      case PostFeedType.audio:
        return const Icon(
          Icons.audiotrack_outlined,
          color: Colors.black,
        );
      default:
        return const Icon(
          Icons.help_outline,
          color: Colors.black,
        ); // Fallback icon
    }
  }
}
