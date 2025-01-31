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

class PublicTab extends StatefulWidget {
  const PublicTab({super.key});

  @override
  State<PublicTab> createState() => _PublicTabState();
}

class _PublicTabState extends State<PublicTab> {
  late final String? userId;
  late final String? userEmail;

  List<({PostFeed post, MsbUser? user})> postUser = [];
  bool isLoading = true;

  List<CommentPost> commentList = [];
  late SubmissionProvider _submissionProvider;
  late SubmissionApiProvider _submissionApiProvider;

  bool isSwitched = false;
  MsbUser? user;

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
      // fetchUserPosts(); // Fetch posts once userId is available
      // user = await userRepository.getOne(userId!);
    }
  }

  Future<void> loadAllSubmissions() async {
    var response = await _submissionApiProvider.getAllSubmissions();
    _submissionProvider.submissions = response['submissions'] as List<Submission>;
  }

  String? customSchoolId;
  String? customGrade;

  // Future<void> fetchUserPosts() async {
  //   try {
  //     final userPosts = await postFeedRepository.getPostsExcludingUserId(
  //       userId!,
  //       schoolId: switch (filter) {
  //         PostFilter.mySchool => user?.schoolId,
  //         PostFilter.other => customSchoolId,
  //         _ => null,
  //       },
  //       sClass: switch (filter) {
  //         PostFilter.myClass => user?.grade,
  //         PostFilter.other => customGrade != '0' ? customGrade : null,
  //         _ => null,
  //       },
  //     );
  //     final result = await Future.wait(
  //       userPosts.map((e) => e.userId!).map(
  //             (e) => userRepository.getOne(e),
  //           ),
  //     );
  //     postUser = [];
  //     for (int i = 0; i < userPosts.length; i++) {
  //       postUser.add((post: userPosts[i], user: result[i]));
  //     }
  //     setState(() => isLoading = false);
  //   } catch (e) {
  //     print("Error fetching user posts: $e");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    loadUserId();

    // fetchSchool();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
      _submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);

      // getUser();
      loadAllSubmissions();
    });
  }

  List<SchoolUser> schoolList = [];

  @override
  void dispose() {
    PostUiUtils.disposeVideoControllers();
    super.dispose();
  }

  Future<void> _modalSchoolSelectionMenu() async {
    return showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                width: 50,
                                decoration:
                                    BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(15.0)),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                customSchoolId == null ? "Select School" : "Select Class",
                                style: GoogleFonts.poppins(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 280,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: customSchoolId == null ? schoolList.length : 13,
                            separatorBuilder: (context, index) => const SizedBox(
                              height: 10,
                            ),
                            itemBuilder: (context, index) {
                              if (customSchoolId == null) {
                                final e = schoolList[index];
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      customSchoolId = e.schoolId;
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        e.schoolName ?? 'School',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      customGrade = 'Grade $index'.toString();
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        index == 0 ? 'All' : 'Class $index',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          });
        });
  }

  PostFilter? filter;

  void handleClick(PostFilter value) async {
    customGrade = null;
    customSchoolId = null;
    if (value == PostFilter.other) {
      await _modalSchoolSelectionMenu();
      if (customGrade == null || customSchoolId == null) return;
    }
    filter = value;
    // fetchUserPosts();
  }

  // fetchSchool() async {
  //   final schools = await schoolUserRepository.getAll();
  //
  //   if (schools.isNotEmpty) {
  //     setState(() {
  //       schoolList = schools;
  //     });
  //   }
  //   print(schoolList.length);
  // }

  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Dance",
      "icon": 'assets/images/trending.png',
      "route": PostFeeds("Dance", contentType: PostFeedType.video.value)
    },
    {
      "title": "Music",
      "icon": 'assets/images/music.png',
      "route": PostFeeds("Music", contentType: PostFeedType.audio.value)
    },
    {
      "title": "Photography",
      "icon": 'assets/images/photography.png',
      "route": PostFeeds("Photography", contentType: PostFeedType.image.value)
    },
    {
      "title": "Art & Crafts",
      "icon": 'assets/images/art.png',
      "route": PostFeeds("Art & Crafts", contentType: PostFeedType.image.value)
    },
    {"title": "Quiz", "icon": 'assets/images/quiz.png', "route": const QuizScreen()},
    {
      "title": "Painting",
      "icon": 'assets/images/painting.png',
      "route": PostFeeds("Painting", contentType: PostFeedType.image.value)
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: FlexibleText(
                              text: switch (filter) {
                                PostFilter.myClass => "Class ${user?.grade}",
                                PostFilter.mySchool => "${user?.schoolName?.split(',').first}",
                                PostFilter.other =>
                                  '${schoolList.firstWhereOrNull((e) => e.schoolId == customSchoolId)?.schoolName?.split(',').first}${[
                                    '0',
                                    null
                                  ].contains(customGrade) ? '' : '\n:Class $customGrade:'}',
                                _ => "All Submissions",
                              },
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              richStyles: [
                                GoogleFonts.poppins(
                                  color: AppColors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<PostFilter>(
                            onSelected: handleClick,
                            child: SvgPicture.asset(
                              "assets/svg/submission.svg",
                              color: const Color(0xFF938A8A),
                            ),
                            itemBuilder: (BuildContext context) {
                              return PostFilter.values.map((PostFilter choice) {
                                return PopupMenuItem<PostFilter>(
                                  value: choice,
                                  padding: const EdgeInsets.symmetric(horizontal: 7),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Container(
                                      width: query.width,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        border: Border.all(color: const Color(0xFFE2DFDF), width: 1),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 15),
                                          Text(
                                            choice.name
                                                .split(RegExp(r'(?=[A-Z])'))
                                                .map((e) => e[0].toUpperCase() + e.substring(1))
                                                .join(' '),
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ],
                      ),
                    ),
                    Consumer<SubmissionProvider>(builder: (ctxt, ref, child) {
                      if (_submissionProvider.submissions.isNotEmpty) {
                        return Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: _submissionProvider.submissions.length,
                            itemBuilder: (context, index) {
                              var post = _submissionProvider.submissions[index];

                              return PostUiUtilsV2.buildPostTile(
                                context,
                                index,
                                post,
                                (postId) => CommentBottomSheet.show(
                                  context,
                                  postId: post.id!,
                                ),
                                () => onLike(index: index),
                                followUser: () => onFollow(
                                  index: index,
                                ),
                                currentUser: user,
                                onSchoolTap: (schoolId) {
                                  filter = PostFilter.other;
                                  customSchoolId = schoolId;
                                  customGrade = null;
                                },
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const SizedBox(height: 15);
                            },
                          ),
                        );
                      } else {
                        return Expanded(
                          // Ensure "return" is added here
                          child: Center(
                            child: Text(
                              "Loading...",
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }
                    }),

                    // Expanded(
                    //   child: ListView.separated(
                    //     padding: EdgeInsets.zero,
                    //     itemCount: postUser.length,
                    //     itemBuilder: (context, index) {
                    //       return PostUiUtils.buildPostTile(
                    //         context,
                    //         index,
                    //         postUser[index].post,
                    //         (postId) => CommentBottomSheet.show(
                    //           context,
                    //           postId: postId,
                    //         ),
                    //         () => onLike(index: index),
                    //         followUser: () => onFollow(
                    //           index: index,
                    //         ),
                    //         writerUser: postUser[index].user,
                    //         currentUser: user,
                    //         onSchoolTap: (schoolId) {
                    //           filter = PostFilter.other;
                    //           customSchoolId = schoolId;
                    //           customGrade = null;
                    //           fetchUserPosts();
                    //         },
                    //       );
                    //     },
                    //     separatorBuilder: (BuildContext context, int index) {
                    //       return const SizedBox(height: 15);
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onLike({required int index}) async {
    var post = _submissionProvider.submissions[index];
    var user = post.user;
    var userHasLiked = post.isLiked!;

    post.isLiked = !userHasLiked;
    if (userHasLiked) {
      post.likesCount = post.likesCount! - 1;
    } else {
      post.likesCount = post.likesCount! + 1;
    }
    _submissionProvider.updateSubmission(post);

    _submissionApiProvider.toggleLike(post.id!);
  }

  Future<void> onFollow({required int index}) async {
    final writterUser = postUser[index].user;
    if (writterUser == null) return;
    if (user == null) return;
    final follower = List<String>.from(writterUser.follower);

    setState(() {
      postUser[index] = (
        user: writterUser.copyWith(
            follower: follower.contains(user!.id!) ? (follower..remove(userId)) : (follower..add(userId!))),
        post: postUser[index].post,
      );
    });

    // userRepository.updateOne(writterUser!);
  }
}
