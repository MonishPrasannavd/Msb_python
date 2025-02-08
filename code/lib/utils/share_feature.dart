import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:msb_app/models/submission.dart';

sharePost({required int postId, required Submission post}) async {
  BranchUniversalObject buo = BranchUniversalObject(
    canonicalIdentifier: 'flutter/branch',
    title: post.title ?? "",
    contentDescription: post.description ?? "",
    contentMetadata: BranchContentMetaData()
      ..addCustomMetadata('post_id', postId),
  );

  BranchLinkProperties lp = BranchLinkProperties(
    channel: 'facebook',
    feature: 'sharing',
    stage: 'new share',
    tags: ['one', 'two', 'three'],
  );
  lp.addControlParam('url', 'http://www.google.com');
  lp.addControlParam('url2', 'http://flutter.dev');

  BranchResponse response = await FlutterBranchSdk.showShareSheet(
    buo: buo,
    linkProperties: lp,
    messageText: post.title ?? "",
    androidMessageTitle: post.title ?? "",
    androidSharingTitle: post.title ?? "",
  );

  if (response.success) {
    debugPrint('showShareSheet Sucess');
  } else {
    debugPrint('Error : ${response.errorCode} - ${response.errorMessage}');
  }
}
