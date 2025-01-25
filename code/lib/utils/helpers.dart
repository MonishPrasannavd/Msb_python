import 'package:flutter/material.dart';


class Helpers {
  static PageRoute pageRouteBuilder(widget) {
    return MaterialPageRoute(builder: (context) => widget);
  }

  static void showSnackBar(BuildContext context, String msg,
      {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          backgroundColor: isError ? Colors.red : Colors.black,
          content: Text(
            msg,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

/*
  static void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor.withOpacity(0.9),
        textColor: AppColors.whiteColor,
        fontSize: 16.0);
  }*/
}