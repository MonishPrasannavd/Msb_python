import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msb_app/Screens/profile/post_details_screen.dart';
import 'package:msb_app/enums/post_feed_type.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/utils/post_video_viewer.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/share_feature.dart';
import 'package:shimmer/shimmer.dart';

class PostUiUtilsV2 {
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
    Function()? onTap,
    bool enableOnTapNavigation = true,
  }) {
    final postHeader = customPostHeader ?? _buildPostHeader;
    final postContent = customPostContent ?? _buildPostContent;
    final postFooter = customPostFooter ?? buildPostFooter;

    return GestureDetector(
      onTap: () async {
        if (enableOnTapNavigation) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        }
        onTap?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  post.title ?? "Default title",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (sideMenu != null) sideMenu,
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => PostDetailScreen(post: post,),
                //     ));
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  post.description ?? "No description found",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (sideMenu != null) sideMenu,
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Talent:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  post.category?.name ?? "Unkown talent",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Uploaded to:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  post.subcategory?.name ?? "Unkown competition",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
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
      case 'image':
        return _buildImagePost(context, post);
      case 'video':
      case 'audio':
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
      case 'text':
      default:
        return _buildTextPost(post);
    }
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
  static Widget buildPostFooter(
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
                          ? AppColors.primary.withValues(alpha: 0.2)
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
                    post.commentsCount?.toString() ?? "0",
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
                  sharePost(postId: post.id!, post: post);
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
