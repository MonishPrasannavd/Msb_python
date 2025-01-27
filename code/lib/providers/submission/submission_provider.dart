import 'package:flutter/material.dart';
import 'package:msb_app/models/submission.dart';

class SubmissionProvider extends ChangeNotifier {
  List<Submission> _submissions = [];

  List<Submission> get submissions => _submissions;

  set submissions(List<Submission> submissions) {
    _submissions = submissions;
    notifyListeners();
  }

  void addSubmission(Submission submission) {
    _submissions.add(submission);
    notifyListeners();
  }

  void updateSubmission(Submission submission) {
    var retSubmission = _submissions.firstWhere((e) => e.id == submission.id);
    _submissions[_submissions.indexOf(retSubmission)] = submission;
    notifyListeners();
  }
}
