import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:msb_app/models/post_feed.dart';

sharePost({required String postId, required PostFeed post}) async {
  BranchUniversalObject buo = BranchUniversalObject(
    canonicalIdentifier: 'flutter/branch',
    //canonicalUrl: '',
    title: post.title??"",
    // imageUrl: 'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg',
    contentDescription: post.description??"",
    keywords: ['Plugin', 'Branch', 'Flutter'],
    publiclyIndex: true,
    locallyIndex: true,
    contentMetadata: BranchContentMetaData()..addCustomMetadata('post_id', postId)
  );

  BranchLinkProperties lp = BranchLinkProperties(
    //alias: 'flutterplugin', //define link url,
      channel: 'facebook',
      feature: 'sharing',
      stage: 'new share',
      tags: ['one', 'two', 'three']
  );
  lp.addControlParam('url', 'http://www.google.com');
  lp.addControlParam('url2', 'http://flutter.dev');


  BranchResponse response = await FlutterBranchSdk.showShareSheet(
      buo: buo,
      linkProperties: lp,
      messageText: post.title??"",
      androidMessageTitle: post.title??"",
      androidSharingTitle: post.title??"",);

  if (response.success) {
    print('showShareSheet Sucess');
  } else {
    print('Error : ${response.errorCode} - ${response.errorMessage}');
  }
}