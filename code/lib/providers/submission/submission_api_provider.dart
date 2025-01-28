import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:msb_app/models/comment_v2.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/utils/api.dart';

class SubmissionApiProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> createSubmission(
    int categoryId,
    int subCategoryId,
    String title,
    String description, {
    File? mediaFile,
  }) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.CREATE_SUBMISSION);

    var request = MultipartRequest("POST", uri);

    request.headers.addAll(AppUrl.headers);

    request.fields['category_id'] = categoryId.toString();
    request.fields['sub_category_id'] = subCategoryId.toString();
    request.fields['title'] = title.toString();
    request.fields['description'] = description.toString();

    if (mediaFile != null && await mediaFile.exists()) {
      request.files.add(
        await MultipartFile.fromPath(
          'media', // Field name for the image
          mediaFile.path,
          contentType: MediaType('image', 'jpeg'), // Adjust the content type if needed
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful'};
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

  Future<Map<String, dynamic>> getAllSubmissions({int? page = 1, int? limit = 10}) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_ALL_SUBMISSIONS);

    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        var submissions = List.castFrom(encodedString['data']).map((e) => Submission.fromJson(e)).toList();
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'submissions': submissions};
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

  Future<Map<String, dynamic>> toggleLike(int submissionId) async {
    Map<String, dynamic> result;

    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.TOGGLE_LIKE}?submission_id=$submissionId");
    try {
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful'};
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

  Future<Map<String, dynamic>> addComment(int submissionId, String comment) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.ADD_COMMENT}?submission_id=$submissionId&comment=$comment");
    try {
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful'};
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

  Future<Map<String, dynamic>> removeComment(int submissionId, int commentId) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.REMOVE_COMMENT}?submission_id=$submissionId&comment_id=$commentId");
    try {
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful'};
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

  Future<Map<String, dynamic>> getComments(int submissionId, {int limit = 10, int? page= 1}) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_COMMENTS}/$submissionId?limit=$limit&page=$page");
    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        List<Comment> comments = List.castFrom(encodedString['data']).map((e) => Comment.fromJson(e)).toList();
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'comments': comments};
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
