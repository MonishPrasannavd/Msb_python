import 'package:audioplayers/audioplayers.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flexible_text/flexible_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/post.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

import '../../enums/post_feed_type.dart';
import '../../models/comment.dart';
import '../../repository/comment_repository.dart';
import '../../repository/school_user_repository.dart';
import '../../utils/colours.dart';
import '../../utils/firestore_collections.dart';
import '../competition/post story/post_feed_screen.dart';
import '../competition/quiz/quiz_screen.dart';

enum PostFilter {
  all,
  myClass,
  mySchool,
  other,
}

class AllSchoolCompetitions extends StatefulWidget {
  final String schoolId;

  const AllSchoolCompetitions({super.key, required this.schoolId});

  @override
  State<AllSchoolCompetitions> createState() => _AllSchoolCompetitionsState();
}

class _AllSchoolCompetitionsState extends State<AllSchoolCompetitions> {
  late final String? userId;
  late final String? userEmail;

  List<({PostFeed post, MsbUser? user})> postUser = [];
  bool isLoading = true;

  late CommentRepository commentRepository;
  late SchoolUserRepository schoolUserRepository;
  late UserRepository userRepository;
  List<CommentPost> commentList = [];

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection(FirestoreCollections.comments);
  late PostFeedRepository postFeedRepository;

  bool isSwitched = false;
  MsbUser? user;
  SchoolUser? school;

  void loadUserId() async {
    var fetchedUserId = await PrefsService.getUserId();
    var fetchedUserNameEmail = await PrefsService.getUserNameEmail();

    setState(() {
      if (fetchedUserId != null) {
        userId = fetchedUserId;
        userEmail = fetchedUserNameEmail ?? "";
      } else {
        // back to login screen
      }
    });
    if (userId != null) {
      fetchUserPosts(); // Fetch posts once userId is available
      user = await userRepository.getOne(userId!);
    }
  }

  String? customSchoolId;
  String? customGrade;

  late SubmissionProvider _submissionProvider;
  late SubmissionApiProvider _submissionApiProvider;

  Future<void> fetchUserPosts() async {
    try {
      final userPosts =
          await postFeedRepository.getPostsBySchoolId(widget.schoolId);
      final result = await Future.wait(
        userPosts.map((e) => e.userId!).map(
              (e) => userRepository.getOne(e),
            ),
      );
      postUser = [];
      for (int i = 0; i < userPosts.length; i++) {
        var post = userPosts[i];
        final comments = await commentRepository.getCommentsByPost(post.id!);
        post = post.copyWith(comments: comments);
        postUser.add((post: post, user: result[i]));
      }
      // comments
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Error fetching user posts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserId();
    commentRepository =
        CommentRepository(commentCollection: collectionReference);
    postFeedRepository = PostFeedRepository();
    schoolUserRepository = SchoolUserRepository();
    userRepository = UserRepository(
        usersCollection: FirebaseFirestore.instance.collection('users'));

    fetchSchool();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submissionProvider =
          Provider.of<SubmissionProvider>(context, listen: false);
      _submissionApiProvider =
          Provider.of<SubmissionApiProvider>(context, listen: false);
    });
  }

  List<Submission> submissions = [];

  List<SchoolUser> schoolList = [];

  void loadSubmissions() async {
    var response = await _submissionApiProvider.getAllSubmissions();
    setState(() {
      submissions = response['submissions'] as List<Submission>;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // fetchUserPosts();
  }

  @override
  void dispose() {
    PostUiUtils.disposeVideoControllers();
    super.dispose();
  }

  PostFilter? filter;

  fetchSchool() async {
    final fetchedSchool =
        await schoolUserRepository.findBySchoolId(widget.schoolId);

    if (fetchedSchool != null) {
      setState(() {
        school = fetchedSchool;
      });
    }
  }

  // final List<Map<String, dynamic>> menuItems = [
  //   {
  //     "title": "Dance",
  //     "icon": 'assets/images/trending.png',
  //     "route": PostFeeds("Dance", contentType: PostFeedType.video.value)
  //   },
  //   {
  //     "title": "Music",
  //     "icon": 'assets/images/music.png',
  //     "route": PostFeeds("Music", contentType: PostFeedType.audio.value)
  //   },
  //   {
  //     "title": "Photography",
  //     "icon": 'assets/images/photography.png',
  //     "route": PostFeeds("Photography", contentType: PostFeedType.image.value)
  //   },
  //   {
  //     "title": "Art & Crafts",
  //     "icon": 'assets/images/art.png',
  //     "route": PostFeeds("Art & Crafts", contentType: PostFeedType.image.value)
  //   },
  //   {
  //     "title": "Quiz",
  //     "icon": 'assets/images/quiz.png',
  //     "route": const QuizScreen()
  //   },
  //   {
  //     "title": "Painting",
  //     "icon": 'assets/images/painting.png',
  //     "route": PostFeeds("Painting", contentType: PostFeedType.image.value)
  //   },
  // ];

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  void playAudio(url) async {
    try {
      await _audioPlayer.play(UrlSource(url)); // No need to capture result
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      debugPrint("Error while playing audio: $e");
    }
  }

  void stopAudio() async {
    try {
      await _audioPlayer.stop(); // No need to capture result
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      debugPrint("Error while playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: query.height / 6,
            width: query.width,
            decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25.0),
                    bottomLeft: Radius.circular(25.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  child: Text(
                    school?.schoolName ?? "School Profile",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        var post = submissions[index];
                        return PostUiUtilsV2.buildPostTile(
                            context,
                            index,
                            post,
                            (postId) async {
                              await CommentBottomSheet.show(
                                context,
                                postId: postId,
                              );

                              fetchUserPosts();
                            },
                            () => onLike(index: index),
                            followUser: () => onFollow(
                                  index: index,
                                ),
                            writerUser: postUser[index].user,
                            currentUser: user,
                            onSchoolTap: (schoolId) {
                              filter = PostFilter.other;
                              customSchoolId = schoolId;
                              customGrade = null;
                              fetchUserPosts();
                            },
                            onNavigateBack: () {
                              fetchUserPosts();
                            });
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 15);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onLike({required int index}) async {
    final post = postUser[index].post;
    final userHasLiked = post.likedBy.contains(userId);
    final likes = List<String>.from(post.likedBy);
    setState(() {
      postUser[index] = (
        post: post.copyWith(
          likedBy: userHasLiked
              ? (likes..remove(userId))
              : (likes
                ..add(
                  userId!,
                )),
        ),
        user: postUser[index].user,
      );
    });

    postFeedRepository.addLikedByForPost(
      post.id!,
      userId ?? '',
      userHasLiked,
    );
  }

  Future<void> onFollow({required int index}) async {
    final writterUser = postUser[index].user;
    if (writterUser == null) return;
    if (user == null) return;
    final follower = List<String>.from(writterUser.follower);

    setState(() {
      postUser[index] = (
        user: writterUser.copyWith(
            follower: follower.contains(user!.id!)
                ? (follower..remove(userId))
                : (follower..add(userId!))),
        post: postUser[index].post,
      );
    });

    userRepository.updateOne(writterUser!);
  }
}
