import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/competition/post%20story/post_feed_screen.dart';
import 'package:msb_app/Screens/competition/quiz/quiz_screen.dart';
import 'package:msb_app/Screens/home/comment_bottom_sheet.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/providers/post_feed_provider.dart';
import 'package:msb_app/providers/submission/submission_api_provider.dart';
import 'package:msb_app/providers/submission/submission_provider.dart';
import 'package:msb_app/utils/post_v2.dart';
import 'package:provider/provider.dart';
import '../../models/post_feed.dart';
import '../../utils/colours.dart';

class CompletionDetailsListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName, postCompilation, subCategoryId;
  final String? contentType;

  final List<PostFeed> postsFuture;

  const CompletionDetailsListScreen(
      {required this.categoryId,
      required this.categoryName,
      required this.contentType,
      required this.postCompilation,
      required this.postsFuture,
      required this.subCategoryId,
      super.key});

  @override
  State<CompletionDetailsListScreen> createState() =>
      _CompletionDetailsListScreenState();
}

class _CompletionDetailsListScreenState
    extends State<CompletionDetailsListScreen> {
  bool isLoadingPosts = false; // Loading indicator for posts

  late PostFeedsProvider postFeedsProvider;
  late SubmissionApiProvider submissionApiProvider;
  late SubmissionProvider submissionProvider;
  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreData = true; // To track if more data is available

  List<Submission> _submissions = [];
  @override
  void initState() {
    super.initState();
    submissionApiProvider =
        Provider.of<SubmissionApiProvider>(context, listen: false);
    submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);

    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchInitialSubmissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postFeedsProvider =
          Provider.of<PostFeedsProvider>(context, listen: false);
      postFeedsProvider.getAllPost();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMoreData) {
        _fetchMoreSubmissions();
      }
    }
  }

  Future<void> _fetchInitialSubmissions() async {
    setState(() => _isFetchingMore = true);

    final response = await submissionApiProvider.getSubmissionsBySubcategory(
      int.parse(widget.subCategoryId),
      page: _currentPage,
    );

    if (response['submissions'] != null && response['submissions'].isNotEmpty) {
      setState(() {
        _submissions = response['submissions'];
        _hasMoreData = response['submissions'].length >=
            10; // If less than 10, assume no more data
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

    final response = await submissionApiProvider.getSubmissionsBySubcategory(
      int.parse(widget.subCategoryId),
      page: _currentPage,
    );

    if (response['submissions'] != null && response['submissions'].isNotEmpty) {
      setState(() {
        _submissions.addAll(response['submissions']);
        _hasMoreData = response['submissions'].length >= 10;
      });
    } else {
      _hasMoreData = false;
    }

    setState(() => _isFetchingMore = false);
  }

  Widget _buildPostListV2() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount:
                _submissions.length + 1, // +1 for the loader at the bottom
            itemBuilder: (context, index) {
              if (index == _submissions.length) {
                return _isFetchingMore
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink();
              }

              Submission post = _submissions[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to post details if needed
                },
                child: PostUiUtilsV2.buildPostTile(
                  context,
                  index,
                  post,
                  (postId) async {
                    await CommentBottomSheet.show(context, postId: postId);
                    await _fetchInitialSubmissions();
                  },
                  () => onLike(post, index: index),
                  onTap: _fetchInitialSubmissions,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshSubmissions();
  }

  Future<void> _refreshSubmissions() async {
    setState(() {
      isLoadingPosts = true;
    });

    final newSubmissions = await submissionApiProvider
        .getSubmissionsBySubcategory(int.parse(widget.subCategoryId));

    setState(() {
      _submissions = newSubmissions['submissions'] as List<Submission>;
      isLoadingPosts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset("assets/svg/back.svg"),
            ),
            Text(
              widget.categoryName,
              style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            SizedBox(width: 24),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.9, // Make the FAB span 90% of the screen width
        child: FloatingActionButton.extended(
          onPressed: () {
            Widget value = PostFeeds(
              categoryId: widget.categoryId,
              subcategoryId: int.parse(widget.subCategoryId),
              widget.categoryName,
              contentType: widget.contentType,
              postCompilation: widget.postCompilation,
            );
            if (widget.contentType == null) {
              value = const QuizScreen();
            }
            Navigator.of(context, rootNavigator: false)
                .push(
              MaterialPageRoute(builder: (_) => value),
            )
                .then((value) {
              setState(() {
                _refreshSubmissions();
              });
            });
          },
          backgroundColor: AppColors.purpleDark,
          label: Text(
            'Submit post',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _buildPostListV2(),
    );
  }

  // Helper to build profile header for both user and school
  Future<void> onLike(Submission post, {required int index}) async {
    var userHasLiked = post.isLiked!;

    post.isLiked = !userHasLiked;
    if (userHasLiked) {
      post.likesCount = post.likesCount! - 1;
    } else {
      post.likesCount = post.likesCount! + 1;
    }
    setState(() => _submissions[index] = post);
    // submissionProvider.updateSubmission(post);

    submissionApiProvider.toggleLike(post.id!);
  }
}
