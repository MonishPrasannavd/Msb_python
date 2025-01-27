import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:msb_app/utils/post.dart';
import '../../repository/comment_repository.dart';
import '../../repository/posts_repository.dart';
import '../../repository/school_user_repository.dart';
import '../../utils/colours.dart';
import '../../utils/firestore_collections.dart';

class MyFeedTab extends StatefulWidget {
  const MyFeedTab({super.key});

  @override
  State<MyFeedTab> createState() => _MyFeedTabState();
}

class _MyFeedTabState extends State<MyFeedTab> {
  late final String? userId;
  late final String? userEmail;
  List<PostFeed> userPosts = [];
  bool isLoading = true;

  late CommentRepository commentRepository;
  late SchoolUserRepository schoolUserRepository;
  late UserRepository userRepository;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection(FirestoreCollections.comments);

  late PostFeedRepository postFeedRepository;
  MsbUser? user;

  bool isSwitched = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    PostUiUtils.disposeVideoControllers();
    super.dispose();
  }

  void loadUserId() async {
    var fetchedUserId = await PrefsService.getUserId();
    var fetchedUserNameEmail = await PrefsService.getUserNameEmail();
    if (fetchedUserId != null) {
      userId = fetchedUserId;
      userEmail = fetchedUserNameEmail ?? "";
      user = await userRepository.getOne(fetchedUserId);
    } else {
      // back to login screen or show an error message
    }
    setState(() {});
    if (userId != null) {
      getPostFeed();
    }
  }

  /*Future<void> fetchUserPosts() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('posts').where(
          'userId', isEqualTo: userId).get();

      setState(() {
        userPosts = snapshot.docs.map((doc) =>
            PostFeed.fromJson(doc.data() as Map<String, dynamic>)).toList();
        isLoading = false;

        // Initialize video controllers for each post
        for (int i = 0; i < userPosts.length; i++) {
          if (userPosts[i].mediaUrls != null &&
              userPosts[i].mediaUrls!.isNotEmpty) {
            _videoControllers[i] = VideoPlayerController.networkUrl(
              Uri.parse(userPosts[i].mediaUrls!.first),
            )
              ..initialize().then((_) {
                setState(() {});
              });
          }
        }
      });
    } catch (e) {
      print("Error fetching user posts: $e");
    }
  }*/

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(
        usersCollection: FirebaseFirestore.instance.collection('users'));
    loadUserId();
    commentRepository =
        CommentRepository(commentCollection: collectionReference);
    postFeedRepository = PostFeedRepository();
    schoolUserRepository = SchoolUserRepository();
    _audioPlayer = AudioPlayer();
  }

  getPostFeed() async {
    final posts =
        await postFeedRepository.getPostsByUserId(userId!, includeHidden: true);

    if (posts.isNotEmpty) {
      setState(() {
        userPosts = posts.cast<PostFeed>();
        isLoading = false;
      });
    }
  }

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  void playAudio(url) async {
    try {
      await _audioPlayer.play(UrlSource(url)); // No need to capture result
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

  void stopAudio() async {
    try {
      await _audioPlayer.stop(); // No need to capture result
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

  Future<void> onLike(PostFeed post, {required int index}) async {
    final userHasLiked = post.likedBy.contains(userId);
    final likes = List<String>.from(post.likedBy);

    setState(() {
      userPosts[index] = post.copyWith(
        likedBy: userHasLiked ? (likes..remove(userId)) : (likes..add(userId!)),
      );
    });

    postFeedRepository.addLikedByForPost(
      post.id!,
      userId ?? '',
      userHasLiked,
    );
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Submissions",
                style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 20),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  return const SizedBox.shrink();
                  // return PostUiUtils.buildPostTile(
                  //   context,
                  //   index,
                  //   userPosts[index],
                  //   (postId) => CommentBottomSheet.show(
                  //     context,
                  //     postId: postId,
                  //   ),
                  //   () => onLike(userPosts[index], index: index),
                  //   currentUser: user,
                  //   sideMenu: Transform.rotate(
                  //     angle: pi / 2,
                  //     child: PopupMenuButton<String>(
                  //       onSelected: (String item) {
                  //         switch (item) {
                  //           case 'showPost':
                  //             {
                  //               setState(() {
                  //                 userPosts[index].isHidden =
                  //                     !userPosts[index].isHidden;
                  //               });
                  //               postFeedRepository.toggleIsHidden(
                  //                   userPosts[index].id.toString());
                  //             }
                  //             break;
                  //           case 'toogleComment':
                  //             {
                  //               setState(() {
                  //                 userPosts[index].commentsEnabled =
                  //                     !userPosts[index].commentsEnabled;
                  //               });
                  //               postFeedRepository.toggleCommentsEnabled(
                  //                   userPosts[index].id.toString());
                  //             }
                  //             break;
                  //           default:
                  //             break;
                  //         }
                  //       },
                  //       itemBuilder: (BuildContext context) =>
                  //           <PopupMenuEntry<String>>[
                  //         PopupMenuItem<String>(
                  //           value: 'showPost',
                  //           child: Text(
                  //             '${userPosts[index].isHidden ? 'Show Post' : 'Hide Post'}',
                  //           ),
                  //         ),
                  //         PopupMenuItem<String>(
                  //           value: 'toogleComment',
                  //           child: Text(
                  //             '${userPosts[index].commentsEnabled ? 'Hide Comment' : 'Show Comment'}',
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 15);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
