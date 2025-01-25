import 'package:flutter/material.dart';

// Navigation to next screen
Future callNextScreen(BuildContext context, StatefulWidget nextScreen) {
  return Navigator.of(context).push(_createRoute(nextScreen));
  //return Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
}

// Remove previous screen and move to next screen
void removeAndCallNextScreen(BuildContext context, StatefulWidget nextScreen) {
  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  Navigator.of(context).pushReplacement(_createRoute(nextScreen));
}

Future callNextScreen1(BuildContext context, StatefulWidget nextScreen) {
  return Navigator.of(context, rootNavigator: true).push(_createRoute(nextScreen));
}
Route _createRoute(StatefulWidget nextScreen) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      }
  );
}