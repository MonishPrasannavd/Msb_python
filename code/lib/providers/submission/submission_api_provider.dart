import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msb_app/models/comment_v2.dart';
import 'package:msb_app/models/submission.dart';
import 'package:msb_app/utils/api.dart';

class SubmissionApiProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> createSubmission(
    int categoryId,
    int subCategoryId,
    String title,
    String description, {
    XFile? mediaFile, // Accept XFile
  }) async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.CREATE_SUBMISSION);
      var request = MultipartRequest("POST", uri);

      request.headers.addAll(AppUrl.headers);

      request.fields['category_id'] = categoryId.toString();
      request.fields['sub_category_id'] = subCategoryId.toString();
      request.fields['title'] = title;
      request.fields['description'] = description;

      if (mediaFile != null) {
        File file = File(mediaFile.path); // Convert XFile to File
        String fileName = path.basename(mediaFile.path);
        String? mimeType = lookupMimeType(file.path);
        mimeType ??= "application/octet-stream";
        request.files.add(
          await MultipartFile.fromPath(
            'media_file', // Field name for media file
            file.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType), // Get mime type from file
            // contentType: MediaType('video', 'mp4'), // Adjust based on file type
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        result = {'status': true, 'message': 'Successful'};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        result = {'status': false, 'message': message};
      }
    } catch (e) {
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }

  Future<Map<String, dynamic>> getAllSubmissions({
    int? categoryId,
    int? subCategoryId,
    int? submissionId,
    int? userId,
    int? schoolId,
    int? gradeId,
    int? page = 1,
    int? limit = 10,
  }) async {
    Map<String, dynamic> result;

    notifyListeners();
    final uri = Uri.parse(
        "${AppUrl.BASE_URL}${AppUrl.GET_ALL_SUBMISSIONS}",
    );

    final uriWithParams = uri.replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (subCategoryId != null) 'sub_category_id': subCategoryId.toString(),
      if (submissionId != null) 'submission_id': submissionId.toString(),
      if (userId != null) 'user_id': userId.toString(),
      if (schoolId != null) 'school_id': schoolId.toString(),
      if (gradeId != null) 'grade_id': gradeId.toString(),
    });

    try {
      var data = {
        "page": page,
        "limit": limit,
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "submission_id": submissionId,
        "user_id": userId,
        "school_id": schoolId,
        "grade_id": gradeId
      };
      var response = await post(uriWithParams, headers: AppUrl.headers, body: jsonEncode(data));
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
    final uri =
        Uri.parse("${AppUrl.BASE_URL}${AppUrl.REMOVE_COMMENT}?submission_id=$submissionId&comment_id=$commentId");
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

  Future<Map<String, dynamic>> getComments(int submissionId, {int limit = 10, int? page = 1}) async {
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

  Future<Map<String, dynamic>> getSubmissionById(int id) async {
    Map<String, dynamic> result;
    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_SUBMISSIONS_BY_ID}/${id.toString()}");

    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        final submission = Submission.fromJson(encodedString['submission']);
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'submission': submission};
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

  Future<Map<String, dynamic>> getSubmissionsByUserId(int userId, {page = 1, limit = 10}) async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_ALL_SUBMISSIONS}?user_id=$userId&page=$page&limit=$limit");
    try {
      //  authToken = await PrefsService.getToken(); // Retrieve token
      //  AppUrl.addHeader('Authorization', 'Bearer $authToken');
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        List<Submission> submissions = List.castFrom(encodedString['data']).map((e) => Submission.fromJson(e)).toList();
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

  Future<Map<String, dynamic>> getSubmissionsBySchool(int schoolId, {page = 1, limit = 10}) async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri =
        Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_ALL_SUBMISSIONS}?school_id=$schoolId&page=$page&limit=$limit");
    try {
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        List<Submission> submissions = List.castFrom(encodedString['data']).map((e) => Submission.fromJson(e)).toList();
        notifyListeners();
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

  Future<Map<String, dynamic>> getSubmissionsBySubcategory(int subcategoryId, {page = 1, limit = 10}) async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse(
        "${AppUrl.BASE_URL}${AppUrl.GET_ALL_SUBMISSIONS}?page=$page&limit=$limit&sub_category_id=$subcategoryId");
    try {
      var response = await post(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        List<Submission> submissions = List.castFrom(encodedString['data']).map((e) => Submission.fromJson(e)).toList();
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
}
