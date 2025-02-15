import 'package:collection/collection.dart';
import 'package:flexible_text/flexible_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/Screens/home/filter_selector.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/post.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';

import '../../enums/post_filter.dart';
import '../../models/comment.dart';
import '../../providers/master/master_provider.dart';
import '../../utils/colours.dart';

// enum PostFilter {
//   all,
//   myClass,
//   mySchool,
//   other,
//   category,
//   subCategory,
//   user,
//   grade
// }

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
  late SubmissionApiProvider _submissionApiProvider;
  late MasterProvider _masterProvider;
  late UserProvider _userProvider;

  bool isSwitched = false;
  // MsbUser? user;

  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreData = true; // Track if there’s more data to fetch

  List<Submission> _submissions = [];

  int? customSchoolId;
  int? customGrade;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _submissionApiProvider = Provider.of<SubmissionApiProvider>(context, listen: false);
    _masterProvider = Provider.of<MasterProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _fetchInitialSubmissions();
  }

  List<SchoolUser> schoolList = [];

  @override
  void dispose() {
    PostUiUtils.disposeVideoControllers();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMoreData) {
        await _fetchMoreSubmissions();
      }
    }
  }

  Future<void> _fetchInitialSubmissions() async {
    setState(() => _isFetchingMore = true);

    final response = await _submissionApiProvider.getAllSubmissions(page: _currentPage);

    if (response['submissions'] != null && response['submissions'].isNotEmpty) {
      setState(() {
        _submissions = response['submissions'];
        _hasMoreData = response['submissions'].length >= 10; // If less than 10, assume no more data
      });
    } else {
      _hasMoreData = false;
    }

    setState(() => _isFetchingMore = false);
  }

  Future<void> _fetchMoreSubmissions() async {
    if (_isFetchingMore || !_hasMoreData) return;

    setState(() {
      _isFetchingMore = true;
      _currentPage++;
    });

    final response = await _submissionApiProvider.getAllSubmissions(page: _currentPage);

    if (response['submissions'] != null && response['submissions'].isNotEmpty) {
      setState(() {
        _submissions.addAll(response['submissions']);
        _hasMoreData = response['submissions'].length >= 10;
      });
    } else {
      _hasMoreData = false; // No more data to load
    }

    setState(() => _isFetchingMore = false);
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
                                final e = _masterProvider.schools[index];
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      customSchoolId = e.id;
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
                                        e.name ?? 'School',
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
                                      customGrade = index;
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

  // void handleClick(PostFilter value) async {
  //   customGrade = null;
  //   customSchoolId = null;
  //   if (value == PostFilter.all) {
  //     await _modalSchoolSelectionMenu();
  //     if (customGrade == null || customSchoolId == null) return;
  //   }
  //   filter = value;
  //
  //   _fetchFilteredSubmissions();
  // }

  void handleClick(PostFilter value, {int? schoolId, int? gradeId, int? userId}) async {
    setState(() {
      filter = value;
      _currentPage = 1;
      _submissions.clear(); // Clear previous data
      _hasMoreData = true;  // Reset pagination flag
    });

    await _fetchFilteredSubmissions(
      schoolId: schoolId,
      gradeId: gradeId,
      userId: userId,
    );
  }

  Future<void> _fetchFilteredSubmissions({
    int? schoolId,
    int? gradeId,
    int? userId,
  }) async {
    setState(() => _isFetchingMore = true);

    final response = await _submissionApiProvider.getAllSubmissions(
      page: _currentPage,
      schoolId: filter == PostFilter.school ? schoolId : null,
      gradeId: filter == PostFilter.grade ? gradeId : null,
      userId: filter == PostFilter.myPosts ? userId : null,
    );

    if (response['submissions'] != null && response['submissions'].isNotEmpty) {
      setState(() {
        _submissions = response['submissions'];
        _hasMoreData = response['submissions'].length >= 10;
      });
    } else {
      _hasMoreData = false;
    }

    setState(() => _isFetchingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<SubmissionApiProvider, MasterProvider, UserProvider>(builder: (ctxt, submissionProvider, masterProvider, userProvider, child) {
        var user = userProvider.user;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 18.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: FlexibleText(
              //           text: switch (filter) {
              //             PostFilter.myClass => "Class ${user.student.grade!.name!}",
              //             PostFilter.grade => "Class ${user.student.grade!.name!}",
              //             PostFilter.mySchool => "${user.student.school?.name?.split(',').first}",
              //
              //             PostFilter.other =>
              //               '${masterProvider.schools.firstWhereOrNull((e) => e.id == customSchoolId)?.name?.split(',').first}${[
              //                 '0',
              //                 null
              //               ].contains(customGrade) ? '' : '\n:Class $customGrade:'}',
              //             _ => "All Submissions",
              //           },
              //           style: GoogleFonts.poppins(
              //             color: AppColors.black,
              //             fontWeight: FontWeight.w500,
              //             fontSize: 15,
              //           ),
              //           richStyles: [
              //             GoogleFonts.poppins(
              //               color: AppColors.black54,
              //               fontWeight: FontWeight.w500,
              //               fontSize: 12,
              //             ),
              //           ],
              //         ),
              //       ),
              //       PopupMenuButton<PostFilter>(
              //         onSelected: handleClick,
              //         child: SvgPicture.asset(
              //           "assets/svg/submission.svg",
              //           color: const Color(0xFF938A8A),
              //         ),
              //         itemBuilder: (BuildContext context) {
              //           return PostFilter.values.map((PostFilter choice) {
              //             var query = MediaQuery.of(context).size;
              //             return PopupMenuItem<PostFilter>(
              //               value: choice,
              //               padding: const EdgeInsets.symmetric(horizontal: 7),
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 2.0),
              //                 child: Container(
              //                   width: query.width,
              //                   height: 50,
              //                   decoration: BoxDecoration(
              //                     color: AppColors.white,
              //                     border: Border.all(color: const Color(0xFFE2DFDF), width: 1),
              //                     borderRadius: BorderRadius.circular(8.0),
              //                   ),
              //                   child: Row(
              //                     children: [
              //                       const SizedBox(width: 15),
              //                       Text(
              //                         choice.name
              //                             .split(RegExp(r'(?=[A-Z])'))
              //                             .map((e) => e[0].toUpperCase() + e.substring(1))
              //                             .join(' '),
              //                         style: GoogleFonts.poppins(
              //                           color: AppColors.black,
              //                           fontWeight: FontWeight.w500,
              //                           fontSize: 14,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }).toList();
              //         },
              //       ),
              //     ],
              //   ),
              // ),

              Row(
                children: [
                  
                  Expanded(
                    child: FlexibleText(
                      text: switch (filter) {
                        PostFilter.grade => "Class ${user.student.grade!.name!}",
                        PostFilter.school => "${user.student.school?.name?.split(',').first}",
                        PostFilter.all => "All Submissions",
                        _ =>"All Submissions",
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
                  FilterSelector(selectedFilter: filter ?? PostFilter.all, onFilterChange: (PostFilter newFilter, {int? schoolId, int? gradeId, int? userId}) {
                    handleClick(newFilter, schoolId: schoolId, gradeId: gradeId, userId: userId);
                  }),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: _submissions.length + 1, // +1 for the loader at the bottom
                  itemBuilder: (context, index) {
                    if (index == _submissions.length) {
                      return _isFetchingMore
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    }

                    var post = _submissions[index];

                    return PostUiUtilsV2.buildPostTile(
                      context,
                      index,
                      post,
                      (postId) async {
                        await CommentBottomSheet.show(context, postId: post.id!);
                        await _fetchInitialSubmissions();
                      },
                      () => onLike(index: index),
                      // followUser: () => onFollow(index: index),
                      // currentUser: user,
                      // onSchoolTap: (schoolId) {
                      //   filter = PostFilter.other;
                      //   // customSchoolId = schoolId;
                      //   customGrade = null;
                      // },
                      onTap: _fetchInitialSubmissions,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> onLike({required int index}) async {
  //   var post = _submissions[index];
  //   var userHasLiked = post.isLiked!;
  //
  //   post.isLiked = !userHasLiked;
  //   if (userHasLiked) {
  //     post.likesCount = post.likesCount! - 1;
  //   } else {
  //     post.likesCount = post.likesCount! + 1;
  //   }
  //   setState(() => _submissions[index] = post);
  //
  //   _submissionApiProvider.toggleLike(post.id!);
  // }
  //
  // Future<void> onFollow({required int index}) async {
  //   final writterUser = postUser[index].user;
  //   if (writterUser == null) return;
  //   if (user == null) return;
  //   final follower = List<String>.from(writterUser.follower);
  //
  //   setState(() {
  //     postUser[index] = (
  //       user: writterUser.copyWith(
  //           follower: follower.contains(user!.id!) ? (follower..remove(userId)) : (follower..add(userId!))),
  //       post: postUser[index].post,
  //     );
  //   });
  }
}
