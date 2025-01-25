import 'package:flutter/material.dart';

Widget buildProgressIndictaor(double progress) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    child: Stack(
      children: [
        Container(
          height: 12, // Height of the progress bar
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            color: Colors.grey[300], // Background color of the progress bar
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * progress, // Adjust the width based on progress
              height: 12, // Height of the progress bar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent], // Gradient from green to blue
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}