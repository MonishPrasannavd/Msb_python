import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

class MsbPostsCarouselV2 extends StatefulWidget {
  final List<Submission> posts;
  final bool showLikes;

  const MsbPostsCarouselV2({super.key, required this.posts, this.showLikes = true});

  @override
  State<MsbPostsCarouselV2> createState() => _MsbPostsCarouselV2State();
}

class _MsbPostsCarouselV2State extends State<MsbPostsCarouselV2> {
  late PageController _pageController;
  int _currentIndex = 0;
  late CachedVideoPlayerPlusController? _videoController;
  bool _isOverlayVisible = false; // Tracks the visibility of video controls
  Timer? _overlayTimer; // Timer to auto-hide the overlay

  late SubmissionApiProvider submissionApiProvider;

  @override
  void initState() {
    super.initState();
    submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);
    if (widget.posts.isEmpty) {
      throw ArgumentError("Posts list cannot be empty");
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubmissionApiProvider>(builder: (context, submissionApiProvider, child) {
      if (widget.posts.isEmpty) {
        return const Center(
          child: Text("No posts available"),
        );
      }

      return Expanded(
        child: CarouselSlider.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index, realIndex) {
            final Submission currentPost = widget.posts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: PostUiUtilsV2.buildPostTile(
                context,
                index,
                currentPost,
                (int index) {
                  CommentBottomSheet.show(context, postId: currentPost.id!);
                },
                () => onLike(
                  currentPost.id!,
                ),
              ),
            );
          },
          options: CarouselOptions(
            autoPlay: true, scrollDirection: Axis.horizontal, viewportFraction: 1.0,
            height: MediaQuery.of(context).size.height / 1.25, // Makes it take full screen height
          ),
        ),
      );
    });
  }

  Future<void> onLike(int index) async {
    var post = widget.posts[index];
    final likes = post.likesCount ?? 0;
    final userHasLiked = post.isLiked ?? false;
    setState(() {
      widget.posts[index] = widget.posts[index].copyWith(
        isLiked: !userHasLiked,
        likesCount: likes + (userHasLiked ? -1 : 1),
      );
    });
    submissionApiProvider.toggleLike(post!.id!);
  }
}
