import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:msb_app/utils/post_v2.dart';

class PostVideoViewer extends StatefulWidget {
  const PostVideoViewer({super.key, required this.post});
  final Submission post;

  @override
  State<PostVideoViewer> createState() => _PostVideoViewerState();
}

class _PostVideoViewerState extends State<PostVideoViewer> {
  late CachedVideoPlayerPlusController controller;
  bool isOverlayVisible = false;
  Timer? timer;

  @override
  void initState() {
    controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.post.mediaUrl!),
      invalidateCacheIfOlderThan: const Duration(minutes: 10),
    )..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        print("Video initialization error: $error");
      });
    controller.addListener(() {
      if (controller.value.isPlaying) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleOverlay() {
    setState(() => isOverlayVisible = !isOverlayVisible);
    if (!isOverlayVisible) return;
    timer?.cancel();
    timer = Timer(
      const Duration(seconds: 3),
      () => setState(() => isOverlayVisible = false),
    );
  }

  void hideOverlay() {
    setState(() => isOverlayVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    var postType = PostUiUtilsV2.getPostFeedType(widget.post);

    return controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              toggleOverlay();
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (postType?.value == 'audio')
                  Center(
                    child: Container(color: AppColors.black87),
                  ),
                SizedBox(
                  height: PostUiUtilsV2
                      .postContentHeight, // Fixed height for all videos
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CachedVideoPlayerPlus(controller),
                  ),
                ),
                isOverlayVisible
                    ? OverlayControls(
                        controller: controller,
                        hideOverlay: hideOverlay,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class OverlayControls extends StatelessWidget {
  const OverlayControls({
    super.key,
    required this.controller,
    required this.hideOverlay,
  });
  final CachedVideoPlayerPlusController controller;
  final Function() hideOverlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          PostUiUtilsV2.postContentHeight, // Overlay covering the entire video
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
                hideOverlay.call();
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
                hideOverlay.call(); // Hide overlay when icon is tapped
              },
            ),
            // Replay button
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.white, size: 30),
              onPressed: () {
                controller.seekTo(Duration.zero);
                controller.play();
                hideOverlay.call(); // Hide overlay when icon is tapped
              },
            ),
          ],
        ),
      ),
    );
  }
}
