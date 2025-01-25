import 'package:flutter/material.dart';
import 'package:msb_app/utils/colours.dart';

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: Material(
              color: Colors.transparent,
              child: LoadingIndicator(text: text),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              // _getHeading(context),
              // _getText(displayedText)
            ]));
  }

  Padding _getLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(0.0),
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}
