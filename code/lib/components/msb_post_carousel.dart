import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/utils/colours.dart';

class MsbPostsCarousel extends StatefulWidget {
  final List<PostFeed> posts;
  final bool showLikes;

  const MsbPostsCarousel(
      {super.key, required this.posts, this.showLikes = true});

  @override
  State<MsbPostsCarousel> createState() => _MsbPostsCarouselState();
}

class _MsbPostsCarouselState extends State<MsbPostsCarousel> {
  int _currentIndex = 0;
  late CachedVideoPlayerPlusController? _videoController;
  bool _isOverlayVisible = false; // Tracks the visibility of video controls
  Timer? _overlayTimer; // Timer to auto-hide the overlay
  @override
  void initState() {
    super.initState();
    if (widget.posts.isEmpty) {
      throw ArgumentError("Posts list cannot be empty");
    }
    _initializeVideoController();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _initializeVideoController() {
    if (widget.posts[_currentIndex].postType == 'video' &&
        widget.posts[_currentIndex].mediaUrls != null) {
      _videoController = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.posts[_currentIndex].mediaUrls!.first),
      )..initialize().then((_) {
          setState(() {});
        }).catchError((error) {
          debugPrint("Video initialization error: $error");
        });
    } else {
      _videoController = null;
    }
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });

    if (_isOverlayVisible) {
      _startOverlayHideTimer();
    }
  }

  void _startOverlayHideTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (_isOverlayVisible) {
        setState(() {
          _isOverlayVisible = false;
        });
      }
    });
  }

  Widget _buildOverlayControls() {
    return Container(
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _videoController!.value.volume > 0
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _videoController!
                    .setVolume(_videoController!.value.volume > 0 ? 0 : 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white),
            onPressed: () {
              _videoController!.seekTo(Duration.zero);
              _videoController!.play();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(PostFeed post) {
    if (post.postType == 'image' &&
        post.mediaUrls != null &&
        post.mediaUrls!.isNotEmpty) {
      return GestureDetector(
        onLongPress: () => _showImagePreview(post.mediaUrls!.first),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: CachedNetworkImage(
              imageUrl: post.mediaUrls!.first,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
          ),
        ),
      );
    } else if (post.postType == 'video' &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          _toggleOverlay();
        },
        child: _videoController!.value.isInitialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity, // Adjust width as needed
                    height: 250, // Set a fixed height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: CachedVideoPlayerPlus(_videoController!),
                      ),
                    ),
                  ),
                  if (_isOverlayVisible) ...[
                    _buildOverlayControls(),
                  ]
                ],
              )
            : const CircularProgressIndicator(),
      );
    } else if (post.postType == 'text') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        width: double.infinity,
        height: 250,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            post.description ?? "No description available",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

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

  Widget _buildLikesIndicator(PostFeed post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.favorite,
          color: AppColors.purple,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(
          post.likedBy.length.toString(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(PostFeed post) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          SizedBox(
            width: 50,
            height: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                shadowColor: Colors.black.withOpacity(0.5),
                elevation: 10,
                backgroundColor:
                    _currentIndex > 0 ? Colors.purple : Colors.grey[300],
              ),
              onPressed: _currentIndex > 0
                  ? () {
                      setState(() {
                        _currentIndex =
                            (_currentIndex - 1) % widget.posts.length;
                        _initializeVideoController();
                      });
                    }
                  : null,
              child: const Icon(Icons.arrow_back_ios,
                  size: 20, color: Colors.white),
            ),
          ),

          // Title, Description, and Likes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      post.title ?? "No Title",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "By ${post.nameOrEmail ?? "Anonymous"}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.showLikes) ...[_buildLikesIndicator(post)]
                ],
              ),
            ),
          ),

          // Next Button
          SizedBox(
            width: 50,
            height: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                shadowColor: Colors.black.withOpacity(1),
                elevation: 12,
                backgroundColor: _currentIndex < widget.posts.length - 1
                    ? Colors.purple
                    : Colors.grey[300],
              ),
              onPressed: _currentIndex < widget.posts.length - 1
                  ? () {
                      setState(() {
                        _currentIndex =
                            (_currentIndex + 1) % widget.posts.length;
                        _initializeVideoController();
                      });
                    }
                  : null,
              child: const Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const Center(
        child: Text("No posts available"),
      );
    }

    final PostFeed currentPost = widget.posts[_currentIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: _buildMediaContent(currentPost),
        ),
        const SizedBox(height: 12),
        _buildIndicator(currentPost),
      ],
    );
  }
}
