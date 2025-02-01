import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/models/post_feed_response.dart';
import 'package:msb_app/utils/api.dart';

class PostFeedsProvider with ChangeNotifier {
  List<PostFeedDataList>? postDataList ;

  PostFeeds? postFeedData;

  Future<Map<String, dynamic>> getAllPost() async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.POST_FEED_ALL}/1");
      Response response = await get(
        uri,
        headers: AppUrl.headers,
      );
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        postFeedData = PostFeeds.fromJson(encodedString);
        postDataList = postFeedData?.data;
        notifyListeners();

        result = {'status': true, 'message': 'Successful', 'data': postFeedData};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        notifyListeners();
        result = {'status': false, 'message': message};
      }
    } catch (e) {
      notifyListeners();
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }
}